import controlP5.*;
import beads.*;

//declare global variables at the top of your sketch
//AudioContext ac; is declared in helper_functions
ControlP5 p5;

SamplePlayer buttonSound;

Gain masterGain;

Glide gainGlide;
Glide cutoffGlide;

BiquadFilter lpFilter;
//end global variables

//runs once when the Play button above is pressed
void setup() {
  size(320, 240); //size(width, height) must be the first line in setup()
  ac = new AudioContext(); //AudioContext ac; is declared in helper_functions 
  p5 = new ControlP5(this);
  buttonSound = getSamplePlayer("amenbreak.wav");
  buttonSound.pause(true);
  
  gainGlide = new Glide(ac, 1.0, 500);
  cutoffGlide = new Glide(ac, 1500.0, 50);
  
  lpFilter = new BiquadFilter(ac, BiquadFilter.LP, cutoffGlide, 0.5f);
   
  masterGain = new Gain(ac, 1, .5);
  masterGain.addInput(buttonSound);
  
  lpFilter.addInput(masterGain);

  ac.out.addInput(lpFilter);
  
  p5.addButton("Play")
  .setPosition(width/2 + 30, 110)
  .setSize(60, 20)
  .setLabel("Play")
  .activateBy((ControlP5.RELEASE));
  
   p5.addSlider("GainSlider")
  .setPosition(10, 10)
  .setSize(20, 100)
  .setRange(0, 100)
  .setValue(50)
  .setLabel("Gain");
  
  p5.addSlider("CutoffSlider")
  .setPosition(80, 10)
  .setSize(20, 100)
  .setRange(0, 20000)
  .setValue(5000)
  .setLabel("Cutoff Frequency");
  
  ac.start();
}
public void Play(int value){
 println("Play Pressed");
 buttonSound.setToLoopStart();
 buttonSound.start();
}

public void GainSlider(float value){
 println("Gain Slider Moved by " + value);
 masterGain.setGain(value/100.0);
}

public void CutoffSlider(float value){
 println("Cutoff Slider Moved by " + value);
 lpFilter.setFrequency(value);
}

void draw() {
  background(0);  //fills the canvas with black (0) each frame
  
}
