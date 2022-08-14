(
//// Function: Volume adjusment based on octave ======================================= ////
~octave_level_factor = {|octave, min, max|
	var return;
	// return = octave.linlin(min,max,1.0,0.25);
	1.0;
};
//// Function: Volume adjusment based on release ====================================== ////
~release_level_factor = {|release, min, max|
	var return;
	// return = release.linlin(min,max,2.0,0.125);
	1.0;
};
//// Function: Map input GUI element values (0 to 1) on a list ======================== ////
~map_on_list = { |input, list|
	var delta = 1/(list.size), return = [];
	input.do{|inputElement|
		if(inputElement == 1, {return = return.add(list[list.size-1])},{
			list.sort.do{|listElement,idx|
				var current = (idx*delta), next = (idx+1)*delta;
				if( (inputElement >= current) && (inputElement < next),
					{return = return.add(listElement)}
				);
			}
		}
		);
	};
	return
};
//// Function: Map list values on input GUI element values (0 to 1) ==================== ////
~map_from_list = { |inputList, list|
	var delta = 1/(list.size), sortedList = list.sort, sortedMap,return = [];
	sortedMap = (0,delta..1);
	inputList.do{|listElement|
		var i = sortedList.indicesOfEqual(listElement);
		if(i.notNil,{return = return.add(sortedMap[i][0])});
	};
	return
};
//// Function: Generate window for a specific molecule ================================= ////
~generate_window = {|moleculeName, windowPosition|
	var wi, he, atKnob, reKnob, durKnob, knobSize, windowSize,atfKnob, refKnob,
	themeColor,stepKnobValue,stepNB,octNB,octValue,activeSeq, synthName, flagRemoveTwin = false;
	("Window generation of molecule "++ moleculeName ++ " started...\n").postln;
	activeSeq = [];
	stepKnobValue = 1;
	octValue = 1;
	themeColor = Color.new(0.5.rand + 0.5,0.5.rand + 0.5,0.5.rand + 0.5);
	windowSize = Rect(windowPosition,
		// Window.screenBounds.height/2,
		Window.screenBounds.height*0.1,
			Window.screenBounds.width/5,
			Window.screenBounds.height*0.85
	);

	if(~scaleDict.keys.asArray.indicesOfEqual(moleculeName.asSymbol).isNil,{
		synthName = moleculeName.asString;
		synthName = synthName[0..synthName.size-3].asSymbol;
		~scaleDict.put(moleculeName.asSymbol,~scaleDict[synthName]);
		~scale.put(moleculeName.asSymbol,~scale[synthName]);
		~activationDict.put(moleculeName.asSymbol,false);
		flagRemoveTwin = true;
	},{
		synthName = moleculeName.asSymbol;
	});


	//// initialize parameters (if not imported from file)
	if(~flagLoadFile == False,{
		~initialValue[moleculeName.asSymbol] = Dictionary.new;
		~initialValue[moleculeName.asSymbol][\octave] = 0;
		~initialValue[moleculeName.asSymbol][\volume] = 0.15;
		~initialValue[moleculeName.asSymbol][\attack] = 0.01;
		~initialValue[moleculeName.asSymbol][\release] = 0.5;
		~initialValue[moleculeName.asSymbol][\pan] = 0;

		if(~scaleDict[moleculeName.asSymbol].size > 20,{
			~initialValue[moleculeName.asSymbol][\notes] = (0..19);
			~initialValue[moleculeName.asSymbol][\duration] = 1!20;
			~initialValue[moleculeName.asSymbol][\steps] = 20;
		},{
			~initialValue[moleculeName.asSymbol][\notes] = (0..(~scaleDict[moleculeName.asSymbol].size-1));
			~initialValue[moleculeName.asSymbol][\duration] = 1!(~scaleDict[moleculeName.asSymbol].size);
			~initialValue[moleculeName.asSymbol][\steps] = ~scaleDict[moleculeName.asSymbol].size;
		});

		~initialValue[moleculeName.asSymbol][\attack_f] = 0.001;
		~initialValue[moleculeName.asSymbol][\release_f] = 1;
		~initialValue[moleculeName.asSymbol][\cutoff] = ~parameterRange[\cutoff][1];
		~initialValue[moleculeName.asSymbol][\resonance] = ~parameterRange[\resonance][0];
		~initialValue[moleculeName.asSymbol][\mod_depth] = ~parameterRange[\mod_depth][0];
		~initialValue[moleculeName.asSymbol][\modulator] = moleculeName.asSymbol;
	});

	//// initialize dictionaries to save current values
	~currentValues[moleculeName.asSymbol] = Dictionary.new;
	~currentValues[moleculeName.asSymbol] = ~initialValue[moleculeName.asSymbol];

	//// initialize patterns
	Pbindef(moleculeName.asSymbol,\instrument,synthName);
	Pbindef(moleculeName.asSymbol,\freq,Pseq(((2**~initialValue[moleculeName.asSymbol][\octave])/(2**2))*~scaleDict[moleculeName.asSymbol][~initialValue[moleculeName.asSymbol][\notes]],inf));
	Pbindef(moleculeName.asSymbol,\dur,Pseq((60/~bpm)*(~initialValue[moleculeName.asSymbol][\duration]),inf));
	Pbindef(moleculeName.asSymbol,\at,~initialValue[moleculeName.asSymbol][\attack]);
	Pbindef(moleculeName.asSymbol,\re,~initialValue[moleculeName.asSymbol][\release]);

	Pbindef(moleculeName.asSymbol,\azi,~initialValue[moleculeName.asSymbol][\pan]);
	Pbindef(moleculeName.asSymbol,\at_f,~initialValue[moleculeName.asSymbol][\attack_f]);
	Pbindef(moleculeName.asSymbol,\re_f,~initialValue[moleculeName.asSymbol][\release_f]);
	Pbindef(moleculeName.asSymbol,\cutoff,~initialValue[moleculeName.asSymbol][\cutoff]);
	Pbindef(moleculeName.asSymbol,\resonance,~initialValue[moleculeName.asSymbol][\resonance]);
	Pbindef(moleculeName.asSymbol,\mod_depth,~initialValue[moleculeName.asSymbol][\mod_depth]);
	Pbindef(moleculeName.asSymbol,\mod_freq,Pseq(((2**~initialValue[moleculeName.asSymbol][\octave])/(2**2))*~scaleDict[moleculeName.asSymbol][~initialValue[moleculeName.asSymbol][\notes]],inf));

	~parameterRange[\attack][moleculeName.asSymbol] = [0.001,4*(~initialValue[moleculeName.asSymbol]['duration'].minItem)];
	~parameterRange[\attack_f][moleculeName.asSymbol] = [0.001,4*(~initialValue[moleculeName.asSymbol]['duration'].minItem)];
	~parameterRange[\release][moleculeName.asSymbol] = [0.001,4*(~initialValue[moleculeName.asSymbol]['duration'].minItem)];
	~parameterRange[\release_f][moleculeName.asSymbol] = [0.001,4*(~initialValue[moleculeName.asSymbol]['duration'].minItem)];


	Pbindef(moleculeName.asSymbol,\main_amp,~initialValue[moleculeName.asSymbol][\volume]*~octave_level_factor.value(~initialValue[moleculeName.asSymbol][\octave],~parameterRange[\octave][0],~parameterRange[\octave][1])*~release_level_factor.value(~initialValue[moleculeName.asSymbol][\release],~parameterRange[\release][moleculeName.asSymbol][0],~parameterRange[\release][moleculeName.asSymbol][1]));

	//// molecule window
	~windowDict[moleculeName.asSymbol] = Window.new(moleculeName.asString,windowSize)
	.front
	.background_(themeColor)
	.alwaysOnTop_(true);
	wi = ~windowDict[moleculeName.asSymbol].bounds.width;
	he = ~windowDict[moleculeName.asSymbol].bounds.height;
	knobSize = 0.15;

	//// draw function
	~windowDict[moleculeName.asSymbol].drawFunc = {
		Pen.strokeColor_(Color.black);
		Pen.width_(4);
		Pen.strokeRect(Rect(0,0,wi,0.125*he));
		Pen.strokeRect(Rect(0,0.25*he,wi,0.125*he));
		Pen.strokeRect(Rect(0,0.5*he,wi,0.085*he));
		Pen.strokeRect(Rect(0,0.885*he,wi,0.125*he));
		Pen.stringInRect("filter",Rect(0.025*wi,0.255*he,0.1*wi,0.15*he));
		Pen.stroke;
	};

	//// play/stop button
	~playButtonDict[moleculeName.asSymbol] = Button(~windowDict[moleculeName.asSymbol],Rect(0.1*wi,0.05*he,75,50))
	.states_([
		["play",Color.black,Color.white],
		["stop",Color.white,Color.black],
	])
	.action_({
		arg obj;
		if(obj.value == 1,{
			Pbindef(moleculeName.asSymbol).play;
			if(~playStopAll.value != 1,{~playStopAll.value_(1)});
		},
			{
			Pbindef(moleculeName.asSymbol).stop;
		});

	});

	//// modulator selection
	StaticText(~windowDict[moleculeName.asSymbol],Rect(0.075*wi,0.165*he,0.25*wi,50))
    .string_("modulator:");
	~modulatorDict[moleculeName.asSymbol] = PopUpMenu.new(~windowDict[moleculeName.asSymbol],Rect(0.305*wi,0.165*he,0.35*wi,50))
	.items_(~activeMolecules)
	.action_({
		arg obj;
		~currentValues[moleculeName.asSymbol][\modulator] = ~activeMolecules[obj.value].asSymbol;
		Pbindef(moleculeName.asSymbol,\mod_freq,Pseq(((2**~currentValues[~currentValues[moleculeName.asSymbol][\modulator]][\octave])/(2**2))*~scaleDict[~currentValues[moleculeName.asSymbol][\modulator]][~currentValues[~currentValues[moleculeName.asSymbol][\modulator]][\notes]],inf));
	});
	//// modulation depth
	Knob(~windowDict[moleculeName.asSymbol],Rect(0.75*wi,0.14*he,knobSize*wi,knobSize*wi))
	.valueAction_(~initialValue[moleculeName.asSymbol][\mod_depth].linlin(~parameterRange[\mod_depth][0],~parameterRange[\mod_depth][1],0.0,1.0))
	.action_({
		arg obj;
		~currentValues[moleculeName.asSymbol][\mod_depth] = obj.value.linlin(0,1,~parameterRange[\mod_depth][0],~parameterRange[\mod_depth][1]);
		Pbindef(moleculeName.asSymbol,\mod_depth,~currentValues[moleculeName.asSymbol][\mod_depth]);
	});
	StaticText(~windowDict[moleculeName.asSymbol],Rect(0.75*wi,0.2*he,80,50))
	.align_(\center)
	.string_("depth");

	//// filter attack
	atfKnob = Knob(~windowDict[moleculeName.asSymbol],Rect(0.1*wi,0.275*he,knobSize*wi,knobSize*wi))
	.valueAction_(~initialValue[moleculeName.asSymbol][\attack_f].explin(~parameterRange[\attack_f][moleculeName.asSymbol][0],~parameterRange[\attack_f][moleculeName.asSymbol][1],0.0,1.0))
	.action_({
		arg obj;
		~currentValues[moleculeName.asSymbol][\attack_f] = obj.value.linlin(0,1,~parameterRange[\attack_f][moleculeName.asSymbol][0],~parameterRange[\attack_f][moleculeName.asSymbol][1]);
		Pbindef(moleculeName.asSymbol,\at_f,~currentValues[moleculeName.asSymbol][\attack_f]);
	});
	StaticText(~windowDict[moleculeName.asSymbol],Rect(0.1*wi,0.325*he,80,50))
	.align_(\center)
	.string_("attack");

	////  filter release
	refKnob = Knob(~windowDict[moleculeName.asSymbol],Rect(0.325*wi,0.275*he,knobSize*wi,knobSize*wi))
	.valueAction_(~initialValue[moleculeName.asSymbol][\release_f].linlin(~parameterRange[\release_f][moleculeName.asSymbol][0],~parameterRange[\release_f][moleculeName.asSymbol][1],0.0,1.0))
	.action_({
		arg obj;
		~currentValues[moleculeName.asSymbol][\release_f] = obj.value.linlin(0,1,~parameterRange[\release_f][moleculeName.asSymbol][0],~parameterRange[\release_f][moleculeName.asSymbol][1]);
		Pbindef(moleculeName.asSymbol,\re_f,~currentValues[moleculeName.asSymbol][\release_f]);

	});
	StaticText(~windowDict[moleculeName.asSymbol],Rect(0.325*wi,0.325*he,80,50))
	.align_(\center)
	.string_("release");

	//// filter cutoff
	Knob(~windowDict[moleculeName.asSymbol],Rect(0.55*wi,0.275*he,knobSize*wi,knobSize*wi))
	.valueAction_(~initialValue[moleculeName.asSymbol][\cutoff].explin(~parameterRange[\cutoff][0],~parameterRange[\cutoff][1],0.0,1.0))
	.action_({
		arg obj;
		~currentValues[moleculeName.asSymbol][\cutoff] = obj.value.linexp(0,1,~parameterRange[\cutoff][0],~parameterRange[\cutoff][1]);
		Pbindef(moleculeName.asSymbol,\cutoff,~currentValues[moleculeName.asSymbol][\cutoff]);

	});
	StaticText(~windowDict[moleculeName.asSymbol],Rect(0.55*wi,0.325*he,80,50))
	.align_(\center)
	.string_("cutoff");

	//// filter resonance
	Knob(~windowDict[moleculeName.asSymbol],Rect(0.775*wi,0.275*he,knobSize*wi,knobSize*wi))
	.valueAction_(~initialValue[moleculeName.asSymbol][\resonance].linlin(~parameterRange[\resonance][0],~parameterRange[\resonance][1],0.0,1.0))
	.action_({
		arg obj;
		~currentValues[moleculeName.asSymbol][\resonance] = obj.value.linlin(0,1,~parameterRange[\resonance][0],~parameterRange[\resonance][1]);
		Pbindef(moleculeName.asSymbol,\resonance,~currentValues[moleculeName.asSymbol][\resonance]);

	});
	StaticText(~windowDict[moleculeName.asSymbol],Rect(0.76*wi,0.325*he,100,50))
	.align_(\center)
	.string_("resonance");


	//// pan slider
	Slider(~windowDict[moleculeName.asSymbol],Rect(0.2*wi,0.525*he,0.6*wi,0.025*he))
	.background_(Color.white)
	.knobColor_(Color.black)
	.valueAction_(~initialValue[moleculeName.asSymbol][\pan].linlin(-1.0,1.0,0,1.0))
	.action_({
		arg obj;
		Pbindef(moleculeName.asSymbol,\azi,obj.value.linlin(0,1.0,-1.0,1.0));
		~currentValues[moleculeName.asSymbol]['pan'] = obj.value.linlin(0,1.0,-1.0,1.0);

	});
	StaticText(~windowDict[moleculeName.asSymbol],Rect(0.45*wi,0.54*he,50,50))
	.align_(\center)
	.string_("pan");
	StaticText(~windowDict[moleculeName.asSymbol],Rect(0.125*wi,0.5125*he,0.05*wi,0.05*he))
	.string_("L");
	StaticText(~windowDict[moleculeName.asSymbol],Rect(0.85*wi,0.5125*he,0.05*wi,0.05*he))
	.string_("R");

	//// volume knob
	Knob(~windowDict[moleculeName.asSymbol],Rect(0.15*wi,0.39*he,knobSize*wi,knobSize*wi))
	.valueAction_((~initialValue[moleculeName.asSymbol][\volume]*~octave_level_factor.value(~initialValue[moleculeName.asSymbol][\octave],~parameterRange[\octave][0],~parameterRange[\octave][1])*~release_level_factor.value(~initialValue[moleculeName.asSymbol][\release],~parameterRange[\release][moleculeName.asSymbol][0],~parameterRange[\release][moleculeName.asSymbol][1])).linlin(~parameterRange[\volume][0],~parameterRange[\volume][1],0,1.0))
	.action_({
		arg obj;
		Pbindef(moleculeName.asSymbol,\main_amp,obj.value.linlin(0,1.0,~parameterRange[\volume][0],~parameterRange[\volume][1])*~octave_level_factor.value(~currentValues[moleculeName.asSymbol][\octave],~parameterRange[\octave][0],~parameterRange[\octave][1])*~release_level_factor.value(~currentValues[moleculeName.asSymbol][\release],~parameterRange[\release][moleculeName.asSymbol][0],~parameterRange[\release][moleculeName.asSymbol][1]));
		~currentValues[moleculeName.asSymbol]['volume'] = obj.value.linlin(0,1.0,~parameterRange[\volume][0],~parameterRange[\volume][1])*~octave_level_factor.value(~currentValues[moleculeName.asSymbol][\octave],~parameterRange[\octave][0],~parameterRange[\octave][1])*~release_level_factor.value(~currentValues[moleculeName.asSymbol][\release],~parameterRange[\release][moleculeName.asSymbol][0],~parameterRange[\release][moleculeName.asSymbol][1]);
	});
	StaticText(~windowDict[moleculeName.asSymbol],Rect(0.15*wi,0.45*he,80,50))
	.align_(\center)
	.string_("volume");

	//// attack knob
	atKnob = Knob(~windowDict[moleculeName.asSymbol],Rect(0.45*wi,0.39*he,knobSize*wi,knobSize*wi))
	.valueAction_(~initialValue[moleculeName.asSymbol][\attack].explin(~parameterRange[\attack][moleculeName.asSymbol][0],~parameterRange[\attack][moleculeName.asSymbol][1],0.0,1.0))
	.action_({
		arg obj;
		Pbindef(moleculeName.asSymbol,\at,obj.value.linexp(0,1,~parameterRange[\attack][moleculeName.asSymbol][0],~parameterRange[\attack][moleculeName.asSymbol][1]));
		~currentValues[moleculeName.asSymbol]['attack'] = obj.value.linexp(0,1,~parameterRange[\attack][moleculeName.asSymbol][0],~parameterRange[\attack][moleculeName.asSymbol][1]);
	});
	StaticText(~windowDict[moleculeName.asSymbol],Rect(0.45*wi,0.45*he,80,50))
	.align_(\center)
	.string_("attack");

	//// release knob
	reKnob = Knob(~windowDict[moleculeName.asSymbol],Rect(0.75*wi,0.39*he,knobSize*wi,knobSize*wi))
	.valueAction_(~initialValue[moleculeName.asSymbol][\release].linlin(~parameterRange[\release][moleculeName.asSymbol][0],~parameterRange[\release][moleculeName.asSymbol][1],0.0,1.0))
	.action_({
		arg obj;
		Pbindef(moleculeName.asSymbol,\re,obj.value.linlin(0,1,~parameterRange[\release][moleculeName.asSymbol][0],~parameterRange[\release][moleculeName.asSymbol][1]));
		~currentValues[moleculeName.asSymbol]['release'] = obj.value.linlin(0,1,~parameterRange[\release][moleculeName.asSymbol][0],~parameterRange[\release][moleculeName.asSymbol][1]);
	});
	StaticText(~windowDict[moleculeName.asSymbol],Rect(0.75*wi,0.45*he,80,50))
	.align_(\center)
	.string_("release");

	//// notes multislider
	StaticText(~windowDict[moleculeName.asSymbol],Rect(0.1*wi,0.6*he,0.125*wi,0.125*he))
	.string_("\+ \n notes \n \-")
	.stringColor_(Color.white)
	.background_(Color.black)
	.align_(\center);
	~notesDict[moleculeName.asSymbol] = MultiSliderView(~windowDict[moleculeName.asSymbol],Rect(0.225*wi,0.6*he,0.675*wi,0.125*he))
	.valueAction_(~initialValue[moleculeName.asSymbol][\notes].linlin(0,~scaleDict[moleculeName.asSymbol].size - 1,0,1))
	.size_(~initialValue[moleculeName.asSymbol][\steps])
	.step_(1/~scaleDict[moleculeName.asSymbol].size)
	.action_({
		arg obj;
		// obj.value.linlin(0,1,0,~scaleDict[moleculeName.asSymbol].size - 1).asInteger.postln;
		~currentValues[moleculeName.asSymbol]['notes'] = obj.value.linlin(0,1,0,~scaleDict[moleculeName.asSymbol].size - 1).asInteger;
		Pbindef(moleculeName.asSymbol,\freq,Pseq(((2**octValue.asInteger)/(2**2))*~scaleDict[moleculeName.asSymbol][obj.value.linlin(0,1,0,(~scaleDict[moleculeName.asSymbol].size - 1)).asInteger],inf));
		~activeMolecules.do{|molecule|
			Pbindef(molecule.asSymbol,\mod_freq,Pseq(((2**~currentValues[~currentValues[molecule.asSymbol][\modulator]][\octave])/(2**2))*~scaleDict[~currentValues[molecule.asSymbol][\modulator]][~currentValues[~currentValues[molecule.asSymbol][\modulator]][\notes]],inf));
		};
		("Note indices of "++ moleculeName ++ " scale:\n").postln;
		~currentValues[moleculeName.asSymbol]['notes'].postln;
		"______________________________________________________________\n".postln;
	})
	.strokeColor_(Color.black)
	.fillColor_(themeColor)
	.drawLines_(true)
	.showIndex_(true)
	.elasticMode_(1);

	//// octave selector
	octNB = NumberBox(~windowDict[moleculeName.asSymbol],Rect(0.8*wi,0.05*he,0.1*wi,0.05*he))
	.valueAction_(~initialValue[moleculeName.asSymbol][\octave])
	.align_('center')
	.background_(Color.black)
	.normalColor_(Color.white);
	Knob(~windowDict[moleculeName.asSymbol],Rect(0.6*wi,0.045*he,knobSize*wi,knobSize*wi))
	.valueAction_(~initialValue[moleculeName.asSymbol][\octave].asFloat.linlin(~parameterRange[\octave][0],~parameterRange[\octave][1],0,1))
	.action_({
		arg obj;
		octValue = obj.value.asFloat.linlin(0,1,~parameterRange[\octave][0],~parameterRange[\octave][1]);
		// octValue.postln;
		octNB.valueAction_(octValue.asInteger);
		Pbindef(moleculeName.asSymbol,\freq,Pseq(((2**octValue.asInteger)/(2**2))*~scaleDict[moleculeName.asSymbol][~notesDict[moleculeName.asSymbol].value.linlin(0,1,0,(~scaleDict[moleculeName.asSymbol].size - 1)).asInteger],inf));
		~currentValues[moleculeName.asSymbol]['octave'] = octValue.asInteger;
		~activeMolecules.do{|molecule|
			Pbindef(molecule.asSymbol,\mod_freq,Pseq(((2**~currentValues[~currentValues[molecule.asSymbol][\modulator]][\octave])/(2**2))*~scaleDict[~currentValues[molecule.asSymbol][\modulator]][~currentValues[~currentValues[molecule.asSymbol][\modulator]][\notes]],inf));
		};
	});
	StaticText(~windowDict[moleculeName.asSymbol],Rect(0.35*wi,0.05*he,0.25*wi,0.05*he))
	.align_(\center)
	.stringColor_(Color.black)
	.string_("octave #");

	//// duration multislider
	StaticText(~windowDict[moleculeName.asSymbol],Rect(0.1*wi,0.75*he,0.125*wi,0.125*he))
	.string_("\+ \n dur \n \-")
	.stringColor_(Color.white)
	.background_(Color.black)
	.align_(\center);
	~durationDict[moleculeName.asSymbol] = MultiSliderView(~windowDict[moleculeName.asSymbol],Rect(0.225*wi,0.75*he,0.675*wi,0.125*he))
	.valueAction_(~map_from_list.value(~initialValue[moleculeName.asSymbol][\duration],~durationList))
	.size_(~initialValue[moleculeName.asSymbol][\steps])
	.step_(1/~durationList.size)
	.action_({
		arg obj;
		var tempDurArray;
		("Duration steps of "++ moleculeName ++ "\n").postln;
		tempDurArray = ~map_on_list.value(obj.value,~durationList);
		tempDurArray.do{|element,idx|
			if(element < 1,{
				tempDurArray[idx] = "1/"++(1/element).asInteger.asString;
			});
		};
		tempDurArray.postln;
		"______________________________________________________________\n".postln;
		Pbindef(moleculeName.asSymbol,\dur,Pseq((60/~bpm)*(~map_on_list.value(obj.value,~durationList)),inf));
		~currentValues[moleculeName.asSymbol]['duration'] = ~map_on_list.value(obj.value,~durationList);
		~parameterRange[\attack][moleculeName.asSymbol][1] = 2*(~currentValues[moleculeName.asSymbol]['duration'].minItem);
		~parameterRange[\attack_f][moleculeName.asSymbol][1] = 2*(~currentValues[moleculeName.asSymbol]['duration'].minItem);
		~parameterRange[\release][moleculeName.asSymbol][1] = 2*(~currentValues[moleculeName.asSymbol]['duration'].minItem);
		~parameterRange[\release_f][moleculeName.asSymbol][1] = 2*(~currentValues[moleculeName.asSymbol]['duration'].minItem);

		atKnob.valueAction_(~currentValues[moleculeName.asSymbol][\attack].explin(~parameterRange[\attack][moleculeName.asSymbol][0],~parameterRange[\attack][moleculeName.asSymbol][1],0.0,1.0));
		atfKnob.valueAction_(~currentValues[moleculeName.asSymbol][\attack_f].explin(~parameterRange[\attack_f][moleculeName.asSymbol][0],~parameterRange[\attack_f][moleculeName.asSymbol][1],0.0,1.0));
		reKnob.valueAction_(~currentValues[moleculeName.asSymbol][\release].explin(~parameterRange[\release][moleculeName.asSymbol][0],~parameterRange[\release][moleculeName.asSymbol][1],0.0,1.0));
		refKnob.valueAction_(~currentValues[moleculeName.asSymbol][\release_f].explin(~parameterRange[\release_f][moleculeName.asSymbol][0],~parameterRange[\release_f][moleculeName.asSymbol][1],0.0,1.0));
	})
	.strokeColor_(Color.black)
	.fillColor_(themeColor)
	.drawLines_(true)
	.showIndex_(true)
	.elasticMode_(1);

	//// number of steps knob
	stepNB = NumberBox(~windowDict[moleculeName.asSymbol],Rect(0.6*wi,0.915*he,0.1*wi,0.05*he))
	.valueAction_(~initialValue[moleculeName.asSymbol][\steps])
	.align_('center')
	.background_(Color.black)
	.normalColor_(Color.white);
	Knob(~windowDict[moleculeName.asSymbol],Rect(0.4*wi,0.905*he,knobSize*wi,knobSize*wi))
	.valueAction_(~initialValue[moleculeName.asSymbol][\steps].linlin(~parameterRange[\steps][0],~parameterRange[\steps][1],0,1))
	.action_({
		arg obj;
		stepKnobValue = obj.value.asFloat.linlin(0,1,~parameterRange[\steps][0],~parameterRange[\steps][1]).asInteger;
		stepNB.valueAction_(stepKnobValue);
		~durationDict[moleculeName.asSymbol].size_(stepKnobValue);
		~notesDict[moleculeName.asSymbol].size_(stepKnobValue);
		~currentValues[moleculeName.asSymbol]['steps'] = stepKnobValue;
	});
	StaticText(~windowDict[moleculeName.asSymbol],Rect(0.15*wi,0.915*he,0.25*wi,0.05*he))
	.align_(\center)
	.stringColor_(Color.black)
	.string_("# of steps");

	~windowDict[moleculeName.asSymbol].onClose_({
			Pbindef(moleculeName.asSymbol).stop;
			Pbindef(moleculeName.asSymbol).clear;
		~currentValues.removeAt(moleculeName.asSymbol);
		// ~activeMolecules.do{|key,idx| if(key == moleculeName.asString ,{~activeMolecules.removeAt(idx)}) };
		~activeMolecules.do{|key,idx|
			if(key == moleculeName.asSymbol ,{
				~activeMolecules.removeAt(idx);
				// "______________________________________________________________\n".postln;
				(moleculeName.asString++" was removed from the list of active molecules!\n").postln;
				"______________________________________________________________\n".postln;
			})
		};
		~activeMolecules.do{|molecule|
			~modulatorDict[molecule.asSymbol].items_(~activeMolecules)
		};
		if(flagRemoveTwin,{
			~scaleDict.removeAt(moleculeName.asSymbol);
			~scale.removeAt(moleculeName.asSymbol);
		});
		});
	if(~currentWindowPosition >= (Window.screenBounds.width*0.6),{
	    ~currentWindowPosition = Window.screenBounds.width/4;
	},{
		~currentWindowPosition = ~currentWindowPosition + ~dp;
	});
	"Scale steps ratio: ".postln;
	// ("~durationList = ~scale["++ moleculeName.asString++"]/~scale["++ moleculeName.asString ++"][0]: ").postln;
	((~scale[moleculeName.asSymbol]/~scale[moleculeName.asSymbol][0]).asString ++ "\n").postln;
	("Window generation of molecule "++ moleculeName ++ " completed!\n").postln;
	"______________________________________________________________\n".postln;

};
//// Function: Load sequence data from file ========================================== ////
~load_file = {|fileName|
	var inputFile, parameterList, modulatorList = [], activeSymbols = [];
	inputFile = TabFileReader.read(~path++"saved_sequences/"++fileName);
	t = TabFileReader.read(~path++"saved_sequences/"++fileName);
	~bpm = inputFile[0][1].asInteger;
	parameterList = inputFile[1][(1..(inputFile[1].size-1))];
	// parameterList.postln;
	(2..(inputFile.size - 1)).do{
		arg mIdx;
		~activeMolecules = ~activeMolecules.add(inputFile[mIdx][0]);
		activeSymbols = activeSymbols.add(inputFile[mIdx][0].asSymbol);
		~initialValue[inputFile[mIdx][0].asSymbol] = Dictionary.new;
		(1..(inputFile[mIdx].size - 1)).do{
			arg pIdx;
			if( ( (parameterList[pIdx - 1] == "notes") || (parameterList[pIdx - 1] == "duration") ),{
				var idxList, tempList, comaIndices;
				comaIndices = inputFile[mIdx][pIdx].findAll(",");
				if(comaIndices.isNil,{
					~initialValue[inputFile[mIdx][0].asSymbol][parameterList[pIdx - 1].asSymbol] = [inputFile[mIdx][pIdx][2].asString.asFloat];
				},{
					idxList = (2,5..(inputFile[mIdx][pIdx].size - 2));
					tempList = [];
					tempList = tempList.add(inputFile[mIdx][pIdx][2..(comaIndices[0]-1)].asString.asFloat);
					(comaIndices.size - 1).do{
						arg sIdx;
						tempList = tempList.add(inputFile[mIdx][pIdx][(comaIndices[sIdx]+2)..(comaIndices[sIdx+1]-1)].asString.asFloat)
					};
					tempList = tempList.add(inputFile[mIdx][pIdx][(comaIndices.last+2)..(inputFile[mIdx][pIdx].size - 2)].asString.asFloat);
					~initialValue[inputFile[mIdx][0].asSymbol][parameterList[pIdx - 1].asSymbol] = tempList;
				});
			},{
				if(parameterList[pIdx - 1] == "modulator",
					{modulatorList = modulatorList.add(inputFile[mIdx][pIdx].asSymbol)},
					{~initialValue[inputFile[mIdx][0].asSymbol][parameterList[pIdx - 1].asSymbol] = inputFile[mIdx][pIdx].asString.asFloat}
				);
		})
		};
		// ~initialValue[inputFile[mIdx][0].asSymbol].postln;
		~generate_window.value(inputFile[mIdx][0].asSymbol,~currentWindowPosition);
		~activeMolecules.do{|molecule|
			~modulatorDict[molecule.asSymbol].items_(~activeMolecules)
		};
		// modulatorList.postln
	};
	("The file ./saved_sequences/"++fileName++" was successfully loaded containing the following molecules:\n").postln;
	~activeMolecules.do{|molecule,idx|
		var j;
		j = activeSymbols.indicesOfEqual(modulatorList[idx].asSymbol)[0];
		~modulatorDict[molecule.asSymbol].valueAction_(j);
		Pbindef(molecule.asSymbol,\mod_freq,Pseq(((2**~initialValue[modulatorList[idx]][\octave])/(2**2))*~scaleDict[modulatorList[idx]][~initialValue[modulatorList[idx]][\notes]],inf));
		("-> "++molecule.asString).postln;
	};
	"______________________________________________________________\n".postln;
	~flagLoadFile = False;
};
//// ===================================================================================== ////
)