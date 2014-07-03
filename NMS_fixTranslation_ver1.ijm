/*
The MIT License (MIT)

Copyright (c) 2014 Nicholas M. Schneider

Permission is hereby granted, free of charge, to any person 
obtaining a copy of this software and associated documentation 
files (the "Software"), to deal in the Software without 
restriction, including without limitation the rights to 
use, copy, modify, merge, publish, distribute, sublicense, 
and/or sell copies of the Software, and to permit persons 
to whom the Software is furnished to do so, subject to the 
following conditions: The above copyright notice and this 
permission notice shall be included in all copies or substantial 
portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, 
EXPRESS OR  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES 
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND 
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT 
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, 
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR 
OTHER DEALINGS IN THE SOFTWARE.

*/


// These macro adjusts xy Translations, adjusts the canvas,
// and then translates each frame

macro "Add and Advance [a]" {
     roiManager("add");
     run("Next Slice [>]");
     // Move Point away for easy clicking
     makePoint(1 , 1);
     
     if (roiManager("count") >= nSlices)
     {
	run("movieStabilize");
     }
  }



macro "movieStabilize" {
     // Get Reference Location
     roiManager("select", 0);
     run("Measure");
     xStart = getResult("X");
     yStart = getResult("Y");

     // Get Video Length 
     numberOfImages = roiManager("count");

     // Image Size 
     imageWidth = getWidth();
     imageHeight = getHeight();

     // Define Arrays of how far to translate
     xTranslation = newArray(numberOfImages);
     yTranslation = newArray(numberOfImages);

     //Track largest movement to calculate new canvas size
     xMaxTranslation = 0;
     xMinTranslation = 0;
     yMaxTranslation = 0;
     yMinTranslation = 0;

     // Loop over selected Points
     for (i = 0; i < numberOfImages; i++) {
        roiManager("select", i);
     	run("Measure");
     	xPosition = getResult("X");
     	yPosition = getResult("Y");
     	xTranslation[i] = xStart - xPosition;
     	yTranslation[i] = yStart - yPosition;

     	if (xTranslation[i] > xMaxTranslation) {
 		xMaxTranslation = xTranslation[i];
 	} else if  (xTranslation[i] < xMinTranslation) {
 		xMinTranslation = xTranslation[i];
 	}

 	
 	if (yTranslation[i] > yMaxTranslation) {
 		yMaxTranslation = yTranslation[i];
 	} else if  (yTranslation[i] < yMinTranslation) {
 		yMinTranslation = yTranslation[i];
 	}
     	
     }
     
     // Canvas and translation constants
     if(xMaxTranslation > abs(xMinTranslation)) {
     	xMattedBy = xMaxTranslation; 
     } else {
     	xMattedBy = abs(xMinTranslation);
     }
     
     if(yMaxTranslation > abs(yMinTranslation)) {
     	yMattedBy = yMaxTranslation; 
     } else {
     	yMattedBy = abs(yMinTranslation);
     }
     imageWidth = imageWidth + 2 * xMattedBy + 20 ;
     imageHeight = imageHeight + 2 * yMattedBy + 20 ;


     setSlice(1);
     run("Canvas Size...", "width="+imageWidth+" height="+imageHeight+" position=Center zero");

     for (i = 0; i < numberOfImages; i++) {
  	run("Translate...", "x="+xTranslation[i]+" y="+yTranslation[i]+" interpolation=None slice");
   	run("Next Slice [>]");
     }

     f = File.open(""); // display file open dialog
     for (i = 0; i < numberOfImages; i++ ){
     	if ( i < numberOfImages){
           print(f, d2s(xTranslation[i],0)+"  \t"+d2s(yTranslation[i],0) + " \n");
     	} else if (i == numberOfImages-1) {
     	   print(f, d2s(xTranslation[i],0)+"  \t"+d2s(yTranslation[i],0)+"");
     	} // Dont print a return on the last line
     }
}


macro "movieStabilizeFromFile" {
  // Image Size 
  imageWidth = getWidth();
  imageHeight = getHeight();

  // Pull from File
  lines = split(File.openAsString(""), "\n");
  length = lines.length;
  xTranslation = newArray(length);
  yTranslation = newArray(length);
  
  //Track largest movement to calculate new canvas size
  xMaxTranslation = 0;
  xMinTranslation = 0;
  yMaxTranslation = 0;
  yMinTranslation = 0;

  
  for (i = 0; i < length; i++) {
  	// Extract xy Translations from txt file
	xy = split(lines[i], ",\t ");
 	xTranslation[i] = parseFloat(xy[0]);
 	yTranslation[i] = parseFloat(xy[1]);
 	
 	if (xTranslation[i] > xMaxTranslation) {
 		xMaxTranslation = xTranslation[i];
 	} else if  (xTranslation[i] < xMinTranslation) {
 		xMinTranslation = xTranslation[i];
 	}

 	
 	if (yTranslation[i] > yMaxTranslation) {
 		yMaxTranslation = yTranslation[i];
 	} else if  (yTranslation[i] < yMinTranslation) {
 		yMinTranslation = yTranslation[i];
 	}
  }

     // Canvas and translation constants
     if(xMaxTranslation > abs(xMinTranslation)) {
     	xMattedBy = xMaxTranslation; 
     } else {
     	xMattedBy = abs(xMinTranslation);
     }
     
     if(yMaxTranslation > abs(yMinTranslation)) {
     	yMattedBy = yMaxTranslation; 
     } else {
     	yMattedBy = abs(yMinTranslation);
     }
     imageWidth = imageWidth + 2 * xMattedBy + 20;
     imageHeight = imageHeight + 2 * yMattedBy + 20;
	

     setSlice(1);
     run("Canvas Size...", "width="+imageWidth+" height="+imageHeight+" position=Center zero");


     for (i = 0; i < length; i++) {
  	run("Translate...", "x="+xTranslation[i]+" y="+yTranslation[i]+" interpolation=None slice");
   	run("Next Slice [>]");
     }
}
