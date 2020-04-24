import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import mqtt.*; 
import ddf.minim.*; 
import ddf.minim.analysis.*; 
import ddf.minim.effects.*; 
import ddf.minim.signals.*; 
import ddf.minim.spi.*; 
import ddf.minim.ugens.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class Satellite_3_0 extends PApplet {


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

public void setup() {
  
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
public void draw() {

  updateSoundParameters();
  valueParsing();
  if (vis=true) {
    updateNet();
    senderInterface();

    drawInterface();
  }
}

public void keyPressed() {
  switch(key) {
  case '1':

    break;
  }
}
public void keyReleased() {
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


public void messageReceived(String topic, byte[] payload) {
  if (topic.equals(personalToken+"/allowedBeats")) {
    availableBeats = PApplet.parseInt(new String(payload));
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

public void senderInterface() {
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



public void drawBeat() {
  pushMatrix();
  pushStyle();
  fill(255);
  rect(0, 0, width, height);
  popStyle();
  popMatrix();
}

public void updateNet() {
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
      x_.add(map(x.get(i), min_x-0.00001f, max_x+0.00001f, 40, width-40));
      y_.add(map(y.get(i), min_y-0.00001f, max_y+0.00001f, 40, height-40));
    }


    //println(y_.get(0)+"  "+y_.get(1));
    //println(x_.get(0)+"  "+x_.get(1));
    //printArray(x_);  
    //printArray(y_);
  }
}


ArrayList<PVector> coordinates = new ArrayList<PVector>();
ArrayList<Pulse> rings = new ArrayList<Pulse>();
PShape surface;
PGraphics surfaceGraphics;
PGraphics circles;
float maxDistance;
float minDistance;
float scaleValue;

public void setupInterface() {

  smooth();
  frameRate(30);

  surface = createShape();
  surfaceGraphics = createGraphics(width, height);

  circles = createGraphics(width, height); //size of mask
}

public void drawInterface() {
  background(0);
  //rings.add(new Pulse(x, y, sz));

  //  surface.beginShape();
  //  surface.noFill();
  //  surface.stroke(255);
  //  for(int k=0;k<coordinates.size()-1;k++){ 
  //  surface.vertex(coordinates.get(k).x,coordinates.get(k).y);
  //  surface.vertex(coordinates.get(k+1).x,coordinates.get(k+1).y); 
  //}
  //surface.endShape(CLOSE);
  surfaceGraphics.beginDraw(); 

  surfaceGraphics.endDraw();

  circles.beginDraw();
  for (int k=0; k<coordinates.size(); k++) {
    float dist;
    dist = coordinates.get(k).mag();
    if (dist>maxDistance) {
      maxDistance = dist;
    }
    if (dist<minDistance) {
      minDistance = dist;
    }
    rings.add(new Pulse(coordinates.get(k).x, coordinates.get(k).y));
    rings.get(k).update();
    rings.get(k).display();
  }
  circles.endDraw();    
  textSize(20);
  textAlign(LEFT, CENTER);
  textFont(mono);
  noFill();
  stroke(255);
  pushMatrix();
  stroke(255);
  text("Spatial Instruments", 10, 10);
  popMatrix();
  pushMatrix();
  if (availableBeats>0);
  {
    stroke(255);
  }

  if (availableBeats==0) {
    stroke(220);
  }
  translate(10, height-20);
  text("add to the beat with TAB and press SPACE to reduce it", 0, 0);
  text(availableBeats+" Beats available", 0, 30);
  popMatrix();

  for (int f=0; f<20; f++) {


    for (int k=0; k<points.size()-1; k++) { 
      pushMatrix();
      stroke(255, 255, 255, 255/(f+1));
      // stroke(255-(f*11));
      line(x_.get(k)+10*f, y_.get(k)+10*f, x_.get(k+1)+10*f, y_.get(k+1)+10*f);
      line(x_.get(0)+10*f, y_.get(0)+10*f, x_.get(points.size()-1)+10*f, y_.get(points.size()-1)+10*f);
      line(x_.get(k), y_.get(k), width/2, 20+10*f);
      line(x_.get(points.size()-1)+10*f, y_.get(points.size()-1)+10*f, width/2, 20+10*f);
      stroke(255);
      popMatrix();
      pushMatrix();
      stroke(255);
      line(x_.get(k), y_.get(k), x_.get(k+1), y_.get(k+1));
      line(x_.get(0), y_.get(0), x_.get(points.size()-1), y_.get(points.size()-1));
      line(x_.get(k), y_.get(k), width/2, 20);
      line(x_.get(points.size()-1), y_.get(points.size()-1), width/2, 20);

      popMatrix();
    }
    for (int i=0; i<availableBeats; i++) {
      //  line(0,0,width/(i+1),height/(i+1));
      line(10, height-(40+(i*10)), 30, height-(40+(i*10)));
    }
  }
  image(surfaceGraphics, 0, 0);
}

class Pulse {
  float x, y;
  float sz = 0, store_sz;

  Pulse(float _x, float _y) {
    x = _x;
    y = _y;
  }
  public void update() {
    sz +=1;
    //creates the max size of the circle
    if (sz>50) {
      //kill = true;
      sz = 0;
    }
  }
  // circle
  public void display() {
    pushStyle();
    noFill();
    stroke(255);
    ellipse(x, y, sz, sz);
    popStyle();
  }
}








Minim minim;
AudioOutput out;

Sampler    beatSampler;
MoogFilter beatFilter;
Delay      beatDelay;

Sampler    singleSampler;
Gain       singleSamplerGain;

FilePlayer ambient;
Gain       ambientGain;
MoogFilter ambientFilter;
Flanger    ambientFlanger;

FilePlayer loop1;
Gain       loop1Gain;
MoogFilter loop1Filter;

FilePlayer loop3;
Gain       loop3Gain;

Oscil LFO;


float testy;
float testx;

boolean playBeatSample;
boolean playSingleSample; 

float beatDelayTime          = 0.4f;
float beatFilterFreq         = 500;

float ambientFilterFreq      = 800;
float ambientGainValue       = -5;

float singleSamplerGainValue = -20;

float loop1GainValue         = -20;
float loop1FilterFreq        = 200;
float loop1FilterFreqMin     = 200;
float loop1FilterFreqMax     = 2000;

float LFOFreq                = 5;
float LFOFreqMin             = 1;
float LFOFreqMax             = 30;

float loop3GainValue         = -20;
float loop3GainValueMin      = -10;
float loop3GainValueMax      = 10;
float loop3GainCurve         = 0.99f;

boolean beatTap = false;
boolean singleSample = false;
float pingbeatDelay;
float weatherdata;
float coordinateSurface;
float userQty;


public void soundSetup() {
  //size(300, 300, P3D);
  minim = new Minim(this);
  out = minim.getLineOut();

  beatSampler = new Sampler("claveBeat.wav", 10, minim);
  singleSampler = new Sampler("bass.wav", 10, minim);
  ambient = new FilePlayer(minim.loadFileStream("ambientLoop.wav"));
  loop1 = new FilePlayer(minim.loadFileStream("testloop.wav"));
  loop3 = new FilePlayer(minim.loadFileStream("loop3.wav"));

  //Gain
  ambientGain = new Gain(0.f);
  singleSamplerGain = new Gain(0.f);
  loop1Gain = new Gain(0.f);
  loop3Gain = new Gain(0.f);
  ambientGain.setValue(ambientGainValue);
  loop1Gain.setValue(loop1GainValue);
  singleSamplerGain.setValue(singleSamplerGainValue);

  //Flanger
  ambientFlanger = new Flanger( 1, // beatDelay length in milliseconds ( clamped to [0,100] )
    0.001f, // lfo rate in Hz ( clamped at low end to 0.001 )
    1, // beatDelay depth in milliseconds ( minimum of 0 )
    0.f, // amount of feedback ( clamped to [0,1] )
    0.7f, // amount of dry signal ( clamped to [0,1] )
    0.3f    // amount of wet signal ( clamped to [0,1] )
    );

  //beatDelays
  beatDelay = new Delay(beatDelayTime, 0.8f, true, true );

  //Filter
  beatFilter = new MoogFilter(ambientFilterFreq, 0.9f);
  ambientFilter= new MoogFilter(ambientFilterFreq, 0.7f); 
  loop1Filter= new MoogFilter(loop1FilterFreq, 0.3f); 

  //LFOs
  LFO = new Oscil(1, 2f, Waves.SQUARE);

  //routing
  beatSampler.patch(beatDelay).patch(beatFilter).patch(out);
  singleSampler.patch(singleSamplerGain).patch(out);
  ambient.patch(ambientGain).patch(ambientFlanger).patch(out);
  loop1.patch(loop1Gain).patch(loop1Filter).patch(out);
  loop3.patch(loop3Gain).patch(out);

  //playSounds
  playAmbientLoop();
  loop1Gain.setValue(-20);
  loop1.loop();
  loop3.loop();
}


public void updateSoundParameters() {
  if (playBeatSample) {
    playRhythm();
  }
  if (playSingleSample) {
    playSingleSample();
  }

  beatDelay.setDelTime(beatDelayTime);
  loop1Filter.frequency.setLastValue(loop1FilterFreq);
  ambientFlanger.rate.setLastValue(LFOFreq);
  loop3Gain.setValue(loop3GainValue);
}
public void playRhythm() {
  beatFilter.frequency.setLastValue(constrain(beatFilter.frequency.getLastValue()+random(-500, 500), 1000, 2000));
  beatSampler.trigger();
}

public void playSingleSample() {
  singleSampler.trigger();
}

public void playAmbientLoop() {
  ambient.loop();
}

public void valueParsing() {
  playBeatSample = beatTap;
  playSingleSample = singleSample;
  beatDelayTime = map(pingbeatDelay, 0, 1, 0, 0.4f); //real vlaues??
  loop1FilterFreq = map(weatherdata, 0, 1, loop1FilterFreqMin, loop1FilterFreqMax);
  LFOFreq = map(userQty, 0, 1, LFOFreqMin, LFOFreqMax); //>>LFO Speed
  loop3GainValue = loop3GainValue*loop3GainCurve+map(coordinateSurface, 0, 1, loop3GainValueMin, loop3GainValueMax)*(1-loop3GainCurve);
  playSingleSample = singleSample;
}

  public void settings() {  size(500, 500, FX2D); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "Satellite_3_0" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
