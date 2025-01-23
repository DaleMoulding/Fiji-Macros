# Fiji-Macros
##### Macros for image analysis, scalebars (ICH microscopes), automating standard tasks. All are covered under an MIT License, so can be freely used and distributed.


---
## **Published Macros**

### **Cilia Lengths & spots:**

[Cilia_Lengths_2D.ijm](/Cilia_Lengths_2D.ijm?raw=true) & [Cilia_Spots_2D.ijm](/Cilia_Spots_2D.ijm?raw=true) were published in:

* Taschner M, Lorentzen A, Mourão A, Collins T, Freke GM, Moulding D, Basquin J, Jenkins D, Lorentzen E. *Crystal structure of intraflagellar transport protein 80 reveals a homo-dimer required for ciliogenesis.* Elife. 2018 Apr 16;7. pii: e33067. PMID: [29658880](https://www.ncbi.nlm.nih.gov/pubmed/29658880)

    **Cilia_Lengths** simply thresholds, skeletonizes and measures the length of cilia.

    **Cilia_Spots** additionally makes a ROI around each cilia, and counts the number of punctae (here IFT80) on each cilia, their density and spacing.
    
---

### **Indentify Upper Surface:**
    
[IdentifyUpperSurfacev2.ijm](/IdentifyUpperSurfacev2.ijm?raw=true) as used in:

**New version - High Speed (GPU based), tunable interactive surface placement, peel any distance and thickness above or below the identified surface in seconds.** [follow this link...](https://github.com/DaleMoulding/SurfacePeeler)

* Vangl2 disruption alters the biomechanics of late spinal neurulation leading to spina bifida in mouse embryos.   Dis Model Mech. 2018 Mar 21;11(3). PMID: [29590636](https://www.ncbi.nlm.nih.gov/pubmed/29590636).
* Spinal neural tube closure depends on regulation of surface ectoderm identity and biomechanics by Grhl2. Nat Commun. 2019 Jun 6;10(1):2487.PMID: [31171776](https://pubmed.ncbi.nlm.nih.gov/31171776/).
* Rho kinase-dependent apical constriction counteracts M-phase apical expansion to enable mouse neural tube closure. J Cell Sci. 2019 Jul 1;132(13)jcs230300.PMID: [31182644](https://pubmed.ncbi.nlm.nih.gov/31182644/).
* Integrin-Mediated Focal Anchorage Drives Epithelial Zippering during Mouse Neural Tube Closure. Dev Cell. 2020 Feb 10;52(3):321-334.e6. PMID: [32049039](https://pubmed.ncbi.nlm.nih.gov/32049039/)
* Cell non-autonomy amplifies disruption of neurulation by mosaic Vangl2 deletion in mice. Nat Commun. 2021 Feb 19;12(1):1159. PMID: [33608529](https://pubmed.ncbi.nlm.nih.gov/33608529/)


Image of murine e9.5 Neural tube closure point (Gabe Galea UCL). Surface extracted with this macro. Macro can be adapted to take any number of pixels from the upper surface, or below the upper surface.

![SurfExt](/Images/SurfExtPic2.gif)

---

### **Sphericity Roundess & Convexivity:**

[SphericityRoundnessConvexity.ijm](/SphericityRoundnessConvexity.ijm?raw=true) published in:
* Bruno Vindrola-Padrós, Dale Moulding, Ciprian Astaloş, Cristian Virag, Ulrike Sommer. Working with broken agents: Exploring computational 2D morphometrics for studying the (post)depositional history of potsherds. J Archaeol Sci. 2019 Feb 104:19-33. [https://doi.org/10.1016/j.jas.2019.01.008](https://doi.org/10.1016/j.jas.2019.01.008).

Macro developed with Bruno Vindrola-Padrós to segment objects (archaeological potsherds here) and provide morphometric measures, including standard Fiji functions & smallest enclosing circle, Maximum Inscribed circle, and convexity (Perimeter / Convex Hull). Requires the [Maximum_Inscribed_Cirlce.jar](/Maximum_Inscribed_Circle.jar) plugin developed by Olivier Burri and Romain Guiet at BIOP [https://biop.epfl.ch/Fiji-Update/plugins/BIOP/](https://biop.epfl.ch/Fiji-Update/plugins/BIOP/)

Image adapted from the paper above:

![SpherConv](/Images/Shapes.jpg)

---

### **Podocyte F-actin / synaptopodin:**

Mason *et al* manuscript submitted.

[GlomActinSynaptov004vEV-6-UPDATESINGLEFILEFINAL.ijm](/GlomActinSynaptov004vEV-6-UPDATESINGLEFILEFINAL.ijm?raw=true) &
[GlomActinSynaptov005vEV-UPDATEFOLDERFINAL.ijm](/GlomActinSynaptov005vEV-UPDATEFOLDERFINAL.ijm?raw=true)
process individual files (for initial threshold adjustments) or a folder of images (using predetermined thresholds). 
Thresholds for two channels (Synaptopodin and F-actin) and measures parameters describing the area of each stain, proprortions of overlaps between stains, intensity of staining in all regions (overlap / non-overlap) as absolute amount and percentages. Outputs results as a .csv table, saves all ROIs and an output image showing regions measured for each file.

![MasonetalGlomsImage.jpg](/Images/MasonetalGlomsImage.jpg)

---

### **Mitochondria and MitoSox measurements**

Wilkinson *et al* [Role of CD14+ monocyte-derived oxidised mitochondrial DNA in the inflammatory interferon type 1 signature in juvenile dermatomyositis](https://pubmed.ncbi.nlm.nih.gov/36564154/).

Radziszewska *et al* Type I interferon and mitochondrial dysfunction are associated with dysregulated cytotoxic CD8+ T cell responses in juvenile systemic lupus erythematosus. (in preparation)

Individual cells were cropped by manually drawing an ellipse around the cell in the centre of the stack, this was then processed to a 3D spheroid mask using [SpherefromCirclev002.ijm](/SpherefromCirclev002.ijm?raw=true) and the individual cell extracted.
Measurements of Mitotracker & MitoSox volumes, surface areas and intensities were calculated by thresholding deconvolved images using [MitoSoxWithTablev016.ijm](MitoSoxWithTablev016.ijm?raw=true).
Outputs a results table summarizing all measurements, per cell and per mitochondrial structure.

Adapted macro for Radziszewska et al CD8 T-cell mitochondrial measurements: [MitoSoxWithTableAniav003.ijm](MitoSoxWithTableAniav003.ijm?raw=true).

Outputs results images showing masks over the original input image:

![Mitotr&MitoSox.jpg](/Images/Mitotr%26MitoSox.jpg)

---

### **3 level Dab quantifier**
Rashidi *et al* Localized Delivery of Growth Factors from Microparticles Modulate Osteogenic and Chondrogenic Gene Expression in Growth Factor-dependent Manner in an ex vivo Chick Embryonic Bone Model. (In prepartaion).

Simple 3 level thresholding of DAB staining. User defines an ROI, the image is colour deconvolved (Colour Deconvolution 2 [Landini G, Martinelli G, Piccinini F. Colour Deconvolution – stain unmixing in histological imaging. Bioinformatics 2020](https://academic.oup.com/bioinformatics/advance-article/doi/10.1093/bioinformatics/btaa847/5913390?guestAccessKey=148a8a4b-24f8-4b42-8742-e985535c9410). 

The macro is available here: [DAB_High_med_low_Hassanv05.ijm](DAB_High_med_low_Hassanv05.ijm?raw=true).

---

### **Bile Canaliculi assay**

Cozmescu *et al* Safety and efficacy analysis of in vivo lentiviral gene therapy for ARC syndrome. (Submitted).

The macro is available here: [BileCanaliculi_Assay_MacroV2.ijm](BileCanaliculi_Assay_MacroV2.ijm?raw=true).

---


## **ICH Light Microscopy Facility Macro tools**

### **Scalebars Macros:**

[ICH_Scalebars_Mag_anywhere_in_Filename_v5.ijm](/ICH_Scalebars_Mag_anywhere_in_Filename_v5.ijm?raw=true) and 
[ICH_scalebars_Mag_from_folder_v06.ijm](/ICH_scalebars_Mag_from_folder_v06.ijm?raw=true)

These set the scale and optionally add scalebars to files with the magnification written anywhere_in_Filename (i.e 5x, 10x, 2.5x, recognizes any format x10, 10x, 10X, X10, as long as there no spaces between number and x). 
    
Alternatively, run the Mag_from_folder version for files grouped into folder by magnification used.
    
Calibrated for ICH Imaging facility microscopes only.

### **Colour image Zeiss CZI Macros:**

[CZItoRGB.ijm](/CZItoRGB.ijm?raw=true) and
[CZItoRGBFolder.ijm](/CZItoRGBFolder.ijm?raw=true)

These macros correct the gamma display in Zeiss CZI files taken with a colour camera. The first macro corrects a single open file (you can save the output as a tif), the second macro will run through a folder of CZI files.

### **Combine 2, 3 or 4 separate colour images (or stacks) into colour composite image:**

 [4ChCompfromFilenamev006.ijm](/4ChCompfromFilenamev006.ijm?raw=true)
 
 [3ChCompfromFilenamev006.ijm](/3ChCompfromFilenamev006.ijm?raw=true)

 [2ChCompfromFilenamev006.ijm](/2ChCompfromFilenamev006.ijm?raw=true)

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
