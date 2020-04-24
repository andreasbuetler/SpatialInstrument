import mqtt.*;
MQTTClient client;
PFont mono;
String[] ip;
String personalToken;
int mode=0;
//BeatTap
int availableBeats;
int centerX;
int centerY;
ArrayList<Float> x=new ArrayList<Float>(1);
ArrayList<Float>x_=new ArrayList<Float>(1);
ArrayList<Float>y=new ArrayList<Float>(1);
ArrayList<Float>y_=new ArrayList<Float>(1);
boolean vis=false;

float min_x;
float max_x;
float min_y;
float max_y;


int nodesConnected = 0;

//receiver
JSONObject incoming=new JSONObject();
JSONArray points =new JSONArray();

void setup() {
  size(500, 500, FX2D);
  mono=createFont("AnonymousPro-Bold.ttf", 10);
  centerX = width/2;
  centerY = height/2;

  client= new MQTTClient(this);
  ip = loadStrings("https://ipv6.icanhazip.com/");
  personalToken=str(random(0, 32769));
  client.connect("mqtt://e2bcd174:ae5a67d2a2e7d9bc@broker.shiftr.io", ip[0]+ " - " + personalToken + " (Sattelite) ");
  client.subscribe(personalToken);
  client.subscribe(personalToken+"/Delay");
  client.subscribe(personalToken+"/allowedBeats");
  client.subscribe("/output");



  soundSetup();
  setupInterface();
}
void draw() {

  updateSoundParameters();
  valueParsing();
  if (vis=true) {
    updateNet();
    senderInterface();

    drawInterface();
  }
}

void keyPressed() {
  switch(key) {
  case '1':

    break;
  }
}
void keyReleased() {
  switch (key) {
  case TAB:
    if (availableBeats > 0) {
      client.publish("/singleBeat", "1");
      drawBeat();
      return;
    }
  case ' ':
    if (availableBeats > 0) {
      client.publish("/singleBeat", "0");
      drawBeat();
      return;
    }
  }
}


void messageReceived(String topic, byte[] payload) {
  if (topic.equals(personalToken+"/allowedBeats")) {
    availableBeats = int(new String(payload));
    println("availableBeats"+availableBeats);
  }

  //DELAY

  if (topic.equals(personalToken+"/Delay")) {
    // println("Delay In");
    String sendList=new String();
    String[] transfer= splitTokens(new String(payload), ",");
    for (int i =1; i<transfer.length; i++) {
      sendList=sendList+transfer[i]+",";
    }
    //  println(sendList +" - resent");
    // println(transfer[1]);
    client.publish(transfer[1]+"/Delay", sendList);
  }
  if (topic.equals("/output")) {
    incoming=parseJSONObject(new String (payload));
    //println(incoming);
    beatTap = incoming.getBoolean("beat");
    singleSample = false;
    pingbeatDelay = constrain(map(incoming.getInt("delay"), 0, 2000, 0, 1), 0, 1);
    weatherdata = map(incoming.getInt("windAverage"), 0, 50, 0, 1);
    coordinateSurface = coordinateSurface;
    userQty = map(constrain(incoming.getInt("NODES"), 0, 20), 0, 20, 0, 1);
    nodesConnected = incoming.getInt("NODES");
    points= incoming.getJSONArray("coordinates");
    coordinates.clear();
    x.clear();
    y.clear();

    for (int i=0; i<points.size(); i++) {

      x.add(points.getJSONObject(i).getFloat("x"));
      y.add(points.getJSONObject(i).getFloat("y"));
      vis=true;
      // coordinates.add(new PVector(x,y));
    }
  }
}

void senderInterface() {
  background(0);  
  textSize(20);
  textAlign(CENTER, CENTER);
  noFill();
  pushMatrix();
  stroke(255);
  translate(centerX, centerY);
  text("press TAB to send Beat  "+ availableBeats, 0, 0);
  text(availableBeats+" Beats available", 0, 30);
  popMatrix();
}



void drawBeat() {
  pushMatrix();
  pushStyle();
  fill(255);
  rect(0, 0, width, height);
  popStyle();
  popMatrix();
}

void updateNet() {
  x_.clear();
  y_.clear();
  if (x.size()>1) {
    min_x=x.get(0);
    max_x=x.get(0);
    min_y=y.get(0);
    max_y=y.get(0);
    for (int i=0; i<x.size(); i++) {
      if (x.get(i)<min_x) {
        min_x=x.get(i);
      }
      if (x.get(i)>max_x) {
        max_x=x.get(i);
      }
      if (y.get(i)<min_y) {
        min_y=y.get(i);
      }
      if (y.get(i)>max_y) {
        max_y=y.get(i);
      }
    }

    for (int i=0; i<points.size(); i++) {
      x_.add(map(x.get(i), min_x-0.00001, max_x+0.00001, 40, width-40));
      y_.add(map(y.get(i), min_y-0.00001, max_y+0.00001, 40, height-40));
    }


    //println(y_.get(0)+"  "+y_.get(1));
    //println(x_.get(0)+"  "+x_.get(1));
    //printArray(x_);  
    //printArray(y_);
  }
}
