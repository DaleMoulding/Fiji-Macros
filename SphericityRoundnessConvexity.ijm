 // This macro calculates convexity (convex perimeter/perimeter),
 // sphericity (Maximum Inscribed Circle diameter / Smallest Enclosing circle diameter) and also records standard shape descriptors.
 // Uses arrays to store results, allowing new measurements to be processed and added to a new results.
 // It requires Maximum_Inscribed_Circle.jar developed by Olivier Burri and Romain Guiet at BIOP - available from UCL GOS ICH Light Microscopy Facility
 // Uses smallest enclosing circle macro adapted from Version: 2009-06-12 by Michael Schmid
/*
Copyright (c) [2018] [UCL written by Dale Moulding] made available for use under the MIT license. 
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

run("ROI Manager...");  
	//get image scale
	Dialog.create("Image scale:");
  	Dialog.addString("Pixel size in mm", "0.0575");

  	Dialog.show();
  	pixelsize = Dialog.getString();
  	distance = 1/pixelsize;

	dir1 = getDirectory("Choose Source Directory "); //select an input folder
	dir2 = getDirectory("Choose a folder to save to"); //select an output folder. 
	list = getFileList(dir1); //make a list of the filenames
	setBatchMode(true); //turn on batch mode
	
	for (j=0; j<list.length; j++) {
	 	showProgress(j+1, list.length);
	 	filename = dir1 + list[j]; 
	open(filename);	 
	Imagename = File.nameWithoutExtension; 
	
// Orig macro 1: make binary image, set the scale
	run("8-bit");
	run("Set Scale...", "distance=distance known=1 pixel=1 unit=mm");
	//run("Rotate 90 Degrees Right");
	setAutoThreshold("Default");
	run("Convert to Mask");
	

// Orig macro 2: Measure area, perimeter, shape descriptors, ferets diameter. Remove small fragments.
	run("Set Measurements...", "area center perimeter shape feret's redirect=None decimal=3");
	run("Analyze Particles...", "size=1000-Infinity pixel show=Masks display exclude clear add in_situ");
	roiManager("Save", dir2+Imagename + "RoiSet.zip"); // saves the ROIs
	RoiSet = dir2 + Imagename + "RoiSet.zip";
	
// Make a new array for each set of results
    n = nResults;
    area = newArray(n);
    perim = newArray(n);
    Circ = newArray(n);
    Feret = newArray(n);
    MinFeret = newArray(n);
    AR = newArray(n);
    Round = newArray(n);
    Solidity = newArray(n);
    areaConvex = newArray(n);
    perimConvex = newArray(n);
    x = newArray(n);
    y = newArray(n);
    MaxInsCirc = newArray(n);
    SmallEncCirc = newArray(n);

// fill the arrays with the results
    for (i=0; i<n; i++) {
      area[i] = getResult('Area', i);
      perim[i] = getResult('Perim.', i);
      Circ[i] = getResult('Circ.', i);
      Feret[i] = getResult('Feret', i);
      MinFeret[i] = getResult('MinFeret', i);
      AR[i] = getResult('AR', i);
      Round[i] = getResult('Round', i);
      Solidity[i] = getResult('Solidity', i);
      x[i] = getResult('XM', i);
      y[i] = getResult('YM', i);
    }

// clear the old results after storing as arrays. Make new measurements of convex hull.
    run("Clear Results"); 
    for (i=0; i<n; i++) {
      xcoord = x[i]*distance;
      ycoord = y[i]*distance;
      doWand(xcoord, ycoord);
      run("Convex Hull");
      run("Measure");
      areaConvex[i] = getResult('Area', i);
      perimConvex[i] = getResult('Perim.', i);
      }

// clear the old results after storing as arrays. Make new measurements of Max Inscribed Circle.
	run("Clear Results"); 
	for (i=0; i<n; i++) {
	  xcoord = x[i]*distance;
      ycoord = y[i]*distance;
	  doWand(xcoord, ycoord);
	  run("Max Inscribed Circles...", "minimum=0 use");
	  number=roiManager("count");
	  roiManager("select", number-1);
	  roiManager("Rename", i+1+"-MaxInsCirc");
	  roiManager("Measure");
	  MaxInsCirc[i] = getResult('Feret', i);
	  }

// clear the old results, make new measurements of Smallest Enclosing Circle.
	run("Clear Results"); 
	for (i=0; i<n; i++) {
	  xcoord = x[i]*distance;
      ycoord = y[i]*distance;
	  doWand(xcoord, ycoord);
//small enc circ macro here
	  	/* This macro creates a circular selection that is the smallest circle
   enclosing the current selection.

   Restrictions:
   - Due to rounding errors, some selection points may be slightly outside the circle
*/

//global variables used for passing or as return values
var fourIndices = newArray(4);
var xcenter, ycenter, radius;


  if (selectionType<0) exit("Error: Roi Required");
  if (selectionType==9) exit("This macro does not work with composite selections");
  run("Line Width...", "line=1");
  getSelectionCoordinates(xCoordinates, yCoordinates);
  smallestEnclosingCircle(xCoordinates, yCoordinates);
  diameter = round(2*radius);
  makeOval(round(xcenter-radius), round(ycenter-radius), diameter, diameter);
 


/* Finds the smallest circle enclosing a set of points */
/* Input: arrays of x and y coordinates of the points */
/* Returns global variables xcenter, ycenter, radius */
function smallestEnclosingCircle(x,y) {
  xl = x.length;
  if (xl==1)
    return newArray(x[0], y[0], 0);
  else if (xl==2)
    return circle2(x[0], y[0], x[1], y[1]);
  else if (xl==3)
    return circle3(x[0], y[0], x[1], y[1], x[2], y[2]);
  //As starting point, find indices of min & max x & y
  xmin = 999999999; ymin=999999999; xmax=-1; ymax=-1;
  for (k=0; k<xl; k++) {
    if (x[k]<xmin) {xmin=x[k]; fourIndices[0]=k;}
    if (x[k]>xmax) {xmax=x[k]; fourIndices[1]=k;}
    if (y[k]<ymin) {ymin=y[k]; fourIndices[2]=k;}
    if (y[k]>ymax) {ymax=y[k]; fourIndices[3]=k;}
  }
  do {
    badIndex = circle4(x, y);  //get circle through points listed in fourIndices
    newIndex = -1;
    largestRadius = -1;
    for (i=0; i<xl; i++) {      //get point most distant from center of circle
      r = vecLength(xcenter-x[i], ycenter-y[i]);
      if (r > largestRadius) {
        largestRadius = r;
        newIndex = i;
      }
    }
    //print(largestRadius);
    retry = (largestRadius > radius*1.0000000000001);
    fourIndices[badIndex] = newIndex; //add most distant point
  } while (retry);
}

//circle spanned by diameter between two points.
function circle2(xa,ya,xb,yb) {
  xcenter = 0.5*(xa+xb);
  ycenter = 0.5*(ya+yb);
  radius = 0.5*vecLength(xa-xb, ya-yb);
  return;
}
//smallest circle enclosing 3 points.
function circle3(xa,ya,xb,yb,xc,yc) {
  xab = xb-xa; yab = yb-ya; c = vecLength(xab, yab);
  xac = xc-xa; yac = yc-ya; b = vecLength(xac, yac);
  xbc = xc-xb; ybc = yc-yb; a = vecLength(xbc, ybc);
  if (b==0 || c==0 || a*a>=b*b+c*c) return circle2(xb,yb,xc,yc);
  if (b*b>=a*a+c*c) return circle2(xa,ya,xc,yc);
  if (c*c>=a*a+b*b) return circle2(xa,ya,xb,yb);
  d = 2*(xab*yac - yab*xac);
  xcenter = xa + (yac*c*c-yab*b*b)/d;
  ycenter = ya + (xab*b*b-xac*c*c)/d;
  radius = vecLength(xa-xcenter, ya-ycenter);
  return;
}
//Get enclosing circle for 4 points of the x, y array and return which
//of the 4 points we may eliminate
//Point indices of the 4 points are in global array fourIndices
function circle4(x, y) {
  rxy = newArray(12); //0...3 is r, 4...7 is x, 8..11 is y
  circle3(x[fourIndices[1]], y[fourIndices[1]], x[fourIndices[2]], y[fourIndices[2]], x[fourIndices[3]], y[fourIndices[3]]);
  rxy[0] = radius; rxy[4] = xcenter; rxy[8] = ycenter;
  circle3(x[fourIndices[0]], y[fourIndices[0]], x[fourIndices[2]], y[fourIndices[2]], x[fourIndices[3]], y[fourIndices[3]]);
  rxy[1] = radius; rxy[5] = xcenter; rxy[9] = ycenter;
  circle3(x[fourIndices[0]], y[fourIndices[0]], x[fourIndices[1]], y[fourIndices[1]], x[fourIndices[3]], y[fourIndices[3]]);
  rxy[2] = radius; rxy[6] = xcenter; rxy[10] = ycenter;
  circle3(x[fourIndices[0]], y[fourIndices[0]], x[fourIndices[1]], y[fourIndices[1]], x[fourIndices[2]], y[fourIndices[2]]);
  rxy[3] = radius; rxy[7] = xcenter; rxy[11] = ycenter;
  radius = 0;
  for (k=0; k<4; k++)
    if (rxy[k]>radius) {
      badIndex = k;
      radius = rxy[badIndex];
    }
  xcenter = rxy[badIndex + 4]; ycenter = rxy[badIndex + 8];
  return badIndex;
}

function vecLength(dx, dy) {
  return sqrt(dx*dx+dy*dy);
}
//end small enc circle macro
	  roiManager("Add");
	  number=roiManager("count");
	  roiManager("select", number-1);
	  roiManager("Rename", i+1+"-SmEnCirc");
	  roiManager("Measure");
	  SmallEncCirc[i] = getResult('Feret', i);
	  }
      
// make a new results table
    run("Clear Results");
    run("Select None"); 
    for (i=0; i<n; i++) {
      setResult("Area", i, area[i]);
      setResult("Perim.", i, perim[i]);
      setResult("Circ.", i, Circ[i]);
      setResult("Feret", i, Feret[i]);
      setResult("MinFeret", i, MinFeret[i]);
      setResult("AR", i, AR[i]);
      setResult("Round", i, Round[i]);
      setResult("Solidity", i, Solidity[i]);
      setResult("areaConvex", i, areaConvex[i]);
      setResult("PerimConvex", i, perimConvex[i]);
      setResult("Convexity", i, perimConvex[i]/perim[i]);
      setResult("MaxInsCircDiam", i, MaxInsCirc[i]);
      setResult("SmallEncCircDiam", i, SmallEncCirc[i]);
      setResult("Sphericity", i, MaxInsCirc[i]/SmallEncCirc[i]);
    }
     updateResults();
     saveAs("Results", dir2+Imagename + ".csv"); // saves results as a table for excel
     roiManager("Save", dir2+Imagename + "RoiAll.zip"); // saves the ROIs
     RoiAll = dir2 + Imagename + "RoiAll.zip";
     
// save an image. Overlay all the ROIS. Show only the numbers from the outlinr ROIs.
	open(filename);
	run("Labels...", "color=white font=72 show draw");
	roiManager("Open", RoiAll);
	roiManager("Show All without labels");
	roiManager("Set Line Width", 8);
	run("Flatten");
	roiManager("reset")
	roiManager("Open", RoiSet);
	roiManager("Show All with labels");
	run("Flatten");
	run("Scale...", "x=0.25 y=0.25 width=866 height=1300 interpolation=Bilinear average create");
	saveAs("Jpeg", dir2+Imagename + "result");
	roiManager("reset")
	
// use number from ROI manager to delete the last 2/3rds of all rois after first show all. Flatten. Delete 2/3rds. Show all with lavbels. Flatten. Save jpg.
// duplicate the orig image right at start of macro, run the macro on the 8 bit version, but keep the orig image to put ROIs on here
     
  }
exit("All Images analysed");
