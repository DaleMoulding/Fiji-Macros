/*
 * Macro written by Dale Moulding & Claudiu Cozmescu 2023
 * Please acknowledge its use
 * Copyright (c) 2023 Dale Moulding, UCL. Made available for use under the MIT license.
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

macro "BC analysis" {
dir1 = getDirectory("Input Folder: your BC images"); 			// select an input folder.
dir2 = getDirectory("Choose a folder to save the marked images"); // select an output folder. 
dir3 = getDirectory("Select a folder to save the composite of co-expression");// select second output folder for composite images of co-expression

  list = getFileList(dir1); // make a list of the filenames in the folder.

for (i=0; i<list.length; i++) {
 	showProgress(i+1, list.length);
 	filename = dir1 + list[i];

open(filename);
Imagename = File.nameWithoutExtension;	                       // this lets you use the string "Imagename" in the macro to save files with the name of the input file
origImage = getTitle();                                        // so you can recall the original image later

run("Color Balance..."); 
resetMinAndMax(); 
// Thresholds, sizes and circularuty should be refined to fit your images. 
//Same settings should be kept for all your analysed images.

run("Split Channels");                                         //split channels into c1 c2 c3

//Dapi analysis 
selectWindow("C1-"+origImage);                                 // selection of Dapi channel C0
run("Z Project...", "projection=[Max Intensity]");
run("Duplicate...", "title=Dapicopy1");
run("Duplicate...", "title=Dapicopy2");
run("Duplicate...", "title=Dapicopy3");
rename("MAX_C1-"+Imagename);                                   // Rename so it keeps the image name in the count
run("Subtract Background...", "rolling=50 sliding disable");
run("Threshold...");                                           // Image/Adjust
setAutoThreshold("Mean dark");                                 // Set Dapi Threshold
setOption("BlackBackground", false);
run("Convert to Mask");                                        // Done by threshold function
run("Watershed");                                              // Process  binary
//Run Dapi annalysis 
run("Analyze Particles...", "size=50-3000 show=[Bare Outlines] exclude summarize"); // Analyze, change size, circularity if need be.
selectWindow("Drawing of MAX_C1-"+Imagename);					// Make image 16-bit
run("16-bit");
rename("Drawing of Nuclei");
//Merge orig with the DAPI outlines
run("Merge Channels...", "c4=Dapicopy1 c7=[Drawing of Nuclei] create"); // Creates a merged verison of the counted ROI and the original Dapi
run("Next Slice [>]");											// Inverts LUT on second slide
run("Invert LUT");
run("RGB Color");
saveAs("Tiff", dir2+Imagename + "Counted Nuclei");				// Save in dir2 - "Counted ROIs"

//MRP2 analysis
selectWindow("C2-"+origImage);                                  // selection of green channel C1
run("Z Project...", "projection=[Average Intensity]");          // needed only if you have a stack 
run("Duplicate...", "title=MRP2copy1");							// Copy for merging with counting outlines composite
run("Duplicate...", "title=MRP2copy2");							// Copy for co-expression masks composite
run("Duplicate...", "title=MRP2copy3");							// Working copy for calculation
rename("AVG_MRP2-"+Imagename);									// Rename so it keeps the image name in the count
run("Subtract Background...", "rolling=50 sliding disable");    // Image preparation Remove bakground 
run("Median...", "radius=2");                                   // Image prep filter 
run("Threshold...");                                            // Image/Adjust								
setThreshold(2200,65535);										//Set Channel 2 Threshold (values can vary between stainings but must be kept consistent for the same analysis)
setOption("BlackBackground", false);
run("Convert to Mask");                                         // Done by threshold function
//Run MRP2 analysis 
run("Analyze Particles...", "size=3-50 circularity=0.50-1.00 show=Masks exclude summarize"); // Analyze, change size, circularity if need be.
selectWindow("AVG_MRP2-"+Imagename);
run("Analyze Particles...", "size=3-50 circularity=0.50-1.00 show=[Bare Outlines] exclude "); //Analyse, same as above but to create outlines
selectWindow("Drawing of AVG_MRP2-"+Imagename);					// Make image 16-bit so can be merged
run("16-bit");
rename("Drawing of MRP2");
//Merge orig with the MRP2 outlines
selectWindow("MRP2copy1");
run("Color Balance...");
setMinAndMax(1416, 14241);										 // Increase inentsity so the BC can be seen better -> when this is done some unobserved canaliculi might appear
run("Apply LUT");
run("Merge Channels...", "c2=MRP2copy1 c7=[Drawing of MRP2] create"); // Merge ROI with original image
run("Next Slice [>]");											// Inverts the lUT of the second slide 
run("Invert LUT");
run("RGB Color");
saveAs("Tiff", dir2+Imagename + "Counted MRP2 BC");				// Save in dir2 - "Counted ROIs"

//CEA analysis
selectWindow("C3-"+origImage);                                  // Selection of red channel C2
run("Z Project...", "projection=[Average Intensity]");          // Needed only if you have a stack 
run("Duplicate...", "title=CEAcopy1");							// Copy for merging with counting outlines composite
run("Duplicate...", "title=CEAcopy2");							// Copy for co-expression masks composite
run("Duplicate...", "title=CEAcopy3");							// Working copy for calculation
rename("AVG_CEA-"+Imagename);									// Rename so it keeps the image name in the count
run("Subtract Background...", "rolling=50 sliding disable");
run("Median...", "radius=0");
run("Threshold...");                                            // Image/Adjust
setThreshold(5200,65535);                                       // Set red Channel 3 Threshold (values can vary between stainings but must be kept consistent for the same analysis)
setOption("BlackBackground", false);                            // done by threshold function
run("Convert to Mask");                                         // done by threshold function
//Run CEA analysi 
run("Analyze Particles...", "size=3-50 circularity=0.50-1.00 show=Masks exclude summarize"); // Analyze, change size, circularity if need be.
selectWindow("AVG_CEA-"+Imagename);
run("Analyze Particles...", "size=3-50 circularity=0.50-1.00 show=[Bare Outlines] exclude "); //Analyse, same as above but to create outlines
selectWindow("Drawing of AVG_CEA-"+Imagename);                  // make image 16-bit so can be merged
run("16-bit"); 
rename("Drawing of CEA");
//Merge orig with the CEA outlines
selectWindow("CEAcopy1");
run("Color Balance...");
setMinAndMax(273, 9485);                                         // Increase inentsity so the BC can be seen better -> when this is done some unobserved canaliculi might appear
run("Apply LUT");
run("Merge Channels...", "c2=CEAcopy1 c7=[Drawing of CEA] create"); // Merge ROI with original image
run("Next Slice [>]");											// Inverts the lUT of the second slide 
run("Invert LUT");
run("RGB Color");
saveAs("Tiff", dir2+Imagename + "Counted CEA BC");				// Save in dir2 - "Counted ROIs"

//Co-expressing canaliculi 
selectWindow("Mask of AVG_MRP2-"+Imagename);
rename("MRP2 expressing BC");
selectWindow("Mask of AVG_CEA-"+Imagename);
rename("CEA expressing BC");
imageCalculator("AND create", "MRP2 expressing BC","CEA expressing BC");
selectWindow("Result of MRP2 expressing BC");
rename("MRP2 and CEA BC co-expression-"+Imagename);
run("Analyze Particles...", "size=4-160 circularity=0.30-1.00 exclude summarize");

//Differentially expressing canaliculi 
imageCalculator("Subtract create", "MRP2 expressing BC","CEA expressing BC");
imageCalculator("Subtract create", "CEA expressing BC","MRP2 expressing BC");
imageCalculator("Add create", "Result of MRP2 expressing BC","Result of CEA expressing BC");
selectWindow("Result of Result of MRP2 expressing BC");
rename("Divergent");
run("16-bit");
selectWindow("MRP2 and CEA BC co-expression-"+Imagename);
rename("Co-expression");
run("16-bit");

//Image generator for co-expression and differential expression
run("Merge Channels...", "c1=CEAcopy2 c2=MRP2copy2 c4=Dapicopy2 c6=Divergent c7=Co-expression create"); 
run("Next Slice [>]");
run("Next Slice [>]");
run("Grays");
run("Next Slice [>]");
run("Invert LUT");
run("Magenta");
run("Next Slice [>]");
run("Invert LUT");
run("Yellow");
run("RGB Color");
saveAs("Tiff", dir3+Imagename + "Co-expression"); 				// Save in dir3 - "Co-expression masks"

//Close
 run("Color Balance..."); 
 resetMinAndMax(); 
run("Close All");
 	}
selectWindow("Summary");
saveAs("Results", dir2+"Summary.csv");// save the summary as a .csv.
exit("BC analyised in "+i+" images"); // close the macro and display a window with number of images processed.
}

