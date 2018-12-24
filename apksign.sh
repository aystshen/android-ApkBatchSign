#!/bin/bash

usage()
{
    echo "USAGE: [r] [-s source directory] [-k key directory]"
    echo "No ARGS means use default build option"
    echo "WHERE: -s = set source directory"
    echo "       -k = key directory"
    echo "       -r = replace source file"
    echo "       -h = help"
    exit 1
}

CUR_DIR=$PWD
SOURCE=$CUR_DIR
SIGNAPK_JAR=signapk.jar
KEY=$CUR_DIR
REPLACE=false

while getopts "s:k:r" opt
do
    case $opt in
        s)
		SOURCE=$OPTARG
        ;;
		k)
        KEY=$OPTARG
        ;;
		r)
        REPLACE=true
        ;;
        h)
        usage ;;
        ?)
        usage ;;
    esac
done


function sign(){
    for filename in $1/*
    do  
        if [ -d $filename ]
        then 
            sign $filename
        elif [ "${filename##*.}" = "apk" ]; then
            echo "签名: "$filename
		
			tempname=$(dirname $filename)"/"$(basename $filename .apk)"_signed.apk"
			java -jar $KEY/signapk.jar $KEY/platform.x509.pem $KEY/platform.pk8 $filename $tempname
			
			if [ $REPLACE = true ]; then
				rm -rf $filename
				mv -vf $tempname $filename
			fi
        fi  
    done
}

sign $SOURCE