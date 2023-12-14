
import netP5.*;
import oscP5.*;
import processing.video.*;

Capture video_1, video_2;
OscP5 osc;
NetAddress remoteLocation;


PImage splash_screen;

ArrayList<strokes> canvas = new ArrayList<strokes>();

PVector brush = new PVector(0, 0, 0);
PVector brush_1 = new PVector(), brush_2 = new PVector();

PVector head = new PVector(0, 0, 0), distance_to_camera = new PVector(0, 0, 0);
PVector head_1 = new PVector(), head_2 = new PVector();

color brush_color = color(0, 255, 0), head_color = color(255, 0, 0);

float pbrush_x, pbrush_y, pbrush_z;

int zone_length = 100, threshold = 30, nomans, canvas_z, buckets_z, phone_width = 1100, phone_height = 1080;
int[] zone = new int[16];

boolean show_image = true, show_drawing = false;

String select= "change brush", subject = "none";


void setup() {
  size(1280, 720);
  frameRate(60);

  splash_screen = loadImage("image.png");

  osc = new  OscP5(this, 54003);
  remoteLocation = new NetAddress("192.168.43.186", 54003);


  String[] cameras = Capture.list();

  printArray(cameras);

   video_1 = new Capture(this, 1280, 720, cameras[73], 30);//17
   video_2 = new Capture(this, 1280, 720, cameras[149], 30);//93
   
   video_1.start();
   video_2.start();

  for (int i = 0; i < 4; i++) {

    zone[0 + i*4] = 0; 
    zone[1 + i*4] = 0; 

    zone[2 + i*4] = 1280;
    zone[3 + i*4] = 720;
  }
}


void draw() {

   if (show_drawing == false) {
   
   background(78, 93, 75);
   video_1.loadPixels();
   video_2.loadPixels();
   
   pushMatrix();
   
   translate(640, 0); //flips the image  
   scale(-1, 1);
   
   if (show_image == true) { // displays image
   
   image(video_1, 0, 0, 640, 360);
   image(video_2, 0, 360, 640, 360);
   }
   
   popMatrix();
   
   fill(255);
   textSize(32);
   
   textAlign(LEFT, TOP);
   
   text("brush coords" + "\n" + "x: " + brush.x + "\n" + "y: " + brush.y + "\n" + "z: " + brush.z + "\n" + "\n" + select, width/2, 0); // text on the top right
   
   text("\n" + "threshold: " + threshold + "\n" + "zone length: " + zone_length*2 + "\n" + "dist: " + 0, 3*width/4, 0);
   
   image(splash_screen, width/2, height/2, width/2, height/2);
   
   noFill(); 
   stroke(255, 0, 0);
   strokeWeight(3);
   rectMode( CORNERS);
   rect((video_1.width -zone[0])/2, zone[1]/2, (video_1.width -zone[2])/2, zone[3]/2); // retracking zone
   
   strokeWeight(20);
   stroke(brush_color);
   
   point(brush_1.x/2, brush_1.y/2);
   point(brush_2.x/2, brush_2.y/2 + video_2.height/2); // points for brush coords in each camera
   
   stroke(head_color);
   
   point(head_1.x/2, head_1.y/2);
   point(head_2.x/2, head_2.y/2 + video_2.height/2);
   
   nomans = int((video_1.width*140)/(2*tan(PI/6)*brush.z)); // NOMANS LAND
   
   noFill();
   strokeWeight(3);
   
   if (on(nomans, video_1.width, 0, video_1.height, -1, 1, brush_1)) { 
   
   stroke(255);
   } else {
   
   stroke(255, 0, 0);
   }
   
   rect(nomans/2, 0, video_1.width/2, video_1.height/2); 
   
   
   if (on(0, video_1.width-nomans, 0, video_1.height, -1, 1, brush_2)) { 
   
   stroke(255);
   } else {
   
   stroke(255, 0, 0);
   }
   
   rect(0, video_1.height/2, (video_1.width- nomans)/2, video_1.height);
   
   //
   } 
   
   brush_1 = detect(brush_color, video_1, 0);
   brush_2 = detect(brush_color, video_2, 1);
   
   if (brush_1.x != 0) brush = irl(140, video_1.width, PI/3, brush_1, brush_2, brush, 0.15); // uses all the info gotten so far, to give an accurate to life x, y and z
   
   head_1 = detect(head_color, video_1, 2);
   head_2 = detect(head_color, video_2, 3);
   
   
   if (head_1.x != 0) head = irl(140, video_1.width, PI/3, head_1, head_2, head, 0.1);
   
/*  if (show_drawing == true) {

    background(78, 93, 75);


    textAlign(CENTER, CENTER);
    fill(0);
    textSize(64);
    text("Dessin", width/4, height/6);
    text(subject, 3*width/4, height/2);

    stroke(0);
    strokeWeight(10);
    fill(255);
    rectMode(CORNER);
    rect(0, height/4, width/2, height/2);

    if (on(phone_width/4, 3 * phone_width/4, phone_height/4, phone_height/4 + phone_height/3, -10000, 0, new PVector(calib(brush.x, "x"), calib(brush.y, "y"), calib(brush.z, "z"))) && check_new_line()) {

      int by = 1/4* (height - (phone_height*height * 3* phone_height^2)/2);
      
      canvas.add( new strokes(calib(pbrush_x, "x") * (width/2)/(2*(phone_width/4)) - width/4, calib(pbrush_y, "y") * ((height*3*phone_height)/2) + by, calib(brush.x, "x") * (width/2)/(2*(phone_width/4)) - width/4, calib(brush.y, "y") * (height/(2*phone_height/3)) + by, 8, color(0)));
    }

    for (strokes s : canvas) {

      s.display();
    }
  }*/

  send(); 

  pbrush_x = brush.x; // sets previous brush coords to the brush coords of the previous frame
  pbrush_y = brush.y;
  pbrush_z = brush.z;
}


void mousePressed() { // selects color 

  if (mouseButton == LEFT) {

    switch (select) {



    case "change brush" :

      brush_color = color_change();

      select = "change head";

      break;



    case "change head" :

      head_color = color_change();
      distance_to_camera = head.copy();

      select = "change brush";

      break;
    }
  }


  if (mouseButton == RIGHT) {

    if (canvas_z == 0) {

      canvas_z = int(brush.z);
    }

    if (canvas_z != 0) {

      buckets_z = int(brush.z);
    }

    if (canvas_z != 0 && buckets_z != 0) {

      canvas_z = 0;
      buckets_z = 0;
    }
  }
}

void keyPressed() { 

  if (key == 'z') threshold += 5;
  if (key == 's') threshold -= 5;

  if (keyCode == UP) zone_length += 25;
  if (keyCode == DOWN) zone_length -= 25;

  if (key == 'r') show_image = false;

  if (key == 'm') show_drawing = boolean((int(show_drawing) + 1) % 2);

  if (key == 'E' && show_drawing) {

    PImage drawing = get(0, height/4, width/2, height/2);
    drawing.save("dessin.jpg");
  }
}

void captureEvent(Capture video_1) { //updates the camera

  video_1.read();
}

color color_change() { //changes color to wherever mouse is

  int pos = (video_1.width-(2*mouseX)) + 2*mouseY*video_1.width;

  color c = video_1.pixels[pos];

  //convert the color to a maxed out version, to find its shade, (100, 20, 10) becomes (255, 51, 25);
  //  float mult = max(red(c), green(c), blue(c))/255;

  c = color(red(c), green(c), blue(c));

  return c;
}

float cal(float p, String axis) { //calibrates coords for phone's canvas

  float d = (brush.z * tan(PI/6));
  float d_ = int(((brush.z * tan(PI/6)) * (((video_1.width- nomans)*10)/video_1.width - 5))/5); // i can only show u this with a piece of paper

  switch (axis) {

  case "x" : 

    p = int ( ( 1100.000/ (d+d_)  * p ) + (1100*d)/(d + d_) );

    break;

  case "y" : 

    p = int ( ( (1080.000/ (2 * d * 9/16 )) * p) + 1080/2 );

    break;

  case "z": 

    float a = -550.00/(canvas_z-buckets_z);
    float b = -100 + 550*canvas_z/(canvas_z-buckets_z);
    p = int( (a * p) + b);
    constrain(p, -50, 450);

    break;
  }

  return p;
}

float calib(float p, String axis) { //calibrates coords for phone's canvas

  float d = (brush.z * tan(PI/6));

  switch (axis) {

  case "x" : 

    p = int ( ( 1100.00/ (1.8*d)  * p ) + (1100.00)/(1.80) );

    break;

  case "y" : 

    p = int ( ( (1080.000/ (2 * d * 9/16 )) * p) + 1080/2 );

    break;

  case "z": 

    float a = 3.33;
    float b = -1570;

    if (canvas_z != 0 && buckets_z != 0) {

      a = -550.00/(canvas_z-buckets_z);
      b = -100 + 550*canvas_z/(canvas_z-buckets_z);
    }

    p = int( (a * p) + b);
    constrain(p, -50, 500);

    break;
  }

  return p;
}


boolean on(float x, float x_end, float y, float y_end, float z, float z_end, PVector b) { //checks if the brush is on the something

  if (b.x > x && b.x < x_end && b.y > y && b.y < y_end && b.z > z && b.z < z_end) {

    return true;
  } else {

    return false;
  }
}

boolean check_new_line() {

  boolean permission = true;

  if (canvas.size() > 10) {

    strokes s = canvas.get(canvas.size() - 1);

    if (s.x == brush.x && s.y == brush.y) {

      permission = false;
    }
  }

  return permission;
}


PVector detect(color c, Capture cam, int trackID) { 

  int n_pixels = 0;
  float total_x = 0, total_y = 0;
  PVector vector = new PVector(0, 0, 0);

  for (int i = zone[0 + trackID*4]; i < zone[2 + trackID*4]; i++) {
    for (int j = zone[1 + trackID*4]; j < zone[3 + trackID*4]; j++) {


      int pos = i + (j * cam.width);
      color pixel = cam.pixels[pos];

      float unit = d(red(pixel), green(pixel), blue(pixel), red(c), green(c), blue(c)); 

      if (unit < threshold*threshold) {

        total_x += i;
        total_y += j;
        n_pixels++;
      }
    }
  }

  if (n_pixels > 50) {

    vector.x = cam.width - (total_x/ n_pixels);
    vector.y = total_y/ n_pixels;

    zone[0 + trackID*4] = int((total_x/n_pixels)- zone_length);
    zone[1 + trackID*4] = int(vector.y - zone_length);

    zone[2 + trackID*4] = int((total_x/n_pixels) + zone_length);
    zone[3 + trackID*4] = int(vector.y + zone_length);

    if ( zone[0 + trackID*4] < 0 ) zone[0 + trackID*4] = 0;
    if ( zone[2 + trackID*4] > cam.width) zone[2 + trackID*4] = cam.width;

    if ( zone[1 + trackID*4] < 0 ) zone[1 + trackID*4] = 0;
    if ( zone[3 + trackID*4] > cam.height) zone[3 + trackID*4] = cam.height;
  } else {

    zone[0 + trackID*4] = 0; 
    zone[1 + trackID*4] = 0; 

    zone[2 + trackID*4] = cam.width;
    zone[3 + trackID*4] = cam.height;
  }

  return vector;
} 


PVector irl(int b, int X, float teta, PVector blob_left, PVector blob_right, PVector current, float easing) { //obtains the z coord and realistic x, y coords because of the cam's fov

  PVector blob = current;

  float target_z = abs((b * X)/(2 * tan(teta/2) * (blob_left.x - blob_right.x)));

  float step_z = target_z - blob.z;
  blob.z += int(step_z * easing);

  float target_x = int(((target_z * tan(teta/2)) * ((blob_right.x*10)/video_1.width - 5))/5);

  float step_x = target_x - blob.x;
  blob.x += int(step_x * easing);

  float target_y = int((((target_z * tan(teta/2)) * ((blob_right.y*10)/video_1.height - 5))/5)*9/16);

  float step_y = target_y - blob.y;
  blob.y += int(step_y * easing);


  return blob;
}

float d(float r, float g, float b, float r1, float g1, float b1) {

  return (r1 - r) *(r1 - r) + (g1 - g) * (g1 - g) + (b1 - b) *(b1 - b);
}
void send() { // sends to phone

  OscMessage msg = new OscMessage("ffffff");
  OscMessage msg2 = new OscMessage("fff");

  msg.add(calib(brush.x, "x"));
  msg.add(calib(brush.y, "y"));
  msg.add(calib(brush.z, "z"));

  msg.add(calib(pbrush_x, "x"));
  msg.add(calib(pbrush_y, "y"));
  msg.add(calib(pbrush_z, "z"));

  msg2.add((head.x-distance_to_camera.x)/2);
  msg2.add((head.y-distance_to_camera.y)/2);
  msg2.add((head.z-distance_to_camera.z)/2);

  osc.send(msg, remoteLocation);
  osc.send(msg2, remoteLocation);
}
