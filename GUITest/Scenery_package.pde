/**
 * Pane class representing a space to put boxes
 */
class Pane{

  // Width and height of the pane
  private final float wid, hei;
  // List of child contained in the pane
  private ArrayList<Box> childs;
  // Absolute center of the pain (relative to the top left corner of the processing window
  private final Point absoluteCenter;
  // Location of the top left corner of the area
  private final Point topLeft;
  
  //  Cosmetic options (is that how we write "cosmetic" ?)
  
  // Fill colour of the area
  private Colour colour;
  // Border colour of the area
  private Colour borderColour;
  // Width of the border
  private float borderWeight;
  // Whether to draw or not the pane
  private Boolean visible;
  
  /**
   * Pane Constructor
   * @param wid : width of the pane area
   * @param hei : height of the pane area
   * @param absoluteCenter : center of the pane relative to the top left corner of the processing window
   * @param visible : set the pane to be visible or not
   * @param childs : list of childs to add at creation
   */
  public Pane(float wid, float hei, Point absoluteCenter, Boolean visible, Box... childs){
    if(wid < 0 || hei < 0)
      throw new IllegalArgumentException("Width and height must be positive");
    this.wid = wid;
    this.hei = hei;
    
    if(absoluteCenter == null)
      throw new NullPointerException("Center not initialized");
    this.absoluteCenter = absoluteCenter;
    this.topLeft = new Point(absoluteCenter.x() - wid/2, absoluteCenter.y() - hei/2);
    
    this.childs = new ArrayList<Box>(childs.length);
    for(Box b : childs){
      this.childs.add(b); 
    }
    
    // Initialize cosmetic options with default values
    this.visible = visible;
    this.colour = new Colour(255,255,255);
    this.borderColour = new Colour(0,0,0);
    this.borderWeight = 1;
  }
  
  /*
   * Draws the pane (if visible) and it's childs
   */
  public void draw(){
    
    if(visible){
      rectMode(CENTER);
      // Set cosmetic
      fill(colour.r(), colour.g(), colour.b());
      stroke(borderColour.r(), borderColour.g(), borderColour.b());
      strokeWeight(borderWeight);
      // Draw the boundary
      rect(absoluteCenter.x(), absoluteCenter.y(), wid, hei);
      rectMode(CORNER);
    }
    
    pushMatrix();
    // Move to the relative coordinates of the pane
    translate(topLeft.x(), topLeft.y());
    for(Box b : childs){
      b.draw(); 
    }
    popMatrix();
  }
  
  public void addChild(Box newChild){
    if(newChild == null)
      throw new NullPointerException("Child not initialized");
    childs.add(newChild);
  }
  
  public void addChilds(Box... newChilds){
    for(Box b : newChilds){
      if(b == null)
        throw new NullPointerException("Child not initialized");
      childs.add(b); 
    }
  }
  
  
  public void setVisible(Boolean visible){
    this.visible = visible; 
  }
}

class Box{
  
  private final float wid, hei;
  private final float radii;
  private final Point center;
  private final Point topLeft;
  
  // Cosmetic options
  private Colour colour;
  private Colour borderColour;
  private float borderWeight;
  
  private BoxFunction fun;
  
  private boolean visible, active;
  

  public Box(float wid, float hei, Point center, float radii){
    if(wid < 0 || hei < 0)
      throw new IllegalArgumentException("Width and height must be positive");
    this.wid = wid;
    this.hei = hei;
    
    if(radii < 0)
      throw new IllegalArgumentException("Radii must be positive");
    this.radii = radii;
    
    if(center == null)
      throw new NullPointerException("Center hasn't been initialized");
    this.center = center;
    this.topLeft = new Point(center.x() - wid/2, center.y() - hei/2);
    
    this.colour = new Colour(255,255,255);
    this.borderColour = new Colour(0,0,0);
    this.borderWeight = 1;
    
    visible = true;
    active = true;
    
    this.fun = new BoxFunction();
  }
  
  public void draw(){
    if(visible){
      rectMode(CENTER);
      fill(colour.r(), colour.g(), colour.b()); 
      stroke(borderColour.r(), borderColour.g(), borderColour.b());
      strokeWeight(borderWeight);
      rect(center.x(), center.y(), wid, hei, radii);
      rectMode(CORNER);
    }
    
    if(active){
      pushMatrix();
      translate(topLeft.x(), topLeft.y());
      fun.run();
      popMatrix();
    }
  }
  
  public void setVisible(boolean vis){
    visible = vis; 
  }
  
  public void setActive(boolean active){
    this.active = active; 
  }
  
  public void setFun(BoxFunction fun){
    if(fun == null)
      throw new NullPointerException("Fun not implemented");
    this.fun = fun;
  }
  
  public void setColour(Colour newCol){
    if(newCol == null)
      throw new NullPointerException("Colour not initialized");
    this.colour = newCol;
  }
  
  public void setBorderColour(Colour newCol){
    if(newCol == null)
      throw new NullPointerException("Colour not initialized");
    this.borderColour = newCol;
  }
  
  public void setBorderWeight(float weight){
    if(weight < 0)
      throw new IllegalArgumentException("Weight must be positive");
    this.borderWeight = weight;
  }
  
  // ------ GETTERS ------
  public float width(){
    return wid; 
  }
  
  public float height(){
    return hei; 
  }
  
  public Point center(){
    return center; 
  }
  
}

class BoxFunction{
  public void run(){
    //println("Not implemented");
  }
}
