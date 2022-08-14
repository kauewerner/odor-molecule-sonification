//// ODOR MOLECULE SONIFICATION main ============================== ////
(
s.waitForBoot({
//// Get current working path
~path = PathName(thisProcess.nowExecutingPath).parentPath;
thisProcess.platform.recordingsDir = ~path ++ "recs/";
~numberOfSemitones = 12;
~flagScaleSpectrum  = true;
//// Global variables
this.executeFile(~path++"scripts/globalVariables.scd");
// Import specific IR data
this.executeFile(~path++"scripts/extractIRfromFile.scd");
//// Get Sound Parameters
this.executeFile(~path++"scripts/getSoundParameters.scd");
//// Create Synths
this.executeFile(~path++"scripts/createSynthDefs.scd");
//// Global functions
this.executeFile(~path++"scripts/globalFunctions.scd");
//// Generate main window
this.executeFile(~path++"scripts/mainWindow.scd");
//// Set a custom duration list
// ~durationList = [1/16, 1/8, 1/7, 1/6, 1/5, 1/4, 1/3, 1/2, 1, 2, 3, 4, 5, 6, 7, 8, 16];
~durationList = [1/8, 1/4, 1/2, 1, 2, 4 , 8, 16];
});
)
//// ============================================================= ////