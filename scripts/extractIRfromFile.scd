// extract IR data from files ======================================
(
var pathEntries;
"Extracting IR data from the database...\n".postln;
pathEntries = PathName(~path++"IR_data").entries;
// ~database = ();
~numberOfMolecules = pathEntries.size;
~moleculeNames = []!~numberOfMolecules;
pathEntries.do{arg pIdx;
	~database.put(pIdx.fileNameWithoutExtension.asSymbol,TabFileReader.read(pIdx.fullPath,true));
};
(0..(~numberOfMolecules-1)).do{arg i;
	~moleculeNames[i] = pathEntries[i].fileNameWithoutExtension;
};
"IR data of the following molecules was sucessfully extracted from database:\n".postln;
~moleculeNames.do{|molecule| ("-> "++molecule.asString).postln};
("______________________________________________________________\n").postln;
)
