/*  Macro written by Dale Moulding, UCL ICH Imaging facility to automate
 *  changing colour camera zeiss .czi files to gamma corrected tifs.
 *  Freely available script from Dale Moulding, UCL Oct 2019. 
 */


macro "ICH_Colour CZI to Tif"{
 
  dir1 = getDirectory("Input folder: images at any magnification from a single microscope"); //select an input folder
  dir2 = getDirectory("Choose a folder to save to"); //select an output folder. 
  list = getFileList(dir1); //make a list of the filenames
  setBatchMode(true); //turn on batch mode

	for (i=0; i<list.length; i++) {
	 	showProgress(i+1, list.length);
	 	filename = dir1 + list[i];
	 	if (endsWith(filename, "czi")) {
		run("Bio-Formats Importer", "open=[filename] autoscale color_mode=Default view=Hyperstack stack_order=XYCZT");	
		Imagename = File.nameWithoutExtension;
	
// Change colour camera .czi files from a 3 channel 14 bit image to a gamma corrected RGB image
		Stack.setChannel(1);
		setMinAndMax(0, 16383);
		Stack.setChannel(2);
		setMinAndMax(0, 16383);
		Stack.setChannel(3);
		setMinAndMax(0, 16383);
		//call("ij.ImagePlus.setDefault16bitRange", 14);
		run("RGB Color");
		run("Gamma...", "value=0.45");
	 
	    saveAs("Tif", dir2+Imagename);//saves the image to output folder and over writes the original files if the input and output folder are the same
	 }
 	
   }
  exit("Gamma set in "+i+" images");
}
