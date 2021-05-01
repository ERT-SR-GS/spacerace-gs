/**
 * Simple Read
 * 
 * Read data from the serial port and change the color of a rectangle
 * when a switch connected to a Wiring or Arduino board is pressed and released.
 * This example works with the Wiring / Arduino program that follows below.
 */


import processing.serial.*;

Unpacker unpacker;

void setup(){
  unpacker = new Unpacker(this);
}

void draw()
{
  
  if(unpacker.available()){
    unpacker.readPacket();
    print(String.format("%d %d %d %d %f %f %f %f %f %f %f\n",unpacker.teamID(), unpacker.altitude(), unpacker.temperature(), unpacker.battery(), unpacker.rotA(), unpacker.rotX(), unpacker.rotY(), unpacker.rotZ(), unpacker.velX(), unpacker.velY(), unpacker.velZ()));
    //print(unpacker.pktID());
  }
}
