/**
 * COMPUTAÇÃO E REPRESENTAÇÃO GRÁFICA - UFES - 2020/1
 * HERICK LIMA NUNES
 * RELÓGIO ORBITAL 3D
 * Este relógio consiste em 3 modos:
 * Modo 1: relógio orbital plano (Pressione 1 para ativar | Ativado por padrão)
 * Modo 2: relógio orbital estelar contido em cubo (Pressione 2 para ativar e mouse esquerdo para alterar as órbitas)
 * Modo 3: reógio orbital estelar universal (rodeado de estrelas | Pressione 3 para ativar e mouse esquerdo para alterar órbitas)
 * Todos os modos: manter botão direito pressionado para obter rotação no eixo Y.
 */

import processing.sound.*;
SoundFile song;

// cores das orbitas de cada ponteiro
final color COR_MLS = color(255,255,0);
final color COR_SEG = color(255,20,147);
final color COR_MIN = color(173,255,47);
final color COR_HOR = color(0,255,255);

final float FREQ = 6; // constante de frequencia de rotação dos planetas

// modos do relógio
final int START  = 1;
final int CUBE   = 2;
final int FULL   = 3;

float centerX, centerY, centerZ;

// variaveis referentes à nuvem de estrelas 
int qtcube = 400; // quantidade de estrelas
int qtfull = 2000;
float[] px = new float[qtcube];
float[] py = new float[qtcube];
float[] pz = new float[qtcube];
float[] px2 = new float[qtfull];
float[] py2 = new float[qtfull];
float[] pz2 = new float[qtfull];

// ângulos de percorrência dos arcos ponteiros relativos ao tempo atual
float millisAngle;
float secondAngle;
float minuteAngle;
float hourAngle;

// variáveis dos angulos de órbita dos planetas
float angleS = 0, angleM = 0, angleH = 0;

// instâncias de cada órbita
Orbit secOrbit, minOrbit, horOrbit, milsOrbit;

float curve = 0, alpha = 100, alpha2 = 0;
int mode = 1, k = 0;
boolean decay = false, run=false;
void setup() {
  fullScreen(P3D);
  
  centerX = width/2;
  centerY = height/2;
  centerZ = 0;
  
  // populando nuvem de estrelas
  for(int i = 0; i<qtcube; i++) {
    px[i] = random(-175, 175);
    py[i] = random(-175, 175);
    pz[i] = random(-175, 175);   
  }
  
  for(int i = 0; i<qtfull; i++) {
    px2[i] = random(-width, width);
    py2[i] = random(-height, height);
    pz2[i] = random(-500, 500);
  }
  
  // instanciando órbitas
  milsOrbit = new Orbit(PI/5, 320, 150, 0, COR_MLS);
  secOrbit = new Orbit(PI/3, 300, 150, angleS, COR_SEG);
  minOrbit = new Orbit(PI/4, 280, 140, angleM,  COR_MIN);
  horOrbit = new Orbit(PI/6, 260, 130, angleH, COR_HOR);
  
  song = new SoundFile(this, "gaze.mp3");
  song.play();
}

void draw() {
  background(0);
  translate(centerX, centerY, centerZ);
  int hr; 
  if(hour()== 00) hr = 23;
  else hr = hour()-1;
  int mn = minute();
  int sc = second();
  int ms = millis();
  
  millisAngle = map(ms % 1000, 0, 1000, 0, TWO_PI);
  secondAngle = map(sc, 0, 60, 0, TWO_PI);
  minuteAngle = map(mn, 0, 60, 0, TWO_PI);
  hourAngle   = map(hr % 12, 0, 12, 0, TWO_PI);
  
  stroke(255);
  textSize(28);
  fill(255);
  text(nf(hr, 2) + ':' + nf(mn, 2) + ':' + nf(sc, 2), -60, 0);
  
  noFill();
  rotate(-HALF_PI);
  rotateX(radians(mouseY));
  if (mousePressed && mouseButton == RIGHT) rotateY(radians(mouseX));
  
  if (mode == CUBE) {
    stroke(100, alpha2);
    strokeWeight(5);
    box(350);
    drawStars(k);
    if (k < qtcube) k++;
    if (alpha2 < 200) alpha2 += .5;
  } 
  else if (mode == FULL) {
    drawStars(k);
    if (k < qtfull) k++;
  } else {
   
  }
    
  secOrbit.draw(secondAngle, FREQ);
  minOrbit.draw(minuteAngle, FREQ-0.5);
  horOrbit.draw(hourAngle, FREQ-1);
  milsOrbit.millis(millisAngle);
  
 }
 
void mousePressed() {
   if (mode != START && mouseButton == LEFT) decay = !decay;
   
 }
 
void keyPressed() {
  if (key == '1') {
    mode = START;
  }
  else if (key == '2') mode = CUBE;
  else if (key == '3') mode = FULL;
  k=0;
}
 
void drawStars(int num) {
  if (random(0, 1) == 1)
     stroke(color(255,0,0));
  else stroke(255);
   strokeWeight(2);
    for(int i = 0; i<num; i++) {
      if(mode == CUBE) point(px[i]+random(-1, 1), py[i]+random(-1, 1), pz[i]+random(-1, 1));
      else point(px2[i]+random(-1, 1), py2[i]+random(-1, 1), pz2[i]+random(-1, 1));
    }
 }
 
 public class Orbit {
    private float rotateAngleY;
    private float dimension;
    private float pointOrbitRadius;
    private float pointOrbitAngle;
    private color colour;

  public Orbit(float rotateAngleY, float dimension, float pointOrbitRadius, float pointOrbitAngle, color colour) {
    this.rotateAngleY = rotateAngleY;
    this.dimension = dimension;
    this.pointOrbitRadius = pointOrbitRadius;
    this.pointOrbitAngle = pointOrbitAngle;
    this.colour = colour;
  }
  
  private void setPlanets(float frequency, color colour) {
      pushMatrix();
      stroke(colour, 255);
      float offsx = sin(radians(pointOrbitAngle))*pointOrbitRadius;
      float offsy = cos(radians(pointOrbitAngle))*pointOrbitRadius;
      translate(offsx, offsy, 0);
      sphere(1);
      popMatrix();
      noFill();
      pointOrbitAngle += frequency;
  }
  
  public void draw(float pathAngle, float frequency) {
      strokeWeight(8);
      if (decay) {
          if (curve<rotateAngleY) {
            curve += radians(TWO_PI/60);
            alpha += .35;
          }
      } else {
          if (curve>0) {
            curve -= radians(TWO_PI/60);
            alpha -= .35;
          }
      }
      rotateY(curve);
      stroke(colour, alpha);
      arc(0, 0, dimension, dimension, 0, pathAngle);
      setPlanets(frequency, this.colour);
  }
  
  public void millis(float angle) {
    strokeWeight(6);
    noFill();
    if (decay) {
      if (curve < PI/5) { 
        curve += radians(TWO_PI/60);
      }
      rotateX(curve);
    } else {
      if (curve > 0) {
        curve -= radians(TWO_PI/60);
      }
    }
    rotateY(curve);
    stroke(COR_MLS, alpha);
    arc(0, 0, 320, 320, 0, angle);
  }
}
 
 
 
