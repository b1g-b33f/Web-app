#!/bin/bash

for char in '%20' '%0a' '%00' '%0d0a' '/' '.\\' '.' '…' ':'; do
    for ext in '.php' '.phps' '.phtml' '.php2' '.php3' '.php4' '.php5' '.php6' '.php7' '.pht' '.pl' '.phar'; do
        echo "shell$char$ext.jpg" >> bypass_list.txt
        echo "shell$ext$char.jpg" >> bypass_list.txt
        echo "shell.jpg$char$ext" >> bypass_list.txt
        echo "shell.jpg$ext$char" >> bypass_list.txt
    done
done

echo -e "\e[31m***Wordlist Created***\e[0m"
