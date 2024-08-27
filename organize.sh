#!/bin/sh

# Define formatting
GREEN="\033[0;32m"
BOLD="\033[1m"
RESET="\033[0m"

FOLDER_CHILDREN="["

# Initialize flags
dry_run=false
recommended=false
print_config=false
quiet=false

CONFIG=""

# Function to print usage
usage() {
    echo -e "${BOLD}Usage: ${RESET}${GREEN}${0}${RESET} [OPTIONS]" 1>&2
    echo -e "\n${BOLD}Options:${RESET}"
    echo -e "  ${GREEN}-d, --dry-run${RESET}				 Perform a dry run without making any changes."
    echo -e "  ${GREEN}-r, --recommended${RESET}			 Uses recommended folders without asking for user input."
    echo -e "  ${GREEN}-p, --print-config${RESET}			 Print the generated configuration at the end."
    echo -e "  ${GREEN}-q, --quiet${RESET}				 Suppress output messages."

    echo -e "\n${BOLD}Examples:${RESET}"
    echo -e "  ${GREEN}${0}${RESET} -r${RESET}			 Create recommended folders."
    echo -e "  ${GREEN}${0}${RESET} -dp${RESET}			 Perform a dry run and print configuration."
    echo -e "  ${GREEN}${0}${RESET} --quiet --recommended${RESET}	 Create recommended folders quietly."
    echo -e "  ${GREEN}${0}${RESET} < input.txt${RESET}		 Read configuration from pipe."

    exit 1
}
# Function to handle short options
handle_short_option() {
    case "$1" in
        d)
            dry_run=true
            ;;
        r)
            recommended=true
            ;;
        p)
            print_config=true
            ;;
        q)
            quiet=true
            ;;
        *)
            usage
            ;;
    esac
}

# Process arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -[!-]*)  # Handle combined short options, e.g., -drpq
            for (( i=1; i<${#1}; i++ )); do
                handle_short_option "${1:$i:1}"
            done
            shift
            ;;
        -d|--dry-run)
            dry_run=true
            shift
            ;;
        -r|--recommended)
            recommended=true
            shift
            ;;
        -p|--print-config)
            print_config=true
            shift
            ;;
        -q|--quiet)
            quiet=true
            shift
            ;;
        --)  # End of options
            shift
            break
            ;;
        -*)
            usage
            ;;
        *)
            break
            ;;
    esac
done

log() {
	if [ "$quiet" = false ]; then
		echo -e "$1"
	fi
}

create_folder() {
	local folder_name="$1"
	local categories="$2"
	local display_name="$3"

	log "${RESET}Creating folder ${GREEN}${BOLD}${folder_name}${RESET}, Categories: ${GREEN}${BOLD}${categories}${RESET}, Display Name:${GREEN}${BOLD} ${display_name}${RESET}"

	# Add the folder to the list, ensuring proper formatting
	if [ "$FOLDER_CHILDREN" = "[" ]; then
		FOLDER_CHILDREN="$FOLDER_CHILDREN '$folder_name'"
	else
		FOLDER_CHILDREN="$FOLDER_CHILDREN, '$folder_name'"
	fi
	CONFIG="${CONFIG}${folder_name}\n$(echo "$categories" | tr -d '[]')\n$(echo "$display_name" | tr -d "'")\n"
	if [ "$dry_run" = false ]; then
		gsettings set org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/"$folder_name"/ categories "$categories"
		gsettings set org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/"$folder_name"/ name "$display_name"
		gsettings set org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/"$folder_name"/ translate true
	fi
}

# Finish the folder-children assignment
finalize_folder_children() {
	FOLDER_CHILDREN="$FOLDER_CHILDREN]"
	CONFIG="${CONFIG}[END]"
	if [ "$dry_run" = false ]; then
		gsettings set org.gnome.desktop.app-folders folder-children "$FOLDER_CHILDREN"
	fi
}
# Reset previous layout
if [ "$dry_run" = false ]; then
	gsettings reset org.gnome.shell app-picker-layout
else
	log "${BOLD}Dry-run:${RESET} Would reset org.gnome.shell app-picker-layout"
fi

if [ "$recommended" = true ]; then
	create_folder "Games" "['Game']" "'Game.directory'"
	#    create_folder "Education" "['Education']" "'Education.directory'"
	create_folder "Utility" "['Utility']" "'Utility.directory'"
	create_folder "Office" "['Office']" "'Office.directory'"
	create_folder "Development" "['Development']" "'Development.directory'"
	create_folder "System" "['System', 'Settings']" "'System-Tools.directory'"
	create_folder "Social" "['Network', 'InstantMessaging']" "'Social'"
	create_folder "Internet" "['Network', 'WebBrowser']" "'Network.directory'"
	create_folder "Media" "['AudioVideo', 'Audio', 'Video']" "'AudioVideo.directory'"
	create_folder "Graphics" "['Graphics']" "'Graphics.directory'"
	finalize_folder_children
else
	# ↓ This may also be used with a pipe
	if [ -t 0 ]; then
		echo "Enter folder details (type '[END]' to stop):"
	fi
	while true; do
		read -p "Folder name: " folder_name
		if [ "$folder_name" = "[END]" ]; then
			break
		fi
		read -p "Categories (comma-separated): " categories
		read -p "Display name: " display_name
		create_folder "$folder_name" "[$categories]" "'$display_name'"
	done
	finalize_folder_children
fi

if [ "$print_config" = true ]; then 
	echo -e "${CONFIG}"
fi

log "${GREEN}Done!${RESET}"
