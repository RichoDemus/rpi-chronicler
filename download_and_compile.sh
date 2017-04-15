#!/bin/bash

if [ -z "$1" ]
then
  echo "please submit which commit to build"
  exit -1
fi

rm -r output
mkdir -p output/build/dependencies

#from http://stackoverflow.com/a/246128
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

commit=$1
curl -L -o code.zip https://github.com/richodemus/chronicler/archive/${commit}.zip
unzip code.zip

# For some reason https doesn't work, some SSL Exception
# sed -i 's/https/http/g' chronicler*/gradle/wrapper/gradle-wrapper.properties

eval "(cd chronicler*/ && ./gradlew copyDependencies)"

cp -r chronicler*/server/docker/build/dependencies/* output/build/dependencies/
cp chronicler*/server/docker/config.yaml output/
cp chronicler*/server/docker/Dockerfile output/

sed -i 's/FROM.*/FROM rpi-java8:latest/g' output/Dockerfile
docker build --tag richodemus/rpi-chronicler:latest output/

rm -r chronicler*/
rm code.zip

