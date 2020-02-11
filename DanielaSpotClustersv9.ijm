/*
 * Macro written by Dale Moulding October 2019
 * Please acknowledge its use!
 * Copyright (Dale Moulding UCL) made available for use under the MIT license.
 * https://opensource.org/licenses/MIT
 * 
 * Written in collaboration with Daniela Cardinale to identify basal body clusters
 * outputs: 4 channel results image, results table, ROIs, a summary of all counted images.
 */

#@File(label = "Input directory", style = "directory") input
#@File(label = "Output directory", style = "directory") output

//setBatchMode(true); //batch mode kills macro at get results table section!?!?
listdir = getFileList(input); 
for (i = 0; i < listdir.length; i++) { 
       path = input + File.separator + listdir[i];
       //print(input, output, path);
       if (File.isDirectory(path)){
        	
SpotsRadius=4;
SpotBrightness=100;
ClusterDistance=15;
ClusterNumber=4;

count=roiManager("count"); // clean up the ROI manager
if (count != 0) roiManager("delete");


run("Image Sequence...", "open=[path] starting=2 increment=2");
name = getTitle();
run("Z Project...", "projection=[Max Intensity]");
run("Duplicate...", "title=MAX_Green duplicate channels=2");
run("Duplicate...", "title=GreenBlobs");
run("Duplicate...", "title=Green");
run("Duplicate...", "title=Outliers");
// Find the basal bodies, using Remove Outliers command with a defined spot size and brightness
run("Remove Outliers...", "radius="+SpotsRadius+" threshold="+SpotBrightness+" which=Bright");
imageCalculator("Difference create", "Green","Outliers");
selectWindow("Result of Green");
rename("Spots");
setAutoThreshold("Li dark");
run("Convert to Mask");

selectWindow("GreenBlobs");
run("Gaussian Blur...", "sigma=5");
setAutoThreshold("RenyiEntropy dark"); // Try others. Original Otsu, new RenyiEntropy
run("Convert to Mask");
run("Options...", "iterations=12 count=1 black do=Dilate");
run("Invert");
imageCalculator("AND create", "GreenBlobs","Spots");

run("SSIDC Cluster Indicator", "distance="+ClusterDistance+" mindensity="+ClusterNumber+"");
Clusters=roiManager("count");
print(name+", Clusters = "+Clusters+", OutliersSize = "+SpotsRadius+", Outliers Brightness ="+SpotBrightness+", Cluster distance ="+ClusterDistance+", Cluster Number ="+ClusterNumber);
// measurements
// Number of spots per cluster (from binary image, ultimate points IntDensity)
selectWindow("Result of GreenBlobs");
run("Duplicate...", "title=FinalSpots");
run("Ultimate Points");
setThreshold(1, 255); 
run("Convert to Mask");
run("Divide...", "value=255");
run("16-bit");

// area of spots per cluster (from binary image IntDensity)
selectWindow("Result of GreenBlobs");
run("Duplicate...", "title=FinalSpotsArea");
run("Divide...", "value=255");
run("16-bit");

// intensity of basal bodies per cluster
selectWindow("GreenBlobs");
run("Divide...", "value=255");
run("16-bit");
imageCalculator("Multiply create", "GreenBlobs","MAX_Green");
rename("GreenMinusBrightBlobs");

// output image of above as 3 channels
run("Merge Channels...", "c1=MAX_Green c2=GreenMinusBrightBlobs c3=FinalSpots c4=FinalSpotsArea create keep");
rename(name+"Intensity_Points_Area");

// output ROI manager results
run("Set Measurements...", "area mean integrated redirect=None decimal=3");
selectWindow(name+"Intensity_Points_Area");
getPixelSize(unit, pw, ph, pd);
run("Properties...", "channels=4 slices=1 frames=1 unit=um pixel_width="+pw*10000+" pixel_height="+ph*10000+" voxel_depth="+pd*10000+"");
roiManager("deselect");
Stack.setChannel(2);
roiManager("measure");
Stack.setChannel(3);
roiManager("measure");
Stack.setChannel(4);
roiManager("measure");

Rows = nResults;
nClusters = Rows/3;
nClustersx2 = nClusters * 2;
pixelsize = 6.45;

for (n = 0; n < nClusters; n++) {
	
	ClusterNumber=n+1;
	Area=getResult("Area", n);
	TotalIntensity=getResult("RawIntDen", n);
	MeanIntensity=getResult("Mean", n);
	CiliaNumber = getResult("RawIntDen", n+nClusters);
	CiliaArea = getResult("RawIntDen", n+nClustersx2) * 6.45 ;
	
	TableName ="Results Table";

	if(n==0) {
	Table.create(TableName);
		Table.set("Cluster", 0, ClusterNumber);
		Table.set("Area um", 0, Area);
		Table.set("Total Intensity", 0, TotalIntensity);
		Table.set("Mean Intensity", 0, MeanIntensity);
		Table.set("Cilia Number", 0, CiliaNumber);
		Table.set("Cilia Area um", 0, CiliaArea);
		Table.update;
		}else{
		Table.set("Cluster", n, ClusterNumber);
		Table.set("Area um", n, Area);
		Table.set("Total Intensity", n, TotalIntensity);
		Table.set("Mean Intensity", n, MeanIntensity);
		Table.set("Cilia Number", n, CiliaNumber);
		Table.set("Cilia Area um", n, CiliaArea);
		Table.update;
		}
}
selectWindow("Results Table");
saveAs("results",  output+File.separator+name+"Results_Table.csv"); 
selectWindow(name+"Intensity_Points_Area");
saveAs("Tiff",  output+File.separator+name+"-Results");
roiManager("Save", output+File.separator+name + "RoiSet.zip");
run("Close All");
selectWindow(name+"Results_Table.csv");
run("Close");
selectWindow("Results");
run("Close");

}
}
selectWindow("Log");
saveAs("Text", output+File.separator+"All-Results");
run("Close");
exit("All Done :-) Buy Dale Cake!");
