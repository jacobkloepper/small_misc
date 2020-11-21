class Particles {
  float x, y;
  float w, h; 
  float g;
  float v = 1;

  boolean isFalling = true;
  boolean isAttracting;
  boolean isExploding;
  boolean isFlick;

  color colour = color(0, 255, 102);

  Particles(float x, float y, float w, float h) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
  }

  void display() {
    pushStyle();

    stroke(0);
    fill(colour);
    ellipse(x, y, w, h);

    popStyle();
  }

  // based on orientation of screen (determined by theta in draw())
  void fall() {
    setGravity();
    v *= g;
    y += v;
  }

  void setGravity() {
    g = random(1.01, 1.0001);
  }

  void reset() {
    x = random(-width, width);
    y = random(-height, height);
    w = random(maxWidth);
    h = random(maxHeight);

    v = 1;
    isFalling = true;
  }
}