class Graph{
  
  private final float wid, hei;
  private Interval x_axis;
  private Interval y_axis;
  private final Direction x_dir;
  private final Direction y_dir;
  
  private float x_scaling;
  private float y_scaling;
  private final float graphScaling_x, graphScaling_y;
  
  private int nbVal_x, nbVal_y;
  
  PShape graph;
  // Origin of the graph relative to the absolute system in which the graph is contained
  private final Point graphOrigin;
  private final Point center;
  
  // Cosmetic stuff
  private Colour graphColour;
  private Colour axisColour;
  private Colour backgroundColour;
  private Colour valuesColour;
  
  private float graphStroke;
  private float textSize;
  
  private float x_padding, y_padding;
  
  public Graph(float wid, float hei, Point centerPoint, Interval x_axis, Interval y_axis, Direction x_dir, Direction y_dir){
    
    x_padding = 100;
    y_padding = 50;
    
    graphColour = new Colour(50, 168, 82);
    axisColour = new Colour(0, 0, 0);
    backgroundColour = new Colour(255, 255, 255);
    valuesColour = new Colour(0,0,0);
    graphStroke = 1;
    textSize = 20;
    
    nbVal_x = 5;
    nbVal_y = 5;
    
    if(wid < 0 || hei < 0)
      throw new IllegalArgumentException("Width or height must be >0");
    this.wid = wid - x_padding;
    this.hei = hei - y_padding;
    
    // Scaling of a unit of the axis
    x_scaling = (float)(this.wid /x_axis.size());
    y_scaling = (float)(this.hei / y_axis.size());
    graphScaling_x = (float)(this.wid /x_axis.size());
    graphScaling_y = (float)(this.hei / y_axis.size());
    
    if(centerPoint == null)
      throw new NullPointerException("Center point not initialized");
    this.center = centerPoint;
    // Compute the graph's origin from the center of the graph
    float zeroOffset_x = abs(x_axis.lo()) * x_scaling;
    float zeroOffset_y = abs(y_axis.lo()) * y_scaling;
    
    graphOrigin = new Point(centerPoint.x() - wid/2 + x_padding/2 + zeroOffset_x, centerPoint.y() + hei/2 - y_padding/2 - zeroOffset_y, centerPoint.z());
    // Create the graph shape and add the origin
    graph = createShape();
    graph.beginShape();
    graph.noFill();
    graph.vertex(0,0);
    graph.endShape();
    
    this.x_axis = x_axis;
    this.y_axis = y_axis;
    this.x_dir = x_dir;
    this.y_dir = y_dir;
    
    
  }
  
  public Graph(float wid, float hei, Point centerPoint, Interval x_axis, Interval y_axis) {
     this(wid, hei, centerPoint, x_axis, y_axis, Direction.RIGHT, Direction.UP);
  }
  
  public void drawGraph(){
    //Draw background;
    rectMode(CENTER);
    setFillColour(backgroundColour);
    noStroke();
    rect(center.x(), center.y(), wid, hei);
    rectMode(CORNER);
    
    // Draw scales 
    drawScale(nbVal_x, y_scaling, y_axis, y_dir, getInsideDir(y_dir));
    drawScale(nbVal_y, x_scaling, x_axis, x_dir, getInsideDir(x_dir));
    shape(graph, graphOrigin.x(), graphOrigin.y());
    adjustTextAlign(null); // set to default values
  }
  
  public void addPoint(Point point){
     if(point.x() < x_axis.lo()) //<>//
       throw new IllegalArgumentException("Adding point below x_axis boundaries");
     if(point.y() < y_axis.lo())
       throw new IllegalArgumentException("Adding point below y_axis boundaries");
     // Rescale if needed
     
     graph.beginShape();
     graph.noFill();
     graph.strokeWeight(2);
     graph.stroke(graphColour.r(), graphColour.g(), graphColour.b());
     graph.vertex(graphScaling_x* point.x(), graphScaling_y * (-point.y()));
     graph.endShape();
     
     rescale((point.x() > x_axis.hi()), (point.y() > y_axis.hi()));
     shape(graph, graphOrigin.x(), graphOrigin.y());
  }
  
  private void drawScale(int nb, float scaling, Interval interval, Direction dir, Direction insideDir){
    
    
    // Adjust text alignment 
    adjustTextAlign(insideDir);
    
    // Draw line
    strokeWeight(graphStroke);
    setFillColour(valuesColour);
    setStrokeColour(axisColour);
    // Move center to the origin of the graph
    pushMatrix();
    goTo(graphOrigin);
    
    line(0, 0, dir.x() * interval.hi() * scaling, dir.y() * interval.hi() * scaling);
    line(0, 0, dir.x() * interval.lo() * scaling, dir.y() * interval.lo() * scaling);
    
    float unitInterval = interval.size() / nb;
    
    pushMatrix();
    for(float i = unitInterval; i<=interval.hi(); i+=unitInterval){
      //Shift in the direction of the scale
      translate((float)(dir.x() * (wid/nb)), (float)(dir.y() * (hei/nb)));
      
      textSize(textSize);
      text(String.valueOf((i)), -insideDir.x() * 4, -insideDir.y() * 4);
       
      // Draw the line (from inside to out)
      strokeWeight(graphStroke);
      line(-insideDir.x() * 2, -insideDir.y() * 2, insideDir.x() * 2, insideDir.y() * 2);
    }
    popMatrix();
    
    pushMatrix();
    for(float i = -unitInterval; i >= interval.lo() ; i-=unitInterval){
      //Shift in the direction of the scale
      translate((float)(dir.x() * (wid/nb)), -(float)(dir.y() * (hei/nb)));
      
      textSize(textSize);
      text(String.valueOf((i)), -insideDir.x() * 4, -insideDir.y() * 4);
      
      // Draw the line (from inside to out)
      strokeWeight(graphStroke);
      line(-insideDir.x() * 2, -insideDir.y() * 2, insideDir.x() * 2, insideDir.y() * 2);
      
     }
    popMatrix();
    popMatrix();
  }
  
  private void rescale(boolean rescaleX, boolean rescaleY){
    if(rescaleX == false && rescaleY == false)
      return;
      
    if(rescaleX){
      Interval newInterval = new Interval(x_axis.lo(), x_axis.hi() + x_axis.size());
      x_scaling = wid / newInterval.size();
      this.x_axis = newInterval;
      
      graph.scale(0.5, 1);
    }
    if(rescaleY){
      Interval newInterval = new Interval(y_axis.lo(), y_axis.hi() + y_axis.size());
      y_scaling = hei / newInterval.size();
      this.y_axis = newInterval;
      
      graph.scale(1, 0.5);
    }
    drawGraph();
  }
  
  // *****************************
  // ********** SETTERS **********
  // *****************************
  
  public void setGraphStroke(float newVal){
    if(newVal < 0)
      throw new IllegalArgumentException("Stroke weight must be positive");
    this.graphStroke = newVal; 
  }
  
  public void setTextSize(float newVal){
    if(newVal < 0)
      throw new IllegalArgumentException("Stroke weight must be positive");
    this.textSize = newVal; 
  }
  
  public void setGraphColour(Colour newCol){
    if(newCol == null)
      throw new IllegalArgumentException("Uninitialized colour");
    this.graphColour = newCol;
  }
  
  public void setAxisCoulour(Colour newCol){
    if(newCol == null)
      throw new IllegalArgumentException("Uninitialized colour");
    this.axisColour = newCol; 
  }
  
  public void setValuesColour(Colour newCol){
    if(newCol == null)
      throw new IllegalArgumentException("Uninitialized colour");
    this.valuesColour = newCol; 
  }
  
  public void setBackgroundColour(Colour newCol){
    if(newCol == null)
      throw new IllegalArgumentException("Uninitialized colour");
    this.backgroundColour = newCol; 
  }
  
  public void setColours(Colour graphCol, Colour axisCol, Colour valuesCol, Colour backgroundCol){
    if(graphCol == null || axisCol == null || valuesCol == null ||backgroundCol == null)
      throw new IllegalArgumentException("Uninitialized colour");
    this.graphColour = graphCol;
    this.axisColour = axisCol;
    this.valuesColour = valuesCol; 
    this.backgroundColour = backgroundCol; 
  }
  
  public void setPadding(float x, float y){
    this.x_padding = x;
    this.y_padding = y;
  }
  
  public void setNbValX(int nb){
    if(nb < 0 )
      throw new IllegalArgumentException("Value must be positive");
    nbVal_x = nb;
  }
  
  public void setNbValY(int nb){
    if(nb < 0 )
      throw new IllegalArgumentException("Value must be positive");
    nbVal_y = nb;
  }
  
  // **************************************
  // ********** HELPER FUNCTIONS **********
  // **************************************
  
  private void setFillColour(Colour col){
    fill(col.r(), col.g(), col.b()); 
  }
  
  private void setStrokeColour(Colour col){
    stroke(col.r(), col.g(), col.b()); 
  }
  
  private void goTo(Point point){
    translate(point.x(), point.y(), point.z()); 
  }
  
  private Direction getInsideDir(Direction dir){
    if(dir == x_dir)
      return y_dir;
    else
      return x_dir;
  }
  
  private void adjustTextAlign(Direction insideDir){
    if(insideDir == null){
     textAlign(LEFT, BOTTOM); // Default value
    } else {
      switch(insideDir){
        case UP:
          textAlign(CENTER, TOP);
          break;
        case DOWN:
          textAlign(CENTER, BOTTOM);
          break;
        case LEFT:
          textAlign(LEFT, CENTER);
          break;
        case RIGHT:
          textAlign(RIGHT, CENTER);
          break;
      }
    }
  }
}

enum Direction{
 UP(0, -1), DOWN(0, 1), LEFT(-1, 0), RIGHT(1, 0);
 
 private final int x, y;
 
 private Direction(int x, int y){
   this.x = x;
   this.y = y;
 }
  
 public int x(){
   return x;
 }
 
 public int y(){
   return y; 
 }
}
