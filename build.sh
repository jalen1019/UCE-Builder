#!/bin/bash 

# DEFINE FUNCTIONS
# define usage information function
usage() {
	echo -e "\t--dest=\t\tdestination folder"
	echo -e "\t--source=\tfolder to scan"
	echo -e "\t--core=\t\tpath to core file"
	echo -e "\t--box-art=\tpath to default boxart"
	echo -e "\t--bezel=\tpath to default bezel"
	echo -e "\t--file-suffix=\tsuffix of file names"
	echo -e	"\t-h | --help\tthis message"
}

# DEFINE MAIN 
# exit if not enough args
if [ "$#" -ne 6 ]; then
	usage
	exit
fi

# parse command line args
for i in "$@"
do
case $i in
	--dest=*)	
		dir_dest="${i#*=}"
		shift
		;;
	--source=*)	
		dir_source="${i#*=}"
		shift
		;;
	--core=*)	
		core="${i#*=}"
		shift
		;;
	--box-art=*)	
		boxart="${i#*=}"
		shift
		;;
	--bezel=*)	
		bezel="${i#*=}"
		shift
		;;
	--file-suffix=*) 
		file_suffix="${i#*=}"
		shift
		;;
	-h | --help )	
		usage
		exit 
		;;
	* )	
		usage
		exit 1		
		;;
esac
done

# MAIN LOOP
for FILE in $dir_source/* 
do
	FILE_NAME="${FILE%.*}"
	echo -e "Creating directory $FILE_NAME/"
	# Create folder hierarchy
 	mkdir -p "$dir_dest/$FILE_NAME/"
 	mkdir -p "$dir_dest/$FILE_NAME/emu"
 	mkdir -p "$dir_dest/$FILE_NAME/roms"
 	mkdir -p "$dir_dest/$FILE_NAME/boxart"
 	mkdir -p "$dir_dest/$FILE_NAME/save"
	cp "$boxart" "$dir_dest/$FILE_NAME/boxart/boxart.png"
 	ln -s "$boxart" "$dir_dest/$FILE_NAME/title.png"
	
	# Generate cartridge.xml file
	cat > "$dir_dest/$FILE_NAME/cartridge.xml" <<- EOF  
	<?XML version="1.0" encoding="UTF-8"?>
	<byog_cartridge version="1.0">
		<title>$FILE_NAME</title>
		<desc>Community Add On</desc>
		<boxart file="boxart\boxart.png" ext="png">
	</byog_cartridge>
	EOF

	# Generate exec.sh file
	cat > "$dir_dest/$FILE_NAME/exec.sh" <<-EOF 
	#!/bin/sh

	set -x
	/emulator/retroplayer ./emu/$core.so "./roms/$($1).bin"
	EOF

	# Move emulator file into emu directory
	cp "$core" "$dir_dest/$FILE_NAME/emu"

	# Move rom into rom directory
	cp "$FILE" "$dir_dest/$FILE_NAME/roms"
done
