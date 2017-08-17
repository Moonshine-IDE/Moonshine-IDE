#!/bin/bash
# Simple script that generates a test copy of ../src/locale/en_US/resources.properties
# This test was suggested in the last point in this post:
# http://www.smashingmagazine.com/2012/07/18/12-commandments-software-localization/
# 
# The new file is called ../src/locale/pt_PT/resources.properties
# Each message in the file will have "ZZ_" at the beginning of every string.
#
# To test the new file, append ?lang=xh or &lang=xh to the URL
# Currently Broken:  I can not use this with the home page.  For example:
# http://localhost:8080/Grails4NotesDesigner/?lang=xh
# This looks like the fix:  http://stackoverflow.com/questions/18818510/does-grails-internationalization-work-in-index-gsp
#
# Once you have generated the test locale, navigate to either
# MoonshineDESKTOPevolved/build or MoonshineWEBevolved/build and run:
#
# ant -Dlocale.list="en_US,ja_JP,pt_PT"

# The current test language is Portuguese
LANGUAGE_CODE=pt_PT

I18N_DIR=../src/locale
ORIGINAL_FILE=${I18N_DIR}/en_US/resources.properties
TEST_DIR=${I18N_DIR}/${LANGUAGE_CODE}
TEST_FILE=${TEST_DIR}/resources.properties
PREFIX="ZZ_"

set -e

# make sure the directory exists
if [ ! -e ${TEST_DIR} ]
then
	mkdir $TEST_DIR
fi

# Delete the test file to start a clean test
if [ -e ${TEST_FILE} ]
then
    echo "Clearing the test file"
    rm ${TEST_FILE}
fi

# Generate the test file:
cat ${ORIGINAL_FILE} | sed "s/\([^=]\)=\(.*\)$/\1=${PREFIX}\2/" > ${TEST_FILE}
echo "File generated at ${TEST_FILE}"

