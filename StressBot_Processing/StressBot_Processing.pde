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
boolean fingerIsInserted = false; //set true in serialEvent when photocell is activated

ControlP5 cp5;     // Declare ControlP5 Controls
PrintWriter output;// Declare Data object to save the Computed Data file
PrintWriter outputRaw;// Declare Data object to save raw Data to file
int xspacing =1;   // How far apart should each horizontal location be spaced
int w;             // Width of entire wave
float theta = 0;   // Start angle at 0
float amplitude;   // Height of wave
float period;      // How many pixels before the wave repeats
float dx;          // Value for incrementing X, a function of period and xspacing
float[] yvalues;   // Using an array to store height values for the wave
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
  
  //SineWave Variables
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
  
  // Create a new file in the sketch directory 
  output = createWriter("data/StressBot_Data_"+day()+hour()+minute()+".txt"); 
  outputRaw = createWriter("data/StressBot_Data_Raw_"+day()+hour()+minute()+".txt"); 
}  // END OF SETUP

//----------------------------------------------------------------
void draw() {
  background(255);
  //State 1 - No Finger 
  if(fingerIsInserted==false){
  instruction();
  }
  
  //State 2 - Finger Instered and IBI values are getting sensed start calibrating
  if (fingerIsInserted) {
    drawCalibrationStatus();
  } 
  
  //State 3 - If the number if IBI values matches the beatCount sample Calibration has finished.
  if (fingerIsInserted && beatIntervals.size() >= beatsCount) {
    background(255);
    sineCurveStart = getIBICycleCrestPoint();
    maxIBIVal = beatIntervals.max(); //set the max here so the graph doesn't jump
    minIBIVal = beatIntervals.min(); //same for the min
    ibiCurveStart = drawIntervalWaveAsCurve(ibiCurveStart); //draw the curve version of the beat intervals
    drawHeartRate(width-150, height-150);
    
    
    
    
    drawControls();
    dx = (TWO_PI /period) * xspacing;
    calcSineWave();
    renderSineWave();
    amplitude=cp5.getController("Sine Wave Amplitude").getValue();
    period=cp5.getController("Sine Wave Period").getValue();
    thetaincrementer=cp5.getController("Sine Wave Frequency").getValue();
  }
  
  //State 4 - Finger is removed Reset
  if (fingerIsInserted==false && beatIntervals.size()>0 ) {
    beatIntervals.clear(); //Clear out the Array.
    removeControls();
    instruction();
    
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

void keyPressed() {
  if (key == 's')
  {   
  output.flush();  // Writes the remaining data to the file
  output.close();  // Finishes the file
  
  outputRaw.flush();  // Writes the remaining data to the file
  outputRaw.close();  // Finishes the file
  
  exit();  // Stops the program
  }
}
