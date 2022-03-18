// Sphere from drawn circle and image dimensions
// v002 convert scaled pixel values to pixel.

//  * Macro written by Dale Moulding December 2021
//  * Please acknowledge its use
//  * Copyright (c) 2021 Dale Moulding, UCL. Made available for use under the MIT license.
//  * https://opensource.org/licenses/MIT

// set to measure the diameter x & y of the drawn cirlce, it centre xy & slice.
run("Set Measurements...", "centroid bounding stack redirect=None decimal=3");
run("Clear Results");

//Get dimensions of open image
getDimensions(width, height, channels, slices, frames);
getPixelSize(unit, pixelWidth, pixelHeight);
Zoffset = 8;
Zr = (slices/2)-Zoffset;									// set the sphere radius to be reduced by Zoffset

// Draw a circle around the middle of the cell & press 'M' to measure it...

waitForUser("Draw a circle around the cell in the central slice \nor widest part of the cell.\n \n *** Then press 'OK' ***");

run("Measure");

ImageName=getTitle();
rename("Input");

Xc= getResult("X")/pixelWidth; // centre of the circle in x
Yc= getResult("Y")/pixelWidth; // centre of the circle in y
Zc= getResult("Slice"); // centre of the circle in z

Xr = (getResult("Width")/2)/pixelWidth; // sphere radius in x
Yr = (getResult("Height")/2)/pixelWidth;


run("3D Draw Shape", "size="+width+","+height+","+slices+" center="+Xc+","+Yc+","+Zc+" radius="+Xr+","+Yr+","+Zr+" vector1=1.0,0.0,0.0 vector2=0.0,1.0,0.0 res_xy=1.000 res_z=1.000 unit=unit value=1 display=[New stack]");

// duplicate the image to match the # channels of the input.
// Merge to a new multichannel image. Use image calcultor to multiply the sphere mask image by the input

selectWindow("Shape3D");
rename("MaskCh1");

for (i = 2; i <= channels; i++) {
	selectWindow("MaskCh1");
	run("Duplicate...", "title=MaskCh"+i+" duplicate");
	}
if(channels == 2) run("Merge Channels...", "c1=MaskCh1 c2=MaskCh2 create");
if(channels == 3) run("Merge Channels...", "c1=MaskCh1 c2=MaskCh2 c3=MaskCh3 create");
if(channels == 4) run("Merge Channels...", "c1=MaskCh1 c2=MaskCh2 c3=MaskCh3 c3=MaskCh3 create");

if (isOpen("MaskCh1")){
	selectWindow("MaskCh1");
	rename("Composite");
}

imageCalculator("Multiply create stack", "Input","Composite");

rename(ImageName+"-Masked");



