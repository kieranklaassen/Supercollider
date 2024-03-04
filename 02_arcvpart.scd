ServerOptions.devices;

s.options.sampleRate = 48000; // Set sample rate to 48000 Hz s.reboot; // Reboot the server to apply changes
// Define notes as a global variable


s.boot;
// Define notes as a global variable using a diatonic scale (C Major for example)
~notes = [60, 62, 64, 65, 67, 69, 71];

(
SynthDef("tintSynthStereo", { arg outBus=0, freq=440, amp=0.1, gate=1; // Lower amp for softer sound
    var env = EnvGen.kr(Env.asr(0.01, 1, 0.1), gate, doneAction:2);
    var sig = SinOsc.ar(freq) * env * amp;
    var stereoSig = [sig, sig]; // Create a stereo signal
    Out.ar(outBus, stereoSig);
}).add;

// *** Pattern Generators ***
// Adjusted for softer sounds and stereo output

// 1. Slow melodic pattern using the diatonic scale
Pbind(
    \instrument, \tintSynthStereo,
    \dur, Pseq([4, 3, 5, 4], inf),
    \midinote, Pseq(~notes, inf), // Cycle through the diatonic scale
    \amp, 0.1 // Softer
).play;

// 2. Static drone – single held note, softer and in stereo
Pbind(
    \instrument, \tintSynthStereo,
    \dur, 16, // Long duration
    \midinote, ~notes[0], // Use root note of the diatonic scale
    \amp, 0.05 // Much softer for background
).play;

// 3. Parallel movement variation using the diatonic scale, softer and in stereo
Pbind(
    \instrument, \tintSynthStereo,
    \dur, Pseq([3, 2, 3.5], inf),
    \midinote, Pseq([
        ~notes + 2, // Shift the diatonic scale up
        ~notes,
        ~notes - 2 // Shift the diatonic scale down
    ], inf),
    \amp, 0.1
).play;
)
