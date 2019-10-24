#!/bin/bash
####################################################
#                                                  #
# Auth: jean-christophe.iacono@1001pharmacies.com  #
#                                                  #
#  img-compressr.sh                                #
#                                                  #
#  Usage: img-compressr.sh <options>               #
#                                                  #
# This script compresses images in target folders  #
#   and subfolders using ImageMagick.              #
#                                                  #
#                                                  #
# Version: 0.4                                     #
#                                                  #
####################################################
#
#
### Documentation used
# - ImageMagick install : https://imagemagick.org/script/install-source.php
# OR apt install. (because manual install means manual plugin management)
#
# - PageSpeed Insights : https://developers.google.com/speed/docs/insights/OptimizeImages
#
### Notes
#
# The purpose of this script is to compress images in a list of folders
# with potential subfolders.
#
# - Script can handle spaces in files or folders names
#
# - imagemagick : target and destination files can be the same, this will overwrite file
#   with compressed version
#
#
#
### TODO
#
#  - Clean debug & unused comments
#  - Catch and manage error codes
#  - Set customizable (maxdepth) recursivity
#
#  - Run extensive tests (homepage OK) <P1>
#
#

PATH=${PATH:-/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/bin}

# imagemagick convert binary
convert=convert

if ! [ -x "$(command -v $convert)" ] ; then
    echo "Imagemagick convert ($convert) is required to execute this script"
    exit 1
fi

lastrun_marker=compression_marker
backup_extension=uncompressedbak

RED="\033[31m"
GREEN="\033[32m"
BLUE="\033[36m"
YELLOW="\033[33m"
BRIGHTGREEN="\033[32m\033[1m"
BRIGHTBLUE="\033[36m\033[1m"
COLOR_RESET="\033[0m"



function show_help(){
    printf "Script usage :\n"
    printf "\t-b          : Backup, copy original images as <imagename>.$backup_extension ;\n"
    printf "\t-c          : Clean backups, backup copies will be removed ;\n"
    printf "\t-f          : Force, ignore last compression timestamp. Will also overwrite backups if combined with -b ;\n"
    printf "\t-r          : Recursive, convert images recursively in folder and subfolders ;\n"
    printf "\t-u          : Undo, revert to original files (requires backup to be previously created) ;\n"
    printf "\t-v          : Verbose, display commands and files being compressed ;\n"
    printf "\t-y          : Yes, do not ask for confirmation to begin compression ;\n"
    printf "\n"
    printf "\t-h          : this screen.\n"
    printf "\n"
    printf "        Examples : $0 -vbr /some/directory \"/directory/with some/spaces\"\n"
    printf "                   $0 -ryu /some/directory \"/directory/with some/spaces\"\n"
    printf "                   $0 -cry /some/directory \"/directory/with some/spaces\"\n"
    printf "\n"
}



function user_confirmation() {
    if [ "$yes" -eq 0 ] ; then
        read -p "Are you sure you want to proceed ? (y/n) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]] ; then
            echo "Operation aborted, no change on files" ; exit 0
        fi
    fi
}



function clean_backups() {
user_confirmation
echo ; echo -e "${BLUE}Cleaning backups...${COLOR_RESET}"

    for target_folder in "$@" ; do
        find "$target_folder" -type f -iname '*.$backup_extension' -delete
    done

echo -e "${BLUE}Cleaning backups ${BRIGHTGREEN}OK${COLOR_RESET}"
exit 0
}


### Catching options ###

backup=0
do_clean_backups=0
force=0
recursive=0
undo=0
verbose=0
yes=0

if [ $# -eq 0 ] ; then # If 0 option
    echo "Some options are required" ; echo
    show_help ; exit 1
fi


while getopts "bcfruvyh" optName; do
    case "$optName" in
    b) backup=1 ; echo "Backup enabled. A copy of files will be created" ;;
    c) do_clean_backups=1 ; echo "Clean mode, backups in target folders will be removed" ;;
    f) force=1 ; echo "Force enabled. Last compression timestamp will be ignored"
        echo "Note that forcing compression will overwrite any existing backups with current version" ;;
    r) recursive=1 ; echo "Recursivity enabled. Subfolders will be treated" ;;
    u) undo=1 ; echo "Undo mode, original files for target folders will be restored if present" ;;
    v) verbose=1 ; echo "Verbose mode enabled" ;;
    y) yes=1 ; echo "Auto confirmation enabled" ;;
    h) show_help ; exit 0 ;;
    *) echo "Option $1 not recognized" ; show_help ; exit 1 ;;
    esac
done
shift "$((OPTIND -1))"

if [ -z "$1" ] ; then
    echo ; echo "You must specify at least one target directory"
    echo ; show_help ; exit 1
fi

if [ $backup -eq 1 ] && [ $undo -eq 1 ] ; then
    echo ; echo "You may not want to backup and undo at the same time"
    echo ; show_help ; exit 1
fi

if [ $do_clean_backups -eq 1 ] ; then
    clean_backups "$@"
fi




#############
### START ###
#############

# Stats : init total
total_before=0
total_after=0


### SUBFOLDERS DISCOVERY ###

# Create the subfolder list
echo ; echo -e "${BLUE}Listing affected subfolders...${COLOR_RESET}"

if [ $recursive -eq 0 ] ; then # target folders will be the actual folder list
    subfolders_list="$(find "$@" -maxdepth 0 -type d)"
else # recursive enabled, get subfolders
    subfolders_list="$(find "$@" -type d)"
fi


# Display and confirm $subfolder_list
echo "$subfolders_list"
echo -e "${BLUE}Listing subfolders ${BRIGHTGREEN}OK${COLOR_RESET}"; echo

user_confirmation



### BACKUP RESTORATION ###
if [ $undo -eq 1 ] ; then # Restore available backups
    echo ; echo -e "${BLUE}Restoring available backups in target subfolders...${COLOR_RESET}"

    while IFS="" read -r folder ; do
        echo
        echo
        echo
        echo -e "${BRIGHTBLUE}*** Entering folder ${COLOR_RESET}${YELLOW}$folder ${COLOR_RESET}"
        echo
        echo -e "${BLUE}Restoring files...${COLOR_RESET}"

            while IFS="" read -r file ; do
                if [ -z "$file" ] ; then # list is empty
                    echo -e "${BLUE}No new files to restore in this folder${COLOR_RESET}"
                else
                    mv "$file" "${file%.$backup_extension}"
                    [ "$verbose" -eq 1 ] && echo -e "File ${YELLOW}${file%.$backup_extension}${COLOR_RESET} ${BLUE}restored${COLOR_RESET}"
                fi
            done <<< "$(find "$folder" -maxdepth 1 -type f -iname "*.$backup_extension")"

        if [ -f "$folder/$lastrun_marker" ] ; then
            echo -e "${BLUE}Removing compression marker${COLOR_RESET}" ; rm "$folder/$lastrun_marker"
        fi
    done <<< "$subfolders_list"

    echo ; echo -e "${BLUE}Cleaning backups ${BRIGHTGREEN}OK${COLOR_RESET}" ; echo
    exit 0
fi




### COMPRESSION ###
while IFS="" read -r folder ; do
    echo
    echo
    echo
    echo -e "${BRIGHTBLUE}*** Entering folder ${COLOR_RESET}${YELLOW}$folder ${COLOR_RESET}"



    ### FILE LISTING ###
    echo ; echo -e "${BLUE}Listing files...${COLOR_RESET}"

    #  If marker present, use it, unless Force is used
    use_marker=0
    if [ $force -eq 0 ] ; then
        if [ -f "$folder/$lastrun_marker" ] ; then
           use_marker=1 ; [ "$verbose" -eq 1 ] && echo -e "${BLUE}Found marker from last compression, only compressing new files${COLOR_RESET}"
        else
            se_marker=0 ; [ "$verbose" -eq 1 ] && echo -e "${BLUE}No marker found, all files in this folder will be compressed${COLOR_RESET}"
        fi
    else
        use_marker=0 ; [ "$verbose" -eq 1 ] && echo -e "${BLUE}Force used, all files in this folder will be compressed${COLOR_RESET}"
    fi

    # Create files list
    #
    # (Duplicated command here, passing -newer with quotes would make find to not locate the marker)
    #
    if [ $use_marker -eq 0 ] ; then
        [ "$verbose" -eq 1 ] && echo -e "${BLUE}command : ${GREEN}find \"$folder\" -maxdepth 1 -type f -iname '*.jpg' -or -iname '*.jpeg'${COLOR_RESET}"
        images_list="$(find "$folder" -maxdepth 1 -type f -iname '*.jpg' -or -iname '*.jpeg')"
    else
        [ "$verbose" -eq 1 ] && echo -e "${BLUE}command : ${GREEN}find $folder -maxdepth 1 -type f \"-newer $folder/$lastrun_marker\" -iname '*.jpg' -or -type f \"-newer $folder/$lastrun_marker\" -iname '*.jpeg'${COLOR_RESET}"
        images_list="$(find "$folder" -maxdepth 1 -type f -newer "$folder/$lastrun_marker" -iname '*.jpg' -or -type f -newer "$folder/$lastrun_marker" -iname '*.jpeg')"
    fi




    ### FILE COMPRESSION ###
    [ "$verbose" -eq 1 ] && echo ; echo -e "${BLUE}Converting files...${COLOR_RESET}"
    [ "$verbose" -eq 1 ] && echo -e "${BLUE}command : ${GREEN}$convert -sampling-factor 4:2:0 -strip -quality 85 -interlace JPEG -colorspace RGB <src> <dst>${COLOR_RESET}"

    if [ -z "$images_list" ] ; then # list is empty
        echo -e "${BLUE}No new files to compress in this folder${COLOR_RESET}"
    else

        # Initialization of folder statistics
        folder_before=0
        folder_after=0

        while IFS="" read -r file ; do

            # Create backup
            if [ $backup -eq 1 ] ; then
                cp -a "$file" "$file.$backup_extension"
            fi

            # Stats before
            size_before=$(stat -c%s "$file")
            folder_before=$(( $folder_before + $size_before ))
            total_before=$(( $total_before + $size_before ))

            $convert -sampling-factor 4:2:0 -strip -quality 85 -interlace JPEG -colorspace RGB "$file" "$file"

            # Stats after
            size_after=$(stat -c%s "$file")
            folder_after=$(( $folder_after + $size_after ))
            total_after=$(( $total_after + $size_after ))
            variation=$(awk -v after="$size_after" -v before="$size_before" 'BEGIN {print int(((after*100)/before)-100)}')

            # Output stats for file
            if [ "$size_after" -gt "$size_before" ] ; then
                [ "$verbose" -eq 1 ] && echo -e "File ${YELLOW}$file${COLOR_RESET} ${RED}increased${COLOR_RESET} from $size_before to $size_after, by ${RED}$variation %${COLOR_RESET}"
            else
                [ "$verbose" -eq 1 ] && echo -e "File ${YELLOW}$file${COLOR_RESET} ${GREEN}decreased${COLOR_RESET} from $size_before to $size_after, by ${GREEN}$variation %${COLOR_RESET}"
            fi
        done <<< "$images_list"

        echo -e "${BLUE}Compression ${BRIGHTGREEN}OK${COLOR_RESET}"

        # Stats for this folder
        echo 
        [ "$verbose" -eq 1 ] && echo -e "${BLUE}Folder${COLOR_RESET} ${YELLOW}$folder ${BLUE}complete.${COLOR_RESET}"
        echo -e "${BLUE}Initial size${COLOR_RESET} :    $folder_before"
        echo -e "${BLUE}Compressed size${COLOR_RESET} : $folder_after"
        folder_variation=$(awk -v after="$folder_after" -v before="$folder_before" 'BEGIN {print int(((after*100)/before)-100)}')
        if [ $folder_after -gt $folder_before ] ; then
                echo -e "${BLUE}Folder compression gain :  ${RED}$folder_variation %${COLOR_RESET}"
            else
                echo -e "${BLUE}Folder compression gain :  ${GREEN}$folder_variation %${COLOR_RESET}"
        fi

        # Test success with exit code ?
        [ "$verbose" -eq 1 ] && echo -e "${BLUE}Success, generating compression marker...${COLOR_RESET}"
        echo "Success" > "$folder/$lastrun_marker"
    fi

done <<< "$subfolders_list"


# Total stats
echo ; echo ; echo ; echo -e "${BRIGHTBLUE}*** Compression complete ! ***${COLOR_RESET}"

if [ $total_before -eq 0 ] ; then
    echo -e "${BLUE}No file were modified.${COLOR_RESET}"
else
    echo -e "${BLUE}Total initial size :${COLOR_RESET}    $total_before"
    echo -e "${BLUE}Total compressed size :${COLOR_RESET} $total_after"
    total_variation=$(awk -v after="$total_after" -v before="$total_before" 'BEGIN {print int(((after*100)/before)-100)}')
    if [ $total_after -gt $total_before ] ; then
             echo -e "${BLUE}Total compression gain :  ${RED}$total_variation %${COLOR_RESET}"
        else
            echo -e "${BLUE}Total compression gain :  ${GREEN}$total_variation %${COLOR_RESET}"
    fi
fi
echo ;
