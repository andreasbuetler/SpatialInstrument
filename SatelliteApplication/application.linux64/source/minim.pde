import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;

Minim minim;
AudioOutput out;

Sampler    beatSampler;
MoogFilter beatFilter;
Delay      beatDelay;

Sampler    singleSampler;
Gain       singleSamplerGain;

FilePlayer ambient;
Gain       ambientGain;
MoogFilter ambientFilter;
Flanger    ambientFlanger;

FilePlayer loop1;
Gain       loop1Gain;
MoogFilter loop1Filter;

FilePlayer loop3;
Gain       loop3Gain;

Oscil LFO;


float testy;
float testx;

boolean playBeatSample;
boolean playSingleSample; 

float beatDelayTime          = 0.4;
float beatFilterFreq         = 500;

float ambientFilterFreq      = 800;
float ambientGainValue       = -5;

float singleSamplerGainValue = -20;

float loop1GainValue         = -20;
float loop1FilterFreq        = 200;
float loop1FilterFreqMin     = 200;
float loop1FilterFreqMax     = 2000;

float LFOFreq                = 5;
float LFOFreqMin             = 1;
float LFOFreqMax             = 30;

float loop3GainValue         = -20;
float loop3GainValueMin      = -10;
float loop3GainValueMax      = 10;
float loop3GainCurve         = 0.99;

boolean beatTap = false;
boolean singleSample = false;
float pingbeatDelay;
float weatherdata;
float coordinateSurface;
float userQty;


void soundSetup() {
  //size(300, 300, P3D);
  minim = new Minim(this);
  out = minim.getLineOut();

  beatSampler = new Sampler("claveBeat.wav", 10, minim);
  singleSampler = new Sampler("bass.wav", 10, minim);
  ambient = new FilePlayer(minim.loadFileStream("ambientLoop.wav"));
  loop1 = new FilePlayer(minim.loadFileStream("testloop.wav"));
  loop3 = new FilePlayer(minim.loadFileStream("loop3.wav"));

  //Gain
  ambientGain = new Gain(0.f);
  singleSamplerGain = new Gain(0.f);
  loop1Gain = new Gain(0.f);
  loop3Gain = new Gain(0.f);
  ambientGain.setValue(ambientGainValue);
  loop1Gain.setValue(loop1GainValue);
  singleSamplerGain.setValue(singleSamplerGainValue);

  //Flanger
  ambientFlanger = new Flanger( 1, // beatDelay length in milliseconds ( clamped to [0,100] )
    0.001f, // lfo rate in Hz ( clamped at low end to 0.001 )
    1, // beatDelay depth in milliseconds ( minimum of 0 )
    0.f, // amount of feedback ( clamped to [0,1] )
    0.7f, // amount of dry signal ( clamped to [0,1] )
    0.3f    // amount of wet signal ( clamped to [0,1] )
    );

  //beatDelays
  beatDelay = new Delay(beatDelayTime, 0.8, true, true );

  //Filter
  beatFilter = new MoogFilter(ambientFilterFreq, 0.9);
  ambientFilter= new MoogFilter(ambientFilterFreq, 0.7); 
  loop1Filter= new MoogFilter(loop1FilterFreq, 0.3); 

  //LFOs
  LFO = new Oscil(1, 2f, Waves.SQUARE);

  //routing
  beatSampler.patch(beatDelay).patch(beatFilter).patch(out);
  singleSampler.patch(singleSamplerGain).patch(out);
  ambient.patch(ambientGain).patch(ambientFlanger).patch(out);
  loop1.patch(loop1Gain).patch(loop1Filter).patch(out);
  loop3.patch(loop3Gain).patch(out);

  //playSounds
  playAmbientLoop();
  loop1Gain.setValue(-20);
  loop1.loop();
  loop3.loop();
}


void updateSoundParameters() {
  if (playBeatSample) {
    playRhythm();
  }
  if (playSingleSample) {
    playSingleSample();
  }

  beatDelay.setDelTime(beatDelayTime);
  loop1Filter.frequency.setLastValue(loop1FilterFreq);
  ambientFlanger.rate.setLastValue(LFOFreq);
  loop3Gain.setValue(loop3GainValue);
}
void playRhythm() {
  beatFilter.frequency.setLastValue(constrain(beatFilter.frequency.getLastValue()+random(-500, 500), 1000, 2000));
  beatSampler.trigger();
}

void playSingleSample() {
  singleSampler.trigger();
}

void playAmbientLoop() {
  ambient.loop();
}

void valueParsing() {
  playBeatSample = beatTap;
  playSingleSample = singleSample;
  beatDelayTime = map(pingbeatDelay, 0, 1, 0, 0.4); //real vlaues??
  loop1FilterFreq = map(weatherdata, 0, 1, loop1FilterFreqMin, loop1FilterFreqMax);
  LFOFreq = map(userQty, 0, 1, LFOFreqMin, LFOFreqMax); //>>LFO Speed
  loop3GainValue = loop3GainValue*loop3GainCurve+map(coordinateSurface, 0, 1, loop3GainValueMin, loop3GainValueMax)*(1-loop3GainCurve);
  playSingleSample = singleSample;
}
