#!/bin/bash
#############################################################################
#
#    <filehippo_ripper_apps.sh is made for downloading apps from 'http://filehippo.com'>
#    Copyright (C) <2014>  <naudit007>
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#
#--------Conceptor-----------------------------------------------------------
#
# Script realised by Naudit007
# date : 20/03/2014
# Contact naudit007@gmail.com
#
#------Description ----------------------------------------------------------
#
#   This sript downloads automatically softwares hosted and provided by http://www.filehippo.com/.
#   Before launch it you must define apps to download into the file text : To_download.txt.
#   /!\  Be careful with 32Bit and 64Bit applications on the file text cos there are 2 different ways.
#   Check before online. e.g: for 7zip :
#                                   - http://www.filehippo.com/download_7-zip_64/
#                                   - http://www.filehippo.com/download_7zip_32/
#   So, in the file text it'll be either "7zip_32" or "7-zip_64" or both.
#                            ---------*******---------
#   Otherwise just put the application name. e.g : for Firefox :
#                                   -http://www.filehippo.com/download_firefox/
#   So, in the file text it'll be simply: firefox
#   Enjoy teh power of bash!
#
#    FI : Windows apps repository hosted on Pydio ! +1
#
#------PREREQUISITE----------------------------------------------------------
#
#    - GNU/Linux OS
#    - Please check if Curl and Wget are already installed
#
#------If you need -> Debug Mode (Filehippo Structure may change) :  --------
#               set -x
#
#############################################################################
#            -       Set_Var         -                                      #
#############################################################################


# Thank to set only those vars :
#          - $export ****_proxy
#          - $CURRENT_DIR
#          - $DESTINATION_DOWNLOAD 
#          - $MOUNT_POINT
#          - $EMAIL_RECIPIENT
#Cheers :)

#Set proxy, Uncomment if needed in your env
#export http_proxy="http://yourproxy:3128"
#export https_proxy="http://yourproxy:3128"
#export ftp_proxy="ftp://yourproxy:3128"


CURRENT_DIR="/home/filehippo_script" #Where is your script : root# pwd
DESTINATION_DOWNLOAD="/mnt/filehippo_repo/applications/"

#Check Mountpoint
MOUNT_POINT="/mnt/filehippo_repo/"

#If you have email configured :
EMAIL_RECIPIENT="naudit007@gmail.com"
#EMAIL_RECIPIENT="naudit007@gmail.com mailer2 mailer3"


#############################################################################
#            -       Permanent_Vars        -                                #
#############################################################################
# Those vars don't need to be setted

# This file log error
ERROR_FILE="$CURRENT_DIR/filehippo_downloader_error.log"

# This file download apps that you put into txt file
DOWNLOAD_APPS="$CURRENT_DIR/filehippo_downloader_apps.txt"

FILEHIPPO="http://www.filehippo.com/download_"


#############################################################################
#            -       Loading environment      -                             #
#############################################################################

# Create/Clean error.log
cat /dev/null > $ERROR_FILE

# Check and create file for downloading apps
if [ ! -f "$DOWNLOAD_APPS" ]; then
   touch $DOWNLOAD_APPS
   # Ready to DL
   echo "firefox">>$DOWNLOAD_APPS
fi

# Check mount point if present

mountpoint $MOUNT_POINT
if [ $? -eq 0 ] ; then
        echo "mount OK, go script"
else
        echo -e "$MOUNT_POINT is not monted"
        echo -e "/!\_ The mount point $MOUNT_POINT is not monted, filehippo can't donwload apps. Please Check NFS" | mail -s "NFS Problem" $EMAIL_RECIPIENT
        exit 0
fi

# Check and create folder download
if [ ! -d "$DESTINATION_DOWNLOAD" ]; then
    mkdir -p $DESTINATION_DOWNLOAD
fi

# set Curl Configuration
        if [ -f "/etc/debian_version" ]; then
                        CURL="/usr/bin/curl -s --connect-timeout 10"
                        WGET="/usr/bin/wget -c --tries 3 --timeout 15"
                else
                        CURL="/opt/bin/curl -s --connect-timeout 10"
                        WGET="/opt/bin/wget -c --tries 3 --timeout 15"
        fi

# Start display screen
clear
echo -e '\e[1;33m' "#-----Launch Script Download Filehippo.com------#"
echo -e '\e[0;m'

#############################################################################
#            -       DECLARE FUNCTION        -                              #
#############################################################################

# Step 2 - Check if app exist on filehippo.com
function check_if_app_exist_on_market
        {
VERSION=$($CURL $FILEHIPPO$SOFTWARE/ |grep title|head -1 |tr ">" "\n"|tr "<" "\n"|grep "Download"|sed -e "s/Download //g"|awk 'BEGIN { FS =" -" } ; { print $1 }'|sed -e "s/ /_/g")
                if [[ ${VERSION} == "FileHippo.com" ]]; then
                                #---- Email page layout :

                                echo -e  "/!\ Be careful the application \"$SOFTWARE\" isn't find on market" >>$ERROR_FILE
                                echo -e  "Thank to check at http://www.filehippo.com/fr/search?q=$SOFTWARE and edit $DOWNLOAD_APPS" >>$ERROR_FILE
                                echo -e "\n" >>$ERROR_FILE
                                #echo  "$VERSION == FileHippo.com"
                        else
                                check_if_already_present
                fi
}

# Step 3 - Check if app is already download, so no download
function check_if_already_present
{
EXTENSION_APP=$($CURL $FILEHIPPO$SOFTWARE/tech/ |grep "<span class=\"field-value\">" |head -n 2 |tail -n 1  |sed 's/<span class="field-value">//g' |sed 's/<\/span>//g' |sed 's/ /_/g' |tr -d '\b\r')
                                if [ -f "$DESTINATION_DOWNLOAD$SOFTWARE/$EXTENSION_APP" ]; then
                                echo -e '\e[1;32m' "|!|Notification. This soft has been already downloaded : $SOFTWARE"
                                ls -l --color $DESTINATION_DOWNLOAD$SOFTWARE/$EXTENSION_APP
                                echo -e '\e[0;m'
                                        else
                                            check_folder
                                            filehippo_get_file
                                fi
}

# Step 4 - Check folder, if doesn't exist = create
function check_folder
{

if [ ! -d "$DESTINATION_DOWNLOAD$SOFTWARE" ]; then
    mkdir -p $DESTINATION_DOWNLOAD$SOFTWARE
fi
}

# Step 5 - Discover hidden URL and Download final file

function filehippo_get_file
{
# Fetch ID link for doanloading :
FETCH_URL=$($CURL $FILEHIPPO$SOFTWARE/  | grep $URL_GET_GREP |awk '{print $NF}'  | cut -d "/" -f 4 | head -n 1)
#echo "Controle de l'url de telechargement STEP N°2 to STEP N°3 : $FETCH_URL"

# Fetch executable link (full uniq ID
EXE_LINK=$($CURL $FILEHIPPO$SOFTWARE/download/$FETCH_URL/  |tr " " "\n"|tr "\"" "\n"|tr "=" "\n" |grep "download/file"|uniq)

# Identify the name and extension of the app
EXTENSION_APP=$($CURL $FILEHIPPO$SOFTWARE/tech/ |grep "<span class=\"field-value\">" |head -n 2 |tail -n 1  |sed 's/<span class="field-value">//g' |sed 's/<\/span>//g' |sed 's/ /_/g' |tr -d '\b\r')

# Download apps
$WGET --output-document "$DESTINATION_DOWNLOAD$SOFTWARE/$EXTENSION_APP" "http://www.filehippo.com/.$EXE_LINK"
}


#############################################################################
#            -             MAIN  PROGRAM              -                     #
#############################################################################


#Step 1 - We're reading file To_download.txt, then launch funtion
        while read SOFTWARE
                do
                # Reset Variables
                URL_GET_GREP="href=\"/download_$SOFTWARE/download"
                # Launch Process function
                   check_if_app_exist_on_market
                done <  $DOWNLOAD_APPS

# Step 6 -  Mini folder check (Comment for cron)
ls -l -color $DESTINATION_DOWNLOAD

# Step 7 - Show program error (Comment for cron)
cat $ERROR_FILE

# Step 8 - If ERROR.LOG isn't find then send email report
# Only if you have a mail configured, otherwise comment the following lines : 
if [[ -s "$ERROR_FILE" ]] ; then
mail -s "<Filehippo Downloader - Error Log File>" $EMAIL_RECIPIENT < $ERROR_FILE
fi

# Hope it's working well and you're enjoying :p
exit 0

