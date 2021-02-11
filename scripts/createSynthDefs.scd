//// Create SynthDef for each molecule in the database ===================================== ////
(
Buffer.freeAll;
/*~scaleDict = Dictionary.new;
~bufs = Dictionary.new;*/
// ~moleculeNames = ["citronellal","geraniol"];
~moleculeNames.do{arg molecule;
	var normAmp;
	// var normAmp = 1/(~spectrum[molecule.asSymbol].size);
	// ~amplitude[molecule.asSymbol].maxItem.postln;
	normAmp = 1/~amplitude[molecule.asSymbol].sum;
	/*normAmp.postln;
	"________________________________________".postln;*/
	~bufs[molecule.asSymbol] = Buffer.alloc(s,2048);
	~bufs[molecule.asSymbol].sine3(~spectrum[molecule.asSymbol],~amplitude[molecule.asSymbol],(90.0!~spectrum[molecule.asSymbol].size).rand);
	~scaleDict.put(molecule.asSymbol,~scale[molecule.asSymbol]);
	// ~scaleDict.put(molecule.asSymbol,~frequency[molecule.asSymbol]);
	SynthDef.new(molecule,{
		arg freq = 400, main_amp = 0.01, azi = 0, out =0,
		at = 0.001, re = 0.5, ca = 0, cr = 0,
		at_f = 0.0001, re_f = 10, ca_f = 0, cr_f = 0,
		fmin = 30, cutoff = 20000, resonance = 0,
		mod_depth=0, mod_freq = 100;
		var sig, env, envf;
		sig = DynKlang.ar(`[
			~spectrum[molecule.asSymbol]*freq*(1 + SinOsc.ar(mod_freq,mul:mod_depth)),
			~amplitude[molecule.asSymbol],
			(pi!~spectrum[molecule.asSymbol].size).rand
		],1);
		env = EnvGen.ar(Env.perc(at,re,curve:[ca,cr]),doneAction:2);
		envf = EnvGen.kr(Env.perc(at_f,re_f,curve:[ca_f,cr_f]),doneAction:0);
		// sig = LPF.ar(sig,fmin + (envf * frange));
		sig = MoogFF.ar(sig,fmin + (envf * cutoff), resonance);
		sig = Pan2.ar(sig * env, azi, main_amp*normAmp);
		Out.ar(out,sig);
	}).add;
};
/*SynthDef.new('wavetableOsc',{
		arg freq = 400, buf, main_amp = 0.01, at = 0.001, re = 0.5, azi = 0;
		var env, sig;
	    sig = Osc.ar(buf,freq);
		env = EnvGen.ar(Env.perc(at,re),doneAction:2);
		sig = Pan2.ar(sig * env, azi, main_amp);
		Out.ar(0,sig);
	}).add;*/
"SynthDefs were created for all molecules in the database\n".postln;
"______________________________________________________________\n".postln;
//// ======================================================================================= ////
)


