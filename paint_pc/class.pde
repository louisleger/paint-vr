class strokes {
  
  float x, y, x_end, y_end, s;
  color c;
  
  strokes(float x_, float y_,  float x__, float y__, int w, color c_) {
    
    x = x_;
    y = y_;
    x_end = x__;
    y_end = y__;
    s = w;
    c = c_;
    
  }
  
  void display() {
   
    
    strokeWeight(s);
    stroke(c);
    fill(c);
    
    line(x, y, x_end, y_end);
    
  }
}
