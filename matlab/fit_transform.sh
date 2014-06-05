#!/bin/bash

BASEDIR=/Users/ejhumphrey
METADATA=${BASEDIR}/metadata

if [ -z "$1" ]; then
    echo "Usage:"
    echo "fit_transform.sh {features} {bands} {[0-4]|*all}"
    echo $'\tfeatures - Name of the feature representation.'
    echo $'\tfold# - Number of the training fold, default=all.'
    exit 0
fi

FEATURES="$1"
BANDS="$2"

if [ "$3" == "all" ] || [ -z "$3" ];
then
    echo "Setting all folds"
    FOLD_IDXS=$(seq 0 4)
else
    FOLD_IDXS=$2
fi

FEATURE_DIR=${BASEDIR}/${FEATURES}

ESTIMATIONS=${BASEDIR}/estimations/${FEATURES}
MODELS=${BASEDIR}/models/${FEATURES}
for idx in ${FOLD_IDXS}
do
    MODELDIR=${MODELS}/${idx}
    TRAINLIST=${METADATA}/train${idx}.txt
    matlab -nodisplay -nosplash -r "extractFeaturesAndTrain "\
"${TRAINLIST} "\
"${FEATURE_DIR} "\
"${MODELDIR} "\
"${BANDS};exit"

    TESTLIST=${METADATA}/test${idx}.txt
    OUTPUTDIR=${ESTIMATIONS}/${idx}
    matlab -nodisplay -nosplash -r "doChordID "\
"${TESTLIST} "\
"${FEATURE_DIR} "\
"${MODELDIR} "\
"${OUTPUTDIR};exit"
done
