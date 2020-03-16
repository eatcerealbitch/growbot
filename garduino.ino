//Libraries
#include <DHT.h>;

//define DHT type
#define DHTTYPE DHT22           

//output pins
const int pumpPin = 26;                                // Pin (output) to control pump relay
const int fanPin = 27;                                 // Pin (output) to control fan relay
const int lampPin = 14;                                // Pin (output) to control grow lamp relay

//input pins
const int MoistPin = 12;                               // Pin (input) to read moisture sensor                       
const int DHTPIN = 13;                             // Pin (input) to read temp and humidity from DHT22
const unsigned int lightOnTime = 54000000;      // time light is on. 54000000 = 15 hours

//Moisture Sensor Variables
int dryVal = 3525;                              // measured value when sensor is completely dry
int wetVal = 1740;                              // measured value when sensor is immersed to the line
int moistVal = 0;                               // Moisture sensor reading
int moistPercent = 0;                           // moisture value mapped as a percent

//pump variables
int pumpDur = 5000;                             // pump ON duration

void(* resetFunc) (void) = 0;

DHT dht(DHTPIN, DHTTYPE);                       // Initialize DHT sensor


//Setup
void setup()
{
  Serial.begin(9600);                           // OPEN SERIAL MONITOR @9600 BAUD
  dht.begin();                                  // INITIALIZE DHT SENSOR 
  digitalWrite(lampPin, HIGH);                  // turn lamp on
  digitalWrite(fanPin, LOW);                    // turn fan off
  delay(2000);                                  // Wait two seconds
    
}

void loop()
{

//pinmodes  
pinMode(pumpPin, OUTPUT);                       // Sets the pump as an output
pinMode(fanPin, OUTPUT);                        // Sets the fan as an output
pinMode(lampPin, OUTPUT);                       // Sets the grow lamp as an output

//DHT Variables
float humVal = 0;                               // Stores humidity value
float tempValC = 0;                             // Stores temperature value in Celsius
float tempValF = 0;                             // Stores temperature value in Farenheit

//TURN OFF LIGHT AND RESET AFTER 24 HOURS TO TURN LAMP BACK ON

  if(millis() >= lightOnTime && lampPin == HIGH){          //determine whether or not to turn the lamp off
    digitalWrite(lampPin, LOW);                           //turn lamp off
  }
  
  if(millis() >= 86400000){                               //resets after ~~24 hours or so
    resetFunc();
  }
  
//DISPLAY TEMPERATURE AND HUMIDITY READINGS AND TURN FAN ON OR OFF
    
    // Read temperature and humidity values and store them to variables
    humVal = dht.readHumidity();
    tempValC = dht.readTemperature();                      // Temperature in Celsius
    tempValF = dht.readTemperature(true);                    // Temperature in Farenheit
  
    // Print temp and humidity values to serial monitor
    Serial.print("Relative Humidity: ");
    Serial.print(humVal);
    Serial.println(" %");
    Serial.print("Temperature: ");
    Serial.print(tempValC);
    Serial.print("C, ");
    Serial.print(tempValF);
    Serial.println("F");
  
  //Turn fan on if temp > 80F
  if(tempValF > 80){
    digitalWrite(fanPin, HIGH);
  }
  //turn fan off if temp < 75F
  else if(tempValF < 75){
    digitalWrite(fanPin, LOW);
  }
  //Wait two seconds
    delay(2000); 
  
//CHECK SOIL MOISTURE LEVEL AND WATER IF DRY  
  moistVal = analogRead(MoistPin);                          // read moisture sensor
  moistVal = map(moistVal, dryVal, wetVal, 0, 100);         // maps the reading so it can be read as a percent
  
  //turn on the pump if the soil is dry
  if(moistVal > 75) {                                      // determine whether or not the soil is too dry
    Serial.println("Soil is dry, turning on the pump.");
    digitalWrite(pumpPin, HIGH);                            // turn on the pump
    delay (pumpDur);                                        // wait while the pump runs
    digitalWrite(pumpPin, LOW);                             // turn the pump off
  }
  else {
    Serial.println("Soil is moist enough.");
  }

  
  
  
  
  
}
