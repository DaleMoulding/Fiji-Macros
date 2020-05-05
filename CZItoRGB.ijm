// Change colour camera Zeiss .czi files from a 3 channel 14 bit image to a gamma corrected RGB.
// Freely available script from Dale Moulding, UCL Oct 2019.
// Works on the currently open file in Fiji. Save the output as a tif if needed.

Stack.setChannel(1);
setMinAndMax(0, 16383);
Stack.setChannel(2);
setMinAndMax(0, 16383);
Stack.setChannel(3);
setMinAndMax(0, 16383);
run("RGB Color");
run("Gamma...", "value=0.45");

