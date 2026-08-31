//All Hue values were attained by selection a NeuN positive blob and running the sample function under color threshold. Saturation and brightness were then adjusted manually until all red orange or yellow blobs were selected.
//This is a conglomerate of the three NeuN color scripts. It was mostly created using Fiji's macro-recorder tool
a=getTitle();
roiManager("reset");

run("Duplicate...", "title=tissue_mask_tmp");
run("8-bit");
setThreshold(15, 255);
run("Convert to Mask");
run("Fill Holes");
run("Create Selection");
roiManager("Add");
close("tissue_mask_tmp");
selectWindow(a);
roiManager("Select", 0);
run("Clear Outside");
run("Select None");

analyzeColor(a, "red",    3, 251, "stop", 132, 255, "pass", 127, 255, "pass", 1, 1000);
analyzeColor(a, "orange", 18, 25, "pass", 163, 255, "pass", 126, 255, "pass", 1, 1000);
analyzeColor(a, "yellow", 37, 43, "pass", 123, 255, "pass", 147, 255, "pass", 1, 1000);

roiManager("reset");

function analyzeColor(src, cname, hmin, hmax, hfilt, smin, smax, sfilt, bmin, bmax, bfilt, szmin, szmax) {
  min=newArray(hmin, smin, bmin);
  max=newArray(hmax, smax, bmax);
  filter=newArray(hfilt, sfilt, bfilt);
  selectWindow(src);
  run("Duplicate...", "title=work_"+cname);
  run("HSB Stack");
  run("Convert Stack to Images");
  selectWindow("Hue");
  rename("0");
  selectWindow("Saturation");
  rename("1");
  selectWindow("Brightness");
  rename("2");
  for (i=0;i<3;i++){
    selectWindow(""+i);
    setThreshold(min[i], max[i]);
    run("Convert to Mask");
    if (filter[i]=="stop")  run("Invert");
  }
  imageCalculator("AND create", "0","1");
  imageCalculator("AND create", "Result of 0","2");
  for (i=0;i<3;i++){
    selectWindow(""+i);
    close();
  }
  selectWindow("Result of 0");
  close();
  selectWindow("Result of Result of 0");
  rename(src+"_"+cname);
  roiManager("Select", 0);
  run("Analyze Particles...", "size="+szmin+"-"+szmax+" display summarize");
  Table.rename("Results", "Results_"+cname);
  close(src+"_"+cname);
}
