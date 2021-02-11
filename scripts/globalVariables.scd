(
//// Initialize and set global variables ===================================================== ////
//
// init main dictionaries
~database = ();
~frequency = ();
~amplitude = ();
~spectrum = ();
~scale = ();
~scaleDict = ();
~bufs = ();
~windowDict = ();
~activationDict = ();
~playButtonDict = ();
~durationDict = ();
~modulatorDict = ();
~notesDict = ();
~currentValues = ();
~parameterRange = ();
~initialValue = ();
//
// set general parameters
~bpm = 120;
~bpmRange = [10,300];
~durFactor = 1;
~moleculeNames.do{arg idx; ~activationDict[idx.asSymbol] = false};
~saveFileName = "new_sequence.txt";
~loadFileName = "example_citronella.txt";
~flagLoadFile = False;
~durationList = [0.06125, 0.125, 0.25, 0.5, 1, 2, 4, 8, 16];
~currentWindowPosition = Window.screenBounds.width/4;
~dp = Window.screenBounds.width/5;
~molIdx = 0;
~activeMolecules = [];
~repetitionIdx = 2;
//
// set parameter range dictionary
// ~parameterRange[\attack] = [0.001,3.5];
// ~parameterRange[\release] = [0.001,3.5];
~parameterRange[\steps] = [1,20];
~parameterRange[\duration] = [1,8];
~parameterRange[\octave] = [-4,4];
~parameterRange[\volume] = [0,1.0];
~parameterRange[\mod_depth] = [0,0.85];
// ~parameterRange[\attack_f] = [0.001,3.5];
// ~parameterRange[\release_f] = [0.001,3.55];
~parameterRange[\cutoff] = [40,20000];
~parameterRange[\resonance] = [0,3];
~parameterRange[\attack] = ();
~parameterRange[\attack_f] = ();
~parameterRange[\release_f] = ();
~parameterRange[\release] = ();
//
////======================================================================================= ////
)
