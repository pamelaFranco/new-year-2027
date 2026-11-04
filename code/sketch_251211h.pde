// Visualizador Neuro-Indie: Filtrado Cromático Puro + Transición 2026 -> 2027
PImage brainImg;
ArrayList<Particle> particles;
ArrayList<TextNode> textNodes;
ArrayList<Spark> sparks;

PFont mainFont;
PFont hudFont;

float pulseRadius = 0;
boolean pulsing = true;
boolean yearChanged = false;

// CONTROL DE GRABACIÓN
boolean guardarVideo = true; 

void setup() {
  size(800, 800);
  surface.setTitle("Cristalización 2026 -> 2027");
  
  background(8, 10, 15);
  
  mainFont = createFont("Consolas", 46, true);
  hudFont = createFont("Consolas", 11, true);
  
  brainImg = loadImage("axial_brain.jpeg"); 
  brainImg.resize(680, 680);
  
  // 1. FILTRADO CROMÁTICO: ELIMINA LA MALLA Y EL CASLEJO GRIS EXTERIOR
  brainImg.format = ARGB;
  brainImg.loadPixels();
  for (int i = 0; i < brainImg.pixels.length; i++) {
    color c = brainImg.pixels[i];
    float r = red(c);
    float g = green(c);
    float b = blue(c);
    
    float maxC = max(r, max(g, b));
    float minC = min(r, min(g, b));
    float colorDiff = maxC - minC; // Variación entre canales de color
    
    // Si es gris/malla (colorDiff bajo) o blanco/claro (maxC y minC altos) -> Eliminar
    if (colorDiff < 24 || (r > 195 && g > 195 && b > 195)) {
      brainImg.pixels[i] = color(0, 0); // Transparente
    } else {
      float alphaVal = map(colorDiff, 24, 45, 120, 255);
      alphaVal = constrain(alphaVal, 0, 255);
      brainImg.pixels[i] = color(r, g, b, alphaVal);
    }
  }
  brainImg.updatePixels();
  
  particles = new ArrayList<Particle>();
  textNodes = new ArrayList<TextNode>();
  sparks = new ArrayList<Spark>();
  
  // 2. PARTÍCULAS SOLO EN LAS FIBRAS DE TRACTOGRAFÍA REAL
  int step = 3; 
  for (int x = 0; x < brainImg.width; x += step) {
    for (int y = 0; y < brainImg.height; y += step) {
      color c = brainImg.pixels[x + y * brainImg.width];
      if (alpha(c) > 60) {
        float posX = (width - brainImg.width)/2 + x;
        float posY = (height - brainImg.height)/2 + y - 30;
        particles.add(new Particle(posX, posY, c));
      }
    }
  }
  
  // Posicionamiento de los 4 dígitos
  char[] digitos = {'2', '0', '2', '6'};
  float spacing = 85;
  float startX = width/2.0 - (3 * spacing) / 2.0;
  for (int i = 0; i < 4; i++) {
    textNodes.add(new TextNode(digitos[i], startX + i * spacing, height - 65));
  }
}

void draw() {
  fill(8, 10, 15, 80);
  rect(0, 0, width, height);

  float centerX = width / 2.0;
  float centerY = height / 2.0 - 30;

  float clarity = map(pulseRadius, 0, 380, 0, 230);
  clarity = constrain(clarity, 0, 230);

  // Renderizado de la tractografía recortada sin bordes grises
  pushMatrix();
  tint(255, clarity);
  image(brainImg, (width - brainImg.width)/2, (height - brainImg.height)/2 - 30);
  popMatrix();

  // Control de la onda de energía
  if (pulsing) {
    pulseRadius += 8.5;
    
    if (pulseRadius > 350 && !yearChanged) {
      yearChanged = true;
      textNodes.get(3).changeChar('7'); // Cambia a 2027
      
      PVector posFinal = textNodes.get(3).pos;
      for (int i = 0; i < 45; i++) {
        sparks.add(new Spark(posFinal.x, posFinal.y));
      }
    }

    if (pulseRadius > width * 0.85) {
      pulseRadius = 0;
      pulsing = false;
    }
  } else if (frameCount % 90 == 0) {
    pulsing = true;
    pulseRadius = 0;
    yearChanged = false;
    textNodes.get(3).changeChar('6');
  }

  // Partículas
  for (Particle p : particles) {
    p.update(centerX, centerY, pulseRadius, clarity);
    p.display();
  }

  // Chispas
  for (int i = sparks.size() - 1; i >= 0; i--) {
    Spark s = sparks.get(i);
    s.update();
    s.display();
    if (s.isDead()) sparks.remove(i);
  }

  // Tipografía
  drawDynamicText();

  // Guardar secuencia
  if (guardarVideo) {
    saveFrame("secuencia_frames/frame-######.png");
    if (frameCount >= 240) {
      println("-> Renderizado pulido completado en /secuencia_frames/");
      noLoop();
    }
  }
}

void mousePressed() {
  pulsing = true;
  pulseRadius = 0;
  yearChanged = false;
  textNodes.get(3).changeChar('6');
}

void drawDynamicText() {
  textAlign(CENTER, CENTER);
  textFont(hudFont);
  
  if (yearChanged) {
    fill(0, 255, 180, 220);
    text("— SYNAPSE LINK :: ESTABLISHED 2027 —", width/2, height - 120);
  } else {
    fill(130, 155, 185, 170);
    text("— RE-WIRING NEURAL NETWORK —", width/2, height - 120);
  }

  textFont(mainFont);
  for (TextNode tn : textNodes) {
    tn.update(pulseRadius);
    tn.display();
  }
}

class TextNode {
  char character;
  PVector basePos;
  PVector pos;
  float glow = 0;
  float offset;

  TextNode(char c, float x, float y) {
    character = c;
    basePos = new PVector(x, y);
    pos = new PVector(x, y);
    offset = random(100);
  }

  void changeChar(char newC) {
    character = newC;
    glow = 255;
  }

  void update(float currentRadius) {
    pos.y = basePos.y + sin(frameCount * 0.05 + offset) * 2.2;
    pos.x = basePos.x + cos(frameCount * 0.03 + offset) * 1.0;

    float d = dist(width/2.0, height/2.0 - 30, pos.x, pos.y);
    if (pulsing && abs(d - currentRadius) < 35) {
      glow = 255;
    } else {
      glow *= 0.90;
    }
  }

  void display() {
    if (glow > 15) {
      stroke(0, 255, 200, glow * 0.7);
      strokeWeight(1.0);
      line(width/2, height/2 + 215, pos.x, pos.y - 25);
    }

    if (glow > 10) {
      fill(0, 240, 255, glow * 0.40);
      text(character, pos.x + 1, pos.y + 1);
      text(character, pos.x - 1, pos.y - 1);
    }

    if (character == '7') {
      fill(80, 255, 190);
    } else {
      fill(225 + glow * 0.1, 245, 255);
    }
    text(character, pos.x, pos.y);

    stroke(0, 255, 180, 100 + glow * 0.6);
    strokeWeight(1);
    line(pos.x - 3, pos.y - 30, pos.x + 3, pos.y - 30);
    line(pos.x, pos.y - 33, pos.x, pos.y - 27);
    
    noStroke();
    fill(0, 255, 180, 150 + glow);
    ellipse(pos.x, pos.y + 30, 3 + glow * 0.02, 3 + glow * 0.02);
  }
}

class Spark {
  PVector pos;
  PVector vel;
  float alpha = 255;
  color col;

  Spark(float x, float y) {
    pos = new PVector(x, y);
    vel = PVector.random2D().mult(random(3, 9));
    col = color(random(80, 255), 255, random(160, 255));
  }

  void update() {
    pos.add(vel);
    vel.mult(0.91);
    alpha -= 8;
  }

  void display() {
    noStroke();
    fill(col, alpha);
    ellipse(pos.x, pos.y, random(2, 4), random(2, 4));
  }

  boolean isDead() {
    return alpha <= 0;
  }
}

class Particle {
  PVector basePos;
  PVector pos;
  color col;
  float size;
  float offset;
  float speed;
  float activeGlow = 0;

  Particle(float x, float y, color c) {
    basePos = new PVector(x, y);
    pos = new PVector(x, y);
    col = c;
    size = random(1.8, 3.2);
    offset = random(100);
    speed = random(0.02, 0.04);
  }

  void update(float cx, float cy, float currentRadius, float clarity) {
    float jitter = map(clarity, 0, 200, 4.0, 0.2);
    float wave = sin(frameCount * speed + offset);
    pos.x = basePos.x + wave * jitter;
    pos.y = basePos.y + cos(frameCount * speed + offset) * jitter;

    float d = dist(cx, cy, pos.x, pos.y);
    if (abs(d - currentRadius) < 25) {
      activeGlow = 180;
    } else {
      activeGlow *= 0.92;
    }
  }

  void display() {
    noStroke();
    float alpha = map(sin(frameCount * 0.03 + offset), -1, 1, 90, 200) + activeGlow;
    fill(red(col) + activeGlow, green(col) + activeGlow, blue(col) + activeGlow, alpha);
    ellipse(pos.x, pos.y, size + (activeGlow > 10 ? 1.2 : 0), size + (activeGlow > 10 ? 1.2 : 0));
  }
}
