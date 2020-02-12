//Macro written by Dale Moulding, ICH Imaging Facility, UCL. 24 March 2016.
//Automates analysis of 4 channel cilia images, identifies cilia in the second channel, 
//then counts the number of spots on each cilia in the 3rd channel.

/*
 * Copyright (c) 2020 Dale Moulding, UCL. Made available for use under the MIT license.
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
 */

// Published in: Taschner M, Lorentzen A, Mourão A, Collins T, Freke GM, Moulding D, Basquin J, Jenkins D, Lorentzen E. 
// Crystal structure of intraflagellar transport protein 80 reveals a homo-dimer required for ciliogenesis. 
// Elife. 2018 Apr 16;7. pii: e33067. PMID: 29658880

macro "Cilia_Spots_2D"{
dir1 = getDirectory("Input Folder: images at the same magnification"); //select an input folder.
  dir2 = getDirectory("Choose a folder to save to"); //select an output folder. 
  list = getFileList(dir1); //make a list of the filenames in the folder.
  //setBatchMode(true); //turn on batch mode. but this kills line 40 as it doesnt see the ROI manager

for (l=0; l<list.length; l++) {
 	showProgress(l+1, list.length);
 	filename = dir1 + list[l];
 	if (endsWith(filename, "tif")|endsWith(filename, "zvi")|endsWith(filename, "ZVI")) {
        if (endsWith(filename, "tif")) open(filename);
        if (endsWith(filename, "zvi")|endsWith(filename, "ZVI")) 
        run("Bio-Formats Importer", "open=[filename] autoscale color_mode=Default view=Hyperstack stack_order=XYCZT");
        
Imagename = File.nameWithoutExtension;

run("Clear Results"); //clear the results
filename=getTitle();
run("8-bit");
run("Split Channels");
selectWindow("C2-"+filename);
run("Duplicate...", "title=copy duplicate");
run("Subtract Background...", "rolling=5"); // removes background. If this is too harsh increase the "rolling" value.
run("Median...", "radius=3"); 
run("Gamma...", "value=0.70"); //optional line may help to include for some noisy images.
setAutoThreshold("Yen dark");// Otsu needed for less bright cilia. Yen may be better if images are bright
setOption("BlackBackground", false);
run("Convert to Mask"); // these 4 lines automatically set a threshold and make a black and white image.
run("Dilate"); run("Dilate"); run("Dilate"); run("Dilate");
run("Skeletonize");
run("Dilate"); run("Dilate"); run("Dilate");
run("Analyze Particles...", "size=1-20 clear include add");
roiManager("Save", dir2+Imagename+"CiliaMasksRoiSet.zip"); // saves the mask ROIs

run("Skeletonize");
run("Duplicate...", "title=copy duplicate");
run("Set Measurements...", "perimeter redirect=None decimal=3");
run("Analyze Particles...", "display clear add");
roiManager("Save", dir2+Imagename+"CilialengthsRoiSet.zip"); // saves the lengths ROIs
selectWindow("ROI Manager"); // select and close the ROI manager window
run("Close");
IJ.renameResults("CiliaPerimeter");// rename the results window so new measurements can be made with the same ROI number

selectWindow("C3-"+filename);
run("Duplicate...", "title=SpotsImage duplicate");
run("Subtract Background...", "rolling=10");
run("Despeckle");
roiManager("Open", dir2+Imagename+"CiliaMasksRoiSet.zip")
roiManager("Show All without labels");
//this section takes each Cilia Mask ROI in order, finds the number of spots in each one, and saves the counts to the results table
 number=roiManager("count");
     for(n=0; n<number;n++) {
      selectWindow("C3-"+filename);
      roiManager("Select", n);
      run("Set Measurements...", "redirect=None decimal=3");
      run("Find Maxima...", "noise=20 output=Count");
     }
     
//to compile results from different measurements the results table is copied to an array
//
CiliaPerimeter = newArray(n); 
Spots = newArray(n); 
     
    for (i=0; i<number; i++) {
       Spots[i] = getResult("Count", i);
 	}// fills the Spots array with the spots results
selectWindow("CiliaPerimeter"); 
IJ.renameResults("Results");

    for (i=0; i<number; i++) {
       CiliaPerimeter[i] = getResult("Perim.", i);
    }// fills the CiliaPerimeter array with the Perimeter measurements
run("Clear Results");

    for (i=0; i<number; i++) {
   	  setResult("Spots", i, Spots[i]);
   	  setResult("Length", i, (CiliaPerimeter[i]/2));
   	  setResult("Spots distance", i, (((CiliaPerimeter[i])/2)/(Spots[i]/2)));
   }
     updateResults(); 
     
saveAs("Results", dir2+Imagename + "-Results.csv"); // saves results as a table for excel.
run("Clear Results");
selectWindow("ROI Manager"); // select and close the ROI manager window
run("Close");
roiManager("Open", dir2+Imagename+"CiliaLengthsRoiSet.zip")
selectWindow("C2-"+filename);
roiManager("Show All without labels");
run("Flatten");
saveAs("Jpeg", dir2+Imagename+"-cilia");//saves an image of the detected cilia.


selectWindow("ROI Manager"); // select and close the ROI manager window
run("Close");
roiManager("Open", dir2+Imagename+"CiliaMasksRoiSet.zip")
selectWindow("C3-"+filename);
roiManager("combine");
run("Find Maxima...", "noise=20 output=[Point Selection]");
selectWindow("ROI Manager"); // select and close the ROI manager window to clear results
run("Close");
roiManager("Add");
roiManager("Save", dir2+Imagename+"CiliaSpotsRoiSet.zip"); // saves the spots ROIs
run("Flatten");
saveAs("Jpeg", dir2+Imagename+"-spots");//saves an image of the detected cilia.
run("Close All");
 	}
}
selectWindow("ROI Manager"); run("Close");
selectWindow("Results"); run("Close");
exit("Cilia and spots analysed in "+l+" images");
}     
