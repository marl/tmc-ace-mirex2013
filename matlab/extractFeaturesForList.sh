#!/bin/bash
# Extract features for a list of audio files and {audio_file}.txt lab-file
#   annotations only.
#
# Sample call:
# $ ./extractFreaturesForList.sh filelist.txt ~/my/features 4

BANDS=$3
matlab -nodisplay -nosplash -r "extractFeaturesForList "\
"$1 "\
"$2/band-${BANDS} "\
"${BANDS};exit"
