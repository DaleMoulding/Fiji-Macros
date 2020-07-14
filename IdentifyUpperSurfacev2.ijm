// Macro to remove all image voxels except those near the top surface of a 3D image.
// requires a thresholded binary image to identify upper surface layer.
// Take the resulting image and use as mask on your original image.
// Written by Dale Moulding, UCL GOS ICH Light Microscopy Facility. February 2017.
/*
Copyright (c) [2017] [UCL written by Dale Moulding] made available for use under the MIT license. 
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE. 
*/
// As first used in the paper:
// Galea GL, Nychyk O, Mole MA, Moulding D, Savery D, Nikolopoulou E, Henderson DJ, Greene NDE, Copp AJ.
// Vangl2 disruption alters the biomechanics of late spinal neurulation leading to spina bifida in mouse embryos. 
// Dis Model Mech. 2018 Mar 21;11(3). PMID: 29590636

macro "IdentifyUpperSurface"{
	image=getTitle();
	getDimensions(width, height, channels, slices, frames);
	newImage("SurfaceMask", "8-bit white", width, height, slices);
	selectWindow(image);
	x = 0;
    y = 0;
    pixelvalue = 0;
    xcoord = newArray(1);
    ycoord = newArray(1);
    row = 0;
    run("Colors...", "foreground=black background=white selection=yellow");
    run("Line Width...", "line=10"); // How thick is your surface in pixels? Set line= to double the width of your surface layer.
    run("Clear Results");
    

	for (z=0; z<slices; z++) { //loop the whole macro one slice at a time.
    setSlice(z+1);
		 for (w=0; w<width; w++) { // scan down each x column for every column
				
				while (pixelvalue == 0 && y<height) { //scan down an x column until the pixel value is not 0, with y reporting the y coordinate of the first +ve pixel
				pixelvalue = getPixel(x, y);
				y = y+1;
				}
			if (y != height){	//record / draw the pixel coordinate unless it is an empty x column
			//print(x+", ");
			//print(y+", ");
			//print("z=" +z+1);
			setResult("xcoord", row, x);
			setResult("ycoord", row, y);
			row = row+1;
			}
			x=x+1; //move to next x column
			y=0; // reset y to start at top of column
			pixelvalue=0;
		 } //end of each column loop
		 
		selectWindow("SurfaceMask");
		setSlice(z+1);
		number = getValue("results.count"); //counts the number of x/y results
		xcoord = newArray(number); //makes an empty array for the x cooordinates
		ycoord = newArray(number);
			for (a=0; a<number; a++) {
       			xcoord[a] = getResult("xcoord", a);
 			}// fills the xcoord array with the spots results
			for (a=0; a<number; a++) {
       			ycoord[a] = getResult("ycoord", a);
 			}// fills the ycoord array with the spots results
		if (number != 0) {makeSelection("Polyline", xcoord, ycoord); // if here checks there are some results, "if no results" it skips drawing a line
		run("Draw", "slice");
		run("Clear Results");
		run("Select None");
		} //end of "if no results" skip it section
		selectWindow(image);
	row=0;	
	x = 0;	 
	w = 0;
	}//end of slice loop = repeats for each slice until all slices done
}

/*
 * 
*/
