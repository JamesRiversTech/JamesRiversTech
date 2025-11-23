#!/bin/bash

# COLORS
########
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[1;33m" # Bold yellow
NC="\e[0m"       # No Color (reset)
########

#FUNCTIONS
##########
function EXIT () {
        echo -e "${NC}\n"
        exit $1
}

function clean {
        echo -e "${RED}\n\nCTRL + C Detected"
        sleep 2
        EXIT 1

}
##########

trap clean SIGINT


while [ 1 ]; do
        echo -e "${RED}CTRL + C or q to exit"
        echo -e "${YELLOW}What do u want to do ?
1 = add 
2 = subtract
3 = multiply
4 = divide
q = quit" 

        read -p ":" option
        # EXIT
        if [[ "$option" -eq "q" ]];then
                EXIT 1
        fi

        echo -e "${YELLOW}Pls give me the first number"
        read -p ":" num1
        echo -e "${YELLOW}Pls give me the second number"
        read -p ":" num2
        # ADDITION
        if [[ "$option" -eq 1 ]]; then
                echo -e "${GREEN}\n  Output:"
                echo -e "----------"
                echo -e "$(($num1 + $num2))"
                echo -e "----------"
        fi
        # SUBTRACTION
        if [[ "$option" -eq 2 ]]; then
                echo -e "${GREEN}\n  Output:"
                echo -e "----------"
                echo -e $(($num1 - $num2))
                echo -e "----------"
        fi
        # MULTIPLICATION
        if [[ "$option" -eq 3 ]]; then
                echo -e "${GREEN}\n  Output:"
                echo -e "----------"
                echo -e $(($num1 * $num2))
                echo -e "----------"
        fi
        # DIVISION
        if [[ "$option" -eq 4 ]]; then
                echo -e "${GREEN}\n  Output:"
                echo -e "----------"
                echo -e $(($num1 / $num2))
                echo -e "----------"
        fi
        echo -e "${NC}\n"
done
