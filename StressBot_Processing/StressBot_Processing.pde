/*     PulseSensor Amped HRV Poncaire Plot
 
 This is an HRV visualizer code for Pulse Sensor.
 Use this with PulseSensorAmped_Arduino_1.1 Arduino code and the Pulse Sensor Amped hardware.
 This code will draw a Poncaire Plot of the IBI (InterBeat Interval) passed from Arduino.
 The Poncaire method of visualizing HRV trends is to plot the current IBI against the last IBI. 
 key press commands included in this version:
 press 'S' or 's' to take a picture of the data window. (.jpg image)
 press 'c' to clear the graph 
 Created by Joel Murphy, early 2013
 This code released into the public domain without promises or caveats.
 */

import processing.serial.*;
import controlP5.*; //Bring in Control P5


Serial port;

int test;                 // general debugger
int pulseRate = 0;        // used to hold pulse rate value from arduino (updated in serialEvent)
int Sensor = 0;           // used to hold raw sensor data from arduino (updated in serialEvent)
int IBI;                  // length of time between heartbeats in milliseconds (updated in serialEvent)
int ppgY;                 // used to print the pulse waveform
int maxppgY = 0;

IntList beatIntervals; //store each beat interval in an IntList so we can compare multiple values over time
int beatsCount = 24; //number of beatintervals to sample from the beatIntervals Array

float sineCurveStart; //Y location to start the sinewave

int maxIBIVal, minIBIVal; //the Min and Max IBI value

// initializing flags here
boolean pulse = false;    // made true in serialEvent when processing gets new IBI value from arduino
boolean fingerIsInserted = true; //set true in serialEvent when photocell is activated

ControlP5 cp5; //initialize CP5
int xspacing =1;   // How far apart should each horizontal location be spaced
int w;              // Width of entire wave

float theta = 0;  // Start angle at 0
float amplitude;  // Height of wave
float period;  // How many pixels before the wave repeats
float dx;  // Value for incrementing X, a function of period and xspacing
float[] yvalues;  // Using an array to store height values for the wave
float thetaincrementer;

//FONTS
PFont font, boldFont, condFont;

void setup() {
  frameRate(20);
  background(255);
  size(1024, 600); // Stage size

  font = loadFont("SmartNeueReg-20.vlw");
  boldFont = loadFont("SmartNeueBold-20.vlw");
  condFont = loadFont("SmartNeueCond-20.vlw");
  textFont(font);

  w = width-2;
  yvalues = new float[w/xspacing];

  beatIntervals = new IntList(); //create empty array list

    // FIND AND ESTABLISH CONTACT WITH THE SERIAL PORT
  println(Serial.list());       // print a list of available serial ports
  port = new Serial(this, Serial.list()[4], 115200); // choose the right serial Port baud rate
  port.bufferUntil('\n');          // arduino will end each ascii number string with a carriage return 
  port.clear();                    // flush the Serial buffer

  cp5 = new ControlP5(this); //Initialize Control P5 controls
  createControls();
}  // END OF SETUP

//----------------------------------------------------------------
void draw() {
  background(255);
  //If IBI values are getting sensed start calibrating
  if (beatIntervals.size() >0) {
    drawCalibrationStatus();
  }

  //If the number if IBI values matches the beatCount sample Calibration has finished.
  if (beatIntervals.size() >= beatsCount) {
    background(255);
    drawControls();
    sineCurveStart = getIBICycleCrestPoint();
    maxIBIVal = beatIntervals.max(); //set the max here so the graph doesn't jump
    minIBIVal = beatIntervals.min(); //same for the min

      //    sineCurveStart = drawSineCurve(sineCurveStart);
    ibiCurveStart = drawIntervalWaveAsCurve(ibiCurveStart); //draw the curve version of the beat intervals
    drawHeartRate(width-150, height-150);
    
    dx = (TWO_PI /period) * xspacing;
    calcSineWave();
    renderSineWave();
    amplitude=cp5.getController("Sine Wave Amplitude").getValue();
    period=cp5.getController("Sine Wave Period").getValue();
    thetaincrementer=cp5.getController("Sine Wave Frequency").getValue();
  }
}
  void calcSineWave() {
    // Increment theta (try different values for 'angular velocity' here
    theta += thetaincrementer;
    // For every x value, calculate a y value with sine function
    float x = theta;
    for (int i = 0; i < yvalues.length; i++) {
      yvalues[i] = sin(x)*amplitude;
      x+=dx;
    }
  }
  
  void renderSineWave() {
    stroke(0);
    strokeWeight(5);
    noFill();
    // A simple way to draw the wave with an ellipse at each location
    beginShape();
    for (int x = 0; x < yvalues.length; x++) {
      vertex(x*xspacing, yvalues[x]+height*.5);  
    }
    endShape();
  }


