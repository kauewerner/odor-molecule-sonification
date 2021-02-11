(
//// Create main window ================================================================ ////
Window.closeAll;
w = Window.new("Odor Molecule Sonification",
	Rect.new(0,
	Window.screenBounds.height/4,
	Window.screenBounds.width/4,
	Window.screenBounds.height/2))
.front
.background_(Color.white)
.alwaysOnTop_(true);
//// Add selection Menu ================================================================ ////
StaticText(w,Rect(w.bounds.width/3,w.bounds.height*0.025,2*w.bounds.width/3,w.bounds.height/12))
.font_(Font.new(Font.defaultSansFace,22,true))
.string_("Choose a molecule:");
PopUpMenu.new(w,Rect(w.bounds.width/5,0.1*w.bounds.height,w.bounds.width/2,w.bounds.height/12))
.items_(~moleculeNames)
.action_({
	arg obj;
	~molIdx = obj.value;
});
Button(w,Rect(w.bounds.width*0.7,0.1*w.bounds.height,0.1*w.bounds.width,w.bounds.height/12))
.states_([
["ok",Color.black,Color.new(0,1,0.5)]
])
.action_({
	arg obj;
	var currentMolecule;
	if(obj.value == 0,{
		if( (~activeMolecules.indicesOfEqual(~moleculeNames[~molIdx].asString).isNil) ,{
			currentMolecule = ~moleculeNames[~molIdx];
		},{
			currentMolecule = (~moleculeNames[~molIdx].asString++"_"++~repetitionIdx.asString).asSymbol;
			~repetitionIdx = ~repetitionIdx + 1;
		});
		~activeMolecules = ~activeMolecules.add(currentMolecule);
		~generate_window.value(currentMolecule,~currentWindowPosition);
		~activeMolecules.do{|molecule|
			~modulatorDict[molecule.asSymbol].items_(~activeMolecules)
		};
	});
});
//// Add bpm knob ====================================================================== ////
~bpmNB = NumberBox(w,Rect(0.4125*w.bounds.width,0.325*w.bounds.height,0.15*w.bounds.width,0.05*w.bounds.height))
.valueAction_(~bpm)
.align_('center')
.background_(Color.black)
.normalColor_(Color.white);
~bpmKnob = Knob(w,Rect(0.25*w.bounds.width,0.3*w.bounds.height,0.1*w.bounds.height,0.1*w.bounds.height))
.valueAction_((~bpm-~bpmRange[0])/(~bpmRange[1]-~bpmRange[0]))
.step_(1.0/(~bpmRange[1]-~bpmRange[0]))
.action_({
	arg obj;
    ~bpm = obj.value.asFloat.linlin(0,1,~bpmRange[0],~bpmRange[1]).asInteger;
	~bpmNB.valueAction_(obj.value.asFloat.linlin(0,1,~bpmRange[0],~bpmRange[1]).asInteger);
	~activeMolecules.do{arg idx;
		Pbindef(idx.asSymbol,\dur,Pseq((60/~bpm)*~currentValues[idx.asSymbol]['duration'],inf));
		if(~activationDict[idx.asSymbol],{
			Pbindef(idx.asSymbol).play;
		})
	};
});
StaticText(w,Rect(0.575*w.bounds.width,0.3*w.bounds.height,0.1*w.bounds.width,0.1*w.bounds.height))
.align_(\center)
.stringColor_(Color.black)
.string_("bpm");
//// Add play/stop button ================================================================ ////
~playStopAll = Button(w,Rect(w.bounds.height/6,w.bounds.height*0.825,w.bounds.height/5,w.bounds.height/12))
.states_([
["play all",Color.black,Color.white],
["stop all",Color.white,Color.black],
])
.action_({
	arg obj;
	if(obj.value == 0,{
		~activeMolecules.do{arg mIdx;
			Pbindef(mIdx.asSymbol).stop;
			~playButtonDict[mIdx.asSymbol].valueAction_(0);
			~activationDict[mIdx.asSymbol] = false;
		};
	});
	if(obj.value == 1,{
		~activeMolecules.do{arg mIdx;
			Pbindef(mIdx.asSymbol).play;
			~playButtonDict[mIdx.asSymbol].valueAction_(1);
			~activationDict[mIdx.asSymbol] = true;
		};
	});
});
//// Add close all button ================================================================ ////
Button(w,Rect((w.bounds.width/1.25) - (w.bounds.height/6),w.bounds.height*0.825,w.bounds.height/5,w.bounds.height/12))
.states_([
["close all",Color.white,Color.red]
])
.action_({
	arg obj;
	if(obj.value == 0,{
		~windowDict.keys.asArray.do{|key| ~windowDict[key.asSymbol].close};
		// ~activeMolecules.do{arg mIdx; Pbindef(mIdx.asSymbol).stop};
		~playStopAll.valueAction_(0);
		~activeMolecules.do{arg mIdx; Pbindef(mIdx.asSymbol).clear};
		~activeMolecules.do{arg idx; ~activationDict[idx.asSymbol] = false};
		~activeMolecules = [];
		~repetitionIdx = 2;
	});
});
//// Add load sequences option =========================================================== ////
Button(w,Rect((w.bounds.width/1.25) - (w.bounds.height/6),w.bounds.height*0.5,w.bounds.height/4,w.bounds.height/12))
.states_([
["load sequence",Color.white,Color.black]
])
.action_({
	arg obj;
	if(obj.value == 0,{
		~loadTextField.doAction;
		~flagLoadFile = True;
		~load_file.value(~loadFileName);
		~bpmKnob.valueAction_((~bpm-~bpmRange[0])/(~bpmRange[1]-~bpmRange[0]));
		~bpmNB.valueAction_(~bpm);
	})
});
~loadTextField = TextField(w,Rect(w.bounds.width*0.15,w.bounds.height*0.5,w.bounds.height/2.5,w.bounds.height/12))
.valueAction_(~loadFileName)
.action_(
	{|obj|
		~loadFileName = obj.value;
	}
);
//// Add save sequences option =========================================================== ////
Button(w,Rect((w.bounds.width/1.25) - (w.bounds.height/6),w.bounds.height*0.65,w.bounds.height/4,w.bounds.height/12))
.states_([
["save sequence",Color.white,Color.black]
])
.action_({
	arg obj;
	if(obj.value == 0,{
			var f, date;
		~saveTextField.doAction;
		if(~saveTextField.isNil,{
		~saveFileName = "saved_seq_"
				++date.day.asString++"_"
				++date.month.asString++"_"
				++date.year.asString++"_"
				++date.hour.asString++"_"
				++date.minute.asString++"_"
			++date.second.asString++".txt"
		});
		f = File(~path++"saved_sequences/"++~saveFileName,"w");
		f.write("bpm\t"++~bpm.asInteger.asString++"\n");
		f.write("molecule\toctave\tvolume\tattack\trelease\tpan\tnotes\tduration\tsteps\tattack_f\trelease_f\tcutoff\tresonance\tmod_depth\tmodulator\n");
			~activeMolecules.do{arg mIdx;
				f.write(mIdx++"\t");
				f.write(~currentValues[mIdx.asSymbol][\octave].asString++"\t");
				f.write(~currentValues[mIdx.asSymbol][\volume].asString++"\t");
				f.write(~currentValues[mIdx.asSymbol][\attack].asString++"\t");
				f.write(~currentValues[mIdx.asSymbol][\release].asString++"\t");
				f.write(~currentValues[mIdx.asSymbol][\pan].asString++"\t");
				f.write(~currentValues[mIdx.asSymbol][\notes].asString++"\t");
				f.write(~currentValues[mIdx.asSymbol][\duration].asString++"\t");
				f.write(~currentValues[mIdx.asSymbol][\steps].asString++"\t");
			    f.write(~currentValues[mIdx.asSymbol][\attack_f].asString++"\t");
				f.write(~currentValues[mIdx.asSymbol][\release_f].asString++"\t");
			    f.write(~currentValues[mIdx.asSymbol][\cutoff].asString++"\t");
				f.write(~currentValues[mIdx.asSymbol][\resonance].asString++"\t");
			    f.write(~currentValues[mIdx.asSymbol][\mod_depth].asString++"\t");
				f.write(~currentValues[mIdx.asSymbol][\modulator].asString++"\n");
			};
		("The molecule sequence was saved as: ./saved_sequences/"++~saveFileName).postln;
		"______________________________________________________________\n".postln;
			f.close;
	})
});
~saveTextField = TextField(w,Rect(w.bounds.width*0.15,w.bounds.height*0.65,w.bounds.height/2.5,w.bounds.height/12))
.valueAction_(~saveFileName)
.action_(
	{|obj|
		~saveFileName = obj.value;
	}
);
w.onClose = {
	Window.closeAll;
	~activeMolecules.do{arg mIdx; Pbindef(mIdx.asSymbol).stop};
	~activeMolecules.do{arg mIdx; Pbindef(mIdx.asSymbol).clear};
	~activeMolecules.do{arg idx; ~activationDict[idx.asSymbol] = false};
	~activeMolecules = [];
	~repetitionIdx = 2;
};
//// ==================================================================================== ////
)
