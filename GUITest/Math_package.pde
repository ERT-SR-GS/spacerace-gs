class Interval{
  
  private final float lo;
  private final float hi;
  private final float size;
  
  public Interval(float lo, float hi){
   if(hi < lo)
     throw new IllegalArgumentException("Upper bound smaller than lower bound");
     
   this.lo = lo;
   this.hi = hi;
   this.size = hi-lo;
 }
 
 public float lo(){
   return lo; 
 }
 
 public float hi(){
   return hi; 
 }
 
 public float size(){
   return size;  
 }
}

class Point {
 
  private final float x, y, z;
  
  public Point(float x, float y, float z){
    this.x = x;
    this.y = y;
    this.z = z;
  }
  
  public Point(float x, float y){
    this(x, y, 0); 
  }
  
  public float x(){
    return x; 
  }
  
  public float y(){
    return y; 
  }
  
  public float z(){
    return z; 
  }
}
