#!/bin/bash
hn=$hostname

funcValidateFile(){
  file="/Users/jaimegutierrez/Desktop/bashTestFiles/application_2.yml"
  if [ ! -f "$file" ]
  then
      echo "$0: File '${file}' not found."
      exit
  else
   echo "processing file.."
  fi
}

funcReadFile(){
   echo "File $file  found it" >&2
   sed -i -e 's/hola/adios/g' /Users/jaimegutierrez/Desktop/bashTestFiles/application_2.yml
}

function main(){
  
  funcValidateFile
  funcReadFile

 }

main
