/*
 * Macro written by Dale Moulding March 2022
 * Please acknowledge its use
 * Copyright (c) 2021 Dale Moulding, UCL. Made available for use under the MIT license.
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
//  v005 correct the x axis scale. Imaging from Oil into water (RI 1.51. to RI 1.33) means z dimensions are (1.51/1.33) too large 
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
	run("Properties...", "pixel_width=0.0645 pixel_height=0.0645 voxel_depth=0.26 frame=[1 sec]");
// v005 change z axis to correct size
	getVoxelSize(width, height, depth, unit);
	zdepth = depth *1.33 / 1.55;
	setVoxelSize(width, height, zdepth, "micron"); // ! it reads it as 'microns' but should be 'micron'
	
	ImageName = File.nameWithoutExtension;
	InputImage = getImageID();
	
// threshold Mitotracker Green
	run("Duplicate...", "title=MTGr duplicate channels=3"); // v007 changed to Ch3
	run("Duplicate...", "title=MTGrBGMed duplicate"); // v010 Median filter as local background
	run("Median...", "radius=10 stack");
	imageCalculator("Subtract create stack", "MTGr","MTGrBGMed");
	rename("MTGrMask");														// Mask image called "MTGrMask"
	setAutoThreshold("IsoData dark stack");				// was RenyiEntropy
								// set threshold as a number
	setOption("BlackBackground", false);
	run("Convert to Mask", "method=IsoData background=Dark");
	run("Invert LUT");
	
	selectImage(InputImage);
	
// threshold MitoSox
	run("Duplicate...", "title=MitoSox duplicate channels=2"); // v007 changed to Ch2
	run("Duplicate...", "title=MitoSoxBGGaus duplicate"); // v010 Median filter as local background
	//run("Median...", "radius=5 stack");
	run("Gaussian Blur...", "sigma=5 stack");				//v015 Gaussian local BG
	imageCalculator("Subtract create stack", "MitoSox","MitoSoxBGGaus");
	rename("MitoSoxMask");												// Mask image called "MitoSoxMask"
	setAutoThreshold("IsoData dark stack");				// was RenyiEntropy
	setOption("BlackBackground", false);
	run("Convert to Mask", "method=IsoData background=Dark");
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
	

// make an 'And' image of the MTGr and MitoSox masks
	imageCalculator("AND create stack", "MTGrMask","MitoSoxMask");
	rename("MTGr&MitoSox");
	
	// measure MitoGr
	selectWindow("MTGrMask");
	run("3D OC Options", "volume surface integrated_density mean_gray_value dots_size=5 font_size=10 store_results_within_a_table_named_after_the_image_(macro_friendly) redirect_to=MTGr");
	run("3D Objects Counter", "threshold=128 slice=42 min.=10 max.=10000000 statistics");
	
	// measure MitSox
	selectWindow("MitoSoxMask");
	run("3D OC Options", "volume surface integrated_density mean_gray_value dots_size=5 font_size=10 store_results_within_a_table_named_after_the_image_(macro_friendly) redirect_to=MitoSox");
	run("3D Objects Counter", "threshold=128 slice=42 min.=10 max.=10000000 statistics");

	// measure MitSox Int in MTGr Mask 	// v011a
	selectWindow("MTGrMask");
	run("3D OC Options", "volume surface integrated_density mean_gray_value dots_size=5 font_size=10 store_results_within_a_table_named_after_the_image_(macro_friendly) redirect_to=MitoSox");
	run("3D Objects Counter", "threshold=128 slice=42 min.=10 max.=10000000 statistics");

	// measure MitSox Int in MTGr AND MitoSox overlap	// v011a
	selectWindow("MTGr&MitoSox");
	run("3D OC Options", "volume surface integrated_density mean_gray_value dots_size=5 font_size=10 store_results_within_a_table_named_after_the_image_(macro_friendly) redirect_to=MitoSox");
	run("3D Objects Counter", "threshold=128 slice=42 min.=10 max.=10000000 statistics");
	
	//merge them and save the image
	selectWindow("MTGrMask");
	run("16-bit");
	run("Multiply...", "value=257 stack"); // set pixels to 0 and 65535 (from 0 and 255)
	selectWindow("MitoSoxMask");
	run("16-bit");
	run("Multiply...", "value=257 stack"); // set pixels to 0 and 65535 (from 0 and 255)
	selectWindow("MTGr&MitoSox");
	run("16-bit");
	run("Multiply...", "value=257 stack"); // set pixels to 0 and 65535 (from 0 and 255)
	run("Merge Channels...", "c1=MTGr c2=MTGrMask c3=MitoSox c4=MitoSoxMask c5=MTGr&MitoSox create");
	Stack.setChannel(1);
	run("Green");
	Stack.setChannel(2);
	run("Cyan");
	Stack.setChannel(3);
	run("Yellow");
	Stack.setChannel(4);
	run("Magenta");
	Stack.setChannel(5);
	run("Grays");

	saveAs("tiff", dir2+ImageName+"-measured.tif");

// Make a results table...

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

// MitoSox Intensity in the MTGr Mask
	selectWindow("Statistics for MTGrMask redirect to MitoSox");	
	Results = Table.size;
	IntDen = newArray(Results);
	    
	for (r = 0; r < Results; r++) {
	    IntD = getResult('IntDen', r);
	    IntDen[r] = IntD;
	    //setResult('myColumn', r, v);
	}
	

	Array.getStatistics(IntDen, min, max, mean, stdDev);
	IntDenTot = mean * Results;
	
	selectWindow("MitoResults");
	if(i==0) {
		Table.set("MitoSox Intensity in MTGr region", 0, IntDenTot);
		Table.update;
	} else {
		Table.set("MitoSox Intensity in MTGr region", i, IntDenTot);
		Table.update;
	}

// Measurements in the Overlap between MTGr mask and MitSox mask
	selectWindow("Statistics for MTGr&MitoSox redirect to MitoSox");	
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
		Table.set("MitoSox/MTGr overlap Volume", 0, VolTot);
		Table.set("MitoSox/MTGr overlap Surface", 0, SurfTot);
		Table.set("MitoSox Intensity in overlap", 0, IntDenTot);
		Table.update;
	} else {
		Table.set("MitoSox/MTGr overlap Volume", i, VolTot);
		Table.set("MitoSox/MTGr overlap Surface", i, SurfTot);
		Table.set("MitoSox Intensity in overlap", i, IntDenTot);
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