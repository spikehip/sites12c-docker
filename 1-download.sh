#!/bin/bash
test -e _machine.sh && source $PWD/_machine.sh
USER=${1:?your oracle username}
PASS=${2:?your oracle password}
cp sources.txt base-java/sources.link
printf "username=$USER\npassword=$PASS\n" >>base-java/sources.link
for i in base-java base-oracle base-weblogic base-sites 
do
image_exists=`docker images | grep owcs/1-$i | wc -l`
if [ $image_exists -gt 0 ]; then
  echo "Skipping $i"
else
  echo ============  BUILD owcs/1-$i:latest 
  installer_file=`cat $i/Dockerfile | awk '/RUN java -jar downloader.jar/ {match($0, "sources.link=([a-z\\\\.]+)$",a)}END{print a[1]}'`
  echo "verifying $installer_file"
  if [ ! -z $installer_file ] && [ -e "$i/$installer_file.zip" ]; then
    echo "OK, $installer_file exists, replacing Dockerfile RUN java -jar downloader.jar with ADD $installer_file"
    sed -i "s/RUN java -jar downloader.jar sources.link=$installer_file/ADD $installer_file.zip \/$installer_file.zip/" $i/Dockerfile
  fi 
  docker build -t owcs/1-$i:latest $i
fi

done
