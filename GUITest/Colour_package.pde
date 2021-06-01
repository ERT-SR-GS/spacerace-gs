static class Colour{
  
  private final int r, g, b;
  
  public Colour(int r, int g, int b){
    this.r = r;
    this.g = g;
    this.b = b;
  
  }
  
  public int r(){
    return r; 
  }
  
  public int g(){
    return g; 
  }
  
  public int b(){
    return b; 
  }
  
}

static enum STDCOLOURS{
  BLACK(new Colour(0,0,0)),
  WHITE(new Colour(255,255,255)),
  SR_GREY(new Colour(112, 128, 144)),
  YELLOW(new Colour(229, 255, 0));
  
  private final Colour col;
  
  private STDCOLOURS(Colour col){
    this.col = col;
  }
  
  public Colour get(){
    return col; 
  }
}
