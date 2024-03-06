ServerOptions.devices;

s.options.sampleRate = 48000; // Set sample rate to 48000 Hz
s.reboot; // Reboot the server to apply changes

s.boot;
// Define notes as a global variable using a diatonic scale (C Major for example)
~notes = [60, 62, 64, 65, 67, 69, 71];

(
SynthDef("tintSynthStereo", { arg outBus=0, freq=440, amp=0.1, gate=1;
    var env = EnvGen.kr(Env.asr(0.01, 1, 0.1), gate, doneAction:2);
    var sig1 = SinOsc.ar(freq) * env * amp;
    var sig2 = Saw.ar(freq * 1.01) * env * amp; // Detuned saw wave for a fuller sound
    var stereoSig = [sig1, sig2]; // Create a stereo signal
    Out.ar(outBus, stereoSig);
}).add;

SynthDef("droneSynthStereo", { arg outBus=0, freq=440, amp=0.05, gate=1;
    var env = EnvGen.kr(Env.asr(2, 1, 2), gate, doneAction:2); // Slow attack and release
    var sig1 = Pulse.ar(freq, width:0.2) * env * amp; // Pulse wave with a narrow width
    var sig2 = LFTri.ar(freq * 0.99) * env * amp; // Detuned triangle wave
    var stereoSig = [sig1, sig2];
    Out.ar(outBus, stereoSig);
}).add;

SynthDef("variationSynthStereo", { arg outBus=0, freq=440, amp=0.1, gate=1;
    var env = EnvGen.kr(Env.asr(0.01, 1, 0.1), gate, doneAction:2);
    var sig1 = VarSaw.ar(freq, width:0.5) * env * amp; // Variable saw wave
    var sig2 = LFPar.ar(freq * 1.02) * env * amp; // Detuned parabolic wave
    var stereoSig = [sig1, sig2];
    Out.ar(outBus, stereoSig);
}).add;

// *** Pattern Generators ***

// 1. Randomized melodic pattern using the diatonic scale
Pbind(
    \instrument, \tintSynthStereo,
    \dur, Prand([1, 2, 3, 4], inf),
    \midinote, Pxrand(~notes, inf), // Randomly select notes from the diatonic scale
    \amp, Pwhite(0.05, 0.15, inf) // Randomize amplitude between 0.05 and 0.15
).play;

// 2. Drone with random note changes
Pbind(
    \instrument, \droneSynthStereo,
    \dur, Pwhite(8, 16, inf), // Randomize duration between 8 and 16 beats
    \midinote, Prand(~notes, inf), // Randomly select notes from the diatonic scale
    \amp, 0.05
).play;

// 3. Parallel movement variation with randomized intervals and durations
Pbind(
    \instrument, \variationSynthStereo,
    \dur, Prand([2, 3, 4], inf),
    \midinote, Pxrand([
        Prand(~notes, inf),
        Prand(~notes.collect(_ + Prand([-2, 2], inf)), inf), // Randomly shift notes up or down by 2
        Prand(~notes.collect(_ + Prand([-4, 4], inf)), inf) // Randomly shift notes up or down by 4
    ], inf),
    \amp, Pwhite(0.08, 0.12, inf) // Randomize amplitude between 0.08 and 0.12
).play;
)