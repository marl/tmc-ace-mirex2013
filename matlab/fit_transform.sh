#!/bin/bash

FEATURES=tmc_features

FOLD_IDXS=$(seq 0 4)
BASEDIR=/Users/ejhumphrey
METADATA=${BASEDIR}/metadata

ESTIMATIONS=${BASEDIR}/estimations/${FEATURES}/
MODELS=${BASEDIR}/models/${FEATURES}/
for idx in ${FOLD_IDXS}
do
    MODELDIR=${MODELS}/${idx}/
    TRAINLIST=${METADATA}/train${idx}.txt
    matlab -nodisplay -nosplash -r "extractFeaturesAndTrain "\
"${TRAINLIST} "\
"${FEATURES} "\
"${MODELDIR};exit"

    TESTLIST=${METADATA}/test${idx}.txt
    OUTPUTDIR=${ESTIMATIONS}/${idx}/
    matlab -nodisplay -nosplash -r "doChordID "\
"${TESTLIST} "\
"${FEATURES} "\
"${MODELDIR} "\
"${OUTPUTDIR};exit"
done
