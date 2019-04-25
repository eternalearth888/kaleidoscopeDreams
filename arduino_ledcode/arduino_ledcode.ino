   
#include <Adafruit_NeoPixel.h>

#define PIN 0
const int pixel_length = 10; //variable for number of LEDs in the neopixel strip

Adafruit_NeoPixel strip = Adafruit_NeoPixel(pixel_length, PIN, NEO_GRB + NEO_KHZ800); //define neopixel strip

int a0_val = 0; //variable that updates from analog reading pin A0

int a0_min = 0; //minimum a0 cut off value
int a0_max = 4095; //maximum a0 cut off value

void setup() {
  analogReadResolution(12); //set analog read resolution of the microcontroller to 12 bits
  strip.begin(); // start the neopixel strip
  strip.setBrightness(10);
  strip.show(); // Initialize all pixels to 'off'
  Serial.begin(9600); //start serial communication
}

void loop() {
  a0_val = (a0_val + analogRead(A0)) / 2; //we analog read a0, add it to itself, and average it to smooth the signal (slightly)
  Serial.println(a0_val); //print a0_val to serial
  int led_count = map(a0_val, a0_min, a0_max, 0, pixel_length); //maps a0_val between min and max to the number of LEDs to light up
  Serial.print("LEDCOUNT: ");
  Serial.println(led_count);
  int step_size = (a0_max - a0_min)/pixel_length; //find the a0 value interval between each LED to light

  //0 to 9, 0 being the first pixel in the list
  for (uint16_t i = 0; i < strip.numPixels(); i++) { //iterate through all the LEDs in the neopixel strip
        strip.setPixelColor(i,random(0,255),random(0,255),random(0,255));
  }
  strip.show(); //update the strip colors
  delay(200); //20ms delay
}
