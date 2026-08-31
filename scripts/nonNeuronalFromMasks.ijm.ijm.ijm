dilateSteps = 2;      // NeuN dilation
minSize = 20;
maxSize = 1000;
closeIfOpen("DAPI");
closeIfOpen("NeuN");
closeIfOpen("NonNeuronal");

if (roiManager("count") == 0)
    exit("No Roi selected.");

titles = getList("image.titles");
dapiSrc = ""; neunSrc = "";
for (i = 0; i < titles.length; i++) {
    t = toLowerCase(titles[i]);
    if (indexOf(t, "dapi") >= 0) dapiSrc = titles[i];
    if (indexOf(t, "neun") >= 0) neunSrc = titles[i];
}
if (dapiSrc == "" || neunSrc == "")
    exit("Open the masks");

selectWindow(dapiSrc);                    
dir = getDirectory("image");
ratID = replace(dapiSrc, "Image-Mask-DAPI350-", "");
ratID = replace(ratID, ".tif", "");       
outName = "NonNeuronal-" + ratID + ".tif";

selectWindow(dapiSrc); run("Duplicate...", "title=DAPI");
selectWindow(neunSrc); run("Duplicate...", "title=NeuN");
run("Options...", "iterations=1 count=1 do=Nothing");

selectWindow("NeuN");
for (d = 0; d < dilateSteps; d++) run("Dilate");
run("Invert");

imageCalculator("AND create", "DAPI", "NeuN");
selectWindow("Result of DAPI");
rename("NonNeuronal");
run("Watershed");

selectWindow("NonNeuronal");
roiManager("Select", 0);
run("Analyze Particles...", "size=" + minSize + "-" + maxSize + " show=Masks display exclude summarize");


selectWindow("Mask of NonNeuronal");
saveAs("Tiff", dir + outName);


selectWindow("Results");
saveAs("Results", dir + "Results-NonNeuronal-" + ratID + ".csv");

selectWindow("Summary");
saveAs("Results", dir + "Summary-NonNeuronal-" + ratID + ".csv");

function closeIfOpen(name) {
    if (isOpen(name)) { selectWindow(name); close(); }
}