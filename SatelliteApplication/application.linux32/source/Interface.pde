
ArrayList<PVector> coordinates = new ArrayList<PVector>();
ArrayList<Pulse> rings = new ArrayList<Pulse>();
PShape surface;
PGraphics surfaceGraphics;
PGraphics circles;
float maxDistance;
float minDistance;
float scaleValue;

void setupInterface() {

  smooth();
  frameRate(30);

  surface = createShape();
  surfaceGraphics = createGraphics(width, height);

  circles = createGraphics(width, height); //size of mask
}

void drawInterface() {
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
