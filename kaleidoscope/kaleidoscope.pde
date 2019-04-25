Cluster cluster;
int numSlices = 6;
float radius = 180;
float gridWidth;
float gridHeight;
boolean isPaused = false;
boolean showTexture = false;
boolean showLines = false;
int axisMode = 1;
float speedMod = 1;
boolean darkStroke = true;
float texWidth; 
float texHeight;
float uv0, uv1;
float angleStep = 0.0;
 
float satMod = 0;
 
import processing.serial.*; 
Serial myPort;
 
void setup()
{
  size(1366, 700, P3D);
  colorMode(HSB);
  background(0);
  textureMode(NORMAL);
 
  angleStep = radians(360/numSlices);
  calculateGrid();
  cluster = new Cluster();
  
 printArray(Serial.list());
  myPort = new Serial(this, Serial.list()[0], 115200);

}
 
void draw()
{ 
  while (myPort.available() > 0) {
    String inBuffer = trim(myPort.readString()); 
    
    if (inBuffer != null) {
        if (inBuffer.equals("A") == true) {
          println(inBuffer);
      
          randomize();
        }
        if (inBuffer.equals("B") == true) {
          println(inBuffer);
      
          cluster.randomizeColor();
        }
        if (inBuffer.equals("AB") == true) {
          println(inBuffer);
      
         cycleAxisMode(); 
        }
    }
    
  }
  
  background(0);
  if (showLines) stroke(0);
  else noStroke();
 
  cluster.update();
 
  if (showTexture) image(cluster.tex, width/2-cluster.pg.width/2, height/2-cluster.pg.height/2);
  else drawHexGrid();
}
 
void randomize()
{
  axisMode = floor(random(0, 3));
 
  int r = floor(random(0, 3));
  switch (r)
  {
  case 0:
  radius = 90;
  break;
 
  case 1:
  radius = 120;
  break;
 
  case 2:
  radius = 180;
  break;
 
    default:
      break;
  }
 
  calculateGrid();
  cluster.createParts();
}
 
void drawHexGrid()
{ 
  int xCount = width/((int)gridWidth) + 1;
  int yCount = height/((int)gridHeight) + 1;
  float xOffset;
 
  for (int x=0; x<xCount; x++)
  {
    for (int y=0; y<yCount; y++)
    {
      if (y%2 == 0) xOffset = 0;
      else xOffset = gridWidth/2;
 
      pushMatrix();
      translate(x*gridWidth+xOffset, y*gridHeight, 0);
      rotateZ(angleStep/2);
 
      switch (axisMode)
      {
      case 0:
        drawHex1();
        break;
 
      case 1:
        drawHex2();
        break;
 
      case 2:
        drawHex3();
        break;
 
      default:
        break;
      }
 
      popMatrix();
    }
  }
}
 
void drawHex1()
{
  beginShape(TRIANGLE_FAN);
  texture(cluster.tex);
  vertex(0, 0, 0, 0.5, 1);
 
  for (int i=0; i<6; i++)
  {
    float x1 = cos(angleStep*i) * radius;
    float y1 = sin(angleStep*i) * radius;
    float x2 = cos(angleStep*(i+1)) * radius;
    float y2 = sin(angleStep*(i+1)) * radius;
 
    if (i%2 == 0)
    {
      vertex(x1, y1, 0, uv0, 0);
      vertex(x2, y2, 0, uv1, 0);
    } else
    {
      vertex(x1, y1, 0, uv1, 0);
      vertex(x2, y2, 0, uv0, 0);
    }
  }
 
  endShape();
}
 
void drawHex2()
{
  beginShape(TRIANGLE_FAN);
  texture(cluster.tex);
  vertex(0, 0, 0, 0.5, 1);
 
  for (int i=0; i<numSlices; i++)
  {
    float x1 = cos(angleStep*i) * radius;
    float y1 = sin(angleStep*i) * radius;
    float x3 = cos(angleStep*(i+1)) * radius;
    float y3 = sin(angleStep*(i+1)) * radius;
    float x2 = (x1 + x3) / 2;
    float y2 = (y1 + y3) / 2;
 
    vertex(x1, y1, 0, uv0, 0);
    vertex(x2, y2, 0, uv1, 0);
    vertex(x3, y3, 0, uv0, 0);
  }
 
  endShape();
}
 
void drawHex3()
{
  beginShape(TRIANGLE_FAN);
  texture(cluster.tex);
  vertex(0, 0, 0, 0.5, 1);
 
  for (int i=0; i<numSlices; i++)
  {
    float x1 = cos(angleStep*i) * radius;
    float y1 = sin(angleStep*i) * radius;
    float x5 = cos(angleStep*(i+1)) * radius;
    float y5 = sin(angleStep*(i+1)) * radius;
    float x3 = (x1 + x5) / 2;
    float y3 = (y1 + y5) / 2;
    float x2 = (x1 + x3) / 2;
    float y2 = (y1 + y3) / 2;
    float x4 = (x3 + x5) / 2;
    float y4 = (y3 + y5) / 2;
 
    vertex(x1, y1, 0, uv0, 0);
    vertex(x2, y2, 0, uv1, 0);
    vertex(x3, y3, 0, uv0, 0);
    vertex(x4, y4, 0, uv1, 0);
    vertex(x5, y5, 0, uv0, 0);
  }
 
  endShape();
}
 
void calculateGrid()
{
  float angle = radians(360/numSlices/2);
  float b = radius * cos(angle);
  gridWidth = b * 2;
  float a = sqrt(radius*radius - b*b);
  gridHeight = radius + a;
 
  texHeight = b;
  texWidth = a*2;
 
  switch (axisMode)
  {
  case 0:
    uv0 = 0;
    uv1 = 1;
    break;
 
  case 1:
    uv0 = 0.25;
    uv1 = 0.75;
    break;
 
  case 2:
    uv0 = 0.375;
    uv1 = 0.625;
    break;
 
  default:
    break;
  }
}
 
void cycleAxisMode()
{
  axisMode++;
  if (axisMode > 2) axisMode = 0;
  calculateGrid();
}
 
void cycleZoom()
{
  switch ((int)radius)
  {
  case 90:
    radius = 180;
    break;
 
  case 120:
    radius = 90;
    break;
 
  case 180:
    radius = 120;
    break;
 
  default:
    radius = 120;
    break;
  }
  calculateGrid();
}
 
void mousePressed()
{
   randomize();
}
 
void keyPressed()
{
  if (key == ' ') isPaused = !isPaused;
  if (key == 't') showTexture = !showTexture;
  if (key == 'g') showLines = !showLines;
  if (key == 'c') cluster.randomizeColor();
  if (key == 'a') cycleAxisMode();
  if (key == 'z') cycleZoom();
  if (key == 'r') cluster.createParts();
  if (key == '=') speedMod *= 1.2;
  if (key == '-') speedMod *= 0.8;
  if (key == 'l') darkStroke = !darkStroke;
}
 
class Cluster
{
  PGraphics pg;
  PImage tex;
  int numParts = 40;
  Part[] allParts;
 
  Cluster()
  {
    pg = createGraphics((int)texWidth,(int)texHeight);
    pg.colorMode(HSB);
    pg.noSmooth();
 
    createParts();
    update();
  }
 
  void update()
  {
    pg.beginDraw();
    updateParts(); 
    pg.endDraw();  
    tex = pg.get();
  }
 
  void createParts()
  {
    allParts = new Part[numParts];
 
    for (int i=0; i<numParts; i++)
    {
      allParts[i] = new Part(pg);
    }
  }
 
  void updateParts()
  {
    pg.ellipseMode(CORNER);
    pg.background(0);
    pg.strokeWeight(0.5);
 
    for (int i=0; i<numParts; i++)
    {
      allParts[i].update();
    }
  }
 
  void randomizeColor()
  {
    for (int i=0; i<numParts; i++)
    {
      allParts[i].randomizeColor();
    }
  }
}
 
class Part
{
  PGraphics pg;
  int age;
  int numVectors = 10;
  PVector[] v;
  float x, y;
  float rot, rotSpeed;
  float scale, scaleOsc, scaleOscSpeed;
  float hue, sat, bright;
  float hueSpeed;
  float satOsc, satOscSpeed;
  float brightOsc, brightOscSpeed;
 
  Part(PGraphics _pg)
  {
    pg = _pg;
    v = new PVector[numVectors];
    init();
    scaleOsc = random(100);
    move();
  }
 
  void init()
  {
    age = 0;
    x = random(0, pg.width);
    y = random(0, pg.height);
    rot = random(radians(360));
    float r = random(0.002, 0.005);
    rotSpeed = r;
    if (r > 0.5) rotSpeed *= -1;
    scale = 0;
    scaleOsc = 0;
    scaleOscSpeed = random(0.002, 0.004);
    randomizeColor();
 
    for (int i=0; i<numVectors; i++) {
      v[i] = new PVector(random(-pg.width, pg.width), random(-pg.height, pg.height));
    }
  }
 
  void randomizeColor()
  {
    hue = random(255);
    // send the value of hue to the arduino to color the LEDS
    // the same color
    hueSpeed = random(0.01, 0.2);
 
    satOsc = random(100);
    satOscSpeed = random(0.001, 0.003);
    sat = sin(satOsc);
    sat = map(sat, -1, 1, 0, 255);
 
    brightOsc = random(100);
    brightOscSpeed = random(0.001, 0.003);
    bright = sin(brightOsc);
    bright = map(bright, -1, 1, 0, 255);
  }
 
  void update()
  {
    if (!isPaused) move();
    render();
  }
 
  void move()
  {
    age++;
 
    rot += rotSpeed * speedMod;
    scaleOsc += scaleOscSpeed * speedMod;
    scale = sin(scaleOsc);
    if (age > 100 && abs(scale) < 0.01) init();
 
    hue += hueSpeed;
    satOsc += satOscSpeed;
    brightOsc += brightOscSpeed;
    sat = sin(satOsc);
    sat = map(sat, -1, 1, 0, 255);
    bright = sin(brightOsc);
    bright = map(bright, -1, 1, 0, 255);
  }
 
  void render()
  {
    if (darkStroke) pg.stroke(0);
    else pg.stroke(255);
 
    pg.pushMatrix();
    pg.fill(hue%255, sat, bright, 255);
    pg.translate(x, y);
    pg.rotate(rot);
    pg.scale(scale, scale);
    pg.beginShape();
    pg.vertex(v[0].x, v[0].y);
    pg.bezierVertex(v[1].x, v[1].y, v[2].x, v[2].y, v[3].x, v[3].y);
    pg.bezierVertex(v[4].x, v[4].y, v[5].x, v[5].y, v[6].x, v[6].y);
    pg.bezierVertex(v[7].x, v[7].y, v[8].x, v[8].y, v[9].x, v[9].y);
    pg.vertex(v[0].x, v[0].y);
    pg.endShape();
    pg.popMatrix();
  }
}
