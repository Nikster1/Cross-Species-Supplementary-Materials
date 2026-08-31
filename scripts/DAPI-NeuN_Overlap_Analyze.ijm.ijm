selectImage("DAPI");
selectImage("NeuN");
run("Invert");
imageCalculator("AND create", "DAPI","NeuN");
selectImage("Result of DAPI");
run("Analyze Particles...", "size=20-1000 show=Masks display exclude summarize overlay");

