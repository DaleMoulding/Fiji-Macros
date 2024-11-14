// macro for Hassan by Dale Moulding ICH imaging facility March 2018
// revised Oct 2024
// outputs a DAB coloour coded levels image, High (red) Med (green) Low (blue)
// a summary window for area of each DAB intensity
// a results window for the area of the whole ROI
// Please acknowledge in any presentation / publication

// requires Colour Deconvolution2
// update Fiji, and select the Colour Deconvolution2 update site

run("Colors...", "foreground=black background=white selection=yellow");

run("Duplicate...", "title=ROI");

waitForUser("Draw your ROI");

setBackgroundColor(255, 255, 255);
run("Clear Outside");
run("Set Measurements...", "area display redirect=None decimal=3");
run("Measure");
run("Colour Deconvolution2", "vectors=[H DAB] output=8bit_Transmittance simulated cross hide");
selectWindow("ROI-(Colour_2)");

rename("DAB low");
run("Duplicate...", "title=[DAB med]");
run("Duplicate...", "title=[DAB High]");

selectWindow("DAB High");
setThreshold(0, 75);
setOption("BlackBackground", false);
run("Convert to Mask");
run("Analyze Particles...", "summarize");

selectWindow("DAB med");
setThreshold(76, 150);
setOption("BlackBackground", false);
run("Convert to Mask");
run("Analyze Particles...", "summarize");

selectWindow("DAB low");
setThreshold(151, 225);
setOption("BlackBackground", false);
run("Convert to Mask");
run("Analyze Particles...", "summarize");

selectWindow("ROI");
run("8-bit");
run("Merge Channels...", "c1=[DAB High] c2=[DAB med] c3=[DAB low] c4=ROI create");
