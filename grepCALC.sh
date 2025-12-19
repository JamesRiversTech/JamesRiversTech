#!/bin/bash
read -p "Enter the string you would like to match: " string
list='!@#$%^&*()_-+=[]{}|;:?.>,<~'"'"'"\\/'
endstr=""

# MAIN
for (( i=0; i<${#string}; i++ )); do
    char=${string:$i:1}
    
    if [[ $char =~ ^[0-9]+$ ]]; then
        endstr+="\\d"
    elif [[ $char =~ ^[a-zA-Z]+$ ]]; then
        endstr+="[a-zA-Z]"
    elif [[ $char == " " ]]; then
        endstr+="\\s"
    else 
        if [[ $list == *"$char"* ]]; then
            endstr+="\\$char"
        else
            echo "Character '$char' is UNKNOWN"
            endstr+="."
        fi
    fi
done

read -p "Want to run the command? (y,n) " aq
if [[ $aq == "y" ]]; then
    read -p "Enter file or a directory to search (default: current directory): " searchpath
    searchpath=${searchpath:-.}  # Use current dir if empty
    grep --color=auto -a -rPo "$endstr" "$searchpath" \
        --exclude-dir={proc,sys,dev,run,tmp,.git,node_modules} 2>/dev/null
else
    echo -e ""
    echo "grep -raPo '$endstr' '$searchpath'"
fi
