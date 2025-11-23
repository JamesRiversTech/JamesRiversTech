#!/bin/bash

help='
Encode or Decode a file 10x in base64
        -f = filename (required)
        -e = encode mode
        -d = decode mode
        -n = number of iterations (default: 10)
        -o = output to different file (preserves original)
        -s = silent mode (no output display)
        -h = show this help message
        -v = verbose mode

Usage examples:
    ./base64.sh -f myfile.txt -e           # Encode 10 times
    ./base64.sh -f myfile.txt -d -v        # Decode 10 times verbosely
    ./base64.sh -f input.txt -e -n 5       # Encode 5 times
    ./base64.sh -f input.txt -e -o out.txt # Encode and save to out.txt
'

filename=""
output_file=""
mode=""
verbose=false
silent=false
iterations=10

while getopts "hvf:edn:o:s" flag; do
    case $flag in
        h) echo "$help"; exit 0 ;;
        v) verbose=true ;;
        s) silent=true ;;
        f) filename=$OPTARG ;;
        e) mode="encode" ;;
        d) mode="decode" ;;
        n) iterations=$OPTARG ;;
        o) output_file=$OPTARG ;;
        \?) echo "$help"; exit 1 ;;
    esac
done

# Validation
[[ -z "$filename" ]] && { echo "Error: No filename specified!"; echo "$help"; exit 1; }
[[ ! -f "$filename" ]] && { echo "Error: File '$filename' does not exist!"; exit 1; }
[[ -z "$mode" ]] && { echo "Error: No mode specified! Use -e for encode or -d for decode"; echo "$help"; exit 1; }
[[ ! "$iterations" =~ ^[0-9]+$ ]] && { echo "Error: Iterations must be a positive number!"; exit 1; }

# Setup working file
if [[ -n "$output_file" ]]; then
    cp "$filename" "$output_file"
    working_file="$output_file"
else
    working_file="$filename"
fi

# Create temp file with proper cleanup
temp_file=$(mktemp) || { echo "Error: Cannot create temp file"; exit 1; }
trap "rm -f '$temp_file'" EXIT

# Function to process file
process_file() {
    local cmd=$1
    local msg=$2
    
    $verbose && echo "$msg $working_file $iterations times..."
    
    for ((i=1; i<=iterations; i++)); do
        $verbose && echo "  Pass $i/$iterations"
        
        if ! $cmd "$working_file" > "$temp_file" 2>/dev/null; then
            echo "Error: Failed to $mode at pass $i"
            exit 1
        fi
        
        # Atomic move using mv (faster than cp + rm)
        mv "$temp_file" "$working_file"
    done
    
    $verbose && echo "${msg^} complete!"
}

# Process based on mode
case $mode in
    encode) process_file "base64" "ENCODING" ;;
    decode) process_file "base64 -d" "DECODING" ;;
esac

# Display result unless silent
if ! $silent; then
    echo -e '\nFile contents:'
    cat "$working_file"
fi
