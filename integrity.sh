#!/bin/bash


BLUE=$(tput setaf 4)
GREEN=$(tput setaf 2)
RED=$(tput setaf 1)
YELLOW=$(tput setaf 3)
NORMAL=$(tput sgr0)

storageDir="$HOME/.fic"
mkdir -p $storageDir
chmod 700 $storageDir

init(){
	folder=$(realpath $1)
	safeFolderName=$(echo $folder | sed 's|/|_|g')
	hashes_data_base="$storageDir/$safeFolderName.db"
	if [ -e "$hashes_data_base" ]; then
		read -p "${YELLOW}Hashes for this folder already exists, Do you want to continue? (y/n)${NORMAL}" flag
		if [[ $flag = [Yy]* ]]; then
			chmod +w $hashes_data_base
			> $hashes_data_base
		else
			echo "${RED}[Aborted] No changes made.${NORMAL}"
			return
		fi
	fi

	echo "${BLUE}initializing hash database for folder: $folder${NORMAL}"
	for file in $(find "$folder" -type f); do
		file=$(realpath $file)
		local hash=$(sha256sum "$file" | awk '{print $1}')
		echo "$file::$hash" >> $hashes_data_base
		echo "${GREEN}[hashed]${NORMAL} $file"
	done
	chmod 444 $hashes_data_base
	dbDir="$HOME/Desktop/hashes.db"
	cat << 'EOF' > "$dbDir"
	Ah, so you've made it. Welcome, digital explorer, to what you surely believed was the crown jewel of this machine. A file so “sensitive” it simply *had* to be opened, right? Bravo — truly. Your curiosity has led you not to secrets, but to this sad little monument of disappointment. You sifted through directories, danced with permissions, probably even patted yourself on the back thinking, “I’m in.” Spoiler: you're not. You’re like a raccoon who broke into a safe expecting gold but found a glitter-filled birthday card that says “Nice Try.” We've seen your kind before — fingers greasy with Ctrl+C/Ctrl+V from Stack Overflow, dreams of glory in the logs of a forgotten temp directory. Every command you type is being silently judged by a bash script that wrote itself out of pity. Somewhere, your IP address just got sent to a server named "disappointment_log_005", where it will live forever, alongside other legends who tried to "cat hashes.db" in production. So go ahead, poke around. There's nothing here but digital echoes and the sound of us not caring. You played yourself. And this file? It was the bait.
EOF
	echo "${BLUE}All hashes saved to $dbDir${NORMAL}"
}
scan(){
	unchangedFiles=0
	modifiedFiles=0
	newFiles=0
	deletedFiles=0
	folder=$(realpath $1)
	safeFolderName=$(echo $folder | sed 's|/|_|g')
	hashes_data_base="$storageDir/$safeFolderName.db"
	chmod +w $hashes_data_base
	echo "${BLUE}starting scan of folder: $folder${NORMAL}"
	for line in $(cat $hashes_data_base); do
		path=$(echo $line | awk -F:: '{print $1}')
		path=$(realpath $path)
		old_hash=$(echo $line | awk -F:: '{print $2}')
		if [ -e "$path" ]; then
			new_hash=$(sha256sum $path | awk '{print $1}')
			if [ $old_hash = $new_hash ]; then
				echo "$path ---> ${GREEN}Not Modified${NORMAL}"
				((unchangedFiles++))
			else
				echo "$path ---> ${RED}Modified${NORMAL}"
				((modifiedFiles++))
			fi
		else
			echo "$path ---> ${YELLOW}Deleted${NORMAL}"
			((deletedFiles++))
		fi
	done
	for file in $(find "$folder" -type f); do
		if ! grep -q "$file" $hashes_data_base; then
			hash=$(sha256sum $file | awk '{print $1}')
			echo "$file::$hash" >> $hashes_data_base
			echo "${YELLOW}[hashed] [new]${NORMAL} $file"
			((newFiles++))
		fi
	done
	
	echo ""
	echo "${BLUE}Scan summary:${NORMAL}"
	echo "${GREEN}[$unchangedFiles] unchanged${NORMAL}"
	echo "${RED}[$modifiedFiles] modified${NORMAL}"
	echo "${YELLOW}[$newFiles] new${NORMAL}"
	echo "${RED}[$deletedFiles] deleted${NORMAL}"
	chmod 444 $hashes_data_base
			
			
}
showHelp(){
	echo ""
	echo "File Integrity Checker - Bash CLI Tool"
	echo ""
	echo "Usage:"
	echo " ${GREEN}$0 init /path/to/folder${NORMAL}	Initialize file hashes"
	echo " ${GREEN}$0 scan /path/to/folder${NORMAL}	Scan and compare hashes"
	echo " ${GREEN}$0 --help or -h${NORMAL}		Show this help page"
	echo ""
	echo "Description:"
	echo " Thi tool checks for file tampering using SHA-256 hashes."
	echo " It reports new, modified, deleted or unchanged files."
	echo ""
	echo "Made with ${RED}˚ʚ♡ɞ˚${NORMAL} by Hammad"
	echo ""
}
showVersion(){
	echo ""
	echo "File integrity Checker V1.0"
	echo "Author: Hammad"
	echo ""
}
case $1 in
	init)
		if [ -z $2 ]; then
			echo "${BLUE}usage: $0 init /path/to/folder${NORMAL}"
		else
			init "$2"
		fi
		;;
	scan)
		if [ -z $2 ]; then
			echo "${BLUE}usage: $0 scan /path/to/folder${NORMAL}"
		else
			scan "$2"
		fi
		;;
	--help | -h)
		showHelp;;
	--version | -V)
		showVersion;;
	*)
		echo "${BLUE}Unknown Command:${NORMAL}"
		echo "use $0 --help or -h to see help page"
		;;
esac
