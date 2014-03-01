/* 
   Effects that we want:
 * Full left
 * Full right
 * Some sort of "snake" effect where each time a note is played a new image is 
 added to a path and if the path is more than N long the last image is removed.

 We might be able to combine an "add to grid path" with a "clear grid" hnadler.
 Or keep using velocity
 */

int gridL4x4Pointer = 15;
int gridR4x4Pointer = 0;

int gridCPointer = 0;
int gridCRows = 3;
int gridCCols = 3;

void clearGridC() {
  renderC.clear();  
}

void addToGridC() {

  if (gridCPointer > (gridCRows*gridCCols)-1) {
    renderC.clear();  
    gridCPointer = 0;
  }

  renderC.add(new RenderArgs( nextTint(),  gifs[nextGifIndex()], gridCCols, gridCRows, gridCPointer) );
  gridCPointer++;
}


void addToGridCReverse() {

  if (gridCPointer < 0 ) {
    renderC.clear();  
    gridCPointer = (gridCRows*gridCCols)-1;
  }

  renderC.add(new RenderArgs( nextTint(),  gifs[nextGifIndex()], gridCCols, gridCRows, gridCPointer) );
  gridCPointer--;
}



void addToGridFullC() {
 gridCRows = 3;
 gridCCols = 6;

 centerScaling = 1.0;
 
 
if (gridCPointer > (gridCRows*gridCCols)-1) {
    renderC.clear();  
    gridCPointer = 0;
  }

  renderC.add(new RenderArgs( nextTint(),  gifs[nextGifIndex()], gridCCols, gridCRows, gridCPointer) );
  gridCPointer++;
}


void addToGridR4x4() {

  if (gridR4x4Pointer > 15) {
    renderR.clear();  
    gridR4x4Pointer = 0;
  }

  renderR.add(new RenderArgs( nextTint(),  gifs[nextGifIndex()], 4, 4, gridR4x4Pointer) );
  gridR4x4Pointer++;
}


void addToGridL4x4() {

  if (gridL4x4Pointer < 0) {
    renderL.clear();  
    gridL4x4Pointer = 15;
  }

  renderL.add(new RenderArgs( nextTint(),  gifs[nextGifIndex()], 4, 4, gridL4x4Pointer) );
  gridL4x4Pointer--;
}

void onNote48(int vel, int channel, String bus_name) {
  if (vel > 0) {
    switch(channel) {
      case 1: 
        addToGridL4x4();
        break;
      case 2: 
        addToGridR4x4();
        break;
    }
  }
}


void onNote60(int vel,  int channel, String bus_name) {
  if (vel > 0) {
    addToGridR4x4();
    //if (vel % 20 < 10 ) { renderL.clear();  }
    // println("* * * v: " + vel + "; sqrt: " + (int)sqrt(vel));
    //renderL.add(new RenderArgs( nextTint(),  gifs[nextGifIndex()], 3, 3, (int)sqrt(vel) - 3 ) );
    return;
  }


}

void onNote50(int vel, int channel, String bus_name) {
  if (vel > 120 ) { 
    renderR.clear();  
    renderR.add(new RenderArgs( nextTint(), gifs[nextGifIndex()], 2, 3, 3) );
    return;
  }

  if (vel > 0 ) { 
    renderR.clear();  
    renderR.add(new RenderArgs( nextTint(), gifs[nextGifIndex()], 1, 1, 0) );
    return;
  }
}

void onNote52(int vel, int channel, String bus_name) {
  if (vel > 60 ) {
    renderL.clear();  
    renderL.add(new RenderArgs( nextTint(),  gifs[nextGifIndex()], 2, 2, 2) );
    return;
  }
  if (vel > 0 ) {
    renderL.clear();  
    renderL.add(new RenderArgs( nextTint(),  gifs[nextGifIndex()], 4, 4, 5) );
  }
}


/* Grid note handlers */
// To get a nicer set off effects we will pretend that the screen is larger than it
// is we want to place an image in the middle but larger than what it would normally be
//  Or jst add a scaling factor and play wiht number
void onGridNote48(int vel, int channel, String bus_name) {
  gridCRows = 8;
  gridCCols = 16;

  gridCPointer = 21;
  centerScaling = 6.0;
  addToGridC();

}

void onGridNote50(int vel, int channel, String bus_name) {
  clearGridC();
}

void onGridNote49(int vel, int channel, String bus_name) {
 centerScaling -= 0.2;
}

void onGridNote51(int vel, int channel, String bus_name) {
  centerScaling += 0.2;
}

void onGridNote52(int vel,  int channel, String bus_name) {
  if (vel > 0) { addToGridFullC(); return; }
}

void onGridNote53(int vel,  int channel, String bus_name) {
  if (vel > 0) { addToGridCReverse(); return; }
}




/*



   If you hand-edit velocity in Renoise, entering 1,2,3, ... as
   you move down the notes, you get these in P5:¹


   Bus 01. Internal MIDI: Note 48, vel 16
   Bus 01. Internal MIDI: Note 48, vel 32
   Bus 01. Internal MIDI: Note 48, vel 48
   Bus 01. Internal MIDI: Note 48, vel 64
   Bus 01. Internal MIDI: Note 48, vel 80
   Bus 01. Internal MIDI: Note 48, vel 96
   Bus 01. Internal MIDI: Note 48, vel 112
   Bus 01. Internal MIDI: Note 48, vel 127

   Basically. a Renoise vel of 10 gives you a P5 of 16. Seems to be some poer of 2 thing here.

 */


