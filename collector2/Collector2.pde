// Collector2
// Made by Jacob Kloepper
// Last updated March 8, 2019

import ketai.ui.*;
import android.view.MotionEvent;
import ketai.sensors.*;
import ketai.camera.*;
KetaiGesture gesture;
KetaiSensor sensor;
KetaiCamera camera;

float x, y;
float w, h;

float theta;

int numOfParticles = 250;
float maxWidth = 9;
float maxHeight = 8.5;
int oobYmax;

int attractDistance = 500;
int initattractDistance = attractDistance;
float attractStrength = 0.97;
float explodeStrength = 1.05;

ArrayList<Particles> particles = new ArrayList<Particles>(numOfParticles);
PVector explosionCentre;

boolean isLongPress;

color backgroundColour = color(0);

void setup() {
  // Set up screen, library classes, bounds, and particles
  orientation(LANDSCAPE);
  fullScreen();

  gesture = new KetaiGesture(this);
  sensor = new KetaiSensor(this);
  sensor.start();
  camera = new KetaiCamera(this, 320, 240, 30);
  camera.setCameraID(0); // back facing

  oobYmax = 2*height;

  for (int i = 0; i < numOfParticles; i++) {
    setupParticles();
  }
}

void draw() {
  // Able to rotate particles
  pushMatrix();
  translate(width/2, height/2);
  rotate(theta);
  translate(-width/2, -height/2);

  // Can change bg colour
  background(backgroundColour);
  if (camera.isStarted()) {
    pushMatrix();
    translate(width/2, height/2);
    imageMode(CENTER); 
    image(camera, 0, 0, width*1.5, height*1.5);
    popMatrix();
  }

  // Display focus area
  pushStyle();
  noFill();
  strokeWeight(8);
  stroke(127, 127);
  ellipseMode(CENTER);
  ellipse(x, y, 100, 100);
  popStyle();

  // Object methods
  for (Particles p : particles) {
    if (p.isFalling) {
      p.fall();
    } else if (p.isAttracting) {
      focus(p);
    } else if (p.isExploding) {
      explode(p);
    } else if (p.isFlick) {
      flick(p);
    }

    // If the mouse is far from the particle and is not exploding, then the particle stops attracting and begins falling
    if (dist(x, y, p.x, p.y) > attractDistance && !p.isExploding) {
      p.isAttracting = false;
      p.isFalling = true;
    }

    // If the particle is attracting, not falling, and the mouse is not pressed, then the particle stops attracting.
    // Also, if the mouse is close to the particle at this moment, the particle explodes. Otherwise, the particle falls.
    if (p.isAttracting && !p.isFalling && !mousePressed) {
      p.isAttracting = false;

      if (dist(mouseX, mouseY, p.x, p.y) < attractDistance) {
        p.isExploding = true;
      } else {
        p.isFalling = true;
      }
    }
  }

  for (Particles p : particles) {
    // Always display and check particles
    if (p.x > - 360 && p.x < width+360 && p.y > -360 && p.y < height+360) {
      p.display();
    } else {
      resetParticles(p);
    }
  }
  if (!mousePressed) {
    isLongPress = false;
  }
  popMatrix();
}

///////////// MOTIONS //////////////////

// Particle travels to a point
void focus(Particles p) {
  p.x = lerp(x, p.x, attractStrength); // x
  p.y = lerp(y, p.y, attractStrength); // y
}

void explode(Particles p) {
  // Particle travels out from a point
  p.x = lerp(explosionCentre.x, p.x, explodeStrength);
  p.y = lerp(explosionCentre.y, p.y, explodeStrength);

  // Once the particle is far enough from the centre, stop travelling
  if (dist(explosionCentre.x, explosionCentre.y, p.x, p.y) > attractDistance) {
    p.isExploding = false;
    p.isFalling = true;
  }
}

// Particle travels to a point determined by flicking
void flick(Particles p) {
  p.x = lerp(x, p.x, attractStrength);
  p.y = lerp(y, p.y, attractStrength);

  // Display focus centre
  pushStyle();
  noStroke();
  fill(255, 40);
  ellipse(x, y, 25, 25);
  popStyle();

  if (dist(x, y, p.x, p.y) < 10) {
    p.isFlick = false;
    p.isFalling = true;
  }
}

/////////////// SETUP //////////////////////

void setupParticles() {
  x = random(-width, width);
  y = random(-height, height);
  w = random(maxWidth);
  h = random(maxHeight);

  // Create all particles
  particles.add(new Particles(x, y, w, h));
}

void resetParticles(Particles p) {
      p.reset();
}

///////////   KETAI   /////////////////////

// Toggle the camera by double tapping
void onDoubleTap(float x, float y) {
  if (camera.isStarted()) {
    camera.stop();
  } else {
    camera.start();
  }
}

// If the mouse is close to a particle and the mouse is pressed, the particle stops falling and exploding, and attracts.
// Also sets explosion centre for later
void onLongPress(float x, float y) {
  explosionCentre = new PVector(x, y);

  for (Particles p : particles) {
    if (dist(x, y, p.x, p.y) < attractDistance) {
      p.isAttracting = true;
      p.isFalling = false;
      p.isExploding = false;
    }
  }
  isLongPress = true;
}

// Increment x and y by the velocity (to 'shoot' it ahead)
// Particles will attract to the flick position if near the flick position, then fall.
void onFlick(float x, float y, float px, float py, float v) {
  x += v/5;
  y += v/5;

  for (Particles p : particles) {
    if (dist(x, y, p.x, p.y) < attractDistance) {
      p.isFalling = false;
      p.isFlick = true;
    }
  }
}

// The matrix rotates with the device on the z-axis
void onGyroscopeEvent(float x, float y, float z) {
  theta -= z/10;
}

void onAccelerometerEvent(float x, float y, float z) {
  // Shake particles by shaking the device violently
  if (x > 15 || y > 15 || z > 15) {
    for (Particles p : particles) {
      p.v = random(-10, 10);
    }
  }
}

// If you shine a light in the sensor, the background goes white
// And by darkening the sensor, the background returns to black.
void onLightEvent(float d) {
  if (d > 7000) {
    backgroundColour = color(255);
  }
  if (d < 10) {
    backgroundColour = color(0);
  }
}

// Camera function
void onCameraPreviewEvent() {
  camera.read();
}

void mousePressed() {
  // Updates the x and y values so that shapes on the rotated matrix can be properly interacted with (by clicking the unrotated screen)
  // Need to update in just mousePressed() as well.
  x = (-width/2+mouseX)*cos(theta) + (-height/2+mouseY)*sin(theta) + width/2;
  y = (-height/2+mouseY)*cos(theta) + (width/2-mouseX)*sin(theta) + height/2;
}

void mouseDragged() {
  // Updates the x and y values so that shapes on the rotated matrix can be properly interacted with (by clicking the unrotated screen)
  x = (-width/2+mouseX)*cos(theta) + (-height/2+mouseY)*sin(theta) + width/2;
  y = (-height/2+mouseY)*cos(theta) + (width/2-mouseX)*sin(theta) + height/2;

  // Run onLongPress() when dragging finger (this allows user to 'focus' without waiting
  if (isLongPress) {
    onLongPress(x, y);
  }
}

public boolean surfaceTouchEvent(MotionEvent event) {
  //call to keep mouseX and mouseY constants updated
  super.surfaceTouchEvent(event);
  //forward events"x: " + x + 
  return gesture.surfaceTouchEvent(event);
}
