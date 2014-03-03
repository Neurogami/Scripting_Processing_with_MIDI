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


float CENTER_SCALNG_DEFAULT = 6.0;

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

 centerScaling = CENTER_SCALNG_DEFAULT;
 
 
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
/* 
 To get a nicer set off effects we will pretend that the screen is larger than it
 is we want to place an image in the middle but larger than what it would normally be
  Or just add a scaling factor and play wiht number

  Handlers for values 48 and above are meant for the QuNexus.
  The others are meant for the Launchpad.

         up     dn    <       >     sess    u1     u2   mixer       
       (104)  (105)  (106)  (107)  (108)  (109)  (110)  (111)       
                                                                    
       [  0]  [  1]  [  2]  [  3]  [  4]  [  5]  [  6]  [  7]  (  8)
       [ 16]  [ 17]  [ 18]  [ 19]  [ 20]  [ 21]  [ 22]  [ 23]  ( 24)
       [ 32]  [ 33]  [ 34]  [ 35]  [ 36]  [ 37]  [ 38]  [ 39]  ( 40)
       [ 48]  [ 49]  [ 50]  [ 51]  [ 52]  [ 53]  [ 54]  [ 55]  ( 56)
       [ 64]  [ 65]  [ 66]  [ 67]  [ 68]  [ 69]  [ 70]  [ 71]  ( 72)
       [ 80]  [ 81]  [ 82]  [ 83]  [ 84]  [ 85]  [ 86]  [ 87]  ( 88)
       [ 96]  [97]   [98]   [ 99]  [100]  [101]  [102]  [103]  (104)
       [112]  [113]  [114]  [115]  [116]  [117]  [118]  [119]  (120)


  The idea with the Launchpad is that pads in the first 3 rows and 5 cols
  are mapped as follows:

  Center button (middle col and row) puts an image in center full scaling.
   


The following tables of pre-calculated velocity values for normal use may also be helpful: 
Hex   Decimal   Colour  Brightness 
 0Ch  12        Off     Off 
 0Dh  13        Red     Low 
 0Fh  15        Red     Full 
 1Dh  29        Amber   Low 
 3Fh  63        Amber   Full 
 3Eh  62        Yellow  Full 
 1Ch  28        Green   Low 
 3Ch  60        Green   Full 

Values for flashing LEDs are: 
Hex  Decimal    Colour  Brightness 
 0Bh  11        Red     Full 
 3Bh  59        Amber   Full 
 3Ah  58        Yellow  Full 
 38h  56        Green  Full 
  

*/

void launchPadGreenLight(int channel, int note ) {
  println("Light up LP for ch " + channel + " and note " + note);
  launchpadOut.sendNoteOn(channel, note, 60); 
  delay(10);
  launchpadOut.sendNoteOff(channel, note, 0); 
}
void onGridNote8(int vel, int channel, String bus_name) {
  clearGridC();
 

}


void onGridNote104(int vel, int channel, String bus_name) {
   increaseCenterScaling();
}


void onGridNote105(int vel, int channel, String bus_name) {
   decreaseCenterScaling();
}


void onGridNote111(int vel, int channel, String bus_name) {
  resetCenterScaling();
}

void onGridNote16(int vel, int channel, String bus_name) {
   placeGif8x16(17, 6.0);
}

void onGridNote17(int vel, int channel, String bus_name) {
   placeGif8x16(19, 6.0);
}
void onGridNote18(int vel, int channel, String bus_name) {
   placeGifInCenter();
}

void onGridNote19(int vel, int channel, String bus_name) {
   placeGif8x16(23, 6.0);
}

void onGridNote20(int vel, int channel, String bus_name) {
   placeGif8x16(25, 6.0);
}

// Smaller
 void onGridNote0(int vel, int channel, String bus_name) {
   placeGif8x16(48, 2.5);
}

void onGridNote1(int vel, int channel, String bus_name) {
   placeGif8x16(51, 2.5);
}
void onGridNote2(int vel, int channel, String bus_name) {
   placeGif8x16(55, 2.5);
}

void onGridNote3(int vel, int channel, String bus_name) {
   placeGif8x16(58, 2.5);
}

void onGridNote4(int vel, int channel, String bus_name) {
   placeGif8x16(61, 2.5);
}

// Larger
 void onGridNote32(int vel, int channel, String bus_name) {
   placeGif8x16(0, 8.0);
}

void onGridNote33(int vel, int channel, String bus_name) {
   placeGif8x16(2, 8.0);
}
void onGridNote34(int vel, int channel, String bus_name) {
   placeGif8x16(4, 8.0);
}

void onGridNote35(int vel, int channel, String bus_name) {
   placeGif8x16(6, 8.0);
}

void onGridNote36(int vel, int channel, String bus_name) {
   placeGif8x16(8, 8.0);
}



void placeGif8x16(int index, float scaling ){
  gridCRows = 8;
  gridCCols = 16;
  gridCPointer = index;
  centerScaling = scaling;
  addToGridC();
  }

void increaseCenterScaling() {
  centerScaling += 0.2;
}


void decreaseCenterScaling() {
  centerScaling -= 0.2;
}

void resetCenterScaling() {
  centerScaling = CENTER_SCALNG_DEFAULT;
}
 
void placeGifInCenter() {  
  placeGif8x16(21, 6.0);
 }

void onGridNote48(int vel, int channel, String bus_name) {
placeGifInCenter();

}

void onGridNote50(int vel, int channel, String bus_name) {
  clearGridC();
}

void onGridNote49(int vel, int channel, String bus_name) {
 centerScaling -= 0.2;
}

void onGridNote51(int vel, int channel, String bus_name) {
  increaseCenterScaling();
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


