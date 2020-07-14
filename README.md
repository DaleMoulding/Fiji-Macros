# Fiji-Macros
##### Macros for image analysis, scalebars (ICH microscopes), automating standard tasks. All are covered under an MIT License, so can be freely used and distributed.

---
## **ICH Light Microscopy Facility Macro tools**

### **Scalebars Macros:**

[ICH_Scalebars_Mag_anywhere_in_Filename_v4.ijm](/ICH_Scalebars_Mag_anywhere_in_Filename_v4.ijm?raw=true) and 
[ICH_scalebars_Mag_from_folder_v5.ijm](/ICH_scalebars_Mag_from_folder_v5.ijm?raw=true)

These set the scale and optionally add scalebars to files with the magnification written anywhere_in_Filename (i.e 5x, 10x, 2.5x, recognizes any format x10, 10x, 10X, X10, as long as there no spaces between number and x). 
    
Alternatively, run the Mag_from_folder version for files grouped into folder by magnification used.
    
Calibrated for ICH Imaging facility microscopes only.

### **Colour image Zeiss CZI Macros:**

[CZItoRGB.ijm](/CZItoRGB.ijm?raw=true) and
[CZIroRGBFolder.ijm](/CZIroRGBFolder.ijm?raw=true)

These macros correct the gamma display in Zeiss CZI files taken with a colour camera. The first macro corrects a single open file (you can save the output as a tif), the second macro will run through a folder of CZI files.

### **Combine 3 individual images into a 3 colour composite image:**

 [3ChCompfromFilenamev004.ijm](/3ChCompfromFilenamev004.ijm?raw=true)

This macro works on a folder of images, where you have taken 3 individually saved images, and combines them into a single 3 channel composite image. 
For example, a folder with the following files:
    
`ControlDapi-a1.tif, Control488-a1.tif, Control594-a1.tif,`
    
`DrugDapi-b1.tif, Drug488-b1.tif, Drug594-b1.tif`
    
Will be processed to give 2 new files in a new folder:
    
`Control-a1-3ch.tif, Drug-b1-3ch.tif`
    
By filling in the pop up box:
    
![3chPopUp](/Images/3chPopupPicv004.JPG)
    
The save filename is generated from Ch1 filename, with the unique identifier removed, and '-3ch' or any text you specify appended.
Enhance contrast will just make the images look brighter, but they can be reset in Fiji using the Adjust Color Balance window.

---
### **Published Macros**

[Cilia_Lengths_2D.ijm](/Cilia_Lengths_2D.ijm?raw=true) & [Cilia_Spots_2D.ijm](/Cilia_Spots_2D.ijm?raw=true) were published in:

* Taschner M, Lorentzen A, Mourão A, Collins T, Freke GM, Moulding D, Basquin J, Jenkins D, Lorentzen E. *Crystal structure of intraflagellar transport protein 80 reveals a homo-dimer required for ciliogenesis.* Elife. 2018 Apr 16;7. pii: e33067. PMID: [29658880](https://www.ncbi.nlm.nih.gov/pubmed/29658880)

    **Cilia_Lengths** simply thresholds, skeletonizes and measures the length of cilia.

    **Cilia_Spots** additionally makes a ROI around each cilia, and counts the number of punctae (here IFT80) on each cilia, their density and spacing.
    
---
    
[IdentifyUpperSurfacev2.ijm](/IdentifyUpperSurfacev2.ijm?raw=true) published in:
* Galea GL, Nychyk O, Mole MA, Moulding D, Savery D, Nikolopoulou E, Henderson DJ, Greene NDE, Copp AJ.Vangl2 disruption alters the biomechanics of late spinal neurulation leading to spina bifida in mouse embryos. Dis Model Mech. 2018 Mar 21;11(3). PMID: [29590636](https://www.ncbi.nlm.nih.gov/pubmed/29590636).

Image of muring e9.5 Neural tube closure point. Gabe Galea UCL. Surface extracted with this macro. Can be adapte to take any number of pixels from the upper surface, or below the upper surface.

![SurfExt](/Images/SurfExtPic.gif)

---

[SphericityRoundnessConvexity.ijm](/SphericityRoundnessConvexity.ijm?raw=true) published in:
* Bruno Vindrola-Padrós, Dale Moulding, Ciprian Astaloş, Cristian Virag, Ulrike Sommer. Working with broken agents: Exploring computational 2D morphometrics for studying the (post)depositional history of potsherds. J Archaeol Sci. 2019 Feb 104:19-33. [https://doi.org/10.1016/j.jas.2019.01.008](https://doi.org/10.1016/j.jas.2019.01.008).

Macro developed with Bruno Vindrola-Padrós to segment objects (archaeological potsherds here) and provide morphometric measures, including standard Fiji functions & smallest enclosing circle, Maximum Inscribed circle, and convexity (Perimeter / Convex Hull). Requires the [Maximum_Inscribed_Cirlce.jar](/Maximum_Inscribed_Circle.jar) plugin developed by Olivier Burri and Romain Guiet at BIOP [https://biop.epfl.ch/Fiji-Update/plugins/BIOP/](https://biop.epfl.ch/Fiji-Update/plugins/BIOP/)

Image adapted from the paper above:

![SpherConv](/Images/Shapes.jpg)


---
