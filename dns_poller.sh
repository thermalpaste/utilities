#!/bin/bash

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.


# List of hosts 
hosts=("host1" "host2" "host3")
status=()  # To store the status of each host
allReady=false  # To check if all records are ready

# Initialize status array
for ((i=0; i<${#hosts[@]}; i++)); do
    status[$i]="\e[31m[Not Ready]\e[0m"
done

# Function to check if a key is pressed
key_pressed() {
    local STTY_SAVE
    STTY_SAVE=$(stty -g)
    stty -icanon -echo min 0 time 0
    local KEY_PRESSED
    KEY_PRESSED=$(dd bs=1 count=1 2>/dev/null)
    stty "$STTY_SAVE"
    [[ "$KEY_PRESSED" == $'\x1b' ]]
}

while true; do
    allReady=true  # Assume all are ready until proven otherwise

    for ((i=0; i<${#hosts[@]}; i++)); do
        host=${hosts[$i]}

        # If the host status is [Not Ready], we check again
        if [ "${status[$i]}" == "\e[31m[Not Ready]\e[0m" ]; then
            output=$(nslookup $host 2>&1)
            
            if [ $? -ne 0 ]; then
                status[$i]="\e[31m[Not Ready]\e[0m"
                allReady=false
            else
                status[$i]="\e[32m[Ready]\e[0m"
            fi
        fi

        echo -e "$host: ${status[$i]}"
    done

    # If all hosts are ready or the escape key is pressed, break out of the loop
    if $allReady || key_pressed; then
        break
    fi

    # Optional: sleep for a duration before checking again
    sleep 5
done
