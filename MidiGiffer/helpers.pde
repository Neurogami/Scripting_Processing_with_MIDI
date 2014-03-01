int RIGHT = 0;
int LEFT = 1;
int CENTER = 2;
float centerScaling = 3.0;

class RenderArgs {

  public color tint;
  public Gif  gif;

  public int numCols = 0;
  public int numRows = 0;
  public int slotIndex;

  RenderArgs(color t, Gif g, int nC, int nR, int idx ) {
    tint = t;   
    gif = g;
    numCols = nC;
    numRows = nR;
    slotIndex = idx;
  }

}


ArrayList<RenderArgs> renderR;
ArrayList<RenderArgs> renderL;
ArrayList<RenderArgs> renderC;

color[] globalTints  = {
  color(255,0,204), 
  color(255,255,255), 
  color(255,255,255), 
  color(255,255,0), 
  color(255,255,255),
  color(255,255,255), 
  color(255,128,0), 
  color(255,255,255), 
  color(128,255,0),
  color(0,0,255),
  color(255,255,255), 
  color(255,255,255), 
  color(255,128,0),
  color(255,255,255),
  color(128,255,0),
};

int globalTintIndex = 0;

void placeGifAt(Gif g, int leftOrRight, int numCols, int numRows, int slotIndex ) {

  int w = width/(numCols*2);
  int h = height/numRows;
  int count = 0;
  int colOffset = 0;
  float scale = 1.0;

  if (leftOrRight == CENTER  ) {
    w = width/numCols;
    scale = centerScaling;

  } else {
    if (leftOrRight == RIGHT ) { colOffset  = width/2; }
  }
  for(int y=0; y<numRows; y++) {
    for(int x=0; x<numCols; x++) {
      if (count == slotIndex) { image(g, x*w+colOffset , y*h, w*scale, h*scale); }
      count++;
    }

  }
}

color nextTint() {
  globalTintIndex++;
  globalTintIndex = globalTintIndex % globalTints.length;
  return globalTints[globalTintIndex];
}

int nextGifIndex() {
  gifIndex++;
  gifIndex %= maxGifs;
  return gifIndex;
}

