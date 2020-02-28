// macro written by Dale Moulding, UCL ICH Imaging facility to automate
// adding scalebars to .tif or .jpg images taken on any of the facility microscopes.
// this macro reads the magnification from the filename.
// Filenames must contain the magnification in the title (5x or x5 or X5 or 5X). i.e 10xcellsdapi or Cellsdapi10xa CellsDapix10b
// 9Jan2018

// Copyright (c) 2019 Dale Moulding, UCL. Made available for use under the MIT license.
// https://opensource.org/licenses/MIT



macro "ICH_Scalebars_mag_from_filename"{
  
  Dialog.create("Set scale...");// open a window for user input of microscope used
  items = newArray("1 Leica-IDS camera", "2 NDU Zeiss axiocam", "5 NDU Zeiss Axiocam", "Olympus inverted rm304", "Zeiss Timelapse Live Imaging");
  Dialog.addRadioButtonGroup("Microscope", items, 5, 1, "");
  Dialog.addChoice("Draw scalebar", newArray("Yes", "No"), "Yes");
  Dialog.show();
  Microscope = Dialog.getRadioButton();
  scalebar =  Dialog.getChoice();

if (scalebar=="Yes"){
  Dialog.create("Choose scale bar options");// open a window for user input of scalebar length, width, fontsize and colour
  Dialog.addSlider("Scalebar length (um):", 1, 500, 10);
  Dialog.addSlider("Scalebar width (pixels):", 1, 100, 10);
  Dialog.addSlider("Scalebar font size (um):", 8, 100, 12);
  Dialog.addChoice("Scale bar colour", newArray("Black", "White", "Yellow", "Red", "Green", "Blue"), "White");
  Dialog.addChoice("Show text", newArray("Yes", "No"), "Yes");
  Dialog.show();
  x = Dialog.getNumber();
  h = Dialog.getNumber();
  f = Dialog.getNumber();
  colour = Dialog.getChoice();
  text = Dialog.getChoice();
  if (text=="Yes") showtext = ""; else showtext = "hide";
}
  
if (Microscope=="null") exit("you need to choose a microscope");

  dir1 = getDirectory("Input folder: images at any magnification from a single microscope"); //select an input folder
  dir2 = getDirectory("Choose a folder to save to"); //select an output folder. 
  list = getFileList(dir1); //make a list of the filenames
  setBatchMode(true); //turn on batch mode

for (i=0; i<list.length; i++) {
 	showProgress(i+1, list.length);
 	filename = dir1 + list[i];
 	if (endsWith(filename, "tif")||endsWith(filename, "jpg")||endsWith(filename, "png")) {
open(filename);	
Imagename = File.nameWithoutExtension;


 if (Microscope=="1 Leica-IDS camera") {
 	if (matches(Imagename, ".*2.5x.*")||matches(Imagename, ".*x2.5.*")||matches(Imagename, ".*2.5X.*")||matches(Imagename, ".*X2.5.*")) exit("No 2.5x on Leica scope"); 
 	else if (matches(Imagename, ".*40x.*")||matches(Imagename, ".*x40.*")||matches(Imagename, ".*40X.*")||matches(Imagename, ".*X40.*")) n = 0.209;
 	else if (matches(Imagename, ".*4x.*")||matches(Imagename, ".*x4.*")||matches(Imagename, ".*4X.*")||matches(Imagename, ".*X4.*")) n = 2.10125;
 	else if (matches(Imagename, ".*5x.*")||matches(Imagename, ".*x5.*")||matches(Imagename, ".*5X.*")||matches(Imagename, ".*X5.*")) n = 1.681;
 	else if (matches(Imagename, ".*10x.*")||matches(Imagename, ".*x10.*")||matches(Imagename, ".*10X.*")||matches(Imagename, ".*X10.*")) n = 0.8934;
 	else if (matches(Imagename, ".*20x.*")||matches(Imagename, ".*x20.*")||matches(Imagename, ".*20X.*")||matches(Imagename, ".*X20.*")) n = 0.4194;
 	else if (matches(Imagename, ".*32x.*")||matches(Imagename, ".*x32.*")||matches(Imagename, ".*32X.*")||matches(Imagename, ".*X32.*")) exit("No 32x on Leica scope"); 
 	else if (matches(Imagename, ".*63x.*")||matches(Imagename, ".*x63.*")||matches(Imagename, ".*63X.*")||matches(Imagename, ".*X63.*")) n = 0.134;
    else exit("Macro aborted - "+Imagename+ " doesn't include recognized a magnification");
    
 	run("Set Scale...", "distance=1 known="+n+" unit=um");
 	run("Remove Overlay");// removes any previously added scalebar
 	if (scalebar=="Yes")  run("Scale Bar...", "width=x height=h font=f color="+colour+" background=None location=[Lower Right] bold "+showtext+" overlay");
    // save as either a new file with -scalebar added to the ned of the name, or with the same name as the original file. 
 	// put // at the start of the unwated save option.
    // saveAs("Tif", dir2+Imagename+"-scalebar");//saves the image to output folder with -scalebar added to the name
    saveAs("Tif", dir2+Imagename);//saves the image to output folder and over writes the original files if the input and output folder are the same
 }


 if (Microscope=="2 NDU Zeiss axiocam") {
 	width=getWidth();// gets image width in pixels so all camera resolutions are accounted for
 	if (matches(Imagename, ".*2.5x.*")||matches(Imagename, ".*x2.5.*")||matches(Imagename, ".*2.5X.*")||matches(Imagename, ".*X2.5.*")) n = 5443; 
 	else if (matches(Imagename, ".*40x.*")||matches(Imagename, ".*x40.*")||matches(Imagename, ".*40X.*")||matches(Imagename, ".*X40.*")) n = 355.5;
 	else if (matches(Imagename, ".*4x.*")||matches(Imagename, ".*x4.*")||matches(Imagename, ".*4X.*")||matches(Imagename, ".*X4.*")) exit("No 4x objective on #2NDU scope");
 	else if (matches(Imagename, ".*5x.*")||matches(Imagename, ".*x5.*")||matches(Imagename, ".*5X.*")||matches(Imagename, ".*X5.*")) n = 2847;
 	else if (matches(Imagename, ".*10x.*")||matches(Imagename, ".*x10.*")||matches(Imagename, ".*10X.*")||matches(Imagename, ".*X10.*")) n = 1421;
 	else if (matches(Imagename, ".*20x.*")||matches(Imagename, ".*x20.*")||matches(Imagename, ".*20X.*")||matches(Imagename, ".*X20.*")) n = 711;
 	else if (matches(Imagename, ".*32x.*")||matches(Imagename, ".*x32.*")||matches(Imagename, ".*32X.*")||matches(Imagename, ".*X32.*")) exit("No 32x objective on #2NDU scope"); 
 	else if (matches(Imagename, ".*63x.*")||matches(Imagename, ".*x63.*")||matches(Imagename, ".*63X.*")||matches(Imagename, ".*X63.*")) n = 226.3;
 	else exit("Macro aborted - "+Imagename+ " doesn't include recognized a magnification");
 	
 	run("Set Scale...", "distance=width known="+n+" unit=um");
 	run("Remove Overlay");// removes any previously added scalebar
 	if (scalebar=="Yes") run("Scale Bar...", "width=x height=h font=f color="+colour+" background=None location=[Lower Right] bold "+showtext+" overlay");
    // save as either a new file with -scalebar added to the ned of the name, or with the same name as the original file. 
 	// put // at the start of the unwated save option.
    // saveAs("Tif", dir2+Imagename+"-scalebar");//saves the image to output folder with -scalebar added to the name
    saveAs("Tif", dir2+Imagename);//saves the image to output folder and over writes the original files if the input and output folder are the same
 }

 if (Microscope=="5 NDU Zeiss axiocam") {
 	width=getWidth();// gets image width in pixels so all camera resolutions are accounted for
 	if (matches(Imagename, ".*2.5x.*")||matches(Imagename, ".*x2.5.*")||matches(Imagename, ".*2.5X.*")||matches(Imagename, ".*X2.5.*")) n = 5443;
 	else if (matches(Imagename, ".*40x.*")||matches(Imagename, ".*x40.*")||matches(Imagename, ".*40X.*")||matches(Imagename, ".*X40.*")) n = 355.5;
 	else if (matches(Imagename, ".*4x.*")||matches(Imagename, ".*x4.*")||matches(Imagename, ".*4X.*")||matches(Imagename, ".*X4.*")) exit("No 4x objective on #5NDU scope");
 	else if (matches(Imagename, ".*5x.*")||matches(Imagename, ".*x5.*")||matches(Imagename, ".*5X.*")||matches(Imagename, ".*X5.*")) n = 2844;
 	else if (matches(Imagename, ".*10x.*")||matches(Imagename, ".*x10.*")||matches(Imagename, ".*10X.*")||matches(Imagename, ".*X10.*")) n = 1412;
 	else if (matches(Imagename, ".*20x.*")||matches(Imagename, ".*x20.*")||matches(Imagename, ".*20X.*")||matches(Imagename, ".*X20.*")) n = 711;
 	else if (matches(Imagename, ".*32x.*")||matches(Imagename, ".*x32.*")||matches(Imagename, ".*32X.*")||matches(Imagename, ".*X32.*")) exit("No 32x objective on #5NDU scope"); 
 	else if (matches(Imagename, ".*63x.*")||matches(Imagename, ".*x63.*")||matches(Imagename, ".*63X.*")||matches(Imagename, ".*X63.*")) n = 226.3;
    else exit("Macro aborted - "+Imagename+ " doesn't include recognized a magnification");
 	
    run("Set Scale...", "distance=width known="+n+" unit=um");
    run("Remove Overlay");// removes any previously added scalebar
 	if (scalebar=="Yes")  run("Scale Bar...", "width=x height=h font=f color="+colour+" background=None location=[Lower Right] bold "+showtext+" overlay");
    // save as either a new file with -scalebar added to the ned of the name, or with the same name as the original file. 
 	// put // at the start of the unwated save option.
    // saveAs("Tif", dir2+Imagename+"-scalebar");//saves the image to output folder with -scalebar added to the name
    saveAs("Tif", dir2+Imagename);//saves the image to output folder and over writes the original files if the input and output folder are the same
 }

 if (Microscope=="Olympus inverted rm304") {
 	if (matches(Imagename, ".*2.5x.*")||matches(Imagename, ".*x2.5.*")||matches(Imagename, ".*2.5X.*")||matches(Imagename, ".*X2.5.*")) exit("No 2.5x on Olympus scope"); 
 	else if (matches(Imagename, ".*40x.*")||matches(Imagename, ".*x40.*")||matches(Imagename, ".*40X.*")||matches(Imagename, ".*X40.*")) n = 0.255;
 	else if (matches(Imagename, ".*4x.*")||matches(Imagename, ".*x4.*")||matches(Imagename, ".*4X.*")||matches(Imagename, ".*X4.*")) exit("No 4x on Olympus scope");
 	else if (matches(Imagename, ".*5x.*")||matches(Imagename, ".*x5.*")||matches(Imagename, ".*5X.*")||matches(Imagename, ".*X5.*")) n = 1.88;
 	else if (matches(Imagename, ".*10x.*")||matches(Imagename, ".*x10.*")||matches(Imagename, ".*10X.*")||matches(Imagename, ".*X10.*")) n = 1.03;
 	else if (matches(Imagename, ".*20x.*")||matches(Imagename, ".*x20.*")||matches(Imagename, ".*20X.*")||matches(Imagename, ".*X20.*")) n = 0.518;
 	else if (matches(Imagename, ".*32x.*")||matches(Imagename, ".*x32.*")||matches(Imagename, ".*32X.*")||matches(Imagename, ".*X32.*")) exit("No 32x on Olympus scope"); 
 	else if (matches(Imagename, ".*63x.*")||matches(Imagename, ".*x63.*")||matches(Imagename, ".*63X.*")||matches(Imagename, ".*X63.*")) exit("No 63x on Olympus scope");
    else exit("Macro aborted - "+Imagename+ " doesn't include recognized a magnification");
 	
 	run("Set Scale...", "distance=1 known="+n+" unit=um");
 	run("Remove Overlay");// removes any previously added scalebar
 	if (scalebar=="Yes")  run("Scale Bar...", "width=x height=h font=f color="+colour+" background=None location=[Lower Right] bold "+showtext+" overlay");
    // save as either a new file with -scalebar added to the ned of the name, or with the same name as the original file. 
 	// put // at the start of the unwated save option.
    // saveAs("Tif", dir2+Imagename+"-scalebar");//saves the image to output folder with -scalebar added to the name
    saveAs("Tif", dir2+Imagename);//saves the image to output folder and over writes the original files if the input and output folder are the same
 }

 	if (Microscope=="Zeiss Timelapse Live Imaging") {
 	if (matches(Imagename, ".*2.5x.*")||matches(Imagename, ".*x2.5.*")||matches(Imagename, ".*2.5X.*")||matches(Imagename, ".*X2.5.*")) exit("No 2.5x on timelapse scope"); 
 	else if (matches(Imagename, ".*40x.*")||matches(Imagename, ".*x40.*")||matches(Imagename, ".*40X.*")||matches(Imagename, ".*X40.*")) n = 0.2283;
 	else if (matches(Imagename, ".*4x.*")||matches(Imagename, ".*x4.*")||matches(Imagename, ".*4X.*")||matches(Imagename, ".*X4.*")) exit("No 4x on timelapse scope");
 	else if (matches(Imagename, ".*5x.*")||matches(Imagename, ".*x5.*")||matches(Imagename, ".*5X.*")||matches(Imagename, ".*X5.*")) n = 2.035;
 	else if (matches(Imagename, ".*10x.*")||matches(Imagename, ".*x10.*")||matches(Imagename, ".*10X.*")||matches(Imagename, ".*X10.*")) n = 1.03;
 	else if (matches(Imagename, ".*20x.*")||matches(Imagename, ".*x20.*")||matches(Imagename, ".*20X.*")||matches(Imagename, ".*X20.*")) n = 0.4676;
 	else if (matches(Imagename, ".*32x.*")||matches(Imagename, ".*x32.*")||matches(Imagename, ".*32X.*")||matches(Imagename, ".*X32.*")) n = 0.3184; 
 	else if (matches(Imagename, ".*63x.*")||matches(Imagename, ".*x63.*")||matches(Imagename, ".*63X.*")||matches(Imagename, ".*X63.*")) exit("No 63x on timelapse scope");
 	else exit("Macro aborted - "+Imagename+ " doesn't include recognized a magnification");
 	
 	run("Set Scale...", "distance=1 known="+n+" unit=um");
 	run("Remove Overlay");// removes any previously added scalebar
 	if (scalebar=="Yes")  run("Scale Bar...", "width=x height=h font=f color="+colour+" background=None location=[Lower Right] bold "+showtext+" overlay");
 	// save as either a new file with -scalebar added to the ned of the name, or with the same name as the original file. 
 	// put // at the start of the unwated save option.
    // saveAs("Tif", dir2+Imagename+"-scalebar");//saves the image to output folder with -scalebar added to the name
    saveAs("Tif", dir2+Imagename);//saves the image to output folder and over writes the original files if the input and output folder are the same
 }
 	
   }
  }
  exit("Scale set in "+i+" images");
}
