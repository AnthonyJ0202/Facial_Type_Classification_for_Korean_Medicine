# Body Shape Recognition using R

This R script analyzes a set of `.png` images using facial detection and classifies the subject's orientation or movement across images.
The goal is to identify patterns in movements variation among subjects.

## How to Run
1. Install packages "Magick" and ""image.libfacedetection_0.1.tar.gz", repos=NULL, type="source"
2. Prepare two or more portraits of same person with clear lighting with high resolution.  
3. Set working directory to the image file
4. Run

Based on how the detected face moves, the script assigns one of the following categories
1 Normal
2 Forward type
3 Backward type
4 Left type
5 Left-forward type
6 Left-backward type
7 Right type
8 Right-forward type
9 Right-backward type
10 Unable to move
11 Cannot determine
