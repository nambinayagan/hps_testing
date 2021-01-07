#!/bin/bash/
read -p "Enter path: " path
if [[ "$path" =~ ^/home[0-9]*/([^/][a-zA-Z0-9]*) ]]; then  du -hac $path | sort -rh | head -50; else echo "$path is not a vaild home directory" ; fi
