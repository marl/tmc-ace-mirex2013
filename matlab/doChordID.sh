#!/bin/bash
# args: fileList, features, model, results

matlab -nodisplay -nosplash -r "doChordID $1 $2 $3 $4;exit"
