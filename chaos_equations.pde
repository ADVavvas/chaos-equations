/**
  Visualization of "chaos equations" in Processing (3.5.4)
  
  Inspired by CodeParade's chaos equations: https://www.youtube.com/watch?v=fDSIRXmnVvk
*/
import java.util.LinkedList;

float stepsPerFrame = 2;
float t = 0.001;
float t_start = -0.1;
float t_end = 0.15;
float plotX = 0;
float plotY = 0;
float dt = 0.0001;
float plotScale = 1;

boolean drawTrail = true;
int numOfParticles = 100;
int trailLength = 100;

PVector[] particles;
LinkedList<PVector>[] trailParticles;

float saturation = 0;
int hue = 0, brightness = 255;

void setup() {
  size(1000, 1000, P2D);
  stroke(255, 50);
  background(0);
  colorMode(HSB);
  strokeWeight(5);
  fill(0,20);
  
  t = t_start;
  
  particles = new PVector[numOfParticles];
  trailParticles = new LinkedList[numOfParticles];
  
  // Init each particle in the particles array
  for(int i = 0; i < numOfParticles; i++) {
    particles[i] = new PVector(0, 0);
  }
  
  // Init each LinkedList in trailParticles array
  for(int i = 0; i < numOfParticles; i++) {
     trailParticles[i] = new LinkedList();
  }
}


void draw() {
  // Update stroke saturation to visualize time better (saturation increases over time)
  stroke(hue,(int)saturation,brightness);
 
  // Step simulation stepsPerFrame times while the mouse is being clicked.
  if(mousePressed){
    for(int i = 0; i < stepsPerFrame; i++) {
      stepSimulation();
    }
  }
}

void stepSimulation() {
  // Clear canvas
  background(0);
  
  println(t);
  // Initialize position of the first particle 
  particles[0].x = t;
  particles[0].y = t;
  
  // Calculate the position of each particle and draw it
  for(int i=1;i<numOfParticles;i++) { 
    // Keep a copy of the old position of the particle (at t = t-dt) 
    PVector oldPoint = particles[i].copy();
    // Calculate the new position of the particle by applying the equation to the previous particle
    PVector newPoint = applyChaos(particles[i-1], t);
   
    // Update the array of particles
    particles[i] = newPoint;
    // Draw the new point
    stroke(255);
    drawPoint(particles[i]);
    
    // Draw the trails of the particles
    if(drawTrail) {
      // Remove excess trail
      if(trailParticles[i].size() >= trailLength) {
        trailParticles[i].remove(0);
      }
      // Add old position of current particle to the trail
      trailParticles[i].add(oldPoint);
      
      // Draw each particle in the trail
      int j = 0;
      // Use a foreach loop since we're using a LinkedList (O(n^2) if we use get() at each iteration). 
      for(PVector point : trailParticles[i]) {
        // Adjust the alpha of each point in the trail depending on how old it is
        // Oldest particles have less alpha, newers have more
        int alpha = (255/trailParticles[i].size()) * (j + 1);
        if(alpha <=0 ) alpha = 1;
        stroke(255, alpha);
        drawPoint(point);
        j++;
      }
    }
  }
  
  // Increment the time
  t += dt;
  // Reset if t has reached the maximum value
  if(t > t_end) {
    t = t_start;
  }  
}

/**
  Calculates the new point after applying the chaos equation.
  @param position The starting position (position of the previous particle).
  @param t        The current time.
  
  @return         A PVector of the position of the particle.
*/
PVector applyChaos(PVector position, float t) {
  float x = position.x;
  float y = position.y;
  
  // A few more equations for testing
  //float newX = -sq(x) + x * t + y;
  //float newY = sq(x) - sq(y) - sq(t)  - x*y - y*t - x + y;
  //float newX sq(t) - x * t - y;
  //float newY -sq(y) - sq(t) - x * y - x * t - y*t - x - t;
  
  float newX = sq(x) -x*t +y + t;
  float newY = sq(x) + sq(y) + sq(t) -x*t -x + y;

  return new PVector(newX, newY);
}

/**
  Calculates position of the particle of the screen.
  @param point A PVector containing the position of the particle in world space (particles start at (t, t) where -3>=t>=3.
  
  @return      A PVector of the position of the particle in screen space (x: [0, width], y: [0, height]).
*/
PVector toScreen(PVector point) {
  float s = plotScale * height/2;
  return new PVector(width/2 + (point.x - plotX) * s , height/2 + (point.y - plotY) * s);
}

/**
  Draws the point on screen only if it is within the screen bounds.
  @param point A PVector containing the position of the particle in world space.
*/
void drawPoint(PVector point) {
  point = toScreen(point);
  if(point.x < width && point.y < height && point.x > 0 && point.y > 0) {
    point(point.x, point.y);
  }
}
