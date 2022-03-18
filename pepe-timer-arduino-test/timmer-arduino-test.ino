#include <EEPROM.h>
#include <SoftwareSerial.h>

String inputString = "";
char myCharInputString[256] = "";
bool readMode = false;
bool writeMode = false;
int addr = 0;

void setup()
{
    // initialize serial:
    Serial.begin(9600);
    // reserve 255 bytes for the inputString
    inputString.reserve(256);
    EEPROM.get(addr, myCharInputString);
    inputString = myCharInputString;
}

void loop()
{
    // print the string when a newline arrives:
    serialEvent();
    if (readMode == true)
    {
        if (inputString.length() == 0)
        {
            Serial.println("No data");
        }
        else
        {
            Serial.println(inputString);
        }
        readMode = false;
    }
}

/*
  SerialEvent occurs whenever a new data comes in the hardware serial RX. This
  routine is run between each time loop() runs, so using delay inside loop can
  delay response. Multiple bytes of data may be available.
*/
void serialEvent()
{
    if (Serial.available())
    {
        // get the new byte:
        char inChar = (char)Serial.read();
        if (readMode == false && writeMode == false)
        {
            if (inChar == 'L')
            {
                readMode = true;
            }
            else if (inChar == 'E')
            {
                writeMode = true;
                inputString = "";
            }
        }
        else if (inChar != '\n' && writeMode == true && inputString.length() < 255)
        {
            inputString += inChar;
            if (inputString.length() == 255)
            {
                writeMode = false;
                strcpy(myCharInputString, inputString.c_str());
                EEPROM.put(addr, myCharInputString);
            }
        }
        Serial.flush();
    }
}
Terms
