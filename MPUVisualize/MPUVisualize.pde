import processing.serial.*;

Unpacker unpacker;
//test
static int AV_WIDTH = 80;
static int AV_LENGTH = 144;
static int AV_HEIGHT = 19;
static int BOX_SCALE = 4;
static int MPU_L_OFFSET = -12;
static int MPU_W_OFFSET = 30;
static int MPU_H_OFFSET = -13;

Serial port;
float[] angles;
String val;

void setup(){
  size(800, 800, P3D);
  unpacker = new Unpacker(this);
  
  angles = new float[4];
}



void draw(){
  translate(width/2, height/2);
  lights();
  if(unpacker.available()){
    unpacker.readPacket();
    background(0);
    angles[0] = unpacker.rotA();
    angles[1] = unpacker.rotX();
    angles[2] = unpacker.rotY();
    angles[3] = unpacker.rotZ();
    //print(String.format("%.2f\t%.2\t%i.2f\t%.2f",angles[0], -angles[1], angles[3], angles[2]));
    drawRocket(angles[0], -angles[1], angles[3], angles[2]);
  }
}

void drawRocket(float w, float x, float y, float z){
  //translate(MPU_W_OFFSET, MPU_H_OFFSET, MPU_H_OFFSET); 
  rotate(w, x, y, z);
  //translate(-MPU_W_OFFSET, -MPU_H_OFFSET, -MPU_H_OFFSET); 
  noFill();
  stroke(255);
  box(AV_WIDTH*BOX_SCALE, AV_HEIGHT*BOX_SCALE, AV_LENGTH*BOX_SCALE);
  //translate(MPU_W_OFFSET, MPU_H_OFFSET, MPU_H_OFFSET); 
  rotate(-w, x, y, z);
  //translate(-MPU_W_OFFSET, -MPU_H_OFFSET, -MPU_H_OFFSET);
}
