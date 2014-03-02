# Scripting Processing with MIDI 


![Glitchtastic](video-example-02.png)

## Overview ##

Processing is perhaps best known as a generator of sound and graphics, but your sketches cannot only create MIDI messages but listen for them as well.  

The MIDI messages can come from not just some standard MIDI keyboard, but from other applications.   

Even better: Your sketch is not limited to listening to only one MIDI source.

This means you can use a music program such as Renoise or Ableton Live to control a Processing sketch both in time to music and on-the-fly.

This article is ostensibly about writing code to drive a Processing sketch from a MIDI stream, but along the way it touches on creating a configuration class for Processing, ways to structure code for the `draw` loop, dynamically calling methods given some string, and organizing code when you are still largely experimenting.

As happens when writing about code, the code evolved during the writing, so in some ways it's something like a travelogue, with some minor detours and false turns on the way to the final destination.  However, all this should help in understanding the bigger picture.

The complete source code can be found on [Neurogami's GitHub](https://github.com/Neurogami/Scripting_Processing_with_MIDI).  Parts of it will look somewhat different from what is shown here because it kept evolving as this was written.  That's the nature of creative coding.

That repo includes the Processing code covered here, the graphics used by the sketch, and a version of a track by Neurogami, "A Temporary Lattice." 


## Getting started ##

I will assume you already know something about Processing and have it installed.  I also assume you have some means of sending MIDI messages.   More than one would be ideal, but is not required to play along. If you have Renoise (there's a free demo version you can grab) you can use the demo track used here.

A version of this code was created by [Neurogami](http://neurogami.com) to drive a music video for by song by [James Britt](http://jamesbritt.com), ["TR3"](http://jamesbritt.bandcamp.com/track/tr3-beta-2).

The idea was to take images of circa 1979 Lower Manhattan and position them in time to the music.  The images weren't still; they were run through some glitching code to generate a series of different distortions and the images were combined into videos.

In addition to the glitched images there were animated drawings created using a different set of distortions.  These specifics are not essential to the use of MIDI, but the effect is good so it's used it here.

### Picking a MIDI library ###

Processing, all on its own, does not know anything about MIDI. Under the hood Processing is Java so any Java MIDI library should work well with Processing.  There are, however, some Java MIDI libraries that have been packaged for use with Processing, which can make some things easier.

There are two MIDI libraries for Processing that seem to come up quite often. One is [proMIDI](http://creativecomputing.cc/p5libs/promidi/), the other is [the MidiBus](http://www.smallbutdigital.com/themidibus.php).  I tried both and went with MidiBus.  I wish I could give you some useful details as to _why_, but I honestly do not remember.  The code described here could plausibly by ported to work with other MIDI libraries so long as they support two features: The ability to connect and listen to events from multiple MIDI devices, and callbacks that are invoked on events from any of the connected devices.

For this article go install the MidiBus library if you do not already have it.

## A simple sketch ###

This is a simple sketch to show basic behavior and to check that things work.


    // SimpleMidi.pde

    import themidibus.*; //Import the library
    import javax.sound.midi.MidiMessage; 

    MidiBus myBus; 

    int currentColor = 0;
    int midiDevice  = 3;

    void setup() {
      size(480, 320);
      MidiBus.list(); 
      myBus = new MidiBus(this, midiDevice, 1); 
    }

    void draw() {
      background(currentColor);
    }

    void midiMessage(MidiMessage message, long timestamp, String bus_name) { 
      int note = (int)(message.getMessage()[1] & 0xFF) ;
      int vel = (int)(message.getMessage()[2] & 0xFF);

      println("Bus " + bus_name + ": Note "+ note + ", vel " + vel);
      if (vel > 0 ) {
       currentColor = vel*2;
      }
    }


First a quick run-through: When you run this you should see (either in the Processing IDE message window, or in a terminal window, depending on how you run it) a list of available MIDI inputs and outputs.   In my case I've attached a QuNexus MIDI keyboard that happens to come up as input number 3, so that's the value I assigned to `midiDevice`.  (I don't care what output device is selected to I just set it to 1.)

The sketch pops up a window that will change shades of gray based on the velocity of whatever MIDI not you send it.

If you are not using device that sends variable velocity then the visuals will not be terribly interesting.  You will still see the assorted `println` details though.

### What's happening in this sketch ###

First up you need to import the `MidiBus` library (`themidibus`) but also a Java library (`javax.sound.midi.MidiMessage`) so that your code can refer to `MidiMessage` objects (as happens in this sketch).

Depending on what you want to do with the methods available via `MidiBus` you may need to import other Java MIDI files, but for this example just that one will do.

In `setup` the sketch initializes the `MidiBus` instance `myBus`. When you create a new instance of a `MidiBus` class you need to pass in a reference to the current sketch (AKA `this`), the index of the device to listen to, and the index of the device to send to.

If you want to see what devices are available you can call `MidiBus.list()` which prints (to STDOUT) the lists of available MIDI input and output devices. The number that appears to the left of an item is the index number you use when creating your `MidiBus` instance.

If you wanted to be really clever you might wrap this up into some sort of GUI (perhaps using [ControlP5](http://www.sojamo.de/libraries/controlP5/)) so that the devices can be set or changed after the sketch is started.  In practice, though, the devices are unlikely to change from one run to the next and hard-coding them is probably good enough for most cases.  Another option is to have your sketch load these values from a configuration file so that if and when you need to change them it is a bit easier to do.

Once a `MidiBus` instance has been created, and a suitable sketch window, it's time to wait for some MIDI input.

A global variable, `currentColor`, is in place to hold the gray-scale value for the sketch background.  All `draw` does is use this value to color the window.  Yet if you are sending MIDI notes to the sketch the window changes.    Where is the change occurring?


`MidiBus` provides a few callback methods.  These are methods that are automatically invoked under various conditions.  This sketch uses `midiMessage`, which is automatically called whenever a MIDI message arrives.  

There are two versions of `midiMessage`; the other one has just one argument for the MIDI message.  This sketch uses  a version that includes the time-stamp and MIDI bus name just to show some of the MIDI details you can get.  

You decide what happens in this method.  For this sketch the code grabs some info about the MIDI message and prints it, and then looks at the note velocity.  If the velocity is greater than zero then that value is doubled and assigned to `currentColor`. 

Why skip values of zero?  The [MIDI specification](http://www.midi.org/techspecs/midimessages.php) defines messages for both "note on" and "note off".  But some devices don't bother with "note off", instead sending a "note on" message with a velocity of zero.

When I was first writing this sketch I simply grabbed the velocity and used it, and saw that the screen went black a soon as I took my fingers off the QuNexus keys. Watching the `println` output I saw what was happening: zero velocity for "note off".  

How you handle this is up to you; just be aware that it can happen.

So this is quite the simple sketch but demonstrates a key idea: The sketch waits for external signals, responds to those signals by updating some variables, and each pass of `draw` uses the current state of those variables to do something.

## Configuration, and getting clever ##

If you write enough Processing sketches that depend on some initial settings that you need to adjust for different executions you are likely to do as I did and work out some way to load such settings from a configuration file.  I suspect this is the kind of coding that falls into the "How hard can it be?" category since I don't think I even bothered to look for an existing solution.  Instead I did something really simple and adjusted it over time.

My first `Config` class loaded a text file from the `data/` folder and  parsed `name:value` strings into a `HashMap`. It worked pretty well for most things.  Great for simple single-item entries, but not so good if you wanted to define a list of values.

I got to wondering if I could use [YAML](http://www.yaml.org/spec/1.2/spec.html) or [JSON](http://www.json.org) so that a text file could represent more complex structures.  Turns out that Processing gives you built-in JSON handling. Perfect.

For the MIDI sketch the configuration was updated to use JSON.  Loading a JSON file and getting at the values is mostly easy but not entirely transparent.  You can get at different types of data using `getInt`, `getFloat`, `getString`, etc., but if you want to grab a list of items you need `getJSONArray` and then need to pull out each item as the correct type.

For this `Config` I decided that in most cases any list of items will be of the same type.  So I added `getStrings` ,`getFloats`, and `getInts`.

Now instead of putting the devices indices into my sketch I could use a config file.  JSON is not as simple as `name:value` but it's not too far off from that.   A bit overkill for short files, very handy for more complex structured data. 

I won't get into the details on that code here.  You can read more about it [here](http://jamesbritt.com/posts/getting-configgy-with-processing.html).

That first demo sketch showed one way to create a `MidiBus` object.  There's another way, and it's not only more friendly but lends itself to better configuration.   `MidiBus` lets you specify what devices to use by name.  The name has to match on what is displayed in the list of available devices, so you may need to first run  `MidiBus.list`  to see what's there.

Once you know the names of things the configuration file can use readable text instead of cryptic numbers.

You can also pass in a name for the bus so that later, when `midiMessage` is invoked, your code can (if you like) behave differently based on the source of the message.

Now the demo sketch (minus the code for `Configgy.pde`) looks like this:


    import java.lang.reflect.Method;

    import themidibus.*; 
    import javax.sound.midi.MidiMessage; 

    Configgy config;

    int currentColor = 0;
    ArrayList devices = new ArrayList();

    void setup() {
      size(480, 320);

      config = new Configgy("config.jsi");
      String[] deviceNames = config.getStrings("devices");
      println("Unavailable Devices");
      println( join(MidiBus.unavailableDevices(),  "\n"));
      println("-----------------------------------------------------");

      String[] available_inputs = MidiBus.availableInputs(); 
      for (int i = 0;i < available_inputs.length;i++) {
        for(int x=0; x < deviceNames.length; x++) {
          println("Check for device " + deviceNames[x] + " against " + available_inputs[i] );
          if (available_inputs[i].indexOf(deviceNames[x]) > -1 ) {
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
      if (vel > 0 ) { currentColor = vel*2; }
    }


The `config.jsi` file (stored in the `data/` folder) is this:

    devices:["QuNexus", "01. Internal MIDI"]
    
You'll have to adjust this to whatever devices you have available to use.

When you run the sketch, your config file  will be loaded  and the code will try to populate an `ArrayList` with `MidiBus` instances based on the device names you provided.

Note that in this example the use of an `ArrayList` means the code is not bothering with specific instance variables for every `MidiBus` instance; this code doesn't ever reference those instances.

The `midiMessage` event handler gets called no matter which of those devices is sending the message.  The handler is passed the name of bus so you can, if you like, have the code take different action depending on the source of the MIDI message.

If you're wondering why bother adding the bus instances to a list if they're never going to be used, the reason is that without some kind of persistent assignment those instances will disappear once `setup` has completed. Once they are gone, the MIDI message event handler will no longer get called.

If you did want the code to reference any of these instances then you might consider using a `HashMap` to hold them so that you could retrieve specific devices by name.

## Where we are so far ##

Here's a recap before we move on:

* You can use  `MidiBus.list()` to see what devices are available
* To create a `MidiBus` instance you can use the index of a device, but you can also use the device name as shown by `MidiBus.list()` 
* `Configgy` lets you create a configuration object using JSON so you store a list of device names.
* The event handler `middiMessage` is called for all messages that come from any of the `MidiBus` objects you have in your sketch
* `middiMessage` can give you the name of MIDI device if you need it (plus, of course, the MIDI message details)

No mention has been made of _sending_ MIDI messages from a sketch.  You can use `MidiBus` for this as well, but that's not going to be covered here.  (However, sending basic notes comes down to getting a `MidiBus` instance for an _output_ device, and then using that instance to call `sendNoteOn(channel, pitch, velocity)`.  But there are more things you can do, particularly with sending custom MIDI messages.)

## Custom message handlers ##

Using `midiMessage` is OK for simple cases, such as having the sketch do something no matter what note is sent, or perhaps selecting behavior based on two or three notes, but if find your code filling up with lengthy `if/then` or `switch/case` statements you should be wary.  These kinds of structures can become hard to maintain.

What would be cleaner than a growing set of conditionals would be a way to invoke a method based on the note value.  Here's one way to do it:

     void midiMessage(MidiMessage message, long timestamp, String bus_name) {
       int note = (int)(message.getMessage()[1] & 0xFF) ;
       int vel = (int)(message.getMessage()[2] & 0xFF);
       println("Bus " + bus_name + ": Note "+ note + ", vel " + vel);
       invokeNoteHandler(note, vel);
    }

    void invokeNoteHandler(int note, int velocity) {
      try {
        Class[] cls = new Class[1];
        cls[0] = int.class;
        Method handler = this.getClass().getMethod( "onNote" + note, cls );
        handler.invoke(this, velocity);
      } catch (Exception e) {
         e.printStackTrace();
      }
    }

When a MIDI message arrives, `midiMessage` pulls out the note value and velocity.  It passes those values on to `invokeNoteHandler`. That's where the fun happens.

[Java reflection](http://docs.oracle.com/javase/tutorial/reflect/member/methodInvocation.html) allows code to find methods by name (using `getMethod`) and call them.   We want to pass an `int` value to some method of the form `onNote<SomeNoteValue>`; to find a method you need to both the name and an array of classes describing what arguments that method takes.

Once a reference to such a method is found it is invoked using (surprise!) `invoke`.

This all happens inside a `try/catch` block.  If something goes wrong (for example, the code tries to find and call a method that doesn't exist) the exception is more or less ignored.  The idea here is that we will have methods for some set of notes, and we don't care about notes for which there is no corresponding handler method.

The last part of this is to define one or more methods to do something for specific notes. For example: 
 
    void onNote48(int vel) {  
      if (vel > 0 ) { currentColor = vel*2; }
    }

    void onNote50(int vel) {
      if (vel > 0 ) { currentColor = vel*2; }
    }


Not terribly imaginative, but what this does is limit screen-color changes to just two notes.

Here's maybe a better example:

First, change the type of `currentColor`:

    color currentColor = new color(0,0,0);

Now have the note handlers set different colors:
 
    void onNote48(int vel) {
       if (vel > 0 ) { currentColor = color(255, vel*2, vel*2); }
    }

    void onNote50(int vel) {
      if (vel > 0 ) { currentColor = color(vel*2, 255, vel*2 ); }
    }

    void onNote52(int vel) {
      if (vel > 0 ) { currentColor = color(vel*2, vel*2, 255); }
    }
   

The key point is that the behavior for any given note is encapsulated in its own method instead of being crammed into one growing catch-all method.

We can make things cleaner yet by putting all the note-handling methods into a separate file (e.g. `noteHandlers.pde`) so you know exactly where to look to add or change anything.

Your own message handlers can be anything you want, and you may want to pass in other parameters, perhaps pass in the original MIDI message itself.  However you set it up you need to set up your version of `invokeNoteHandler` so that it locates methods with the correct parameter signature.

For example, if you want to use handler methods that take the note velocity and the bus name, you need to change the `Class` array used with `getMethod` to indicate the types of these two parameter:

    void invokeNoteHandler(int note, int velocity, String busName) {
      try {
        // An array of size 2 since we are looking for a method that
        // takes two arguments
        Class[] cls = new Class[2];
        cls[0] = int.class;
        cls[1] = String.class;
        Method handler = this.getClass().getMethod( "onNote" + note, cls );
        // Now call the located method with the two arguments
        handler.invoke(this, velocity, busName);

      } catch (Exception e) {
         e.printStackTrace();
      }
    }


## A multimedia extravaganza ##

What we have so far is a way to listen to any number of available MIDI input devices and dispatch to specific handler methods based on note value. 

What initially drove this code was wanting to take a song created using a DAW (in this case [Renoise](http://renoise.com)) and generate visuals that changed in time with the music.

Renoise (and no doubt other audio software) can not only record MIDI notes but can itself be a MIDI message source.  A song track can be devoted to sending MIDI notes without triggering any specific sound.  This can be used to trigger events on a Processing sketch.

### Using a Renoise track to only send MIDI ###

If you do not already have Renoise you can [download a demo version](http://www.renoise.com/download) for free.   The explanation here is for the current official release, version 2.8.2

When you open up a Renoise song, or create a new one, you can set up a track that plays MIDI notes while not triggering any sound in the song itself.    (The Renoise song included with the source code already has these tracks set up.)

It is instruments in Renoise that send external MIDI, not tracks.  A track can make use of any of the instruments in the song, but it is common for tracks to be mapped to specific instruments.  This can make it easier to organize what's making what sound.  

Tracks are broken up into patterns, with patterns containing some number of lines; these lines hold the commands to play notes, trigger samples, and control effects.    Commands to play notes map to instruments.  Usually these instruments are there to make sounds, but there's no requirement for that.  That allows you to create a soundless MIDI-trigger track.   

To do this, select or add a new, empty track.  Give it a sensible name; I'm prone to calling such tracks "MIDI TRIGGER", all caps, so that it stands out as something special.  I also like to set the track color to either white or black, while all the actual music tracks are assorted shades of red, blue, green, and so on.  

Now select an empty `Instrument` slot in the upper right.  Since you do not want any sound generated you need to make sure no actual instrument is assign to that slot. 

With that unassigned-instrument slot selected go down to the bottom and select the "Instrument Settings" tab. Click on "Ext. MIDI" and select a device.  For example, "01. Internal MIDI".  (Your choices will depend on what's available on your machine.)

While still on that tab you can, if you like, name this "instrument"; it says "Untitled Instrument" by default but you can click on that and edit it.  Maybe call it "MIDI TRIGGER". Now you can see this name up in the instrument panel up top.

With that no-sound instrument selected go to your MIDI TRIGGER track and enter notes.  When you play the song these notes will be sent out on the external MIDI device you assigned to the no-sound instrument.

By the way, you can assign an external MIDI device to any instrument you like and have tracks that both make sounds for the song while also sending those notes to an external device.  For my purposes I like keeping the MIDI triggering instrument separate because I do not intend it to mirror any specific instrument and this way I can change the triggering notes without altering the sound of the song.  

The trigger notes can be any value you like (since they are not being heard).  It's useful, though, to work out some kind of naming scheme to help identify what different notes are meant to do.  For example,  one octave (starting at C4) could be was used to alter video images placed in assorted grid locations on the right side of the screen. Notes in another octave (at C5) might alter the left side of the screen, and so on.    (We'll see later on that there are other ways to organize you notes and handlers, such as using channel and MIDI device name.)

Depending on the complexity of your sketch you may want a chart of some kind to map note names to note values. Renoise, for example, displays notes as letters and octave; you see "C4" instead of "48".

With the current state of the demo sketch you need to limit the notes to the values C4, D4, and E4 (since those are the only handlers defined so far).  As written, these handlers will show the color white when the note velocity is 100% (i.e. 127).  If you enter the notes using a velocity-sensitive keyboard (such as the handy QuNexus) then you can get a variety of velocity values below the maximum.  If you are entering them by hand (using perhaps you computer's "Z", "X", and "C" keys) you can go back and [edit the velocity](http://tutorials.renoise.com/wiki/Pattern_Editor#Sub-Note_Columns) of each note (which are, by default, the maximum).

Now if you configure the demo sketch to listen to the same device as the MIDI trigger instrument uses the sketch should react as each trigger note is played.

## We can do better ##

Let's now take all this and see if we can make it a bit more exciting.  

First, an important caveat: The Neurogami aesthetic may not be yours.  It's a kind of glitchy minimalism.  I do hope you like it, but that's not really the goal here. 

The approach taken was to first create a number of animated GIFs made using ImageMagick and some custom Ruby software to glitch images. The Processing code then places, scales, etc., this or that GIF file based on what MIDI note and channel comes in.

It's probably more common to see Process sketches where all of the visual effects are done by Processing (or some P5 library) right in the sketch.  There approach here is, in way, cheating: it's just showing pictures of graphic effects.  So what: It's the end result that matters.

However, using pre-made animations does make things easier. Getting the same visual effects real-time in Processing would be nigh impossible.  Couple that with also responding to MIDI messages in real-time makes it more likely for things to go wrong.

There is something about this sketch that is common to most Processing sketches.  If you look at most any example that renders something visually striking the sketch generally works like this: On each pass of `draw`, run some code to update a set of variables, then use the current state of those variables to determine what to render.

This sketch is the same.  It uses a very slick library called [gifAnimation](http://extrapixel.github.io/gif-animation/) to play animated GIFs.  You can use them as you would any regular image file, that is, pass a reference to an animated GIF to `image` to control the placement and scaling.

The thing is,  if you are looking to render numerous images in varying places, some persisting some not, you need some way to keep track of them.  If you knew the exact number of images you might be able to use a fixed set of variables to hold all the details, but past some small number that gets cumbersome.

I had in mind to render the GIFs placed into grids of different sizes.   I decided to split the screen in half, down the middle.  Image placement would be done by specifying  left or right, what size grid (by giving the number of rows and columns), and where in that grid to place the image.

Tracking a set of related data calls for some way to group them. Sometimes an array works, but in this case there needs to be two sets of grouped data.  Making your classes in Processing is easy and affords a way to keep related data together.    I defined a class called `RenderArgs` (you'll see why in a moment)

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

It's just a way to group a tint color, a reference to an animated GIF, the number of columns and rows in a grid, and where in that grid to place the GIF.

These (except for the tint) are all arguments to a method `placeGifAt`.

    void placeGifAt(Gif g, int leftOrRight, int numCols, int numRows, int slotIndex ) {
      int w = width/(numCols*2);
      int h = height/numRows;
      int count = 0;
      int colOffset = 0;

      if (leftOrRight == RIGHT ) {
        colOffset  = width/2;
      }

      for(int y=0; y<numRows; y++) {
        for(int x=0; x<numCols; x++) {
          if (count == slotIndex) {
            image(g, x*w+colOffset , y*h, w, h); 
          }
          count++;
        }
      }

    }

(The file with this code also defines `RIGHT` as `1` to make this more readable.)

Plausibly, this method could be part of the same class that holds all of the argument values; the code evolved from first creating a method to define how to place an image in a grid-slot.  

`renderGifAt`  gets called in `draw`, along with a call to `tint`.  All this could be wrapped up in an instance method (`render`, perhaps) in `renderArgs` (which would then need a better name) so that data and behavior are kept together (sort of the whole point of classes). I just haven't done this.  I'm still trying things out and I'm OK if code hasn't settled into some final form.

There are assorted helper methods that manage a list of animated GIF instances and a list of tints, and some `ArrayList` instances to hold on to `RenderArgs` instances.  

`draw` does very little. It sets a black background then iterates over the `RenderArgs` lists, and for each item calls `tint` then `image`.  In other words, it looks at a set of variables and uses them to decide what to render.

## What's that channel? ##

Since `draw` doesn't do much the real action must be happening elsewhere.  Indeed, it's the note-handling methods that drive what is seen.    When a MIDI message comes in it gets dispatched to a matching note handler if one exists.  I decided I wanted to be able to generate some patterns, such as filling up a 4x4 grid with images note-by-note.  I wrote a note handler that did this for the left side of the sketch window, and thought it would be nice to do the same on the right side, but reversed. 

At first I did this using two different note handlers, thinking I would use one octave for things to happen on the left side, and another octave for the right.  This felt awkward.  Why not get channels involved?

`MidiBus` provides some additional event handlers, including `noteOn`, which, if you define it, gets called when any device receives a note-on message.  This method will give you the channel, the note value, and the velocity.   However, it does not give you the name of the MIDI bus that received it.

At this point in development I did not have a clear plan for using the bus name but some ideas were forming and I did not want to drop the option of using it.  But I wanted the channel, too.

`midiMessage` is called with some specific data handed right to you (such as the bus name) but the message itself is somewhat cryptic.  You may have noticed there's some interesting math going on to get the note and velocity values.

    int note = (int)(message.getMessage()[1] & 0xFF) ;

A MIDI message is pretty compact.  It is sent as a series of bytes.  I'm going to skip the technical details but to get the useful value of these bytes in Java you need to grab a subsection of them and then apply a "mask".  This mask forces some part of the value to assume a certain value giving us a useful result.

The code was doing this to get the note and velocity values.  They same approach can be used to get the channel as well.  `midiMessage` then becomes this:

    void midiMessage(MidiMessage message, long timestamp, String bus_name) {
      int channel = (int)(message.getMessage()[0] & 0x0F) + 1;
      int note = (int)(message.getMessage()[1] & 0xFF) ;
      int vel = (int)(message.getMessage()[2] & 0xFF);
      invokeNoteHandler(note, vel, channel, bus_name);
    }


`invokeNoteHandler` now needs to do a method look-up with three arguments: 

     void invokeNoteHandler(int note, int velocity, int channel, String bus_name) {
      try {
        Class[] cls = new Class[3];
        cls[0] = int.class;
        cls[1] = int.class;
        cls[2] = String.class;
        Method handler = this.getClass().getMethod( "onNote" + note, cls );
        handler.invoke(this, velocity, channel, bus_name);
      } catch (Exception e) { 
        println("* * * * * * Error handling note " + note + " * * * * * *  ");
        e.printStackTrace(); }
    }

With both channel and bus name available each note handler can behavior differently depending on the source of the note.  In some cases this makes it easier to organize the notes at the point of origin.  For example, I created a method that would keep adding an image to  4x4 grid, tracking a grid index.  If the index went out of bounds (that is, below 0 or above 15, depending on which direction was used to fill the grid) the grid would be cleared.

I assigned this the C4 (i.e. note 48). Before bringing channels into the code I had C64 trigger this behavior on the left side of the sketch and C5 used to trigger it on the right (where it would run in reverse, starting from grid location 15).  But I wasn't happy with this use of octaves.  Deciding to add channels I created another MIDI-trigger instrument in Renoise and set it to output on channel 2.  This way I could set up each note to map to some specific behavior, with the channel determining on what side of the screen it would appear.  

These kinds of organizing decisions are quite subjective.  This works for me (so far; perhaps after more use I'll work out some other scheme).  The point is that there is no one true way to do this; find an approach that works for you.

Here's how `onNote48` ended up after that change:

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
    
## Yet another bus ... ##

You can look at the final source code to see what I came up with for note handlers, run it with the example Renoise file, or [watch the video](http://youtu.be/M0bEJilXtJM) to just see it in action.  There's a very good chance that the code will not be exactly what I've shown here.  As I've been describing the sketch I've been reconsidering how things should work.  This is the nature of exploratory coding.

While trying out this and that I realized that it can be hard to pre-plan every change and switch and jump you might want to see in the sketch.   As I would alter code or edit the MIDI tracks in Renoise and watch the results I kept thinking, hey, a sudden tint change would be good, or this would be the right beat to throw up dual full-sized images for half a bar.  In other words, there were a few select effects I wanted but only at key moments.  

Editing this into the Renoise trigger tracks would be tricky. So much nicer to activate some things in real-time using another controller as the song plays.

I had started off experimenting with my QuNexus keyboard. This device allows you shift the octave so I could have worked with a range of notes not already assigned.  But I wanted to use a controller that might be more intuitive, something other than a standard keyboard.

I picked up a [Novation Launchpad](http://us.novationmusic.com/midi-controllers-digital-dj/launchpad) sometime last year.  It's a grid of touch-pad switches.  There's no velocity control, just on/off, great for triggering samples and loops and such.  It sends MIDI notes within a preset range.  Now, I sure there's a way to change what notes are assigned to each button, but since the bus name is passed on to the MIDI note handlers in the sketch I can safely reuse the existing notes.

Another approach might be to set the Launchpad to use a specific channel.  You can decide for yourself whether selecting behavior on yet another channel or branching based on bus name better fits you mental model of what's happening.

There are various places the code can switch behavior based on bus name.  One, of course, is inside any of the note-handling methods.  Another would be in `invokeNoteHandler`.   Although I've been passing the bus name on to the note handlers my ideas for how to use the Launchpad didn't feel like a good fit for the existing  note handling code. For example, if I send C48 from the Launchpad I'm might not be looking to do another variation on the 4x4 grid-fill pattern, but something quite different.  Adding a test in `onNote48` for this particular device felt clunky. Suppose I defined a different set of note handlers, specific to this device?

This would save me the trouble of having to add this device-name check to every single `onNoteNN` method on the off-chance there's a note value overlap.  The downside is having a device name hard-coded in my sketch.

### ... and yet another configuration option ###

While I wanted to dispatch certain MIDI messages to select handlers based on bus name I did not want to hard-code the bus name.  At home I have a choice of controllers, but as I write this sentence I happen to be at [HeatSync Labs](http://www.heatsynclabs.org).  I did not bring the Launchpad; the QuNexus fit much better into my laptop bag.

Rather than rely on the name of a specific controller in the code I added another configuration option to allow mapping device names to some other text.

The `config.jsi`  entry looks like this:  

    device_mappings: {"Launchpad": "grid", "QuNexus": "grid" }

In sketch the code that sets up devices now also looks to see if there is a device mapping for a found device, and if so then it uses that mapping name as the bus name rather than then given device name.

This required yet another change to [Configgy.pde](http://neurogami.com/blog/neurogami-conffigy-evolution.html).  What's new is that you can store a `name:{<hashmap>}` setting and get back a `HashMap` of name/value string pairs.

So the sketch grabs these device name mappings ...

    HashMap mappings = config.getHashMap("device_mappings");

... and then later ...

    if (mappings.containsKey( deviceNames[x] ) ) {
      println("+ + + + Add device using mapping " + mappings.get( deviceNames[x]) );
      devices.add( new MidiBus(this, available_inputs[i], 1, (String) mappings.get( deviceNames[x]) ) ); 
    } else {
      devices.add( new MidiBus(this, available_inputs[i], 1, deviceNames[x]) ); 
    }




     [[  TODO: See what happens if you do actualy have both the QuNexus and the Launchpad at the same time.
         Does it matter if more than once device has the same bus name? Maybe not. ]]

Now the MIDI message dispatching code can look for messages from a bus named `grid`; the actual device could be any number of devices depending on what you've attached and how you've mapped names.

Now dispatching on MIDI messages can call specialized handlers:

    void invokeNoteHandler(int note, int velocity, int channel, String bus_name) {
      try {
        Class[] cls = new Class[3];
        cls[0] = int.class;
        cls[1] = int.class;
        cls[2] = String.class;

        if (bus_name.equals("grid") ) {
          Method handler = this.getClass().getMethod( "onGridNote" + note, cls );
          handler.invoke(this, velocity, channel, bus_name);
        } else { 
          Method handler = this.getClass().getMethod( "onNote" + note, cls );
          handler.invoke(this, velocity, channel, bus_name);
        }

      } catch (Exception e) { 
        println("* * * * * * Error handling note " + note + ", velocity " + 
           velocity + ", channel " + channel + ", bus_name " + bus_name + "  * * * * * *  ");
        e.printStackTrace(); }
    }

## Gridly goodness  ##

This setup allows multiple devices to lay the role of `grid`.  What's left is to add some final flourishes.

The bulk of the graphics happens on a split screen.  One more rendering structure that covered the entire screen would be nice.  To this end, an new `RengerArgs` `ArrayList` instance is created.

A few more tweaks get introduced as well. The option to set a scaling factor when rendering a GIF. This allows two interesting features: You can center a large GIF that would not otherwise fit int a uniform grid (since you can place it near the upper left and then scale it), and you can grow/shrink GIFs as they are show.

The default MIDI mapping for the legacy Launchpad is described [here](http://www.audionewsroom.net/2010_01_01_archive.html). You'll note that some notes seem to get lost as you move across and go row-to-row.

I wanted to relate pad position to some aspect of an effect to make it more intuitive.  

    [[ FIXME NEED TO FLESH THIS OUT ]]

## Wrapping up ##

I'm happy with what I've done so far.  I'm happy, too, to keep playing around and changing things.

Over time I can see parts of this sketch being extracted into something more reusable.  

If you're wondering how the final results are to be captured and turned into video, I've been experimenting with some screen-capture software.    If you've been playing along at home you may have noticed, depending on how beefy is your setup, that the rendering of the GIFs when viewed on their own (say, in a browser) are different than when they appear in the sketch.  As part of a collection of a dozen or so images that come and go the GIFs tend to show more jitter and lags.  Perfect!

Likewise, when I've done some test recordings using a screen-capture tool I end up with similar sorts of glitches and artifacts.  There's little point in trying to prevent this.  It may be possible but I'd rather embrace the quirks of a given tool or medium.  That's a big part of the fun.

I do want things to be synchronized, and if need be I can adjust that in some video tool, but for the most part what I've been getting is a stable coordinated structure at the larger level with odd coincidental "errors" happening within that. Much like the [music of Neurogami](http://music.neurogami.com).



### Coda ###

After endless playing I decided that it would be nice if I could record my QuNexus/Launchpad improvisations in case I end up with something I really like.  I set up  a new track in the Renoise piece, and added the QuNexus as a MIDI input.  But once Renoise was capturing that device it was no longer available to the sketch.  Quandary.

This got me thinking of routing `grid` messages based on channel number.  This way Renoise can capture notes from whatever is supposed to be the `grid` device and output on some specific channel (3, perhaps).   Now the behavior should be the same as if the `grid` device were directly talking to the sketch while all notes were recorded by Renoise.

