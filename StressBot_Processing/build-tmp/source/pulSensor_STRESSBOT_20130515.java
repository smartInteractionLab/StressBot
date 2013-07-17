import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import processing.serial.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class pulSensor_STRESSBOT_20130515 extends PApplet {

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

 
 Serial port;

int test;                 // general debugger
int pulseRate = 0;        // used to hold pulse rate value from arduino (updated in serialEvent)
int Sensor = 0;           // used to hold raw sensor data from arduino (updated in serialEvent)
int IBI;                  // length of time between heartbeats in milliseconds (updated in serialEvent)
int ppgY;                 // used to print the pulse waveform
int maxppgY = 0;

IntList beatIntervals; //store each beat interval in an IntList so we can compare multiple values over time
int beatsCount = 24; //number of beats to sample from the IntList

float sineCurveStart = 0; //intitialize default point to start the sivewave

int maxIBIVal, minIBIVal;

// initializing flags here
boolean pulse = false;    // made true in serialEvent when processing gets new IBI value from arduino
boolean personIsNear = true; // set true in serialEvent when prox sensor is activated
boolean fingerIsInserted = true; //set true in serialEvent when photocell is activated


public void setup() {
  frameRate(20);
  background(255);
  size(1024, 600); // Stage size
  // screenMask = loadImage("stressbot-screen-mask.png");

  beatIntervals = new IntList(); //create empty array list

    // FIND AND ESTABLISH CONTACT WITH THE SERIAL PORT
  println(Serial.list());       // print a list of available serial ports
  port = new Serial(this, Serial.list()[0], 115200); // choose the right baud rate
  port.bufferUntil('\n');          // arduino will end each ascii number string with a carriage return 
  port.clear();                    // flush the Serial buffer
}  // END OF SETUP

//----------------------------------------------------------------
public void draw() {
  background(255);
  if (personIsNear) {
    //TODO: draw wakwup animation
    if (fingerIsInserted) {
      //draw intro animation
      if(beatIntervals.size() == beatsCount) {
        sineCurveStart = getIBICycleCrestPoint();
        maxIBIVal = beatIntervals.max(); //set the max here so the graph doesn't jump
        minIBIVal = beatIntervals.min(); //same for the min
      }
      if(beatIntervals.size() <= beatsCount) drawCalibrationStatus();
      else { //take beatsCount beats to calibrate
        // background(map(ppgY, 0, maxppgY, ));
        sineCurveStart = drawSineCurve(sineCurveStart);
        ibiCurveStart = drawIntervalWaveAsCurve(ibiCurveStart); //draw the curve version of the beat intervals
        drawHeartRate(width-150, height-150);
        }
      }
    }
  }

public float getAverageIBI() {
	int _sampleSize = 10;
  	if (beatIntervals.size() < _sampleSize) return -1;
  	else {
	  float _bpmAvg = 0;
	  for (int i=beatIntervals.size()-_sampleSize; i<beatIntervals.size(); i++) {
	    _bpmAvg += beatIntervals.get(i); //add up all the IBI values
	  }
	  return abs(_bpmAvg / _sampleSize); //get the average IBI value
	}
}

public int getAverageBPM() {
	float _avgIBI = getAverageIBI(); //get the average interbeat interval in 
	if (_avgIBI == -1) return -1;
  	else {
		_avgIBI /= 1000; //divide by 1000 to convert to seconds
		return round(60/_avgIBI); //divide 60 by the average IBI to get BPM. Round and return as int
	}
}

public float getAvgIBIDelta() {
	int _sampleSize =10;
	if (beatIntervals.size() <= _sampleSize) return -1;
	else {		
		float _totalDelta = 0;
		for (int i=beatIntervals.size()-_sampleSize; i<beatIntervals.size(); i++) {
			_totalDelta += abs(beatIntervals.get(i)-beatIntervals.get(i-1)); //add up the differences of the last 20 IBI values
		}
		return abs(_totalDelta / _sampleSize); //return the average delta value
	}
}

public int getIBICycleLength() {
	int _startBeat = -1;
	for (int i=0; i<beatIntervals.size(); i++) {
		if (beatIntervals.get(i) == beatIntervals.min()) {
			_startBeat = i; //should be the trough of a wave
		}
		if (_startBeat > -1) {
			if (beatIntervals.get(i+1) < beatIntervals.get(i)) {
				return i - _startBeat; //should be the length of half a wave
			}
		}
	}
	return -1;
}

public int getIBICycleCrestPoint() { //get the highest point of the first IBI cycle. This is used to sync up the IBI wave with the sample sine wave
	for (int i=0; i<beatIntervals.size(); i++) {
		if (beatIntervals.get(i) == beatIntervals.max()) return i;
	}
	return -1;
}

public String describeBPM() {
	int _heartRate = getAverageBPM();
	if (_heartRate < 0) return "";
	else if (_heartRate < 60) return "low";
	else if (_heartRate < 75) return "cool";
	else return "a bit high";
}
public void drawCalibrationStatus() {
  pushMatrix();
    translate(width/2, height/2);
    pushStyle();
      noStroke();
      fill(map(ppgY, 0, maxppgY, 255, 200));
      pushStyle();
      ellipseMode(CENTER);
      float counterPosX = -12*5*5+7.5f;
        for (int i=0; i<beatsCount; i++) {
          fill(200);
          if (i < beatIntervals.size()) fill(80);
          rect(counterPosX, -15, 8, 15, 3);
          counterPosX += 25;
          // float _size = map(beatsCount-beatIntervals.size(), 0, beatsCount, 0, height-25);
          // ellipse(0, 0, _size, _size);
        }
      popStyle();
    popStyle();
    drawHeartRate(0,60);
    pushStyle();
      textAlign(CENTER);
      fill(0);
      textSize(30);
      if (getAverageBPM() > 0) {
        String heartRate = "Your Heartrate is " + str(getAverageBPM()) + " beats per minute, which is " + describeBPM() + ".";
        text(heartRate, 0, 130); //draw average bpm to screen
      }
      else text("calibrating", 0, 130);
    popStyle();
  popMatrix();
}

public void drawHeartRate(int _xPos, int _yPos) {
  PImage bpmIcon = loadImage("BPMicon.png");
  pushStyle();
    ellipseMode(CENTER);
    imageMode(CENTER);
    rectMode(CENTER);
    pushStyle();
      noFill();
      stroke(0);
      rect(_xPos, _yPos, 70, 70);
    popStyle();
    fill(map(ppgY, 0, maxppgY, 230, 25));
    // ellipse(_xPos, _yPos, map(ppgY, 0, maxppgY, 10, 50), map(ppgY, 0, maxppgY, 10, 50));
    image(bpmIcon, _xPos, _yPos, map(ppgY, 0, maxppgY, 10, 50), map(ppgY, 0, maxppgY, 10, 50));
  popStyle();
}

float ibiCurveStart = 0;

public float drawIntervalWaveAsCurve(float xStart) {
  float interval = width/(beatsCount-4);
  float xPos = xStart-interval; //set the first point off-screen as it is a control point and won't be drawn
  pushMatrix();
    translate(0, height/2); //move vertical origin to center of screen. This will likely change to accomodate the frame overlay
    pushStyle();
      noFill();
      strokeWeight(20);
      smooth();
      stroke(0);
      beginShape();
      for (int i=0; i<beatIntervals.size(); i++) {  //step through the set of interval vals
        float yPos = map(beatIntervals.get(i), minIBIVal, maxIBIVal, -150, 150); 
        curveVertex(xPos, yPos);
        xPos+=interval;
      }
      endShape();
    popStyle();
  popMatrix();
  return xStart-1;
}

// Variables to control background sine wave
public float drawSineCurve(float xStart){
  float _waveLength = width/5;
  pushStyle();
    smooth();
    noFill();
    ellipseMode(CENTER);
    pushMatrix();
      translate(0, height/2); //move the coordinate system down to the middle of the screen
      strokeWeight(1);
      stroke(180);
      strokeWeight(25);
      stroke(200);
      beginShape(); //start drawing the curve
        float yPos = 150; //height of curve
        float controlLength = _waveLength/2;
        vertex(xStart, yPos);
        for(float i=xStart; i<width+_waveLength; i+=_waveLength){
          //calculate first control point at the bottom fo the wave
          float cp1X = i+controlLength;
          //calculate next point on curve
          float nextPtX = i+_waveLength;
          //calculate second control point
          float cp2X = nextPtX-controlLength;
          bezierVertex(cp1X, yPos, cp2X, yPos*-1, nextPtX, yPos*-1);
          yPos*=-1;         
        }
      endShape();
    popMatrix();
  popStyle();
  return xStart-1;
}

public void serialEvent(Serial port) {   
  String inData = port.readStringUntil('\n');  

  if (inData.charAt(0) == 'Q') {          // leading 'Q' means time between beats in milliseconds
    inData = inData.substring(1);        // cut off the leading 'Q'
    inData = trim(inData);               // trim the \n off the end
    IBI = PApplet.parseInt(inData);                  // convert ascii string to integer IBI 
    beatIntervals.append(IBI);              // add this beat to the ArrayList
    println("IBI: " + IBI);  
    println("IBI Interval:" + str(getAvgIBIDelta()));              
    return;
  }

  if (inData.charAt(0) == 'S') {          // leading 'S' means sensor data
    inData = inData.substring(1);        // cut off the leading 'S'
    inData = trim(inData);               // trim the \n off the end
    ppgY = PApplet.parseInt(inData);                 // convert to integer
    if (ppgY > maxppgY) maxppgY = ppgY;   // reset the max interval value if needed
    return;
  }   

  if (inData.charAt(0) == 'F') {          // leading 'F' means finger data
    inData = inData.substring(1);        // cut off the leading 'F'
    inData = trim(inData);               // trim the \n off the end
    if (PApplet.parseInt(inData) == 1) 
    fingerIsInserted = true;             //set finger flag
    return;
  }

  if (inData.charAt(0) == 'P') {        // leading 'P' means prox sensor data
    inData = inData.substring(1);       // cut off leading 'P'
    inData = trim(inData);              // trim the \n off the end
    if (PApplet.parseInt(inData) == 1) 
    personIsNear = true;                //set proximity flag
    return;
  }
}// END OF SERIAL EVENT

  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "pulSensor_STRESSBOT_20130515" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
