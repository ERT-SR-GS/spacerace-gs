import processing.serial.*;
import java.awt.*;
import java.util.*;

Serial port;
String val;
float[] angles;

//Declaring data variables
float batteryLevel; //Battery level (0-100%)
float altitude; //Altitude (0-2048 meters)
float temperature; //Temperature (-64/64 C)
float[] orientation = new float [3] ; //Orientation (3D: 3*16 bit for x,y,z axis)
float[] acceleration = new float[3]; //Acceleration (3D: 3*16 bit for x,y,z axis)
int event; // event 0-3
int startToLiftoff;
boolean liftOff; String timeOfLiftOff;
boolean apogee; String timeOfApogee;
boolean recoveryTrigger; String timeOfRecoveryTrigger;
boolean touchdown; String timeOfTouchdown;
PImage logo;  
Unpacker unpack;

void setup(){
  size(1900, 900, P3D);
  background(112,128,144);
  surface.setTitle("Ground Station Monitor");  
  initializeTestValues();
  unpack = new Unpacker (this);
}

void draw(){
   if(unpack.available()){
     unpack.readPacket();
     translate(0,0,-100);  
     stroke(112,128,144);
     strokeWeight(1);
     drawEnvironment();
     drawTelemetryData();
     updateTelemetryData();
     checkEvent(event);
     stroke(0,0,0);
     strokeWeight(4);
     //graphs pas encore au point
     drawTempGraph();
     drawAltGraph();
     translate(0,0,100);
     pushMatrix();
     drawRocket();
     popMatrix();
   }
}
  
  void drawTempGraph(){
    line(40, height*0.8+25, 530,height*0.8+25); //Time axis
    line(40, height*0.9+50, 40, height*0.7); //Temp axis
   }
   
   void drawAltGraph(){
    line(40, height*0.6-30, 530,height*0.6-30); //Time axis
    line(40, height*0.6-30, 40, height*0.3); //Alt axis
   }
  
  void drawRocket(){
    translate(width/2,height/2+50);
    stroke(255);
    fill(220,20,60);
    rotate(unpack.rotA(), unpack.rotX(), unpack.rotY(), unpack.rotZ()); 
    //En angles d'Euler:
    //rotateX(unpack.rotA()*unpack.rotX());
    //rotateY(unpack.rotA()*unpack.rotY());
    //rotateZ(unpack.rotA()*unpack.rotZ());
    strokeWeight(1);
    drawCylinder( 9,  40, 200 );
    pushMatrix();
    translate(0,0,150);
    drawCone( 8, 40, 5, 100 );
    popMatrix();
  }

  //Déterminer la phase de vol en fonction d'event
  void checkEvent(int event){
    // THEO : Si tu met comme type "Event" au lieu de "int" pour ton event, tu peux utiliser la fonction switch qui sera plus propre que des if
    if (event == 0 && !liftOff){ 
      startToLiftoff = millis();
      liftOff = true;
      timeOfLiftOff = timeOfTheDay();  
    }
    if (event == 1 && !apogee){
      timeOfApogee = timeOfTheDay();
      apogee = true;
    }
    if (event == 2 && !recoveryTrigger){
      timeOfRecoveryTrigger = timeOfTheDay();
      recoveryTrigger = true;
    }
    if (event == 3 && !touchdown){
      timeOfTouchdown = timeOfTheDay();
      touchdown = true;
    }
  }
  
  String timeOfTheDay(){
   return hour() + ":" + minute() + ":" + second();
  }

void drawTelemetryData(){
  text(batteryLevel + " %", 340, 130);
  text(altitude + " m", 350, 90);
  text(temperature + " °C", 410, 50);
  text(orientation[0], 700, 90);
  text(orientation[1], 700, 130);
  text(orientation[2], 700, 170);
  text(acceleration[0], 1050, 90);
  text(acceleration[1], 1050, 130);
  text(acceleration[2], 1050, 170);
  if (liftOff){
    text(fromMillisToReadableTime(millis()-startToLiftoff),  450, 170);
    text(timeOfLiftOff + " Lift-off", width*0.7+30 , 100);
    if (apogee){
         text(timeOfApogee + " Apogee", width*0.7+30 , 150);
           if (recoveryTrigger){
             text(timeOfRecoveryTrigger + " Rec.Trigger", width*0.85, 100);
             if (touchdown){
               text(timeOfTouchdown + " Touchdown", width*0.85, 150);
          }
      }
    }
}
  else{text(fromMillisToReadableTime(0), 450, 170);}
}

  
  
String fromMillisToReadableTime(int timeInMillis) {
    int seconds = (timeInMillis / 1000) % 60;
    int minutes = (timeInMillis / (1000*60)) % 60;
    int hours = ((timeInMillis/(1000*60*60)) % 24);                      
    String time = (hours+": " +minutes+ ": "+ seconds);
    return time;
  }

//TO DELETE
void updateTelemetryData(){
  event = unpack.event().ordinal();
  batteryLevel = unpack.battery();
  altitude = unpack.altitude();
  temperature = unpack.temperature();
  orientation[0] = unpack.rotX() * unpack.rotA();
  orientation[1] = unpack.rotY() * unpack.rotA();
  orientation[2] = unpack.rotZ() * unpack.rotA();
  acceleration[0] = unpack.velX();
  acceleration[1] = unpack.velY();
  acceleration[2] = unpack.velZ();
}

//TO DELETE
void initializeTestValues(){
  batteryLevel = 100;
  altitude = 0;
  temperature = -64;
  orientation[0] = 0; orientation[1] = 0; orientation [2] = 0;
  acceleration[0] = 0; acceleration[1] = 0; acceleration [2] = 0;
  event = 5;
}
  
void drawEnvironment(){
   //Preparing visualization
 fill(176,196,222);
 rect(10, 10, width*0.7, height*0.2, 7);  //Telemetry Rectangle
 rect(width*0.7 + 20, 10, width*0.25+60, height*0.2, 7); //Event Display Rectangle
 rect(10, height*0.2 + 20, width*0.25+60, height*0.4, 7); //Altitude Rectangle
 rect(10, height*0.65 - 15, width*0.25+60, height*0.35,  7); //Temperature Rectangle
 rect(width*0.25+80, height*0.2+20, width*0.4+25, height*0.75+10, 7); //Orientation Rectangle 
 textSize(26);
 fill(0);
 text ("Telemetry: ", 30, 50);
 text ("Temperature: ", 200, 50);
 text ("Altitude: ", 200, 90);
 text ("Battery: ", 200, 130);
 text ("Time since lift-off: ", 200, 170);
 text ("Orientation:", 600, 50);
 text ("x-axis:", 600, 90);
 text ("y-axis:", 600, 130);
 text ("z-axis:", 600, 170);
 text ("Acceleration:", 950, 50);
 text ("x-axis:", 950, 90);
 text ("y-axis:", 950, 130);
 text ("z-axis:", 950, 170);
 text ("Event Display: ", width*0.7+30, 50);
 text (hour() + ":" + minute() +":" + second(), width*0.8+30, 50);
 text ("|   " + day() + "/" + month() +"/" + year(), width*0.9-30, 50);
 text ("Altitude:", 20, height*0.2 + 45);
 text ("Temperature:", 20, width*0.25+120);
 text ("Orientation:", width*0.25+90, height*0.2 + 45);

}

  
//Source for Cylinder and Cone methods: https://vormplus.be/full-articles/drawing-a-cylinder-with-processing
void drawCylinder( int sides, float r, float h)
{
    float angle = 360 / sides;
    float halfHeight = h / 2;

    // draw top of the tube
    beginShape();
    for (int i = 0; i < sides; i++) {
        float x = cos( radians( i * angle ) ) * r;
        float y = sin( radians( i * angle ) ) * r;
        vertex( x, y, -halfHeight);
    }
    endShape(CLOSE);

    // draw bottom of the tube
    beginShape();
    for (int i = 0; i < sides; i++) {
        float x = cos( radians( i * angle ) ) * r;
        float y = sin( radians( i * angle ) ) * r;
        vertex( x, y, halfHeight);
    }
    endShape(CLOSE);
    
    // draw sides
    beginShape(TRIANGLE_STRIP);
    for (int i = 0; i < sides + 1; i++) {
        float x = cos( radians( i * angle ) ) * r;
        float y = sin( radians( i * angle ) ) * r;
        vertex( x, y, halfHeight);
        vertex( x, y, -halfHeight);    
    }
    endShape(CLOSE);

}
  void drawCone( int sides, float r1, float r2, float h)
{
    float angle = 360 / sides;
    float halfHeight = h / 2;

    // draw top of the tube
    beginShape();
    for (int i = 0; i < sides; i++) {
        float x = cos( radians( i * angle ) ) * r1;
        float y = sin( radians( i * angle ) ) * r1;
        vertex( x, y, -halfHeight);
    }
    endShape(CLOSE);

    // draw bottom of the tube
    beginShape();
    for (int i = 0; i < sides; i++) {
        float x = cos( radians( i * angle ) ) * r2;
        float y = sin( radians( i * angle ) ) * r2;
        vertex( x, y, halfHeight);
    }
    endShape(CLOSE);
    
    // draw sides
    beginShape(TRIANGLE_STRIP);
    for (int i = 0; i < sides + 1; i++) {
        float x1 = cos( radians( i * angle ) ) * r1;
        float y1 = sin( radians( i * angle ) ) * r1;
        float x2 = cos( radians( i * angle ) ) * r2;
        float y2 = sin( radians( i * angle ) ) * r2;
        vertex( x1, y1, -halfHeight);
        vertex( x2, y2, halfHeight);    
    }
    endShape(CLOSE);
}
