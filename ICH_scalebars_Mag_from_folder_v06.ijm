/* 
*macro written by Dale Moulding, UCL ICH Imaging facility, to automate 
*adding scalebars to tif or jpg images taken on any of the facility microscopes.
*this macro assumes all files in a folder are taken at the same magnification, 
*so your files must be grouped in folders specific for each microscope and each magnification.
*16 July 2019
*Modified to accept filenames with a pseudo extension (i.e .a_1, .a_2 etc) before the .tif extension
*/

// v6 fixed 'run("Remove Overlay");' whcih was previously inside the 'if (scalebar=="Yes") {' loop.
// It now removes the scalebar if none is to be drawn
// ALso opens .tiff files

// Copyright (c) 2019 Dale Moulding, UCL. Made available for use under the MIT license.
// https://opensource.org/licenses/MIT

macro "ICH_Scalebars_mag_from_folder"{
  Dialog.create("Set scale...");// open a window for user input of microscope and magnification
  items = newArray("1 Leica-IDS camera", "2 NDU Zeiss axiocam", "5 NDU Zeiss Axiocam", "Olympus inverted rm304", "Zeiss Timelapse Live Imaging");
  Dialog.addRadioButtonGroup("Microscope", items, 5, 1, "");
  items = newArray("2.5x", "4x", "5x", "10x", "20x", "32x", "40x", "63x");
  Dialog.addRadioButtonGroup("Objective", items, 2, 4, "");
  Dialog.addChoice("Draw scalebar", newArray("Yes", "No"), "Yes");
  Dialog.show();
  Microscope = Dialog.getRadioButton();
  Mag = Dialog.getRadioButton();
  scalebar =  Dialog.getChoice();
  
  if (scalebar=="Yes"){
  Dialog.create("Choose scale bar options");// open a window for user input of scalebar length, width, fontsize and colour
  Dialog.addSlider("Scalebar length (um):", 1, 500, 50);
  Dialog.addSlider("Scalebar width (pixels):", 1, 100, 10);
  Dialog.addSlider("Scalebar font size (um):", 8, 100, 12);
  Dialog.addChoice("Scale bar colour", newArray("Black", "White", "Yellow", "Red", "Green", "Blue"), "White");
  Dialog.addChoice("Show text", newArray("Yes", "No"), "No");
  Dialog.show();
  x = Dialog.getNumber();
  h = Dialog.getNumber();
  f = Dialog.getNumber();
  colour = Dialog.getChoice();
  text = Dialog.getChoice();
  if (text=="Yes") showtext = ""; else showtext = "hide";
}
  
if (Microscope=="null") exit("you need to choose a microscope");
if (Mag=="null") exit("you need to choose your magnification");

  dir1 = getDirectory("Input Folder: images at the same magnification"); //select an input folder
  dir2 = getDirectory("Choose a folder to save to"); //select an output folder. 
  list = getFileList(dir1); //make a list of the filenames
  setBatchMode(true); //turn on batch mode

for (i=0; i<list.length; i++) {
 	showProgress(i+1, list.length);
 	filename = dir1 + list[i];
 	if (endsWith(filename, "tif")||endsWith(filename, "tiff")||endsWith(filename, "jpg")||endsWith(filename, "png")) {
open(filename);	
//fullname = getTitle();
//Imagename = substring(fullname, 0, lengthOf(fullname)-4); 
Imagename = File.nameWithoutExtension;
savepath = dir2+Imagename+".tif";
//print("filename= "+filename+", Fullname= " +fullname+", Imagename= "+Imagename+ ", savepath"+savepath);


 if (Microscope=="1 Leica-IDS camera") {
 	if (Mag=="2.5x") exit("objective chosen is not on this scope"); 
 	if (Mag=="4x") n = 2.10125
 	if (Mag=="5x") n = 1.681;
 	if (Mag=="10x") n = 0.8934;
 	if (Mag=="20x") n = 0.4194;
 	if (Mag=="32x") exit("objective chosen is not on this scope"); 
 	if (Mag=="40x") n = 0.209;
 	if (Mag=="63x") n = 0.134;
 	
 	run("Set Scale...", "distance=1 known="+n+" unit=um");
  run("Remove Overlay");// removes any previously added scalebar
 	if (scalebar=="Yes") {
 		run("Scale Bar...", "width=x height=h font=f color="+colour+" background=None location=[Lower Right] bold "+showtext+" overlay");
 	}
     // save as either a new file with -scalebar added to the ned of the name, or with the same name as the original file. 
 	// put // at the start of the unwated save option.
    // saveAs("Tif", dir2+Imagename+"-scalebar");//saves the image to output folder with -scalebar added to the name
     save(savepath);//saves the image to output folder and over writes the original files if the input and output folder are the same
 }


 	if (Microscope=="2 NDU Zeiss axiocam") {
 	width=getWidth();// gets image width in pixels so all camera resolutions are accounted for
 	if (Mag=="2.5x") n = 5443; 
 	if (Mag=="4x") exit("objective chosen is not on this scope");
 	if (Mag=="5x") n = 2847;
 	if (Mag=="10x") n = 1421;
 	if (Mag=="20x") n = 711;
 	if (Mag=="32x") exit("objective chosen is not on this scope"); 
 	if (Mag=="40x") n = 355.5;
 	if (Mag=="63x") n = 226.3;
 	
 	run("Set Scale...", "distance=width known="+n+" unit=um");
  run("Remove Overlay");// removes any previously added scalebar
 	if (scalebar=="Yes") {
 		run("Scale Bar...", "width=x height=h font=f color="+colour+" background=None location=[Lower Right] bold "+showtext+" overlay");
 	}
     // save as either a new file with -scalebar added to the ned of the name, or with the same name as the original file. 
 	// put // at the start of the unwated save option.
    // saveAs("Tif", dir2+Imagename+"-scalebar");//saves the image to output folder with -scalebar added to the name
     save(savepath);//saves the image to output folder and over writes the original files if the input and output folder are the same
 }

if (Microscope=="5 NDU Zeiss axiocam") {
 	width=getWidth();// gets image width in pixels so all camera resolutions are accounted for
 	if (Mag=="2.5x") n = 5443;
 	if (Mag=="4x") exit("objective chosen is not on this scope");
 	if (Mag=="5x") n = 2844;
 	if (Mag=="10x") n = 1412;
 	if (Mag=="20x") n = 711;
 	if (Mag=="32x") exit("objective chosen is not on this scope"); 
 	if (Mag=="40x") n = 355.5;
 	if (Mag=="63x") n = 226.3;
 	
  run("Set Scale...", "distance=width known="+n+" unit=um");
  run("Remove Overlay");// removes any previously added scalebar
 	if (scalebar=="Yes") {
 		run("Scale Bar...", "width=x height=h font=f color="+colour+" background=None location=[Lower Right] bold "+showtext+" overlay");
 	}
     // save as either a new file with -scalebar added to the ned of the name, or with the same name as the original file. 
 	// put // at the start of the unwated save option.
    // saveAs("Tif", dir2+Imagename+"-scalebar");//saves the image to output folder with -scalebar added to the name
     save(savepath);//saves the image to output folder and over writes the original files if the input and output folder are the same
 }


 if (Microscope=="Olympus inverted rm304") {
 	if (Mag=="2.5x") exit("objective chosen is not on this scope"); 
 	if (Mag=="4x") exit("objective chosen is not on this scope");
 	if (Mag=="5x") n = 1.88;
 	if (Mag=="10x") n = 1.03;
 	if (Mag=="20x") n = 0.518;
 	if (Mag=="32x") exit("objective chosen is not on this scope"); 
 	if (Mag=="40x") n = 0.255;
 	if (Mag=="63x") exit("objective chosen is not on this scope");
 	
 	run("Set Scale...", "distance=1 known="+n+" unit=um");
  run("Remove Overlay");// removes any previously added scalebar
 	if (scalebar=="Yes") {
 		run("Scale Bar...", "width=x height=h font=f color="+colour+" background=None location=[Lower Right] bold "+showtext+" overlay");
 	}
     // save as either a new file with -scalebar added to the ned of the name, or with the same name as the original file. 
 	// put // at the start of the unwated save option.
    // saveAs("Tif", dir2+Imagename+"-scalebar");//saves the image to output folder with -scalebar added to the name
    save(savepath);//saves the image to output folder and over writes the original files if the input and output folder are the same
 }

 	if (Microscope=="Zeiss Timelapse Live Imaging") {
 	if (Mag=="2.5x") exit("objective chosen is not on this scope"); 
 	if (Mag=="4x") exit("objective chosen is not on this scope");
 	if (Mag=="5x") n = 2.035;
 	if (Mag=="10x") n = 1.03;
 	if (Mag=="20x") n = 0.4676;
 	if (Mag=="32x") n = 0.3184; 
 	if (Mag=="40x") n = 0.2283;
 	if (Mag=="63x") exit("objective chosen is not on this scope");

 	run("Set Scale...", "distance=1 known="+n+" unit=um");
  run("Remove Overlay");// removes any previously added scalebar
 	if (scalebar=="Yes") {
 		run("Scale Bar...", "width=x height=h font=f color="+colour+" background=None location=[Lower Right] bold "+showtext+" overlay");
 	}
     // save as either a new file with -scalebar added to the ned of the name, or with the same name as the original file. 
 	// put // at the start of the unwated save option.
    // saveAs("Tif", dir2+Imagename+"-scalebar");//saves the image to output folder with -scalebar added to the name
     save(savepath);//saves the image to output folder and over writes the original files if the input and output folder are the same
 }
 	
   }
  }
  exit("Scale set in "+i+" images");
}
