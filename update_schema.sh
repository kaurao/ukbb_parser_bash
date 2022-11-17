#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

mkdir -p $SCRIPT_DIR/schema
wget -nd -O $SCRIPT_DIR/schema/field.txt "biobank.ctsu.ox.ac.uk/ukb/scdown.cgi?fmt=txt&id=1"
wget -nd -O $SCRIPT_DIR/schema/catbrowse.txt "biobank.ctsu.ox.ac.uk/ukb/scdown.cgi?fmt=txt&id=13"
