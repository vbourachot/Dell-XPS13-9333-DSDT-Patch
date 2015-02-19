#!/bin/bash

# disassemble.sh
#
# Creates DSL files from raw Linux extract
#
# Part of DSDT paching process for Haswell Envy 15
#
# Created by RehabMan
#

set -x

if [ ! -d "tmp" ]; then
    mkdir ./tmp
fi
if [ -e tmp/* ]; then
    rm ./tmp/*
fi

cp ./origin/DSDT.aml ./origin/SSDT* ./tmp
chmod +w ./tmp/*
cd ./tmp
list=`echo *`

for aml in $list; do
    /usr/local/bin/iasl -p ../unpatched/${aml%.*}.dsl -e ${list//$aml/} -d $aml
done

cd ..
rm -R tmp
