/*
  Solve for the intersection of two line segments
  
  Thanks to this post for a good framework to get the draggable 
  points set up.
  http://gamedev.stackexchange.com/questions/68832/how-can-i-drag-a-polygon-based-on-a-mouse-moved-event
*/

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

class My_intersection{
  int x, y;
  int radius = 5;
  boolean visible = false;
  
  My_intersection(){
    x=-5;
    y=-5;
  }
  
  void set_visible(boolean val) {visible = val;}
  
  void update(int mx, int my) {
    x = mx;
    y = my;
  }
  
  void display(){
    if(visible) {
      stroke(0);
      fill(255);
      ellipse(x, y, radius, radius);
      fill(30);
      String data = "K ("+x+","+y+")";
      text(data, x+10, y);
    }
  }
}

class Simple_vec{
  float x, y;
  
  void norm() {
    float tmp_mag = mag();
    x = x / tmp_mag;
    y = y / tmp_mag;
  }
  
  String toString() {
    return "[ "+x+", "+y+" ]";
  }
  
  float mag() {
    return sqrt((x*x) + (y*y));
  }
}


int window_x = 400;
int window_y = 400;

My_point a;
My_point b;
My_point m;
My_point n;

My_intersection k;

Simple_vec u, v;


ArrayList<My_point> points;

void setup() {
  size(window_x, window_y);

  a = new My_point("A");
  b = new My_point("B");
  m = new My_point("M");
  n = new My_point("N");
  k = new My_intersection();
  
  u = new Simple_vec();
  v = new Simple_vec();
  
  points = new ArrayList<My_point>();
  points.add(a);
  points.add(b);
  points.add(m);
  points.add(n);
  
}

void draw() {
  background(#E6E6E6);
  
  fill(30);
  text("Drag the points to make the segments intersect", 10, 15);
  
  stroke(0);
  line(a.x, a.y, b.x, b.y);
  line(m.x, m.y, n.x, n.y);
  
  for (int i=0; i<points.size(); ++i) {
    My_point tmp = points.get(i);
    tmp.display();
  }
  
  
  boolean intersection = calc_intersection(a,b,m,n);
  if (intersection) {
    text("Segments intersect", 10, height*.95);
    k.set_visible(true);
  } else {
    k.set_visible(false);
  }
  
  k.display();
}

boolean calc_intersection(My_point p1, My_point p2, My_point q1, My_point q2) {
  boolean res = false;
  boolean parallel = false;  
  boolean vertical = false;
  float radian_dirac = .05;
  float vert_dirac = .5;
  float intersection_dirac = .01;
  float ky=0;
  float kx=0;
  float k_radius = 5;
  float dot;
  float theta;

  /*
    Any two lines intersect unless they are parallel.  So the basic approach
    for this function is:
      - Test for parallel with the dot product.
      - if not parallel then find the intersection point K
      - the segments intersect if the ky point of the intersection is
        (ay1 <= Ky <= ay2) && (by1 <= Ky <= by2)
  */

  // TEST FOR || 
  //load vectors with coords
  u.x = (p1.x-p2.x);
  u.y = (p1.y-p2.y);
  v.x = (q1.x-q2.x);
  v.y = (q1.y-q2.y);

  dot = u.x*v.x + u.y*v.y;
  theta = acos(dot / (u.mag() * v.mag()) ) ;

  println("thata is: " + str(theta));

  //there are two cases where the lines are ||.  The first is when the
  //vector point in the same direction and the angle between them is 
  //almost zero radians.  The second is when they point in opposite 
  //directions and the angle between them is almost PI radians.  We allow
  //for some numerical error by checking for || within some val + dirac, 
  //where dirac represents a small error in the calculation.
  if((theta > -radian_dirac) && (theta < radian_dirac)) {
    println("parallel'ish");
    parallel = true;
  }                   
  if((theta > PI-radian_dirac) && (theta < PI+radian_dirac)) {
    println("parallel'ish");
    parallel = true;
  }
  if(parallel) return false;  
  
  //check if one line is vertical and solve the easy case 
  //where one equation, for example, p is
  //  Xp = p1.x = Xq = kx ; for intersecting lines
  //  Yq = Mq(Xq - q1.x) + q1.y
  //combining:
  //  Yq = Mq(p1.x -q1.x) + q1.y
  //We alrady know they aren't vertical so there has to be a solution for
  //both cases where one line is vertical...again taking into account a 
  //dirac for almost vertical that will account for numerical errors
  if ( ((p1.x-vert_dirac) < p2.x) && ((p1.x + vert_dirac) > p2.x)) {
    //p is vertical
    vertical = true;
    kx = p1.x;
    float m_q = (q1.y-q2.y) / (q1.x-q2.x);
    ky = m_q*(kx - q1.x) + q1.y;
    println("vert intersection y is: " + str(ky)); 
  }
  if ( ((q1.x-vert_dirac) < q2.x) && ((q1.x + vert_dirac) > q2.x)) {
    //q is vertical
    vertical = true;
    kx = q1.x;
    float m_p = (p1.y-p2.y) / (p1.x-p2.x);
    ky = m_p*(kx - p1.x) + p1.y;
    println("vert intersection y is: " + str(ky)); 
  }
    
  // If we got this far then an intersection exists so solve the system of
  // equations for the intersction, K.  The two linear equation are:
  //   Yp = Mp(Xp - p1.x) + p1.y
  //   Yq = Mq(Xq - q1.x) + q1.y
  // Since the Y's are equal at the intersection then we can set the two 
  // equation equal to one another:
  //   Mp(X - p1.x) + p1.y = Mq(X - q1.x) + q1.y
  // Then solving for X
  //             Mp*p1.x - Mq*q1.x - p1.y + q1.y
  //        X = ---------------------------------
  //                       Mp - Mq
  
  //Test for vertical because it will cause an division by zero
  if (!vertical) {
    float m_p = (p1.y-p2.y) / (p1.x-p2.x);
    float m_q = (q1.y-q2.y) / (q1.x-q2.x);
  
    kx = (m_p*p1.x - m_q*q1.x - p1.y + q1.y) / (m_p - m_q);
    ky = m_p * (kx - p1.x) +p1.y;
    println("intersection y is " + str(ky) );
  }

  //Finally, the segments only intersect if ky falls between the y vals
  //for both endpoints.
  float p_low_y = min(p1.y, p2.y);
  float p_high_y = max(p1.y, p2.y);
  float q_low_y = min(q1.y, q2.y);
  float q_high_y = max(q1.y, q2.y);
  
  if(ky <= p_high_y + intersection_dirac && 
     ky <= q_high_y + intersection_dirac && 
     ky >= p_low_y -  intersection_dirac && 
     ky >= q_low_y -  intersection_dirac ) {
    res = true;
    k.update(int(kx), int(ky));
    return res;
  }
  
  //If we haven't sent a return value yet, then the lines are aren't ||, but
  //the intersection falls outside the endpoints of the line segments.
  return res;
}

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






