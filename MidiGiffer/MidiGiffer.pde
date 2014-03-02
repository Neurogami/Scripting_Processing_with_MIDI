import java.lang.reflect.Method;

import themidibus.*; 
import javax.sound.midi.MidiMessage; 

import java.util.Map;
import gifAnimation.*;

MidiBus myBus; 
Configgy config;
int maxImages = 1000;


ArrayList devices = new ArrayList();

int alternateGridChannel;

String[] gifFiles = { 

  "GIFs/animated-greytone001_600-1300.20_jpg.gif", 
  "GIFs/animated-greytone001_600-1400.20_gif.gif", 
  "GIFs/animated-greytone001_600-1800.20_jpg.gif", 
  "GIFs/animated-greytone001_600-3100.20_gif.gif", 
  "GIFs/animated-greytone001_600-4000.20_gif.gif", 
  "GIFs/scroller_001.gif",
  "GIFs/animated-greytone001_600-900.20_jpg.gif", 
  "GIFs/animated-greytone001_600_magenta-1700.20_jpg.gif", 
  "GIFs/animated-greytone001_600_magenta-4400.20_jpg.gif",
  "GIFs/scroller_001.gif",

  "GIFs/rot45_animated-greytone001_600-1300.20_jpg.gif", 
  "GIFs/rot45_animated-greytone001_600-1400.20_gif.gif", 
  "GIFs/scroller_002.gif",
  "GIFs/rot45_animated-greytone001_600-1800.20_gif.gif", 
  "GIFs/scroller_001.gif",
  "GIFs/rot45_animated-greytone001_600-2500.20_jpg.gif", 
  "GIFs/rot45_animated-greytone001_600-600.20_gif.gif", 
  "GIFs/rot45_animated-greytone001_600_magenta-1500.20_gif.gif", 
  "GIFs/scroller_002.gif",
  "GIFs/rot45_animated-greytone001_600_magenta-4400.20_jpg.gif",
  "GIFs/scroller_001.gif",


  "GIFs/flop_animated-greytone001_600-1300.20_jpg.gif", 
  "GIFs/flop_animated-greytone001_600-1400.20_gif.gif", 
  "GIFs/flop_animated-greytone001_600-1600.20_jpg.gif", 
  "GIFs/scroller_001.gif",
  "GIFs/flop_animated-greytone001_600-2500.20_jpg.gif", 
  "GIFs/flop_animated-greytone001_600-4000.20_gif.gif", 
  "GIFs/flop_animated-greytone001_600-900.20_jpg.gif", 
  "GIFs/scroller_001.gif",
  "GIFs/flop_animated-greytone001_600_magenta-1500.20_gif.gif", 
  "GIFs/flop_animated-greytone001_600_magenta-4400.20_jpg.gif",

  "GIFs/scroller_002.gif",

};



Gif[] gifs;

int gifIndex = 0;
int maxGifs = 0;

void setup() {
  size(1200, 600);
  maxGifs  = gifFiles.length;
  config = new Configgy("config.jsi");
  String[] deviceNames = config.getStrings("devices");
  HashMap mappings = config.getHashMap("device_mappings");
  alternateGridChannel = config.getInt("alternateGridChannel_", 3);
  maxImages = config.getInt("maximages", maxImages);

  println("Unavailable Devices");
  println( join(MidiBus.unavailableDevices(),  "\n"));
  println("-----------------------------------------------------");

  String[] available_inputs = MidiBus.availableInputs(); 

  for (int i = 0;i < available_inputs.length;i++) {
    for(int x=0; x < deviceNames.length; x++) {
      println("Check for device " + deviceNames[x] + " against " + available_inputs[i] );
      // Stupid MIDI thing does not always give the exact same device name for certain devices
      if (available_inputs[i].indexOf(deviceNames[x]) > -1 ) {
        println("* * * * Add device " + deviceNames[x] + " * * * * ");

        if (mappings.containsKey( deviceNames[x] ) ) {
          println("+ + + + Add device using mapping " + mappings.get( deviceNames[x]) );
          devices.add( new MidiBus(this, available_inputs[i], 1, (String) mappings.get( deviceNames[x]) ) ); 
        } else {
          devices.add( new MidiBus(this, available_inputs[i], 1, deviceNames[x]) ); 
        }
      }
    }
  }

  if (devices.size() < 1 ) {
    println("Failed to assign any of the desired devices.\nExiting.");
    exit();
  }


  renderL = new ArrayList<RenderArgs>();
  renderR = new ArrayList<RenderArgs>();
  renderC = new ArrayList<RenderArgs>();

  if (maxImages < maxGifs ) { maxGifs = maxImages; }

  gifs = new Gif[maxGifs];
  
  
  for (int i = 0; i < maxGifs; i++) {
    println("Load " + gifFiles[i] );
    gifs[i] = new Gif(this, gifFiles[i]);
    gifs[i].play();
  }

  println("Setup is done.");
}


void draw() {
  background(0);
  RenderArgs ra;

  for( int i =0; i < renderL.size(); i++ ) {
    ra = renderL.get(i);
    tint(ra.tint);
    placeGifAt( ra.gif, LEFT, ra.numCols, ra.numRows, ra.slotIndex );
  }

  for( int i =0; i < renderR.size(); i++ ) {
    ra = renderR.get(i);
    tint(ra.tint);
    placeGifAt(ra.gif, RIGHT, ra.numCols, ra.numRows, ra.slotIndex );
  }

  for( int i =0; i < renderC.size(); i++ ) {
    ra = renderC.get(i);
    tint(ra.tint);
    placeGifAt( ra.gif, CENTER, ra.numCols, ra.numRows, ra.slotIndex );
  }

}



void midiMessage(MidiMessage message, long timestamp, String bus_name) {
  int channel = (int)(message.getMessage()[0] & 0x0F) + 1;
  int note = (int)(message.getMessage()[1] & 0xFF) ;
  int vel = (int)(message.getMessage()[2] & 0xFF);
  if (vel > 0 ) {
    println("Bus " + bus_name + ": Note "+ note + ", vel " + vel + " : channel = "  + channel);
  }
  invokeNoteHandler(note, vel, channel, bus_name);
}


void invokeNoteHandler(int note, int velocity, int channel, String bus_name) {
  try {
    Class[] cls = new Class[3];
    cls[0] = int.class;
    cls[1] = int.class;
    cls[2] = String.class;

    if (bus_name.equals("grid") || channel == alternateGridChannel ) {
      println(" ########################### GRID MESSAGE ####################################### ");
      Method handler = this.getClass().getMethod( "onGridNote" + note, cls );
      handler.invoke(this, velocity, channel, bus_name);
    } else { 
      Method handler = this.getClass().getMethod( "onNote" + note, cls );
      handler.invoke(this, velocity, channel, bus_name);
    }

  } catch (Exception e) { 
    println("* * * * * * Error handling note " + note + ", velocity " + velocity + ", channel " + channel + ", bus_name " + bus_name + "  * * * * * *  ");
    e.printStackTrace(); }
}

void keyPressed() { 
  if (key == 'x') {
    resetLists();
  }
}

void resetLists() {
  renderR.clear();
  renderL.clear();
  renderC.clear();
  centerScaling = 3.0;
  globalTintIndex = 0;
  gridL4x4Pointer = 15;
  gridR4x4Pointer = 0;

  gridCPointer = 0;
  gridCRows = 3;
  gridCCols = 3;

}

