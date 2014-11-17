/*
  Processing sketch that uses barycentric coordinates to determine whether a
  point is within a triangle.
  
  See these three sites for a good intro to barycentric coords
  http://totologic.blogspot.fr/2014/01/accurate-point-in-triangle-test.html
  
  http://stackoverflow.com/questions/540014/compute-the-area-of-intersection-between-a-circle-and-a-triangle
  
  http://en.wikipedia.org/wiki/Barycentric_coordinate_system
*/


//***********************************************************************
//                               GLOBAL VARIABLES
//***********************************************************************
int window_x = 400;
int window_y = 400;

My_point p;
My_point q;
My_point r;
My_point k;

My_point drag_target;

ArrayList<My_point> points;

color fill_color;
color inside = color(255);
color outside = color(180);

//***********************************************************************
//                             SETUP AND DRAW
//***********************************************************************
void setup() {
  size(window_x, window_y);

  p = new My_point("P");
  q = new My_point("Q");
  r = new My_point("R");
  k = new My_point("K");
    
  points = new ArrayList<My_point>();
  points.add(p);
  points.add(q);
  points.add(r);  
  points.add(k);
  
  fill_color = outside;
}

void draw() {
  background(#E6E6E6);
  
  fill(30);
  text("Drag point K into the triangle to test detection.", 10, 15);
  text("Drag P, Q or R to change the triangle.", 10, 30);
  
  boolean inside_t = calc_inside_t(k.x, k.y);
  fill_color = inside_t ? inside : outside;
  
  stroke(0);
  fill(fill_color);
  triangle(p.x, p.y, q.x, q.y, r.x, r.y);
  
  if(inside_t) {
    fill(30);
    text("K is inside the triangle", 10, height*.95);
  }
  
  for (int i=0; i<points.size(); ++i) {
    My_point tmp = points.get(i);
    tmp.display();
  }
}

//***********************************************************************
//                    CALCULATE BARYCENTRIC CONTAINMENT
//
//  Barycentric coordinates allow expression of the coordinates of any point
//  as a linear combination of a triangle's vertices.  The physical association
//  is that you can balance a triangle on any point within its boundary or on
//  along its edge with three scalar weights at the vertices defined as
//  a, b, and c such that:
//      x = a * x1 + b * x2  + c * x3
//      y = a * y1 + b * y2 + c * y3
//      a + b + c = 1
//
//  Solving these equations for a, b and c yields:
//     a = ((y2-y3)*(x-x3) + (x3-x2)*(y-y3)) / ((y2-y3)*(x1-x3) + (x3-x2)*(y1-y3))
//     b = ((y3-y1)*(x-x3) + (x1-x3)*(y-y3)) / ((y2-y3)*(x1-x3) + (x3-x2)*(y1-y3))
//     c = 1 - a - b
//
//  For any balance point along an edge or within the boundary of the triangle
//  the scalars will be equal to zero or positive numbers.  If a point is 
//  outside the triangle you would have to apply negative weight, or pull up
//  on one point of the triangle to get it to balance.  So to find out if a 
//  point is inside the triangle we apply the property:
//    K inside T if and only if 0<=a<=1 and 0<=b<=1 and 0<=c<=1
//***********************************************************************
boolean calc_inside_t(float x, float y){
  boolean res = false;
  
  float den = (q.y-r.y)*(p.x-r.x) + (r.x-q.x)*(p.y-r.y);
  float a = ((q.y-r.y)*(x-r.x) + (r.x-q.x)*(y-r.y)) / den;
  float b = ((r.y-p.y)*(x-r.x) + (p.x-r.x)*(y-r.y)) / den;
  float c = 1 - a - b;
  
  res =  0<=a && a<=1 && 0<=b && b<=1 && 0<=c && c<=1;
  
  return res;
}

//***********************************************************************
//                               MOUSE EVENTS
//***********************************************************************
void mousePressed() {
  //Cycle through all the points to find out if the mouse was pressed on one
  //of them.  If so then set a pointer to that object so other mouse events
  //can reach the right object.
  for (int i=0; i<points.size(); ++i) {
    My_point tmp = points.get(i);
    if( tmp.clicked(mouseX, mouseY) ) {
      drag_target = tmp;
      break;
    }
  }
}

void mouseDragged() {
  //If the target was set in mousePressed then update the position of the
  //object for drag, but keep it inside the window.
  if(drag_target != null) {
    float dx = mouseX;
    float dy = mouseY;
    dx = (dx < .05*width) ? .05*width : dx; 
    dy = (dy < .10*height) ? .10*height : dy;  //allow text room at the top 
    dx = (dx > .95*width) ? .95*width : dx;
    dy = (dy > .90*height) ? .90*height : dy;  //allow text room at the bottom 
    drag_target.update(dx, dy);
  }
}

void mouseReleased() {
  //when the mouse button is released we set the drag_target back to null so
  //that subseqeunt drags don't move the object if it's not clicked on again.
  drag_target = null;
}

//***********************************************************************
//                           CUSTOM TYPES
//***********************************************************************
class My_point{
  float x, y;
  String n;
  
  float radius = 10.0;
  
  My_point(String name) {
    n = name;
    x = random(.1*float(window_x), .9*float(window_x));
    y = random(.1*window_y, .9*window_y);  
  }
  
  void display() { 
    stroke(0);
    fill(255);
    ellipse(x, y, radius, radius);
    fill(30);
    text(n, x+10, y);
  }
  
  String toString() {
    return "("+x+", "+y+")"; 
  }
  
  boolean clicked(float mx, float my) {
    boolean res = false;
    if ( dist(mx,my,x,y) < radius) {
      res = true;
    }
    return res;
  }
  
  void update(float mx, float my) {
    x = mx;
    y = my;
  }
}

