# Fiji-Macros
##### Macros for image analysis, scalebars (ICH microscopes), automating standard tasks. All are covered under an MIT License, so can be freely used and distributed.

---
### **ICH Light Microscopy Facility Macro tools**

**Scalebars Macros:**

* ICH_Scalebars_Mag_anywhere_in_Filename_v4.ijm  

* ICH_scalebars_Mag_from_folder_v5.ijm

    These set the scale and optionally adds scalebars to files with the magnification written anywhere_in_Filename (i.e 5x, 10x, 2.5x). 

    Alternatively, run the Mag_from_folder version for files grouped into folder by magnification used.

    Calibrated for ICH Imaging facility microscopes only.

**Colour image Zeiss CZI Macros:**

* CZItoRGB.ijm
* CZIroRGBFolder.ijm

    These macros correct the gamma display in Zeiss CZI files taken with a colour camera. The first macro corrects a single open file (you can save the output as a tif), the second macro will run through a folder of CZI files.
    
---
### **Published Macros**

[Cilia_Lengths_2D.ijm](https://github.com/DaleMoulding/Fiji-Macros/blob/master/Cilia_Lengths_2D.ijm) & [Cilia_Spots_2D.ijm](https://github.com/DaleMoulding/Fiji-Macros/blob/master/Cilia_Spots_2D.ijm) were published in:

* Taschner M, Lorentzen A, Mourão A, Collins T, Freke GM, Moulding D, Basquin J, Jenkins D, Lorentzen E. *Crystal structure of intraflagellar transport protein 80 reveals a homo-dimer required for ciliogenesis.* Elife. 2018 Apr 16;7. pii: e33067. PMID: [29658880](https://www.ncbi.nlm.nih.gov/pubmed/29658880)

    **Cilia_Lengths** simply thresholds, skeletonizes and measures the length of cilia.

    **Cilia_Spots** additionally makes a ROI around each cilia, and counts the number of punctae (here IFT80) on each cilia, their density and spacing.

---
