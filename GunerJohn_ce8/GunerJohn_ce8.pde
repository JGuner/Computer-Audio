import controlP5.*;
// FFT_01.pde
// This example is based in part on an example included with
// the Beads download originally written by Beads creator
// Ollie Bown. It draws the frequency information for a
// sound on screen.
import beads.*;

Gain masterGain;

SamplePlayer player;

UGen micInput;

BiquadFilter filter;
Glide cutoffGlide;

Button resynthButton;
Slider resynthGainSlider;

Reverb reverb;
PowerSpectrum ps;
ControlP5 p5;
Frequency f;
Glide frequencyGlide;
WavePlayer wp;
PeakDetector beatDetector;
Gain waveGain;

boolean micOn = false;
boolean reverbOn = false;

float meanFrequency = 400.0;

float brightness;

color fore = color(255, 255, 255);
color back = color(0,0,0);
color highlight = color(255, 0, 0);
void setup()
{

 size(1000,600);

ac = new AudioContext();
p5 = new ControlP5(this);

 // set up a master gain object
 masterGain = new Gain(ac, 2, 0.3);
 ac.out.addInput(masterGain);

frequencyGlide = new Glide(ac, 50, 10);
wp = new WavePlayer(ac, frequencyGlide, Buffer.SINE);
waveGain = new Gain(ac, 1, 0);
ac.out.addInput(waveGain);


 // load up a sample included in code download
 SamplePlayer player = null;
 try
 {
 // Load up a new SamplePlayer using an included audio
 // file.
 
 player = getSamplePlayer("audio.wav",false);
 player.setLoopType(SamplePlayer.LoopType.LOOP_FORWARDS);
 // connect the SamplePlayer to the master Gain
 masterGain.addInput(player);
 }
 catch(Exception e)
 {
 // If there is an error, print the steps that got us to
 // that error.
 e.printStackTrace();
 }
 // In this block of code, we build an analysis chain
 // the ShortFrameSegmenter breaks the audio into short,
 // discrete chunks.
 waveGain.addInput(wp);
 
  cutoffGlide = new Glide(ac, 1500.0, 50);
 filter = new BiquadFilter(ac, BiquadFilter.AP, cutoffGlide, 0.5f);
 filter.addInput(player);
 
 masterGain.addInput(filter);
 
 ShortFrameSegmenter sfs = new ShortFrameSegmenter(ac);
 sfs.addInput(ac.out);

 // FFT stands for Fast Fourier Transform
 // all you really need to know about the FFT is that it
 // lets you see what frequencies are present in a sound
 // the waveform we usually look at when we see a sound
 // displayed graphically is time domain sound data
 // the FFT transforms that into frequency domain data
 FFT fft = new FFT();
 // connect the FFT object to the ShortFrameSegmenter
 sfs.addListener(fft);

 // the PowerSpectrum pulls the Amplitude information from
 // the FFT calculation (essentially)
 ps = new PowerSpectrum();
 // connect the PowerSpectrum to the FFT
 fft.addListener(ps);
 // list the frame segmenter as a dependent, so that the
 // AudioContext knows when to update it.
 
 f = new Frequency(44100.0f);
 ps.addListener(f);
 
 SpectralDifference sd = new SpectralDifference(ac.getSampleRate());
 ps.addListener(sd);
 
 beatDetector = new PeakDetector();
 sd.addListener(beatDetector);
 
 beatDetector.setThreshold(0.2f);
 
 beatDetector.setAlpha(.9f);
 
 beatDetector.addMessageListener(
   new Bead(){
     protected void messageReceived(Bead b) {
       brightness = 1.0;
   }
 }
 );
 ac.out.addDependent(sfs);
 
 reverb = new Reverb(ac);
 reverb.setSize(0.01);
 reverb.setDamping(0.1);
 reverb.setEarlyReflectionsLevel(0.1);
 
 micInput = ac.getAudioInput();
 
   p5.addButton("LowPassFilter")
    .setPosition(900, 0)
    .setSize(100, 20)
    .setLabel("Low Pass Filter");
    
    p5.addButton("HighPassFilter")
    .setPosition(900, 25)
    .setSize(100, 20)
    .setLabel("High Pass Filter");
    
    p5.addButton("BandPassFilter")
    .setPosition(900, 50)
    .setSize(100, 20)
    .setLabel("Band Pass Filter");
    
    p5.addButton("NoFilter")
    .setPosition(900, 75)
    .setSize(100, 20)
    .setLabel("No Filter");
    
    p5.addButton("Reverb")
    .setPosition(900, 125)
    .setSize(100, 20)
    .setLabel("Reverb");
    
   p5.addButton("Mic")
    .setPosition(900, 175)
    .setSize(100, 20)
    .setLabel("Mic Toggle");
   
    p5.addSlider("CutoffSlider")
    .setPosition(700, 100)
    .setSize(200, 20)
    .setRange(20.0, 15000.0)
    .setValue(5000.0)
    .setLabel("Cutoff Frequency");
    
    p5.addSlider("Damping")
    .setPosition(700, 150)
    .setSize(200, 20)
    .setRange(0.0, 1.0)
    .setValue(.5)
    .setLabel("Damping");
    
    resynthButton = p5.addButton("resynthButton")
    .setPosition(600, height - 70)
    .setSize(80, 50)
    .activateBy((ControlP5.RELEASE))
    .setLabel("Resynth Toggle");
    
    resynthGainSlider = p5.addSlider("resynthGainSlider")
    .setPosition(600, height - 100)
    .setSize(300 ,20)
    .setRange(0, 100)
    .setValue(50)
    .setLabel("Resynth Gain");
 
 // start processing audio
 ac.start();
}
// In the draw routine, we will interpret the FFT results and
// draw them on screen.

public void NoFilter(){
  println("no filter button pressed");
  filter.setType(BiquadFilter.AP);
}

public void LowPassFilter(){
  println("LP filter button pressed");
  filter.setType(BiquadFilter.LP);
}

public void HighPassFilter(){
  println("HP filter button pressed");
  filter.setType(BiquadFilter.HP);
}

void Mic(){
  if (micOn) {
    micOn = false;
  }  else {
    micOn = true;
  }

if (micOn){
  filter.clearInputConnections();
  filter.addInput(micInput);
}
else {
  filter.clearInputConnections();
  filter.addInput(player);
  }
}

void Reverb(){
  if (reverbOn) {
    reverbOn = false;
    reverb.clearInputConnections();
    masterGain.clearInputConnections();
    masterGain.addInput(filter);
  }
  else {
    reverbOn = true;
    masterGain.clearInputConnections();
    reverb.addInput(filter);
    masterGain.addInput(reverb);
  }
}

void BandPassFilter(){
   println("BP filter button pressed");
  filter.setType(BiquadFilter.BP_SKIRT);
}

public void CutoffSlider(float value){
  println("cuttoff slider pressed");
  cutoffGlide.setValue(value);
}

public void Damping(float value){
  println("damping slider pressed");
  reverb.setDamping(value);
}
float resynthVal = 0;
void resynthGainSlider(float value) {
  resynthVal = value / 200;
  if (resynthOn) {
    waveGain.setGain(resynthVal);
}
}
boolean resynthOn = false;

void resynthButton() {
    resynthOn = !resynthOn;
    if (resynthOn) {
      masterGain.setGain(0.075);
      waveGain.setGain(resynthVal);
    } else {
    masterGain.setGain(0.5);
    waveGain.setGain(0);
    }
}



int time;

void draw()
{
 int strongestFreqIndex = 0;
 background(back);
 stroke(fore);

  if (f.getFeatures() != null && random(1.0) > 0.75){
    float inputFrequency = f.getFeatures();
    if(inputFrequency < 3000){
      meanFrequency = (0.4 * inputFrequency) + (0.6 * meanFrequency);
      frequencyGlide.setValue(meanFrequency);
    }
  }
  fill(255);
  text(" Dectected Strongest Frequency: " + meanFrequency, 500, 100);
  fill(brightness*255);
  ellipse(450, 95, 20, 20);
  
  int dt = millis() - time;
  brightness -= (dt *0.01);
  if (brightness < 0) brightness = 0;
  time += dt;
  
  strongestFreqIndex = (int) ((meanFrequency / 19980.0) * 256.0);

 // The getFeatures() function is a key part of the Beads
 // analysis library. It returns an array of floats
 // how this array of floats is defined (1 dimension, 2
 // dimensions ... etc) is based on the calling unit
 // generator. In this case, the PowerSpectrum returns an
 // array with the power of 256 spectral bands.
 float[] features = ps.getFeatures();

 // if any features are returned
 if(features != null)
 {
 // for each x coordinate in the Processing window
 for(int x = 0; x < width; x++)
 {
 // figure out which featureIndex corresponds to this x-
 // position
 int featureIndex = (x * features.length) / width;
 // calculate the bar height for this feature
 int barHeight = Math.min((int)(features[featureIndex] *
 height), height - 1);
 if (featureIndex == strongestFreqIndex){
   stroke(highlight);
 }
   else{
     stroke(fore);
   }
 // draw a vertical line corresponding to the frequency
 // represented by this x-position
 line(x, height, x, height - barHeight);
 }
 }
}
