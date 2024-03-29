// Set server options
s.options.sampleRate = 48000; // Set sample rate to 48000 Hz
s.reboot; // Reboot the server to apply changes

// Define a SynthDef for filtered pink noise
SynthDef(\filteredPinkNoise, { |out=0, freq=440, pan=0|
    var signal, env;

    // Generate pink noise
    signal = PinkNoise.ar(1);

    // Apply band-pass filter
    signal = BPF.ar(signal, freq, 0.05);

    // ADSR envelope like a raindrop with a long decay
    env = EnvGen.ar(Env.perc(0.01, 2, 1, -4), doneAction:2);
    signal = signal * env;

    // Pan the signal
    Out.ar(out, Pan2.ar(signal, pan));
}).add;

// Define a SynthDef for a drone
SynthDef(\drone, { |out=0, freqs=#[440, 550, 660, 770], amp=0.01, atk=3, rel=7|
    var signal, env, leftSignal, rightSignal;

    // Create a sum of sine waves for each frequency
    signal = Mix(SinOsc.ar(freqs, 0, amp));

    // ADSR envelope with long attack and decay
    env = EnvGen.ar(Env.linen(atk, 5, rel, 1, -4), doneAction:2);
    signal = signal * env;

    // Stereo widening effect by slightly detuning left and right channels
    leftSignal = signal * LFNoise2.kr(0.4).range(0.98, 1.02);
    rightSignal = signal * LFNoise2.kr(0.4).range(0.98, 1.02);

    // Add reverb (optional, add if needed)
    signal = FreeVerb.ar(signal, 0.4, 0.9, 0.5);

    Out.ar(out, [leftSignal, rightSignal]);
}).add;

// Function to randomly choose a frequency from the A minor scale
~randomFreq = {
    var scale = Scale.minorPentatonic.degrees;
    var root = 69; // MIDI note number for A4
    var note = root + scale.choose;
    440 * (2 ** ((note - 69) / 12));
};

// Function to generate random chord frequencies
~randomChord = {
    var scale = Scale.minorPentatonic.degrees;
    var root = 69; // MIDI note number for A4
    var notes = List.fill(4, { root + scale.choose });
    notes = notes.scramble; // Randomize note order
    notes.collect({ |note| 440 * (2 ** ((note - 69) / 12)) });
};

// Random Sequencer for filteredPinkNoise
{
    var freq, pan;
    inf.do {
        freq = ~randomFreq.value;
        pan = 2.rand - 1; // Random pan between -1 and 1
        Synth(\filteredPinkNoise, [freq: freq, pan: pan]);
        0.5.wait; // Wait for 500 ms
    };
}.fork;

// Random Sequencer for drone
{
    var chordFreqs;
    inf.do {
        chordFreqs = ~randomChord.value;
        Synth(\drone, [freqs: chordFreqs]);
        10.wait; // Change chord every 10 seconds
    };
}.fork;
