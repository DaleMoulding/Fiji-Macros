// "Batch Create 3 colour composite image" adapted from "Batch RGB merge" 
// Source: http://rsb.info.nih.gov/ij/macros/Batch_RGB_Merge.txt
// Adaptation by Dale Moulding, UCL Institute of Child Health Imaging Facilty, 2020
 
// ****************************************************************************************
// 		The original macro required the end of each filename to have a unique identifier.
// 		i.e. Dapi, GFP, RFP. So Image001Dapi.tif etc
// 		This new version allows the identifier to be anywhere in the filename.
// 		i.e. Image001Dapi-Left-hemisphere.tif, Image001-Dapi-10June2020.tif
// 		Files must still be listed in the folder in order, so the first 
// 	 	3 files makes the first image, the next 3 are the second image etc.
// ****************************************************************************************

// v002: you can set each channel to any default colour (Blue, Green, Red, Cyan, Yellow, Magenta, Grays)
// v002: you have the option to enhance contrast on the output images. This can be reversed.
// v003: ch1 used to generate a new filename, removing the channel identifier from the new name.

macro "Batch combine 3 channel images" {

  Dialog.create("Batch create 3 colour composite");
  Dialog.addMessage("Please enter the 3 unique identifiers in the filename for each channel...")
  Dialog.addString("Channel 1 identifier:", "_dapi_RAW_ch00.tif"); // this channel also used to set the output filename.
  Dialog.addString("Channel 2 identifier:", "_570_");
  Dialog.addString("Channel 3 identifier:", "_690_");
  Dialog.addMessage("Set the output colours...")
  Dialog.addChoice("Ch1 colour", newArray("Blue", "Green", "Red", "Cyan", "Magenta", "Yellow", "Grays"), "Blue");
  Dialog.addChoice("Ch2 colour", newArray("Blue", "Green", "Red", "Cyan", "Magenta", "Yellow", "Grays"), "Green");
  Dialog.addChoice("Ch3 colour", newArray("Blue", "Green", "Red", "Cyan", "Magenta", "Yellow", "Grays"), "Red");
  Dialog.addMessage("Would you like to enhance contrast in the output images?\nImages will look brighter but this can still be reset afterwards.")
  Dialog.addCheckbox("Enhance Contrast?", true);

  Dialog.show();
  ch1Ident = ".*" + Dialog.getString() + ".*"; // add .* before and after the identifier string, so that 'matches' can be used later to find the identifier anywhere in the filename
  ch2Ident = ".*" + Dialog.getString() + ".*";
  ch3Ident = ".*" + Dialog.getString() + ".*";
  ch1colour = Dialog.getChoice();
  ch2colour = Dialog.getChoice();
  ch3colour = Dialog.getChoice();
  EnhanceContrast = Dialog.getCheckbox();
 
  batchConvert();
  x=nImages();
  print(x+" sets of 3-channel composite images produced");
  exit;

  function batchConvert() {
      dir1 = getDirectory("Choose Source Directory...");
      dir2 = getDirectory("Choose Destination Directory...");
      list = getFileList(dir1);
      setBatchMode(true);
      n = list.length;
      if ((n%3)!=0)
         exit("The number of files must be a multiple of 3");
      first = 0;
      for (i=0; i<n/3; i++) {
          showProgress(i+1, n/3);
          red="?"; green="?"; blue="?";
          for (j=first; j<first+3; j++) {
              if (matches(list[j], ch1Ident))
                  ch1 = list[j];
              if (matches(list[j], ch2Ident))
                  ch2 = list[j];
              if (matches(list[j], ch3Ident))
                  ch3 = list[j];
          }
          open(dir1 +ch1);
          open(dir1 +ch2);
          open(dir1 +ch3);
          
          run("Merge Channels...", "c1=["+ch1+"] c2=["+ch2+"] c3=["+ch3+"] create");
          Stack.setChannel(1); //set channel colours:
          run(ch1colour);
          if (EnhanceContrast) // if you selected to enhance contrast it is applied here
          	run("Enhance Contrast...", "saturated=0.1");
          Stack.setChannel(2); 
          run(ch2colour);
          if (EnhanceContrast)
          	run("Enhance Contrast...", "saturated=0.1");
          Stack.setChannel(3); 
          run(ch3colour);
          if (EnhanceContrast)
          	run("Enhance Contrast...", "saturated=0.1");
          	
	      remove = replace(ch1Ident, "\\.\\*", ""); // remove the .* from before and after the ch1Indent string. 
	      savename = replace(ch1, remove,""); // delete the ch1 indentifier from the ch1 filename so it saves with a sensible new name.
          saveAs("tiff", dir2+savename+"-Composite");
          first += 3;
      }
  }