import processing.serial.*;

class Unpacker {
 
  static final int DATA_START_INDEX = 15;
  static final int PACKET_SIZE = 51;
  static final int DATA_SIZE = 35;
  static final int XBEE_FREQ = 9600;
  
  // Packet Data
  private int pktID;
  private int teamID;
  
  private Event event;
   
  private int altitude;
  private int temperature;
  private int battery;
  
  private float velX;
  private float velY;
  private float velZ;
  
  private float rotA;
  private float rotX;
  private float rotY;
  private float rotZ;
  
  private byte data[];
  private byte parsed[];
  private final Serial xbee;
  
  Unpacker(PApplet applet){
    // Open COM port 
    xbee = new Serial(applet, Serial.list()[1], XBEE_FREQ); //preferabily right [0] and plug only 1 usb into the computer. Else check device manager for port number
    
    data = new byte[PACKET_SIZE];
    parsed = new byte[DATA_SIZE];
    
    // Init packet data attributes
    teamID = 0;
    pktID = 0;
    
    event = Event.NO_EVENT;
    
    altitude = 0;
    temperature = 0;
    battery = 0;
    
    velX = 0;
    velY = 0;
    velZ = 0;
    rotA = 0;
    rotX = 0;
    rotY = 0;
    rotZ = 0;
  }
  
  public boolean available(){
    return xbee.available() >= PACKET_SIZE; 
  }
  
  public void readPacket(){
    if(available()) {
      data = xbee.readBytes(PACKET_SIZE);
      parse();
      unpack();
    }
  }
  // ---------- SETTERS ---------- //
  
  // ---------- GETTERS ---------- //
  public int teamID(){
    return teamID; 
  }
  
  public int pktID(){
    return pktID;  
  }
  
  public int altitude(){
    return altitude; 
  }
  
  public Event event(){
    return event; 
  }
  
  public int temperature(){
    return temperature; 
  }
  
  public int battery(){
    return battery; 
  }
  
  public float velX(){
    return velX; 
  }

  public float velY(){
    return velY; 
  }

  public float velZ(){
    return velZ; 
  }
  
  public float rotA(){
    return rotA; 
  }
  
  public float rotX(){
    return rotX; 
  }
  
  public float rotY(){
    return rotY; 
  }
  
  public float rotZ(){
    return rotZ; 
  }
  
  // ---------- PRIVATE ---------- //
  private void parse(){
    for(int i = 0; i<DATA_SIZE; i++){
      parsed[i] = data[i + DATA_START_INDEX];     
    }
  }
  
  private void unpack(){
    this.teamID = parsed[0] & 0b11;
    this.event = Event.fromInt((parsed[0] >> 2) & 0b111);
    this.pktID = ((0 + parsed[1]) << 8) + parsed[2];
    
    temperature = parsed[3];
    battery = parsed[4];
    altitude = ((0+parsed[5]) << 8) + parsed[6];
    
    int temp = ((0 + parsed[7] << 24) + ((0 + parsed[8]) << 16) + ((0 + parsed[9]) << 8) + parsed[10]);
    Float.intBitsToFloat(temp);
    
    temp = ((0 + parsed[7] << 24) + ((0 + parsed[8]) << 16) + ((0 + parsed[9]) << 8) + parsed[10]);
    rotA = Float.intBitsToFloat(temp);
    
    temp = ((0 + parsed[11] << 24) + ((0 + parsed[12]) << 16) + ((0 + parsed[13]) << 8) + parsed[14]);
    rotX = Float.intBitsToFloat(temp);
    
    temp = ((0 + parsed[15] << 24) + ((0 + parsed[16]) << 16) + ((0 + parsed[17]) << 8) + parsed[18]);
    rotY = Float.intBitsToFloat(temp);
    
    temp = ((0 + parsed[19] << 24) + ((0 + parsed[20]) << 16) + ((0 + parsed[21]) << 8) + parsed[22]);
    rotZ = Float.intBitsToFloat(temp);
    
    temp = ((0 + parsed[23] << 24) + ((0 + parsed[24]) << 16) + ((0 + parsed[25]) << 8) + parsed[26]);
    velX = Float.intBitsToFloat(temp);
    
    temp = ((0 + parsed[27] << 24) + ((0 + parsed[28]) << 16) + ((0 + parsed[29]) << 8) + parsed[30]);
    velY = Float.intBitsToFloat(temp);
    
    temp = ((0 + parsed[31] << 24) + ((0 + parsed[32]) << 16) + ((0 + parsed[33]) << 8) + parsed[34]);
    velZ = Float.intBitsToFloat(temp);
  }
}

enum Event{
 NO_EVENT(""),
 LIFTOFF("Liftoff"),
 APOGEE("Apogee"),
 RETRIGGER("Recovery trigger"),
 TOUCHDOWN("Touchdown");
 
 private final String name;
 
 private Event(String name){
   this.name = name;
 }
 
 public String toString(){
   return name;
 }
 
 static public Event fromInt(int val){
   return Event.values()[val]; 
 }
}
