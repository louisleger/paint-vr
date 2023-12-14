class strokes {

  float x, y, x_end, y_end, s;
  color c;

  strokes(float x_, float y_, float x__, float y__, float w, color c_) {

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

class button {

  int x, y, x_end, y_end, z_translation, weight;
  float corner, circle_rad = -PI/2;
  color unselected, selected;
  String text, orientation;
  boolean setDisp = true;

  button( int x_, int y_, int x__, int y__, int z_t, int w, color c, color c_, String s, float teta, String orient) {

    x = x_;
    y = y_;
    x_end = x__;
    y_end = y__;
    weight = w;
    unselected = c; 
    selected = c_;
    text = s;
    corner = teta;
    z_translation = z_t;
    orientation = orient;
  }

  void display() {

    if (onButton()) {

      stroke( color(255 * sq(red(selected)/255), 255 * sq(green(selected)/255), 255 * sq(blue(selected)/255)) );

      fill(selected);
    } else {

      stroke( color(255 * sq(red(unselected)/255), 255 * sq(green(unselected)/255), 255 * sq(blue(unselected)/255)) );

      fill(unselected);
    }

    pushMatrix();

    translate(0, 0, -z_translation);

    strokeWeight(weight);

    rotation(orientation);

    rectMode(CORNERS);
    rect(x, y, x_end, y_end, corner);

    textAlign(CENTER, CENTER); 
    textSize(int(60.00/380 * (x_end-x)));
    fill(0);

    if (setDisp) text( text, (x + x_end)/2, (y + y_end)/2);

    //CIRCLE stuff

    noFill();

    if (onButton()) {

      strokeWeight(weight);
      stroke( color(255 * sq(red(selected)/255), 255 * sq(green(selected)/255), 255 * sq(blue(selected)/255)) );

      circle_rad += 2*PI / frameRate;
    } else {

      noStroke();

      circle_rad = -PI/2;
    }

    arc((x + x_end)/2, (y + y_end)/2, (y_end - y)/2, (y_end - y)/2, circle_rad, 3*PI/2, PIE);

    popMatrix();
  }


  boolean onButton() {

    boolean bool = false;

    switch (orientation) {

    case "CENTER" :

      if (brush.x > x && brush.x < x_end && brush.y > y && brush.y < y_end && brush.z < z_translation + 50) {

        bool = true;
      }

      break;

    case "LEFT" : 

      if (brush.z > x && brush.z < x_end && brush.y > y && brush.y < y_end && brush.x < 175) {

        bool=  true;
      } 

      break;
    }

    return bool;
  }


  boolean clicked() {

    if ( circle_rad >= 3*PI/2) {

      circle_rad = -PI/2;
      
      return true;
    } else {

      return false;
    }
  }

  void rotation(String o) {

    switch (o) {

    case "LEFT" :

      translate(0, 0, (x+x_end));
      rotateY(PI/2);


      break;
    }
  }
}
