// "Batch Create 4 colour composite image" adapted from "Batch RGB merge" 
// Source: http://rsb.info.nih.gov/ij/macros/Batch_RGB_Merge.txt
// Adaptation by Dale Moulding, UCL Institute of Child Health Imaging Facilty, 2021
 
// ****************************************************************************************
//		Takes a folder of individually saved 4 channel images, and produces a new image
//		with the 4 channels combined into a single composite image.
// 		The original macro required the end of each filename to have a unique identifier.
// 		i.e. Dapi, GFP, RFP. So Image001Dapi.tif etc
// 		This new version allows the identifier to be anywhere in the filename.
// 		i.e. Image001Dapi-Left-hemisphere.tif, Image001-Dapi-10June2020.tif
// 		Files must still be listed in the folder in order, so the first 
// 	 	4 files makes the first image, the next 4 are the second image etc.
// ****************************************************************************************

// v002: you can set each channel to any default colour (Blue, Green, Red, Cyan, Yellow, Magenta, Grays)
// v002: you have the option to enhance contrast on the output images. This can be reversed.
// v006: changed from Enhance contrast to ResetMinAndMAx(); this sets the display to the entire intensity range
// v003: ch1 used to generate a new filename, removing the channel identifier from the new name.
// v004: choose your own output filename ending. Suggested: -3ch
// v005: fixes filenames saved with original extension
// v006: if its a stack moves to centre slice before enhance contrast - now resetMinAndMAx();
// v006: function also outputs number of images processed.

macro "Batch combine 4 channel images" {

  Dialog.create("Batch create 4 colour composite");
  Dialog.addMessage("Please enter the 4 unique identifiers \nin the filenames for each channel...")
  Dialog.addString("Ch1 identifier:", "_ch00"); // this channel also used to set the output filename.
  Dialog.addString("Ch2 identifier:", "_ch01");
  Dialog.addString("Ch3 identifier:", "_ch02");
  Dialog.addString("Ch4 identifier:", "_ch03");
  Dialog.addMessage("Set the output colours... ");
  Dialog.addChoice("Ch1 colour", newArray("Blue", "Green", "Red", "Cyan", "Magenta", "Yellow", "Grays"), "Cyan");
  Dialog.addChoice("Ch2 colour", newArray("Blue", "Green", "Red", "Cyan", "Magenta", "Yellow", "Grays"), "Yellow");
  Dialog.addChoice("Ch3 colour", newArray("Blue", "Green", "Red", "Cyan", "Magenta", "Yellow", "Grays"), "Magenta");
   Dialog.addChoice("Ch4 colour", newArray("Blue", "Green", "Red", "Cyan", "Magenta", "Yellow", "Grays"), "Grays");
  Dialog.addMessage("What do you want the new files to be labelled as?")
  Dialog.addString("Filename ends:", "-4ch");
  Dialog.addMessage("Reset display range in output images? \nThis makes dim images visible & can be reversed");
  Dialog.setInsets(5, 80, 0);
  Dialog.addCheckbox("Reset display?", true);

  Dialog.show();
  ch1Ident = ".*" + Dialog.getString() + ".*"; // add .* before and after the identifier string, so that 'matches' can be used later to find the identifier anywhere in the filename
  ch2Ident = ".*" + Dialog.getString() + ".*";
  ch3Ident = ".*" + Dialog.getString() + ".*";
  ch4Ident = ".*" + Dialog.getString() + ".*";
  ch1colour = Dialog.getChoice();
  ch2colour = Dialog.getChoice();
  ch3colour = Dialog.getChoice();
  ch4colour = Dialog.getChoice();
  ending = Dialog.getString();
  EnhanceContrast = Dialog.getCheckbox();
 
  nProcessed = batchConvert(); // v006 count the number of mages processed
  print(nProcessed+" sets of 4-channel composite images produced");
  exit;

  function batchConvert() {
      dir1 = getDirectory("Choose Source Directory...");
      dir2 = getDirectory("Choose Destination Directory...");
      list = getFileList(dir1);
      setBatchMode(true);
      n = list.length;
      if ((n%4)!=0)
         exit("The number of files must be a multiple of 4");
      first = 0;
      for (i=0; i<n/4; i++) {
          showProgress(i+1, n/4);
          //red="?"; green="?"; blue="?";
          for (j=first; j<first+4; j++) {
              if (matches(list[j], ch1Ident))
                  ch1 = list[j];
              if (matches(list[j], ch2Ident))
                  ch2 = list[j];
              if (matches(list[j], ch3Ident))
                  ch3 = list[j];
              if (matches(list[j], ch4Ident))
                  ch4 = list[j];
          }
          open(dir1 +ch1);
	  imagename = File.nameWithoutExtension;
          open(dir1 +ch2);
          open(dir1 +ch3);
          open(dir1 +ch4);
          
          run("Merge Channels...", "c1=["+ch1+"] c2=["+ch2+"] c3=["+ch3+"] c4=["+ch4+"] create");
          
          getDimensions(width, height, channels, slices, frames); // is it a z-stack, if so set it to the centre slice
		  if (slices > 1)
				Stack.setSlice(slices/2);
	
          Stack.setChannel(1); //set channel colours:
          run(ch1colour);
          if (EnhanceContrast) // if you selected to enhance contrast it is applied here
          	resetMinAndMax();
          Stack.setChannel(2); 
          run(ch2colour);
          if (EnhanceContrast)
          	resetMinAndMax();
          Stack.setChannel(3); 
          run(ch3colour);
          if (EnhanceContrast)
          	resetMinAndMax();
          Stack.setChannel(4); 
          run(ch4colour);
          if (EnhanceContrast)
          	resetMinAndMax();
          	
	      remove = replace(ch1Ident, "\\.\\*", ""); // remove the .* from before and after the ch1Indent string. 
	      savename = replace(imagename, remove,""); // delete the ch1 indentifier from the ch1 filename so it saves with a sensible new name.
          saveAs("tiff", dir2+savename+ending);
          first += 4;
      }
      return n/4; //v006 count processed images, not just images open at end of function
  }
}
         
