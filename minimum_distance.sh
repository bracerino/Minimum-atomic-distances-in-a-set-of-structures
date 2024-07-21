#!/bin/bash

# Define the directory containing the files
DIRECTORY="."

# Temporary Python script
TEMP_PYTHON_SCRIPT=$(mktemp /tmp/process_file_pandas.py.XXXXXX)
cat << 'EOF' > $TEMP_PYTHON_SCRIPT
import pandas as pd
import argparse

def process_file(input_file):
    df = pd.read_csv(input_file, sep='\s+', header=None, skiprows=1, names=['Col1', 'Col2'])
    filtered_df = df[df['Col2'] != 0.0]
    print(filtered_df.iloc[0, 0])
    return filtered_df.iloc[0, 0]

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Process a file and return the first value of the first column after filtering.')
    parser.add_argument('input_file', type=str, help='The input file to process')
    args = parser.parse_args()
    
    result = process_file("rdf_total.dat")
    with open("output_all.txt", 'a') as f0:
        f0.write(f"{args.input_file} {result}\n")
EOF

# Loop over all files in the directory
for FILE in "$DIRECTORY"/*
do
    yes | atomsk --rdf "$FILE" 10 0.1
    # Run the Python script with the current file as input
    python3 "$TEMP_PYTHON_SCRIPT" "$FILE"
done

# Clean up the temporary Python script
rm $TEMP_PYTHON_SCRIPT
