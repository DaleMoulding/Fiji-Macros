// 	     ***************************
//    Copyright (c) 2020 Dale Moulding, UCL. 
// Made available for use under the MIT license.
//     https://opensource.org/licenses/MIT
//       ***************************

//    Modifications to ROIs and measurements by Elisavet Vasilopoulou University of Kent 2021.
  
  saveSettings();
// This version will work on a single file at a time. 
// ****** You must close the results table before running the next image. ******

/*
* Raw data desired – Mean of F-actin (channel 3) that is specific to the podocytes (synaptopodin, channel 1). 
* Integrated Density of F-actin that is specific to the podocytes. 
* Total area covered (um2) of F-actin that is specific to podocytes. 
* % area of the podocyte cells that is covered by F-actin. 
 */


run("Set Measurements...", "area mean standard integrated area_fraction display redirect=None decimal=3");

Name = getTitle(); // get the image name
name = substring(Name, 0, lengthOf(Name)-4); //remove the last 4 characters (.czi or .tif for example)


// Make a mask of the Synaptopdin +ve region & add to ROI manager
	run("Duplicate...", "title=SynaptopodinMask duplicate channels=1");
	run("Median...", "radius=2");
	setThreshold(20, 255);
	run("Convert to Mask");
	run("Create Selection");
	roiManager("Add");
	count = roiManager("count");
	roiManager("Select", count-1);
	roiManager("Rename", name+"_Synaptopodin");
	run("Make Inverse");
	roiManager("Add");
	count = roiManager("count");
	roiManager("Select", count-1);
	roiManager("Rename", name+"_SynaptopodinInverse");
	run("Select None");
	selectWindow(Name);

// Make a mask of the F-actin +ve region & add to ROI manager
	run("Duplicate...", "title=F-ActinMask duplicate channels=3");
	run("Median...", "radius=2");
	setThreshold(20, 255);
	run("Convert to Mask");
	run("Create Selection");
	roiManager("Add");
	count = roiManager("count");
	roiManager("Select", count-1);
	roiManager("Rename", name+"_F-Actin");
	
// Make a mask of the overlap region & add to ROI manager
	imageCalculator("AND create", "F-ActinMask","SynaptopodinMask");
	selectWindow("Result of F-ActinMask");
	rename("OverlapMask");
	run("Create Selection");
	roiManager("Add");
	count = roiManager("count");
	roiManager("Select", count-1); //
	roiManager("Rename", name+"_Overlap");

	selectWindow(Name);
	run("Split Channels");


// measure stuff...

	selectWindow("C3-"+Name); // F-actin
	roiManager("Select", count-2); // F-actin ROI
	run("Measure");
	Table.set("Label", nResults-1, name+" F-Actin Area & Intensity");
	
	selectWindow("C1-"+Name); // Synaptopodin
	roiManager("Select", count-4); // Synaptopodin ROI
	run("Measure");
	Table.set("Label", nResults-1, name+" Synaptopodin Area & Intensity");
	
	selectWindow("C1-"+Name); // Synaptopodin
	roiManager("Select", count-1); // Overlap ROI
	run("Measure");
	Table.set("Label", nResults-1, name+" Overlap Area & Synaptopodin Intensity");

	selectWindow("C3-"+Name); // F-Actin
	roiManager("Select", count-1); // Overlap ROI
	run("Measure");
	Table.set("Label", nResults-1, name+" Overlap Area & F-actin Intensity");

	selectWindow("C3-"+Name); // F-actin
	roiManager("Select", count-4); // Synaptopodin ROI
	run("Measure");
	Table.set("Label", nResults-1, name+" F-Actin Mean & Intensity within Synaptopodin");

	selectWindow("C3-"+Name); // F-actin
	roiManager("Select", count-3); // SynaptopodinInverse ROI
	run("Measure");
	Table.set("Label", nResults-1, name+" F-Actin Mean & Intensity within Synaptopodin-negative area");
	Table.update;
	
	
	run("Merge Channels...", "c1=[C1-"+Name+"] c2=[C2-"+Name+"] c3=[C3-"+Name+"] c4=SynaptopodinMask c5=F-ActinMask c6=OverlapMask create");
	Stack.setChannel(1);
	run("Green");
	run("Enhance Contrast", "saturated=0.35");
	Stack.setChannel(2);
	run("Blue");
	run("Enhance Contrast", "saturated=0.35");
	Stack.setChannel(3);
	run("Red");
	run("Enhance Contrast", "saturated=0.35");
	Stack.setChannel(4);
	run("Cyan");
	Stack.setChannel(5);
	run("Magenta");
	Stack.setChannel(6);
	run("Yellow");
	rename(name+"-Result");

	FActArea = getResult("Area", 0);  // F-actin total Area
	SpodinArea = getResult("Area", 1); // Spodin Total Area
	OverlapArea = getResult("Area", 2); // Overlap area
	FActPerc =  OverlapArea/FActArea*100; // % of F-Actin area thats Synaptopdin +ve
	SpodinPerc = OverlapArea/SpodinArea*100; // % of Synaptopdin area thats F-Actin +ve
	SpodinMean = getResult("Mean", 2); // Mean Spodin intensity in overlap
	SpodinInt = getResult("IntDen", 2); // Total Spodin intensity in overlap
	FActMean = getResult("Mean", 3); // Mean F-actin intensity in overlap
	FActInt = getResult("IntDen", 3); // Total F-actin intesnity in overlap
	TotSpodinmean = getResult("Mean", 1); // Total Spodin staining Mean intensity
	TotSpodinInt = getResult("IntDen", 1); // Total Spoding staining intensity
	TotFActMean = getResult("Mean", 0); // Total F-actin staining mean intensity
	TotFActInt = getResult("IntDen", 0); // Total F-actin staining intensity
	TotFActOverlap = FActInt/TotFActInt*100; // % of total F-actin in the overlap (by intensity)
	TotSpodinOverlap = SpodinInt/TotSpodinInt*100; // % of Total Spodin in the overlap (by intensity)
	FactinMeaninSynpo = getResult("Mean", 4); // Mean F-actin intensity in Synaptopodin area
	FactinIntinSynpo = getResult("IntDen", 4); // Total F-actin intensity in Synaptopodin area
	FactinMeanoutsideSynpo = getResult("Mean", 5); // Mean F-actin intensity outside Synaptopodin area
	FactinIntoutsideSynpo = getResult("IntDen", 5); // Total F-actin intensity outside Synaptopodin area
	
	//run("Clear Results");

	table="GlomMeasurements";

	c = roiManager("count")/4;
	
	if (c==1){
	Table.create(table);
	Table.set("Image", 0, name);
	Table.set("F-actin Area", 0, FActArea);
	Table.set("Spodin Area", 0, SpodinArea);
	Table.set("Overlap Area", 0, OverlapArea);
	Table.set("% of F-Actin area thats Synaptopdin +ve", 0, FActPerc);
	Table.set("% of Synaptopdin area thats F-Actin +ve", 0, SpodinPerc);
	Table.set("Synapto Overlap Mean", 0, SpodinMean);
	Table.set("Synapto Overlap amount", 0, SpodinInt);
	Table.set("F-Actin Overlap Mean", 0, FActMean);
	Table.set("F-Actin Overlap amount", 0, FActInt);
	Table.set("Synapto Total Mean", 0, TotSpodinmean);
	Table.set("Synapto Total amount", 0, TotSpodinInt);
	Table.set("F-actin Total Mean", 0, TotFActMean);
	Table.set("F-actin Total amount", 0, TotFActInt);
	Table.set("F-Act Amount % in overlap", 0, TotFActOverlap);
	Table.set("Synapto Amount % in overlap", 0, TotSpodinOverlap);
	Table.set("F-actin Mean in Synpo area", 0, FactinMeaninSynpo);
	Table.set("F-actin IntDen in Synpo area", 0, FactinIntinSynpo);
	Table.set("F-actin Mean outside Synpo area", 0, FactinMeanoutsideSynpo);
	Table.set("F-actin IntDen outside Synpo area", 0, FactinIntoutsideSynpo);
	Table.update;
	} else {
	selectWindow(table);		// Select the table to update!!
	Table.set("Image", c-1, name);
	Table.set("F-actin Area", c-1, FActArea);
	Table.set("Spodin Area", c-1, SpodinArea);
	Table.set("Overlap Area", c-1, OverlapArea);
	Table.set("% of F-Actin area thats Synaptopdin +ve", c-1, FActPerc);
	Table.set("% of Synaptopdin area thats F-Actin +ve", c-1, SpodinPerc);
	Table.set("Synapto Overlap Mean", c-1, SpodinMean);
	Table.set("Synapto Overlap amount", c-1, SpodinInt);
	Table.set("F-Actin Overlap Mean", c-1, FActMean);
	Table.set("F-Actin Overlap amount", c-1, FActInt);
	Table.set("Synapto Total Mean", c-1, TotSpodinmean);
	Table.set("Synapto Total amount", c-1, TotSpodinInt);
	Table.set("F-actin Total Mean", c-1, TotFActMean);
	Table.set("F-actin Total amount", c-1, TotFActInt);
	Table.set("F-Act Amount % in overlap", c-1, TotFActOverlap);
	Table.set("Synapto Amount % in overlap", c-1, TotSpodinOverlap);
	Table.set("F-actin Mean in Synpo area", c-1, FactinMeaninSynpo);
	Table.set("F-actin IntDen in Synpo area", c-1, FactinIntinSynpo);
	Table.set("F-actin Mean outside Synpo area", c-1, FactinMeanoutsideSynpo);
	Table.set("F-actin IntDen outside Synpo area", c-1, FactinIntoutsideSynpo);
	Table.update;
	}


restoreSettings;






