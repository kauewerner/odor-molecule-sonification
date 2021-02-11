// Get sound parameters from IR data
(
var speedOfLight, freqFactor, erb, erbFactor, freqIdx, peaks, df, dfIdx;
speedOfLight = 3*(10**8); // speed of light
freqFactor = (2**28); // frequency conversion factor
erbFactor = 0.5;
/*~frequency = ();
~amplitude = ();
~spectrum = ();
~scale = ();*/
~moleculeNames.do{arg molecule;
			~frequency[molecule.asSymbol] = 0!~database[molecule.asSymbol].size;
			~amplitude[molecule.asSymbol] = 0!~database[molecule.asSymbol].size;
			~database[molecule.asSymbol].size.do{arg wnIdx;
				~frequency[molecule.asSymbol][wnIdx] = (speedOfLight*~database[molecule.asSymbol][wnIdx][0].asFloat)/freqFactor;
				~amplitude[molecule.asSymbol][wnIdx] = ~database[molecule.asSymbol][wnIdx][1].asFloat;
			};
			~amplitude[molecule.asSymbol] = ~amplitude[molecule.asSymbol]/(~amplitude[molecule.asSymbol].maxItem);
			~spectrum[molecule.asSymbol] = ~frequency[molecule.asSymbol]/(~frequency[molecule.asSymbol].minItem);

			freqIdx = (0..(~frequency[molecule.asSymbol].size-1));
			peaks = []!~amplitude[molecule.asSymbol].size;
			if(~amplitude[molecule.asSymbol][1] < ~amplitude[molecule.asSymbol][0]){peaks[0] = 1}{peaks[0] = 0};
			(1..(~amplitude[molecule.asSymbol].size-1)).do{arg i;
				if(i < (~amplitude[molecule.asSymbol].size-1)){
					if(((~amplitude[molecule.asSymbol][i+1] - ~amplitude[molecule.asSymbol][i]) <= 0) && ((~amplitude[molecule.asSymbol][i] - ~amplitude[molecule.asSymbol][i-1]) >= 0)){peaks[i] = 1}{peaks[i] = 0}
				}{
					if((~amplitude[molecule.asSymbol][i] - ~amplitude[molecule.asSymbol][i-1]) < 0){peaks[i] = 0}{peaks[i] = 1}
				}
			};
			peaks = peaks.indicesOfEqual(1);
			erb = 24.7*(0.00437*~frequency[molecule.asSymbol] + 1);
			(0..(peaks.size-1)).do{arg j;
				df = (~frequency[molecule.asSymbol][peaks[j]] - ~frequency[molecule.asSymbol]);
				dfIdx = (df.abs < (erb[peaks[j]]*erbFactor).round).indicesOfEqual(true);
				if(dfIdx.isNil.not){
					(0..(dfIdx.size-1)).do{arg k;
						if(k != dfIdx.indexOf(dfIdx[~amplitude[molecule.asSymbol][dfIdx].maxIndex])){
							freqIdx.remove(dfIdx[k]);
						}
					};
				};
			};
			~scale[molecule.asSymbol] = ~frequency[molecule.asSymbol][freqIdx];
};
"Sound parameters were successfully extracted from the database\n".postln;
"______________________________________________________________\n".postln;
)