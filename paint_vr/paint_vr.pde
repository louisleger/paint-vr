import ketai.net.*;
import netP5.*;
import oscP5.*;

OscP5 oscP5;
NetAddress remoteLocation;

import processing.vr.*;

PShape grid, buckets, brush_vr;

PFont font = createFont("Serif", 72);

PVector brush, pbrush;
PVector head;

String remoteAddress = "192.168.43.189", round_subject;

String[] theme = {"menu", "fantasy", "forest", "jungle", "sea", "snow_mountain", "space", "vietnam"};

int x, y, z = -50, w, h, game_state = 0, subjects_per_theme = 10;

final int menu = 0, game = 1, chat = 2, camera_height = 1320;

color paint = color(0);


Table menuButton_info, gameButton_info, subjects;

ArrayList<strokes> canvas = new ArrayList<strokes>(); 

ArrayList<button> menu_buttons = new ArrayList<button>();

ArrayList<button> game_buttons = new ArrayList<button>();

ArrayList<String> subject_list = new ArrayList<String>();

//skybox
PImage back;
PImage down;
PImage front;
PImage left;
PImage right;
PImage up;

// bonus

char[][] lettres = new char[10][10];

button[][] c_buttons = new button[10][10];

int dir = int(random(5, 8)), pos_x = int(random(0, 6)), pos_y = int(random(0, 6));

String mot = "CHAT";

void setup() {

  fullScreen(STEREO);

  brush = new PVector(0, 0, 0);
  pbrush = new PVector(0, 0, 0);
  head = new PVector(0, 0, 0); 

  ground(200, camera_height, 4);

  brush_vr = createShape(SPHERE, 30); 
  buckets = loadShape("buckets.obj"); // transformation pour les couleurs

  buckets.translate(-buckets.width/2, -buckets.height/2, 50);

  buckets.rotateZ(PI);
  buckets.rotateY(3*PI/2);
  buckets.translate(0, 0, 100);
  buckets.scale(9);

  x = width/4; // position du tableau blanc

  y = height/4;

  w = width/2;

  h = height/3;

  initNetworkConnection(); // etablie une connection sur le port demande

  menuButton_info = new Table(); // initialisation des tables a partir de fichiers .csv
  gameButton_info = new Table();

  subjects = new Table();

  menuButton_info = loadTable("menu_data.csv", "header");
  gameButton_info = loadTable("game_data.csv", "header");

  subjects = loadTable("subjects.csv", "header");

  for (int i = 0; i < 2; i++) {

    menu_buttons.add(new button(menuButton_info.getInt(i, "x"), menuButton_info.getInt(i, "y"), menuButton_info.getInt(i, "x_end"), menuButton_info.getInt(i, "y_end"), menuButton_info.getInt(i, "z_translation"), menuButton_info.getInt(i, "weight"), color(255, 228, 181), color(255, 218, 185), menuButton_info.getString(i, "text"), menuButton_info.getFloat(i, "teta"), menuButton_info.getString(i, "orientation")));
  }
  for (int i = 0; i < 3; i++) {

    game_buttons.add(new button(gameButton_info.getInt(i, "x"), gameButton_info.getInt(i, "y"), gameButton_info.getInt(i, "x_end"), gameButton_info.getInt(i, "y_end"), gameButton_info.getInt(i, "z_translation"), gameButton_info.getInt(i, "weight"), color(255, 228, 181), color(255, 218, 185), gameButton_info.getString(i, "text"), gameButton_info.getFloat(i, "teta"), gameButton_info.getString(i, "orientation")));
  }
  for (int i = 0; i < 70; i++) {

    subject_list.add(subjects.getString(i, "subjects"));
  }


  set_sky_box_textures(menu);
}

void calculate() {
}

void draw() {

  background(240, 234, 214);

  skybox(); 

  shape(grid);


  pushMatrix();

  translate(brush.x, brush.y, brush.z); 

  brush_vr.setFill(paint);
  shape(brush_vr);

  popMatrix();

  translate(-head.x, -head.y, -head.z); // bouge le monde dans le sens inverse du mouvement de la tete

  switch (game_state) {

  case menu : 

    fill(255, 218, 185); 
    textAlign(CENTER, CENTER); 
    textSize(60); 
    textFont(font);

    pushMatrix();

    text("scribbles in vr", width/2, height/3, -50);

    for (button b : menu_buttons) { // enhanced for loop, tout les elements d'une liste

      b.display();
    }

    popMatrix();


    button play = menu_buttons.get(0);
    if (play.clicked()) {

      int r = int(random(0, subjects_per_theme * 7));

      round_subject = subject_list.get(r);

      set_sky_box_textures(int((r/subjects_per_theme)) + 1);


      game_state = game;
    }

    button mini = menu_buttons.get(1);
    if (mini.clicked()) {

      initGame();

      game_state = chat;
    }

    break;

  case game : 

    pushMatrix(); 

    translate(0, 0, -200);

    fill(255);
    noStroke();

    rectMode(CORNER);
    rect(x, y, w, h);

    for (strokes s : canvas) {
      s.display();
    }

    popMatrix();

    pushMatrix();

    paint = buckets(paint, int(brush.z));

    translate(0, 0, -200);

    shape(buckets, 1.02* width, height - buckets.height);

    popMatrix();

    translate(0, 0, 50);

    if (on(x, x + w, y, y + h, - 1000, z) && pbrush.x != 0 && check_new_line()) {

      canvas.add(new strokes(pbrush.x, pbrush.y, brush.x, brush.y, 6, paint));
    }


    button subject = game_buttons.get(2);
    subject.text = "draw " + "\n" + round_subject;
    if (subject.clicked()) {

      int r = int(random(0, subjects_per_theme * 7));

      round_subject = subject_list.get(r);

      set_sky_box_textures(int((r/subjects_per_theme)) + 1);
      
    }

    for (button b : game_buttons) {

      b.display();
    }

    button clear = game_buttons.get(0);
    if (clear.clicked()) {

      canvas.clear();
    }

    button menu_b = game_buttons.get(1);
    if (menu_b.clicked()) {

      game_state = menu;

      set_sky_box_textures(menu);
    }

    break;


  case chat :

    for (int i = 0; i < 10; i++) {
      for (int j = 0; j < 10; j++) {


        c_buttons[i][j].display();


        if (c_buttons[i][j].clicked()) {

          c_buttons[i][j].setDisp = true;
        }
      }
    }

    if (win()) {

      fill(0); 
      textAlign(CENTER, CENTER); 
      textSize(60); 
      textFont(font);


      text("M Grava vous felicite", width/2, height/3, -25);
    }

    break;
  }
}

boolean on(float x, float x_end, float y, float y_end, float z, float z_end) {

  if (brush.x > x && brush.x < x_end && brush.y > y && brush.y < y_end && brush.z > z && brush.z <= z_end) {

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

color buckets(color c, int distance) {

  if (on(860, 10000, 725, 10000, -10000, 10000)) {

    switch (int((distance-20)/110)) {

    case 0 :

      c = color(236, 30, 30);

      break;

    case 1 :

      c = color(50, 205, 50);

      break;

    case 2 :

      c = color(0, 0, 128);

      break;

    case 3 :

      c = color(0);

      break;
    }
  }

  return c;
}

void ground(int size_tile, int altitude, int size_grid) {


  grid = createShape(GROUP);

  for (int i = -size_grid; i < 2 *size_grid + 1; i++) {
    for (int j = -size_grid; j < 2 *size_grid + 1; j++) {

      PShape tile = createShape();

      tile.beginShape();

      tile.vertex(i*size_tile, altitude, j*size_tile );
      tile.vertex((i+1)*size_tile, altitude, j*size_tile);
      tile.vertex((i+1)*size_tile, altitude, (j+1)*size_tile);
      tile.vertex(i*size_tile, altitude, (j+1)*size_tile);

      tile.endShape(CLOSE);

      strokeWeight(.5);
      tile.setFill(color(250, 235, 215));

      grid.addChild(tile);
    }
  }
}


void initNetworkConnection() {

  oscP5 = new OscP5(this, 54003);
  remoteLocation = new NetAddress(remoteAddress, 54003);
}


void oscEvent(OscMessage msg) {

  if (msg.checkTypetag("ffffff")) {

    brush.x = msg.get(0).floatValue();
    brush.y = msg.get(1).floatValue();
    brush.z = msg.get(2).floatValue();

    pbrush.x = msg.get(3).floatValue();
    pbrush.y = msg.get(4).floatValue();
    pbrush.z = msg.get(5).floatValue();
  }

  if (msg.checkTypetag("fff")) {

    head.x = msg.get(0).floatValue();
    head.y = msg.get(1).floatValue();
    head.z = msg.get(2).floatValue();
  }
}

void initGame() {

  for (int i =  0; i < 10; i++) {

    for (int j = 0; j < 10; j++) {

      int n = int(random(0, mot.length()));

      lettres[i][j] = mot.charAt(n);

      for (int c = 0; c < mot.length(); c++) {

        if (dir == 5) lettres[pos_x + c][pos_y] = mot.charAt(c);

        if (dir == 6) lettres[pos_x][pos_y + c] = mot.charAt(c);

        if (dir == 7) lettres[pos_x + c][pos_y + c] = mot.charAt(c);
      }


      c_buttons[i][j] = new button(i*80 + ((width-800)/2), j * 80 + ((height-800)/2), (i+1)*80 + ((width-800)/2), (j+1) * 80 + ((height-800)/2), 50, 1, color(255, 239, 213), color(255, 218, 185), str(lettres[i][j]), 7, "CENTER");

      c_buttons[i][j].setDisp = false;
    }
  }
}


boolean win() {

  boolean bool = false;

  switch (dir) {

  case 5 :

    if (c_buttons[pos_x][pos_y].setDisp && c_buttons[pos_x + 1][pos_y].setDisp && c_buttons[pos_x + 2][pos_y].setDisp && c_buttons[pos_x + 3][pos_y].setDisp) {

      bool = true;
    }

    break;

  case 6 :

    if (c_buttons[pos_x][pos_y].setDisp && c_buttons[pos_x][pos_y + 1].setDisp && c_buttons[pos_x][pos_y + 2].setDisp && c_buttons[pos_x][pos_y + 3].setDisp) {

      bool = true;
    }

    break;

  case 7 : 

    if (c_buttons[pos_x][pos_y].setDisp && c_buttons[pos_x + 1][pos_y + 1].setDisp && c_buttons[pos_x + 2][pos_y + 2].setDisp && c_buttons[pos_x + 3][pos_y + 3].setDisp) {

      bool = true;
    }

    break;
  }


  return bool;
}

void set_sky_box_textures(int skybox) {

  back = loadImage("skyboxes/"+ theme[skybox] +"/bk.jpg");

  down = loadImage("skyboxes/"+ theme[skybox] +"/dn.jpg");

  front = loadImage("skyboxes/"+ theme[skybox] +"/ft.jpg");

  left = loadImage("skyboxes/"+ theme[skybox] +"/lf.jpg");

  right = loadImage("skyboxes/"+ theme[skybox] +"/rt.jpg");

  up = loadImage("skyboxes/"+ theme[skybox] +"/up.jpg");
}

void skybox() {

  pushMatrix();

  translate(width/2, height/2);

  int l = 5000;
  int s = 1024;

  beginShape();

  texture(up);

  vertex(-l, -l, l, s, 0);
  vertex(l, -l, l, s, s);
  vertex(l, -l, -l, 0, s);
  vertex(-l, -l, -l, 0, 0);

  endShape();


  beginShape();

  texture(down);

  vertex(-l, l, l, s, s);
  vertex(l, l, l, s, 0);
  vertex(l, l, -l, 0, 0);
  vertex(-l, l, -l, 0, s); 

  endShape();

  beginShape(); 

  texture(front);

  vertex(-l, -l, -l, 0, 0);
  vertex(l, -l, -l, s, 0);
  vertex(l, l, -l, s, s);
  vertex(-l, l, -l, 0, s);

  endShape();


  beginShape();

  texture(back);

  vertex(-l, -l, l, s, 0);
  vertex(l, -l, l, 0, 0);
  vertex(l, l, l, 0, s);
  vertex(-l, l, l, s, s);

  endShape();


  beginShape();

  texture(left);

  vertex(-l, -l, l, 0, 0);
  vertex(-l, -l, -l, s, 0);
  vertex(-l, l, -l, s, s);
  vertex(-l, l, l, 0, s);

  endShape();


  beginShape();

  texture(right);

  vertex(l, -l, l, s, 0);
  vertex(l, -l, -l, 0, 0);
  vertex(l, l, -l, 0, s);
  vertex(l, l, l, s, s);

  endShape();

  popMatrix();
}
