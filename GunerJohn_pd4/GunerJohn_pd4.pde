import beads.*;
import org.jaudiolibs.beads.*;
import java.util.*;
import controlP5.*;


TextToSpeechMaker ttsMaker; 


//to use this, copy notification.pde, notification_listener.pde and notification_server.pde from this sketch to yours.
//Example usage below.

//name of a file to load from the data directory
String eventDataJSON1 = "hand_position_good.json";
String eventDataJSON2 = "squat_bad.json";
String eventDataJSON3 = "squat_good.json";

NotificationServer server;
ArrayList<Notification> notifications;

ControlP5 p5;
Gain masterGain;
Panner p;

int waveCount = 1;
float baseFrequency = 440.0;

// Array of Glide UGens for series of harmonic frequencies for each wave type (fundamental wave, square, triangle, sawtooth)
Glide[] waveFrequency = new Glide[waveCount];
// Array of Gain UGens for harmonic frequency series amplitudes (i.e. baseFrequency + (1/3)*(baseFrequency*3) + (1/5)*(baseFrequency*5) + ...)
Gain[] waveGain = new Gain[waveCount];
Glide masterGainGlide;
// Array of wave wave generator UGens - will be summed by masterGain to additively synthesize square, triangle, sawtooth waves
WavePlayer[] handTone = new WavePlayer[waveCount];
Slider xposSlide;

SamplePlayer backTone;
SamplePlayer kneeSound;
Glide glide;
Example example;

//Comparator<Notification> comparator;
//PriorityQueue<Notification> queue;
PriorityQueue<Notification> q2;

void setup() {
  size(600, 600);

  ac = new AudioContext(); //ac is defined in helper_functions.pde
  p5 = new ControlP5(this);
  masterGainGlide = new Glide(ac, .2, 200);  
  masterGain = new Gain(ac, 1, masterGainGlide);
  ac.out.addInput(masterGain);
  NotificationComparator priorityComp = new NotificationComparator();
  glide = new Glide(ac, 1);
  kneeSound = getSamplePlayer("knee.mp3",false);
  kneeSound.setLoopType(SamplePlayer.LoopType.LOOP_FORWARDS);
  kneeSound.setRate(glide);
  
  masterGain.addInput(kneeSound);
  
  q2 = new PriorityQueue<Notification>(10, priorityComp);

  //comparator = new NotificationComparator();
  //queue = new PriorityQueue<Notification>(10, comparator);
  
   
 
    float waveIntensity = 1.0;
    waveFrequency[0] = new Glide(ac, 1000 * 1, 200);
      
    
  
  handTone[0] = new WavePlayer(ac, waveFrequency[0], Buffer.SINE);
  waveIntensity = 1 == 1 ? 1.0 : 0; // fundamental only    
  waveGain[0] = new Gain(ac, 1, waveIntensity); // create the gain object
  waveGain[0].addInput(handTone[0]); // then connect the waveplayer to the gain
  masterGain.addInput(waveGain[0]);
  p = new Panner(ac, 1001);

  server = new NotificationServer();

  //instantiating a custom class (seen below) and registering it as a listener to the server
  example = new Example();
  server.addListener(example);

  //loading the event stream, which also starts the timer serving events

  //END NotificationServer setup
  p5.addButton("Good_Hand_Position")
    .setPosition(width/2 + 50 , 40)
    .setSize(150, 20)
    .setLabel("Good Hand Position");
 
  p5.addButton("Good_Squat")
    .setPosition(width/2 + 50, 70)
    .setSize(150, 20)
    .setLabel("Good Squat");
  
  p5.addButton("Bad_Squat")
    .setPosition(width/2 + 50, 100)
    .setSize(150, 20)
    .setLabel("Bad Squat");

  p5.addButton("startButton")
    .setPosition(130, 170)
    .setSize(50, 20)
    .setLabel("Start");
    
  p5.addButton("stopButton")
    .setPosition(25, 170)
    .setSize(50, 20)
    .setLabel("Stop");
    
   p5.addSlider("xposSlide")
    .setPosition(10, 50)
    .setSize(200, 20)
    .setRange(0.0, 5.0)
    .setValue(5)
    .setLabel("Hand Position Slider");
    
   p5.addSlider("backContraction")
    .setPosition(10, 80)
    .setSize(200, 20)
    .setRange(0.0, 100.0)
    .setValue(5)
    .setLabel("Back Contraction Slider");
   
   
    p5.addSlider("kneeContraction")
    .setPosition(10, 110)
    .setSize(200, 20)
    .setRange(0.0, 100.0)
    .setValue(5)
    .setLabel("Knee Contraction Slider");
    
   p5.addSlider("ROM")
    .setPosition(10, 140)
    .setSize(200, 20)
    .setRange(0.0, 100.0)
    .setValue(5)
    .setLabel("ROM Slider");
    
}

//in your own custom class, you will implement the NotificationListener interface 
//(with the notificationReceived() method) to receive Notification events as they come in
class Example implements NotificationListener {

  public Example() {
    //setup here
  }

  //this method must be implemented to receive notifications
  public void notificationReceived(Notification notification) { 
    println("<Example> " + notification.getType().toString() + " notification received at " 
      + Integer.toString(notification.getTimestamp()) + " ms");

    String debugOutput = ">>> ";
    switch (notification.getType()) {
    case left_hand:
      debugOutput += "left_hand: ";
      ac.start();
      waveFrequency[0].setValue(notification.getX_pos() * 1000);
      glide.setValue(0);
      break;
    case right_hand:
      ac.reset();
      debugOutput += "right_hand: ";
      ac.start();
      waveFrequency[0].setValue(notification.getX_pos() * 1000);
      break;
    case left_knee:
      debugOutput += "left_knee: ";
      glide.setValue(.015 * notification.getContraction());
      waveFrequency[0].setValue(notification.getRom() * 12);
      ac.start();

      break;
    case right_knee:
      debugOutput += "right_knee: ";
      break;
    case chest:
      debugOutput += "chest: ";
      break;
    case back:
    ac.reset();
    boolean dangerFlag = true;
    if(notification.getContraction() > 80 && dangerFlag){
       dangerFlag = false;
       SamplePlayer backDanger = null;
       backDanger = getSamplePlayer("dangerAlarm.wav",false);
       masterGain.addInput(backDanger);
       ac.start();
    }
      debugOutput += "back: ";
      break;
    }
    debugOutput += notification.toString();
    //debugOutput += notification.getLocation() + ", " + notification.getTag();

    println(debugOutput);

    //You can experiment with the timing by altering the timestamp values (in ms) in the exampleData.json file
    //(located in the data directory)
  }
}
public void Good_Hand_Position() {
  server.stopEventStream(); //always call this before loading a new stream
  server.loadEventStream(eventDataJSON1);
  println("**** New event stream loaded: " + eventDataJSON1 + " ****");
}

public void Bad_Squat() {
  server.stopEventStream(); //always call this before loading a new stream
  server.loadEventStream(eventDataJSON2);
  println("**** New event stream loaded: " + eventDataJSON2 + " ****");
}

public void Good_Squat() {
  server.stopEventStream(); //always call this before loading a new stream
  server.loadEventStream(eventDataJSON3);
  println("**** New event stream loaded: " + eventDataJSON3 + " ****");
}
 
 public void startButton() {
   ac.reset();
   ac.start();
  println("Starting");
}
  public void stopButton() {
  ac.stop();
  ac.reset();
  println("Stopping");
}

public void xposSlide(float value) {
  waveFrequency[0].setValue(1000*value);
}

public void backContraction(float value) {
   if(value > 80){
     SamplePlayer backDanger = null;
     backDanger = getSamplePlayer("dangerAlarm.wav",false);
     masterGain.addInput(backDanger);
}
}

public void kneeContraction(float value) {
      glide.setValue(.015 * value);
    }

public void ROM(float value) {
    waveFrequency[0].setValue(value * 12);
}

void draw() {
  //this method must be present (even if empty) to process events such as keyPressed()  
  background(0);
}
