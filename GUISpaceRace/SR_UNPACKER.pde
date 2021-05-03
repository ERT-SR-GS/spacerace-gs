import processing.serial.*;

class Unpacker {
 
  static final int DATA_START_INDEX = 15;
  static final int PACKET_SIZE = 51;
  static final int DATA_SIZE = 35;
  static final int XBEE_FREQ = 9600;
  static final int MASK = 255;
  
  // Packet Data
  private int pktID;
  private int teamID;
  
  private Event event;
   
  private int altitude;
  private int temperature;
  private int battery;
  
  private float accelX;
  private float accelY;
  private float accelZ;
  
  private float rotA;
  private float rotX;
  private float rotY;
  private float rotZ;
  
  private byte data[];
  private byte parsed[];
  private final Serial xbee;
  
  Unpacker(PApplet applet){
    // Open COM port 
    xbee = new Serial(applet,"COM10", XBEE_FREQ); //preferabily write "[0]" and plug only 1 usb into the computer. Else check device manager for port number
    
    data = new byte[PACKET_SIZE];
    parsed = new byte[DATA_SIZE];
    
    // Init packet data attributes
    teamID = 0;
    pktID = 0;
    
    event = Event.NO_EVENT;
    
    altitude = 0;
    temperature = 0;
    battery = 0;
    
    accelX = 0;
    accelY = 0;
    accelZ = 0;
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
      xbee.clear();
      parse();
      unpack();
    }
    /*
    data = xbee.readBytes(PACKET_SIZE);
    xbee.clear();
    parse();
    unpack();
    */
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
  
  public float accelX(){
    return accelX; 
  }

  public float accelY(){
    return accelY; 
  }

  public float accelZ(){
    return accelZ; 
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
    this.teamID = parsed[0] & 3;
    this.event = Event.fromInt((parsed[0] >> 2) & 7);
    this.pktID = ((0 + parsed[1]) << 8) + parsed[2];
    
    temperature = parsed[3];
    battery = parsed[4];
    altitude = ((0+parsed[5]) << 8) + parsed[6];
    
    int temp = ( (((parsed[7]) & MASK)<< 24) + (((parsed[8]) & MASK)<< 16) + (((parsed[9]) & MASK)<< 8) + (((parsed[10]) & MASK)) );
    rotA = Float.intBitsToFloat(temp);
    
    temp = ( (((parsed[11]) & MASK)<< 24) + (((parsed[12]) & MASK)<< 16) + (((parsed[13]) & MASK)<< 8) + (((parsed[14]) & MASK)) );
    rotX = Float.intBitsToFloat(temp);
    
    temp = ( (((parsed[15]) & MASK)<< 24) + (((parsed[16]) & MASK)<< 16) + (((parsed[17]) & MASK)<< 8) + (((parsed[18]) & MASK)) );
    rotY = Float.intBitsToFloat(temp);
    
    temp = ( (((parsed[19]) & MASK)<< 24) + (((parsed[20]) & MASK)<< 16) + (((parsed[21]) & MASK)<< 8) + (((parsed[22]) & MASK)) );
    rotZ = Float.intBitsToFloat(temp);
    
    temp = ( (((parsed[23]) & MASK)<< 24) + (((parsed[24]) & MASK)<< 16) + (((parsed[25]) & MASK)<< 8) + (((parsed[26]) & MASK)) );
    velX = Float.intBitsToFloat(temp);
    
    temp = ( (((parsed[27]) & MASK)<< 24) + (((parsed[28]) & MASK)<< 16) + (((parsed[29]) & MASK)<< 8) + (((parsed[30]) & MASK)) );
    velY = Float.intBitsToFloat(temp);
    
    temp = ( (((parsed[31]) & MASK)<< 24) + (((parsed[32]) & MASK)<< 16) + (((parsed[33]) & MASK)<< 8) + (((parsed[34]) & MASK)) );
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
