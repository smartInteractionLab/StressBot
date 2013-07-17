void drawCalibrationStatus() {
  pushMatrix();
    translate(width/2, height/2);
    pushStyle();
      noStroke();
      fill(map(ppgY, 0, maxppgY, 255, 200));
      pushStyle();
      ellipseMode(CENTER);
      float counterPosX = -12*5*5+7.5;
        for (int i=0; i<beatsCount; i++) {
          fill(200);
          if (i < beatIntervals.size()) fill(80);
          rect(counterPosX, -15, 8, 15, 3);
          counterPosX += 25;
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
      else text("Calibrating", 0, 130);
    popStyle();
  popMatrix();
}

void drawHeartRate(int _xPos, int _yPos) {
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

float drawIntervalWaveAsCurve(float xStart) {
  float interval = width/(beatsCount-4);
  float xPos = xStart-interval; //set the first point off-screen as it is a control point and won't be drawn
  pushMatrix();
    translate(0, height/2); //move vertical origin to center of screen. This will likely change to accomodate the frame overlay
    pushStyle();
      noFill();
      strokeWeight(20);
      smooth();
      stroke(0);
//      beginShape();
      for (int i=0; i<beatIntervals.size(); i++) {  //step through the set of interval vals
        float yPos = map(beatIntervals.get(i), minIBIVal, maxIBIVal, -150, 150); 
//        curveVertex(xPos, yPos);
        xPos+=interval;
        
        fill(255,0,0);
        ellipse(xPos,yPos,10,10);
      }
//      endShape();
    
      
    
    popStyle();
  popMatrix();
  return xStart-1;
}


void createControls(){
  cp5.setControlFont(condFont);
  ControlFont.sharp();
  cp5.setColorForeground(#484848);
  cp5.setColorBackground(#E3E3E3);  
  cp5.setColorActive(#6C6C6C);

  cp5.addSlider("Sine Wave Amplitude")
    .setPosition(-100, -305)
      .setSize(200, 20)
        .setRange(0, 200)
          .setValue(100)
            ;
   
   cp5.addSlider("Sine Wave Period")
    .setPosition(-100, -305)
      .setSize(200, 20)
        .setRange(0, 200)
          .setValue(200)
            ;
   
   cp5.addSlider("Sine Wave Frequency")
    .setPosition(-100, -305)
      .setSize(200, 20)
        .setRange(0, .5)
          .setValue(.02)
            ;                  
}
void drawControls(){
  // reposition the Labels for controller 'Sine Wave Amplitude Slider'
  cp5.getController("Sine Wave Amplitude").setPosition(100,height*.7);
  cp5.getController("Sine Wave Amplitude").getValueLabel().align(ControlP5.RIGHT, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0); //Slider Value
  cp5.getController("Sine Wave Amplitude").getValueLabel().setSize(12);
  cp5.getController("Sine Wave Amplitude").getValueLabel().setColor(#0A0A0A);
  cp5.getController("Sine Wave Amplitude").getCaptionLabel().align(ControlP5.LEFT, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0); //Slider Label
  cp5.getController("Sine Wave Amplitude").getCaptionLabel().setSize(12);
  cp5.getController("Sine Wave Amplitude").getCaptionLabel().setColor(#0A0A0A);
  
  // reposition the Labels for controller 'Sine Wave Period Slider'
  cp5.getController("Sine Wave Period").setPosition(100,height*.8);
  cp5.getController("Sine Wave Period").getValueLabel().align(ControlP5.RIGHT, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0); //Slider Value
  cp5.getController("Sine Wave Period").getValueLabel().setSize(12);
  cp5.getController("Sine Wave Period").getValueLabel().setColor(#0A0A0A);
  cp5.getController("Sine Wave Period").getCaptionLabel().align(ControlP5.LEFT, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0); //Slider Label
  cp5.getController("Sine Wave Period").getCaptionLabel().setSize(12);
  cp5.getController("Sine Wave Period").getCaptionLabel().setColor(#0A0A0A);
  
  // reposition the Labels for controller 'Sine Wave Frequency Slider'
  cp5.getController("Sine Wave Frequency").setPosition(100,height*.9);
  cp5.getController("Sine Wave Frequency").getValueLabel().align(ControlP5.RIGHT, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0); //Slider Value
  cp5.getController("Sine Wave Frequency").getValueLabel().setSize(12);
  cp5.getController("Sine Wave Frequency").getValueLabel().setColor(#0A0A0A);
  cp5.getController("Sine Wave Frequency").getCaptionLabel().align(ControlP5.LEFT, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0); //Slider Label
  cp5.getController("Sine Wave Frequency").getCaptionLabel().setSize(12);
  cp5.getController("Sine Wave Frequency").getCaptionLabel().setColor(#0A0A0A);
}
