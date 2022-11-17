#!/bin/bash
# This script is used to parse the UK Biobank data

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# get user input
if [ $# -ne 3 ]; then
    echo "Usage: $0 category ukbb_data.tsv output.tsv"
    exit 1
fi

# set variables
cat=$1
if [ $((cat)) != $cat ]; then
    echo "cat must be a number"
    exit 1
fi
ukbb_data=$2
if [ ! -f $ukbb_data ]; then
    echo "Error: $ukbb_data does not exist"
    exit 1
fi
output=$3
if [ -f "${output}.tsv" ] || [ -f "${output}.fields" ]; then
    echo "Error: $output already exists"
    exit 1
fi

echo "Parsing $cat"
# get child categories if any
childcat=$(grep "^${cat}"$'\t' $SCRIPT_DIR/schema/catbrowse.txt | cut -f2 -d$'\t' | tr '\n' ' ')
if [ ! -z "$childcat" ] && [ "$childcat" != " " ]; then
    echo "Child categories found"
    cat=(${childcat[@]})
else
    echo "No child categories found"
    cat=("$cat")
fi
echo "categories ${cat[*]}"

# get datafields
fields=()
for c in ${cat[@]}; do
    cfields=$(cut -f1,14 -d$'\t' $SCRIPT_DIR/schema/field.txt | grep $'\t'"${c}$" | cut -f1 -d$'\t' | xargs | tr '\n' ' ')
    if [ ! -z "$cfields" ] && [ "$cfields" != " " ]; then
        cfields=($cfields)
        echo "${#cfields[@]} fields found for category $c"  
        fields+=(${cfields[@]})
    else
        echo "No fields found for category $c"
    fi
done
if [ ${#fields[@]} -eq 0 ]; then    
    echo "Assuming its a field"
    fields=${cat[@]}
fi
echo "Number of fields: ${#fields[@]}"
#echo "fields ${fields[@]}"
printf "%s\n" "${fields[@]}" > "${output}.fields"

# get column numbers
cols=()
for f in ${fields[*]}; do    
    fcols=$(head -n 1 $ukbb_data | tr '\t' '\n' | nl -nln | grep $'\t'"${f}\-" | cut -f1 | xargs | tr '\n' ' ')
    if [ ! -z "$fcols" ] && [ "$fcols" != " " ]; then        
        cols+=(${fcols[@]})
    else        
        echo "No columns found for field $f"
    fi
done
if [ ${#cols[@]} -eq 0 ]; then
    echo "No columns found for fields $fields"
    exit 1
fi
echo "Number of columns: ${#cols[@]}"
#echo "cols ${cols[@]}"
cols=$(printf "%s,"  "${cols[@]}")
# we will have , at the end so just append 1 which is eid
cols="${cols}1"

# get data
#awk -v cols=$cols -F $'\t' 'BEGIN{OFS=FS} NR==1{print $cols} NR>1{print $cols}' $ukbb_data > $output
cut -f"$cols" -d$'\t' $ukbb_data > "${output}.tsv"
