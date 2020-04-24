class Pulse {
  float x, y;
  float sz = 0, store_sz;

  Pulse(float _x, float _y) {
    x = _x;
    y = _y;
  }
  void update() {
    sz +=1;
    //creates the max size of the circle
    if (sz>50) {
      //kill = true;
      sz = 0;
    }
  }
  // circle
  void display() {
    pushStyle();
    noFill();
    stroke(255);
    ellipse(x, y, sz, sz);
    popStyle();
  }
}
