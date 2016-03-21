#!/bin/bash
for i in base-java base-oracle base-weblogic base-sites 
do
image_exists=`docker images | grep owcs/1-$i | wc -l`
if [ $image_exists -gt 0 ]; then
  echo "Skipping $i"
else
  echo ============  CHECK DOWNLOAD FOR owcs/1-$i:latest 
  installer_file=`cat $i/Dockerfile | awk '/RUN java -jar downloader.jar/ {split($0,a,"=")}END{print a[2]}'`
  echo "verifying $installer_file"
  if [ ! -z $installer_file ] && [ -e "$i/$installer_file.zip" ]; then
    echo "OK, $installer_file exists"
  else
    if [ ! -z $installer_file ]; then
      origi=`grep $installer_file sources.txt | cut -d"=" -f2`
      echo "Download $origi as $installer_file.zip into $i"
    fi
  fi 
fi

done
