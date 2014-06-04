#!/bin/bash

matlab -nodisplay -nosplash -r "extractFeaturesAndTrain $1 $2;exit"
