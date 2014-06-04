#!/bin/bash

BASEDIR=/Users/ejhumphrey
METADATA=${BASEDIR}/metadata

if [ -z "$1" ]; then
    echo "Usage:"
    echo "fit_transform.sh {features|all} {[0-4]|*all}"
    echo $'\tfeatures - Name of the feature representation.'
    echo $'\tfold# - Number of the training fold, default=all.'
    exit 0
fi

if [ "$1" == "all" ]
then
    echo "Setting all known features..."
    FEATURES="tmc_features"
else
    FEATURES="$1"
fi

if [ "$2" == "all" ] || [ -z "$2" ];
then
    echo "Setting all folds"
    FOLD_IDXS=$(seq 0 4)
else
    FOLD_IDXS=$2
fi

for features in ${FEATURES}
do
    FEATURE_DIR=${BASEDIR}/${features}

    ESTIMATIONS=${BASEDIR}/estimations/${features}
    MODELS=${BASEDIR}/models/${features}
    for idx in ${FOLD_IDXS}
    do
        MODELDIR=${MODELS}/${idx}
        TRAINLIST=${METADATA}/train${idx}.txt
        matlab -nodisplay -nosplash -r "extractFeaturesAndTrain "\
"${TRAINLIST} "\
"${FEATURE_DIR} "\
"${MODELDIR};exit"

        TESTLIST=${METADATA}/test${idx}.txt
        OUTPUTDIR=${ESTIMATIONS}/${idx}
        matlab -nodisplay -nosplash -r "doChordID "\
"${TESTLIST} "\
"${FEATURE_DIR} "\
"${MODELDIR} "\
"${OUTPUTDIR};exit"
    done
done
