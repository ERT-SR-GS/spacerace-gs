import java.io.*;

class StoreTheData{
  
  //All the files and fileWriters we will need
  PrintWriter altitudeWriter;                   //Altitude of the rocket
  PrintWriter orientationWriter;                //Orientation of the rocket
  PrintWriter accelerationWriter;               //Acceleration of the rocket
  PrintWriter batteryLevelWriter;               //Battery level of the computer on the rocket
  PrintWriter internalTemperatureWriter;        //Internal temperature of the rocket
  
  //Public constructor for this class. Arguments specify file names (and their locations).
  public StoreTheData(String altitudeFileName, String orientationFileName, String accelerationFileName, String batteryLevelFileName, String internalTemperatureFileName){
    try{
      this.altitudeWriter = new PrintWriter(new BufferedWriter(new FileWriter(altitudeFileName)));
      this.orientationWriter = new PrintWriter(new BufferedWriter(new FileWriter(orientationFileName)));
      this.accelerationWriter = new PrintWriter(new BufferedWriter(new FileWriter(accelerationFileName)));
      this.batteryLevelWriter = new PrintWriter(new BufferedWriter(new FileWriter(batteryLevelFileName)));
      this.internalTemperatureWriter = new PrintWriter(new BufferedWriter(new FileWriter(internalTemperatureFileName)));
    }
    catch(IOException e){
      throw new UncheckedIOException(e);
    }
  }
  
  //Closes all the Writers. Only use when all data collecting is done, but make sure to do so when data collecting is indeed done.
  public void closeAllFiles(){
    this.altitudeWriter.close();
    this.orientationWriter.close();
    this.accelerationWriter.close();
    this.batteryLevelWriter.close();
    this.internalTemperatureWriter.close();
  }
  
  //Writes the altitude into the altitude file.
  //Argument time specifies the time at which this altitude was achieved.
  //Argument altitude specifies the altitude.
  public void writeAltitude(double time, double altitude){
    this.altitudeWriter.print("Time: " + time + "s; ");
    this.altitudeWriter.println("Altitude: " + altitude + "m;");
  }
  
  //Writes the orientation vector and other variable into the orientation file.
  //Argument time specifies the time at which this orientation was achieved.
  //Arguments orientation_x, orientation_y, orientation_z specify the rocket's orientation in x, y and z coordinates respectively.
  //Argument other specifies the other component you guys have for the orientation.
  public void writeOrientation(double time, double orientation_x, double orientation_y, double orientation_z, double other){
    this.orientationWriter.print("Time: " + time + "s; ");
    this.orientationWriter.print("Orientation: (" + orientation_x + ", " + orientation_y + ", " + orientation_z + ") [orientation units?]; ");
    this.orientationWriter.println("[other]: " + other + "[other's units];");
  }
  
  //Writes the acceleration vector and magnitude into the acceleration file.
  //Argument time specifies the time at which this acceleration was achieved.
  //Arguments accel_x, accel_y, accel_z specify the rocket's acceleration in x, y and z coordinates respectively.
  public void writeAcceleration(double time, double accel_x, double accel_y, double accel_z){
    this.accelerationWriter.print("Time: " + time + "s; ");
    this.accelerationWriter.print("Velocity: (" + accel_x + ", " + accel_y + ", " + accel_z + ") [in m/s^2]; ");
    this.accelerationWriter.println("Acceleration intensity: " + (Math.sqrt(accel_x*accel_x + accel_y*accel_y + accel_z*accel_z)) + "m/s^2;");
  }
  
  //Writes the battery level into the battery level file.
  //Argument time specifies the time at which this battery level was achieved.
  //Argument batteryLevel specifies the battery level.
  public void writeBatteryLevel(double time, double batteryLevel){
    this.batteryLevelWriter.print("Time: " + time + "s; ");
    this.batteryLevelWriter.println("Battery Level: " + batteryLevel + "%;");
  }
  
  //Writes the internal temperature into the internal temperature file.
  //Argument time specifies the time at which this internal temperature was achieved.
  //Argument internalTemperature specifies the internal temperature.
  public void writeInternalTemperature(double time, double internalTemperature){
    this.internalTemperatureWriter.print("Time: " + time + "s; ");
    this.internalTemperatureWriter.println("Internal Temperature: " + internalTemperature + "m;");
  }
}
