import processing.serial.*;
import java.awt.*;
import java.util.*;

Serial port;
String val;
float[] angles;

// Scaling for the rocket model
float ROCKET_SCALE = 40; //0.2;
// PShape model of the rocket
PShape rocketModel;

PImage SR_logo;
PImage team_logo;
String team_name = "VOSTOK";

//Declaring data variables
float batteryLevel; //Battery level (0-100%)
float altitude; //Altitude (0-2048 meters)
float temperature; //Temperature (-64/64 C)
float[] orientation = new float [3] ; //Orientation (3D: 3*16 bit for x,y,z axis)
float[] acceleration = new float[3]; //Acceleration (3D: 3*16 bit for x,y,z axis 0-300)
int startToLiftoff;
boolean liftOff; String timeOfLiftOff; String timeSinceLiftOff;
boolean apogee; String timeOfApogee;
boolean recoveryTrigger; String timeOfRecoveryTrigger;
boolean touchdown; String timeOfTouchdown;
Event event; 

HashMap<Double, Double> allAltitudes = new HashMap<Double, Double>();               //Stores all the altitudes and their times written in the files here
HashMap<Double, Double[]> allOrientations = new HashMap<Double, Double[]>();        //Stores all the orientations and their times written in the files here, array corresponds to: {a, x, y, z}
HashMap<Double, Double[]> allAccelerations = new HashMap<Double, Double[]>();       //Stores all the accelerations and their times written in the files here, array corresponds to: {x, y, z, sqrt(x^2+y^2+z^2)}
HashMap<Double, Double> allBatteryLevels = new HashMap<Double, Double>();           //Stores all the battery levels and their times written in the files here
HashMap<Double, Double> allInternalTemperatures = new HashMap<Double, Double>();    //Stores all the internal temperatures and their times written in the files here
int i = 1; 
float lastTimeAlt = 0;

// Graph instances
Graph graphAlt;
Graph graphTemp;
Graph graphAccel;

// Intervals for the graphs
Interval altInterval = new Interval(0, 1000); // should never be rescaled
Interval tempInterval = new Interval(-50, 50); // should never be rescaled
Interval accelInterval = new Interval(-100, 100); // should never be rescaled
Interval initTimeInterval = new Interval(0, 20); // Will be rescale as time goes by

// Pane which will contain all the visualisation tools
Pane pane;
// Different boxes element which will be in the pane
Box telemetry_box;
Box event_box;
Box alt_box, temp_box, accel_box;
Box visu_box;
Box team_box;

void setup(){
  // Prepare the window
  size(1900, 900, P3D);
  surface.setTitle("Ground Station Monitor");
  
  // Only for testing
  initializeTestValues();
  
  // Load rocket model
  rocketModel = loadShape("skins/minecraft-steve.obj");
  PImage img = loadImage("skins/Steve.png");
  rocketModel.setTexture(img);
  
  SR_logo = loadImage("logo/logo.png");
  SR_logo.resize(120, 120);
  team_logo = loadImage("logo/" + team_name.toLowerCase() + ".png");
  team_logo.resize(180, 180);
  
  
  // Build the visualisation and initialize each box's function
  
  // Space between boxes
  float box_padding = 10;
  
  // ********* First Row *********
  
  // Telemtry box 
  float telemWidth = width * 0.7;
  float telemHeight = height * 0.2;
  telemetry_box = new Box(telemWidth, telemHeight, new Point(telemWidth / 2, telemHeight / 2), 7);
  telemetry_box.setColour(STDCOLOURS.SR_GREY.get());
  telemetry_box.setFun(new BoxFunction(){
    @Override
    public void run(){
      drawTelemetryContent();
    }
  });
  
  
  // Event box
  float eventWidth = width*0.25;
  float eventHeight = height*0.2;
  event_box = new Box(eventWidth, eventHeight, new Point(telemWidth + eventWidth/2 + box_padding, eventHeight / 2), 7);
  event_box.setColour(STDCOLOURS.SR_GREY.get());
  event_box.setFun(new BoxFunction(){
    @Override
    public void run(){
      drawEventContent(); 
    }
  });
  
  // ********* Second Row *********
  
  // Altitude box
  float altWidth = width * 0.3 - box_padding;
  float altHeight = height * 0.35 - box_padding / 2;
  alt_box = new Box(altWidth, altHeight, new Point(altWidth/2, telemHeight + altHeight/2 + box_padding), 7);
  alt_box.setColour(STDCOLOURS.SR_GREY.get());
  graphAlt = new Graph(altWidth - 20, altHeight - 20, new Point(altWidth/2, altHeight/2), initTimeInterval, altInterval);
  graphAlt.setTextSize(15);
  graphAlt.setGraphStroke(3);
  graphAlt.setColours(STDCOLOURS.YELLOW.get(), STDCOLOURS.BLACK.get(), STDCOLOURS.WHITE.get(), STDCOLOURS.SR_GREY.get());
  alt_box.setFun(new BoxFunction() {
    @Override 
    public void run(){
      if(millis() > 0)
        graphAlt.addPoint(new Point(millis() / 1000.0, altitude));
      graphAlt.drawGraph();
    }
  });
  
  // Rocket visu box
  float visuWidth = width*0.4;
  float visuHeight = height * 0.70;
  visu_box = new Box(visuWidth, visuHeight, new Point(altWidth + visuWidth /2 + box_padding, telemHeight + visuHeight/2 + box_padding), 7);
  visu_box.setColour(STDCOLOURS.SR_GREY.get());
  visu_box.setFun(new BoxFunction() {
    @Override
    public void run(){
       drawRocket();
    }
  });
  
  // Acceleration box
  float accelWidth = width*0.25;
  float accelHeight = height * 0.4;
  accel_box = new Box(accelWidth, accelHeight, new Point(altWidth + 2*box_padding + visuWidth + accelWidth/2, telemHeight + accelHeight/2 + box_padding), 7);
  accel_box.setColour(STDCOLOURS.SR_GREY.get());
  graphAccel = new Graph(accelWidth, accelHeight, new Point(accelWidth/2, accelHeight/2), initTimeInterval, accelInterval);
  graphAccel.setTextSize(15);
  graphAccel.setGraphStroke(3);
  graphAccel.setColours(STDCOLOURS.YELLOW.get(), STDCOLOURS.BLACK.get(), STDCOLOURS.WHITE.get(), STDCOLOURS.SR_GREY.get());
  accel_box.setFun(new BoxFunction(){
    @Override
    public void run(){
      if(millis() > 0)
        graphAccel.addPoint(new Point(millis() / 1000.0, altitude));
      graphAccel.drawGraph();
    }
  });
  
  // ********* Third Row *********
  
  // Temperature box
  float tempWidth = altWidth;
  float tempHeight = altHeight;
  temp_box = new Box(tempWidth, tempHeight, new Point(tempWidth/2, telemHeight + altHeight + tempHeight/2 + 2*box_padding), 7);
  temp_box.setColour(STDCOLOURS.SR_GREY.get());
  graphTemp = new Graph(tempWidth, tempHeight, new Point(tempWidth/2, tempHeight/2), initTimeInterval, tempInterval);
  graphTemp.setTextSize(15);
  graphTemp.setGraphStroke(3);
  graphTemp.setColours(STDCOLOURS.YELLOW.get(), STDCOLOURS.BLACK.get(), STDCOLOURS.WHITE.get(), STDCOLOURS.SR_GREY.get());
  temp_box.setFun(new BoxFunction(){
    @Override
    public void run(){
      if(millis() > 0)
        graphTemp.addPoint(new Point(millis() / 1000.0, altitude));
      graphTemp.drawGraph();
    }
  });
  
  // Logo box
  float teamWidth = accelWidth;
  float teamHeight = visuHeight - accelHeight - box_padding;
  team_box = new Box(teamWidth, teamHeight, new Point(altWidth + 2*box_padding + visuWidth + teamWidth/2, telemHeight + accelHeight + teamHeight/2 + 2 * box_padding), 7);
  team_box.setColour(STDCOLOURS.SR_GREY.get());
  team_box.setFun(new BoxFunction(){
    @Override 
    public void run(){
      image(team_logo, 130, team_box.height()/2); 
      textAlign(LEFT, CENTER);
      fill(255);
      textSize(40);
      text(team_name, 130 + team_logo.width/2 + 25, team_box.height()/2);
      textSize(20);
      text("team", 130 + team_logo.width/2 + 25, team_box.height()/2 - 25);
    }
  });
  
  pane = new Pane(telemWidth + box_padding + eventWidth, 800, new Point(width/2, height/2), false);
  pane.addChilds(telemetry_box, event_box, alt_box, temp_box, visu_box, accel_box, team_box);
}

int ind = 0;
void draw(){
  background(0);
  pane.draw();
  ind += 1;
  ind = ind % Event.values().length;
  event = Event.values()[ind];
}
   
   
  void drawRocket(){
    // Should be :rotate(unpack.rotA(), unpack.rotX(), unpack.rotY(), unpack.rotZ());
    rocketModel.resetMatrix();
    rocketModel.scale(ROCKET_SCALE);
    rocketModel.rotateX(PI);     
    rocketModel.rotateY(-PI/2);
    shape(rocketModel, visu_box.width()/2, visu_box.height()/2 + 100);
  }


void checkEvent(){
  switch(event){
    case LIFTOFF:
      if(!liftOff){
         startToLiftoff = millis();
        liftOff = true;
        timeOfLiftOff = timeOfTheDay();
      }
      break;
    case APOGEE:
      if(!apogee){
        timeOfApogee = timeOfTheDay();
        apogee = true;
      }
      break;
    case RETRIGGER:
      if(!recoveryTrigger){
        timeOfRecoveryTrigger = timeOfTheDay();
        recoveryTrigger = true;
      }
      break;
    case TOUCHDOWN:
      if(!touchdown){
        timeOfTouchdown = timeOfTheDay();
        touchdown = true;
      }
      break;
    case NO_EVENT:
      break;
  }
}

String timeOfTheDay(){
  return hour() + ":" + minute() + ":" + second();
}
  
void drawEventContent(){
  checkEvent();
  textAlign(LEFT, TOP);
  fill(255);
  textSize(30);
  if(liftOff)
    text(timeOfLiftOff + " Lift-off", 30 , 20);
  if (apogee)
    text(timeOfApogee + " Apogee", 30 , 60);
  if (recoveryTrigger)
    text(timeOfRecoveryTrigger + " Rec.Trigger", 30, 100);
  if (touchdown)
    text(timeOfTouchdown + " Touchdown", 30, 140);
}

void drawTelemetryContent(){
  textAlign(LEFT, TOP);
  fill(255);
  imageMode(CENTER);
  image(SR_logo, 80, telemetry_box.height()/2);
  textSize(25);
  
  textAlign(RIGHT, CENTER);
  text ("Temperature: ", 400, 20); 
  text ("Altitude: ", 400, 60); 
  text ("Battery: ", 400, 100); 
  if(liftOff) {
    timeSinceLiftOff = fromMillisToReadableTime(millis()-startToLiftoff);
  } else {
    timeSinceLiftOff = fromMillisToReadableTime(0);
  }
  text ("Time since lift-off: ", 400, 140); 
  
  textAlign(LEFT, CENTER);
  text(temperature + " °C", 420, 20);
  text(altitude + " m", 420, 60);
  text(batteryLevel + " %", 420, 100);
  text(timeSinceLiftOff, 420, 140);
  
  textAlign(RIGHT, CENTER);  
  text ("Orientation:", 800, 20);
  text ("x-axis:", 800, 60); 
  text ("y-axis:", 800, 100); 
  text ("z-axis:", 800, 140);
  
  textAlign(LEFT, CENTER);
  text(orientation[0], 820, 60);
  text(orientation[1], 820, 100);
  text(orientation[2], 820, 140);
  
  textAlign(RIGHT, CENTER);  
  text ("Acceleration:", 1200, 20);
  text ("x-axis:", 1200, 60); 
  text ("y-axis:", 1200, 100); 
  text ("z-axis:", 1200, 140); 
  
  textAlign(LEFT, CENTER);
  text(acceleration[0], 1220, 60);
  text(acceleration[1], 1220, 100);
  text(acceleration[2], 1220, 140);
}
  
String fromMillisToReadableTime(int timeInMillis) {
    int seconds = (timeInMillis / 1000) % 60;
    int minutes = (timeInMillis / (1000*60)) % 60;
    int hours = ((timeInMillis/(1000*60*60)) % 24);                      
    String time = (hours+": " +minutes+ ": "+ seconds);
    return time;
}

//TO DELETE
void initializeTestValues(){
  event = Event.LIFTOFF;
  batteryLevel = 100;
  altitude = 0;
  temperature = -64;
  orientation[0] = 0; orientation[1] = 0; orientation [2] = 0;
  acceleration[0] = 0; acceleration[1] = 0; acceleration [2] = 0;
 // event = Event.NO_EVENT;
  allAltitudes.put((double)0,(double)0);             //Stores all the altitudes and their times written in the files here
  Double[] orientations = {(double)0, (double)0, (double)0};
  allOrientations.put((double) 0, orientations);       //Stores all the orientations and their times written in the files here, array corresponds to: {a, x, y, z}
  allAccelerations.put((double) 0, orientations);      //Stores all the accelerations and their times written in the files here, array corresponds to: {x, y, z, sqrt(x^2+y^2+z^2)}
  allBatteryLevels.put((double) 0, (double) 0);          //Stores all the battery levels and their times written in the files here
  allInternalTemperatures.put((double) 0, (double) 0);    //Stores all the internal temperatures and their times written in the files here
}
