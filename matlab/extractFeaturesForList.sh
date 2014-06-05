#!/bin/bash

BANDS=$3
matlab -nodisplay -nosplash -r "extractFeaturesForList "\
"$1 "\
"$2/band-${BANDS} "\
"${BANDS};exit"
