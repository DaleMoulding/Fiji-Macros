// macro written by Dale Moulding, UCL ICH Imaging facility. March 2016.
// measures cilia length in 2d images using auto-thresholding, skeletonizing, then using half the perimeter of each skeleton as cilia length.
// please acknowledge its use in any publications or presentations.

/*
 * Copyright (c) Dale Moulding, UCL. Made available for use under the MIT license.
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


macro "Cilia_lengths_2D" {
  dir1 = getDirectory("Input Folder: images at the same magnification"); //select an input folder.
  dir2 = getDirectory("Choose a folder to save to"); //select an output folder. 
  list = getFileList(dir1); //make a list of the filenames in the folder.
  setBatchMode(true); //turn on batch mode.

for (i=0; i<list.length; i++) {
 	showProgress(i+1, list.length);
 	filename = dir1 + list[i];
 	if (endsWith(filename, "tif")|endsWith(filename, "zvi")) {
        if (endsWith(filename, "tif")) open(filename);
        if (endsWith(filename, "zvi")) 
        run("Bio-Formats Importer", "open=[filename] autoscale color_mode=Default view=Hyperstack stack_order=XYCZT");
        
Imagename = File.nameWithoutExtension;

run("Clear Results"); //clear the results
run("Duplicate...", "title=copy duplicate channels=2");
run("Duplicate...", "title="+Imagename+" duplicate");
run("Subtract Background...", "rolling=5"); // removes background. If this is too harsh increase the "rolling" value.
run("Median...", "radius=3"); 
//run("Gamma...", "value=0.70"); //optional line may help to include for some noisy images.
setAutoThreshold("Yen dark");
setOption("BlackBackground", false);
run("Convert to Mask"); // these 3 lines automatically set a threshold and make a black and white image.
run("Dilate");
run("Dilate"); // makes each thresholded cilia one pixel wider, to join any gaps. Omit if results shpow cilia are too long.
run("Skeletonize");
run("Set Measurements...", "area perimeter redirect=None decimal=3");
run("Analyze Particles...", "size=0.1-100 show=[Overlay Masks] display exclude clear include summarize add in_situ");
        for(n=0; n<nResults;n++) {
	        setResult("Cilia Length", n, ((getResult("Perim.", n))/2));
        } // this for loop takes the results of each cilia perimeter, divides by 2 to give the length and adds it to the results table.
selectWindow("copy");
roiManager("Show All without labels");
run("Flatten");
saveAs("Tif", dir2+Imagename+"-cilia");//saves an image of the detected cilia.
saveAs("Results", dir2+Imagename + "-Results.csv"); // saves results as a table for excel.
roiManager("Save", dir2+Imagename + "-RoiSet.zip"); // saves the ROIs .
roiManager("Delete");
close("copy");

 	  }
}
selectWindow("Summary");
saveAs("Results", dir2+"Summary.csv");// save the summary as a .csv.
exit("Cilia measured in "+i+" images"); // close the macro and display a window with number of images processed.
}