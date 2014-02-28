import java.lang.reflect.Method;

import themidibus.*; //Import the library
import javax.sound.midi.MidiMessage; //Import the MidiMessage classes http://java.sun.com/j2se/1.5.0/docs/api/javax/sound/midi/MidiMessage.html
//import javax.sound.midi.SysexMessage;
//import javax.sound.midi.ShortMessage;

MidiBus myBus; 
Configgy config;

color currentColor = color(0,0,0);

ArrayList devices = new ArrayList();

void setup() {
  size(480, 320);

  config = new Configgy("config.jsi");

  String[] deviceNames = config.getStrings("devices");

  println("Unavailable Devices");

  println( join(MidiBus.unavailableDevices(),  "\n"));

  println("-----------------------------------------------------");

  String[] available_inputs = MidiBus.availableInputs(); //Returns an array of available input devices
  for (int i = 0;i < available_inputs.length;i++) {
    for(int x=0; x < deviceNames.length; x++) {
      println("Check for device " + deviceNames[x] + " against " + available_inputs[i] );
      if (deviceNames[x].equals(available_inputs[i] )) {
        println("* * * * Add device " + deviceNames[x] + " * * * * ");
        devices.add( new MidiBus(this, deviceNames[x], 1, deviceNames[x]) ); 
      }
    }
  }

  if (devices.size() < 1 ) {
    println("Failed to assign any of the desired devices.\nExiting.");
    exit();
  }

}


void draw() {
  background(currentColor);
}



     void midiMessage(MidiMessage message, long timestamp, String bus_name) {
       int note = (int)(message.getMessage()[1] & 0xFF) ;
       int vel = (int)(message.getMessage()[2] & 0xFF);
       println("Bus " + bus_name + ": Note "+ note + ", vel " + vel);
       invokeNoteHandler(note, vel, bus_name);
      
    }

    void invokeNoteHandler(int note, int velocity, String bus_name) {
      try {
        // An array of size 2 since we are looking for a method that
        // takes 2 arguments
        Class[] cls = new Class[2];
        cls[0] = int.class;
        cls[1] = String.class;
        Method handler = this.getClass().getMethod( "onNote" + note, cls );
        handler.invoke(this, velocity, bus_name);

      } catch (Exception e) {
         e.printStackTrace();
      }
    }

void onNote48(int vel, String bus_name) {
  if (vel > 0 ) { currentColor = color(255, vel*2, vel*2); }
}

void onNote50(int vel, String bus_name) {
  if (vel > 0 ) { currentColor = color(vel*2, 255, vel*2 ); }
}

void onNote52(int vel, String bus_name) {
  if (vel > 0 ) { currentColor = color(vel*2, vel*2, 255); }
}

