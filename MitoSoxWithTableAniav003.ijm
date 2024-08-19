/*
 * Macro written by Dale Moulding June 2024
 * Please acknowledge its use
 * Copyright (c) 2024 Dale Moulding, UCL. Made available for use under the MIT license.
 * https://opensource.org/licenses/MIT
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:

 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.

 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 * 
 */

//changelog
// v005 correct the x axis scale. Imaging from Oil into water (RI 1.51. to RI 1.33) means z dimensions are (1.51/1.33) too large 
// v006 change the saved output images so the binary images (ch2 & 4 are scaled to 16 bit, so +ve pixels = 65535, not 255).
// v007 !!! the channels are wrong. Ch1 = CD14, Ch2 = MitoSox, Ch3 = MTGr
// v010 more mitosox adjustents. Try Med10 as back ground subtraction
// v011 Do med local background for both channels
// v011a add new measures & output table and output images
// 1) measure mitosox intensity in the MTGr mask
// 2) make an overlap of the MTGr and MitoSox Masks. Measure volume etc & Int D in MitoSox
// 3) add a channel of the overlap of MTGr and MitoSox
// v013 measure every individual Mitotracker Green mitochondria, compile tables showing
// from line 185 & also adds to original tables lines 170 # of Mito and AveSize
// 1) Volume of every mitochondria in each image/cell
// 2) surface area of every mitochondria
// v014 shrink the masked images by 1 (or 2) pixels to avoid adge artefacts where lots of small ROIs are identified on the edge of each spherically cropped image.
// run and compare to version 13 to check the results.
// v015 change MitoSox BG removal to a gaussian.
// v016 corrected the scale of the input tifs. These had defaulted to 1x1x1 pixel, shoudl be 0.0645xy and 0.26umz.
// v017 Ania images often have very low signal which is throwing the auto thrreshold. Define a hard theshold.
// v017 crashing if no objects at line 144. Add an 'if' to skip the measurement if there is no signal.
// check if this will crash the results section if nothing is measured.
//
//Ania version 001. Cells moving during acquistion, so overlaps cannot be measured.
// Ania v002. make sure the results tables are still populated (with values = 0) if a channel produces no results.
// ania v003 corrected pixel sizes for 63 acquistion

	dir1 = getDirectory("Choose Source Directory "); //select an input folder
	dir2 = getDirectory("Choose a folder to save to"); //select an output folder. 
	list = getFileList(dir1); //make a list of the filenames
	setBatchMode(true); //turn on batch mode
	
	for (i=0; i<list.length; i++) {
	 	showProgress(i+1, list.length);
	 	filename = dir1 + list[i]; 
	if (endsWith(filename, "tif")){ 
        open(filename);
	} 
	 
	run("Clear Results");
// v016 set the scale of the input TIF images back to the original values
	run("Properties...", "pixel_width=0.1031750 pixel_height=0.1031750 voxel_depth=0.26 frame=[1 sec]"); // make sure it is the correct magnification 
	// 100x is 0.0645 xy., 63x is 0.1031750 xy
// v005 change z axis to correct size
	getVoxelSize(width, height, depth, unit);
	zdepth = depth *1.33 / 1.55;
	setVoxelSize(width, height, zdepth, "micron"); // ! it reads it as 'microns' but should be 'micron'
	
	ImageName = File.nameWithoutExtension;
	InputImage = getImageID();
	
// threshold Mitotracker Green
	run("Duplicate...", "title=MTGr duplicate channels=3"); // v007 changed to Ch3
	run("Duplicate...", "title=MTGrMask duplicate"); // v010 Median filter as local background
	//run("Median...", "radius=10 stack");
	//run("Gaussian Blur...", "sigma=4 stack");		// v017 Gaus for BG removal
	//imageCalculator("Subtract create stack", "MTGr","MTGrBG");
	setThreshold(10000, 65535, "raw");				// v001 Ania, hard threshold, no BG subtraction as this was enhancing membrane signal
	setOption("BlackBackground", false);
	run("Convert to Mask", "background=Dark");
	run("Invert LUT");
	
	selectImage(InputImage);
	
// threshold MitoSox
	run("Duplicate...", "title=MitoSox duplicate channels=2"); // v007 changed to Ch2
	run("Duplicate...", "title=MitoSoxMask duplicate"); // v010 Median filter as local background
	//run("Median...", "radius=5 stack");
	run("Gaussian Blur...", "sigma=1 stack");				//v015 Gaussian local BG
	//imageCalculator("Subtract create stack", "MitoSox","MitoSoxBG");
	setThreshold(1500, 65535, "raw");				// v017 set a hard threshold. 2000
	setOption("BlackBackground", false);
	run("Convert to Mask", "background=Dark");
	run("Invert LUT");

// v014 
	selectImage(InputImage);
	run("Duplicate...", "title=ch3 duplicate channels=3"); // copy the MtGr spherically cropped channel
	selectImage(InputImage);
	run("Duplicate...", "title=ch2 duplicate channels=2"); // copy the MitoSox spherically cropped channel
	imageCalculator("Add create stack", "ch3","ch2");
	rename("Sphere");
	close("ch*");
	setThreshold(1, 65535); 								// threshold it so the entire sphere is a mask
	setOption("BlackBackground", false);
	run("Convert to Mask", "method=Default background=Dark");
	run("Divide...", "value=255 stack");					// make the mask image Zeros and ones (O / 1)
	run("Minimum 3D...", "x=1 y=1 z=1");	
	
// Apply the 1 pixel smaller spherical mask to the "MTGrMask" & "MitoSoxMask" images
	imageCalculator("Multiply create stack", "Sphere","MTGrMask");
	selectWindow("MTGrMask");
	close();
	selectWindow("Result of Sphere");
	rename("MTGrMask");
	imageCalculator("Multiply create stack", "Sphere","MitoSoxMask");
	selectWindow("MitoSoxMask");
	close();
	selectWindow("Result of Sphere");
	rename("MitoSoxMask");


// need to add an if command here to miss out the "run("3D Objects Counter"," line if there is no signal
	// measure MitoGr
	selectWindow("MTGrMask");
	Stack.getStatistics(voxelCount, mean, min, max, stdDev); // check there is a signal to measure
	if (max == 255){
	run("3D OC Options", "volume surface integrated_density mean_gray_value dots_size=5 font_size=10 store_results_within_a_table_named_after_the_image_(macro_friendly) redirect_to=MTGr");
	run("3D Objects Counter", "threshold=128 slice=42 min.=10 max.=10000000 statistics");
	}
	else{ // make a results table with all values = zero v002
		name = "Statistics for MTGrMask redirect to MTGr";
		Table.create(name);
		Table.set("Volume (micron^3)", 0, 0);
		Table.set("Surface (micron^2)", 0, 0);
		Table.set("IntDen", 0, 0);
		Table.update;
	}
	// measure MitSox
	selectWindow("MitoSoxMask");
	Stack.getStatistics(voxelCount, mean, min, max, stdDev); // check there is a signal to measure
	if (max == 255){
	run("3D OC Options", "volume surface integrated_density mean_gray_value dots_size=5 font_size=10 store_results_within_a_table_named_after_the_image_(macro_friendly) redirect_to=MitoSox");
	run("3D Objects Counter", "threshold=128 slice=42 min.=10 max.=10000000 statistics");
	}
	else{ // make a results table with all values = zero v002
		name = "Statistics for MitoSoxMask redirect to MitoSox";
		Table.create(name);
		Table.set("Volume (micron^3)", 0, 0);
		Table.set("Surface (micron^2)", 0, 0);
		Table.set("IntDen", 0, 0);
		Table.update;
	}
	//merge them and save the image
	selectWindow("MTGrMask");
	run("16-bit");
	run("Multiply...", "value=257 stack"); // set pixels to 0 and 65535 (from 0 and 255)
	selectWindow("MitoSoxMask");
	run("16-bit");
	run("Multiply...", "value=257 stack"); // set pixels to 0 and 65535 (from 0 and 255)
	
	run("Merge Channels...", "c1=MTGr c2=MTGrMask c3=MitoSox c4=MitoSoxMask create");
	Stack.setChannel(1);
	run("Green");
	Stack.setChannel(2);
	run("Cyan");
	Stack.setChannel(3);
	run("Yellow");
	Stack.setChannel(4);
	run("Magenta");

	saveAs("tiff", dir2+ImageName+"-measured.tif");

// Make a results table...

// Ania v001 need to make a results table with all Zeros if there was no signal...

// Select the results from the MTGr threshold image, measuring Volume and surface area, and the total intensity of MTGr signal in that volume
	

	selectWindow("Statistics for MTGrMask redirect to MTGr");	
	Results = Table.size;  // count the number of lines of results
	Vol = newArray(Results); // make a new array for each set of results to be saved
	Surface = newArray(Results);
	IntDen = newArray(Results);
	    
	for (r = 0; r < Results; r++) { // fill each array with the results
	    v = getResult('Volume (micron^3)', r);
	    Vol[r] = v;
	    s = getResult('Surface (micron^2)', r);
	    Surface[r] = s;
	    IntD = getResult('IntDen', r);
	    IntDen[r] = IntD;
	    //setResult('myColumn', r, v);
	}
	Array.getStatistics(Vol, min, max, mean, stdDev); // total up the results from each ROI to get the total amount
	VolTot = mean * Results;
	MtGrMeanSize = mean; // v012
	Array.getStatistics(Surface, min, max, mean, stdDev);
	SurfTot = mean * Results;
	Array.getStatistics(IntDen, min, max, mean, stdDev);
	IntDenTot = mean * Results;
	
	if (isOpen("MitoResults") == false){
		name = "MitoResults";
		Table.create(name);
	}
	selectWindow("MitoResults");
	if(i==0) {
		Table.set("Image", 0, ImageName);
		Table.set("MTGr Volume", 0, VolTot);
		Table.set("MTGr # of Mito", 0, Results); //v012
		Table.set("MTGr Ave Mito Size", 0, MtGrMeanSize);//v012
		Table.set("MTGr Surface", 0, SurfTot);
		Table.set("MTGr Intensity", 0, IntDenTot);
		Table.update;
	} else {
		Table.set("Image", i, ImageName);
		Table.set("MTGr Volume", i, VolTot);
		Table.set("MTGr # of Mito", i, Results); //v012
		Table.set("MTGr Ave Mito Size", i, MtGrMeanSize);//v012
		Table.set("MTGr Surface", i, SurfTot);
		Table.set("MTGr Intensity", i, IntDenTot);
		Table.update;
	}

// v012 new tables for every individual MtGr mitochondria volume and surface

	if (isOpen("MitoVolumes") == false){
		name = "MitoVolumes";
		Table.create(name);
	}
// here make a new resutls table
// just need to change the column name to be the imagename+Vol or +Surf
	selectWindow("MitoVolumes");
	for (r = 0; r < Results; r++) {
		Table.set(ImageName+" Volume ", r, Vol[r]);
		Table.update;
	}

// make a table for surfaces
	if (isOpen("MitoSurfaces") == false){
			name = "MitoSurfaces";
			Table.create(name);
		}
	selectWindow("MitoSurfaces");
	for (r = 0; r < Results; r++) {
		Table.set(ImageName+" Surface", r,  Surface[r]);
		Table.update;
	}

// end of v012 new tables

// do the same for the MitoSox thresholded image
// section to check there are some results... make an empty results table if it is not open...


		selectWindow("Statistics for MitoSoxMask redirect to MitoSox");	
		Results = Table.size;
		Vol = newArray(Results);
		Surface = newArray(Results);
		IntDen = newArray(Results);
		    
		for (r = 0; r < Results; r++) {
		    v = getResult('Volume (micron^3)', r);
		    Vol[r] = v;
		    s = getResult('Surface (micron^2)', r);
		    Surface[r] = s;
		    IntD = getResult('IntDen', r);
		    IntDen[r] = IntD;
		    //setResult('myColumn', r, v);
		}
		
		Array.getStatistics(Vol, min, max, mean, stdDev);
		VolTot = mean * Results;
		Array.getStatistics(Surface, min, max, mean, stdDev);
		SurfTot = mean * Results;
		Array.getStatistics(IntDen, min, max, mean, stdDev);
		IntDenTot = mean * Results;
		
		selectWindow("MitoResults");
		if(i==0) {
			Table.set("MitoSox Volume", 0, VolTot);
			Table.set("MitoSox Surface", 0, SurfTot);
			Table.set("MitoSox Intensity", 0, IntDenTot);
			Table.update;
		} else {
			Table.set("MitoSox Volume", i, VolTot);
			Table.set("MitoSox Surface", i, SurfTot);
			Table.set("MitoSox Intensity", i, IntDenTot);
			Table.update;
		}
	
	
run("Close All"); // v010 kept crashing 3rd image

	}
selectWindow("MitoResults");
saveAs("Results", dir2+"MitoResults.xls");

selectWindow("MitoVolumes");
saveAs("Results", dir2+"MitoVolumes.xls");

selectWindow("MitoSurfaces");
saveAs("Results", dir2+"MitoSurfaces.xls");

exit("All Done! "+i+" images analysed");