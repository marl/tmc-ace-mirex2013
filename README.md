# tmc-ace-mirex2013

----------------------------------------------------------------------
## Contact Info

* [Taemin Cho](tmc323@nyu.edu) (kudos and high fives)
* [Juan P. Bello](jpbello@nyu.edu)
* [Eric J. Humphrey](ejhumphrey@nyu.edu) (help and maintenance)

[Music and Audio Research Lab (MARL)](http://steinhardt.nyu.edu/marl/) @ New York University


----------------------------------------------------------------------
## Description

This is our (TMC) submission to the 2013 MIREX Audio Chord Estimation task.
It uses our new K-stream technique, described at length in the following document: 

[Cho, Taemin. "Improved techniques for automatic chord recognition from music audio signals." PhD Thesis, NYU (2014).](http://gradworks.umi.com/36/13/3613471.html)

The algorithms estimate 157 chords: 

maj, min, maj7, min7, 7, maj6, min6, dim, aug, sus4, sus2, hdim7 and dim7 for 12 keys plus no-chord.


This submission contains two different models:

CB1. Pre-trained Model - The model is trained with 495 songs consisting of 100 RWC pop songs, 195 uspop songs, The Beatles, and Queen songs.

CB2. for Train-test evaluation. - The training set must have all 157 chord types indicated above.

----------------------------------------------------------------------
## Platform

Tested on Arch Linux and OS X 10.6.8

### Requirements

MATLAB v.2012b or above, the submitted systems use Map Containers.

MATLAB-Tempogram-Toolbox_1.0 by Peter Grosche and Meinard Mueller 
* This submission includes this toolbox and a pre-compiled binary of "compute_fourierCoefficients.c" for Windows (32 bit), Linux (64 bit) and Mac (64 bit) systems. Other systems may need to call "COMPILE.m" in the toolbox folder (please refer README.txt in the toolbox folder for details).

### Memory Usage

Tested on a 64bit 6GB memory machine.
Usually, needs less than 1.5 GB during the training process.

### Runtime

Based on observed performance using a 2 x 2.26 Ghz Quad-Core Intel Xeon.

* Decoding: When the process uses full 8 cores, decoding needs average less than 20 sec per a song.
* Training: For 495 songs, it took four and half hours. (uses 1 core)

----------------------------------------------------------------------
## Use

From the `matlab` subdirectory, you should be able to execute the following:
```
# CB1.
./doChordID.sh /path/to/testFileList.txt /path/to/results

# CB2.
./extractFeaturesAndTrain  /path/to/trainFileList.txt  /path/to/scratch
./doChordID.sh /path/to/testFileList.txt /path/to/scratch /path/to/results
```
