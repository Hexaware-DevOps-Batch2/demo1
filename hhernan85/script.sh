#!/bin/bash
DIRECTORY="~/my-projects/demo2"
PROPERTIESFILE="properties.txt"
SERVER="ubuntu@ec2-18-219-236-181.us-east-2.compute.amazonaws.com"
KEY="trainingubuntukeypair.pem"
APPFILE="application.yml"
CREATED=true
TRANSFERED=true
UPDATED=false
WRITTEN=true

function createDirectory(){
    ssh -i $KEY $SERVER "mkdir -p $DIRECTORY"
	if [ "$?" -eq "0" ];
		then
			echo "Directory created"
		else
			CREATED=false
	fi
}
function transferFile(){
	if ssh -i $KEY $SERVER '[ -e $DIRECTORY/$APPFILE ]'
	then
		UPDATED=true
	fi
	
    scp -i $KEY application.yml $SERVER:$DIRECTORY
	if [ "$?" -eq "0" ];
		then
			echo "File transfered"
		else
			TRANSFERED=false
	fi
}
function changeFilePerm(){
	ssh -i $KEY $SERVER "chmod -R 744 $DIRECTORY/$APPFILE"
	
}

function writeEnvProperties(){

	local NEW=$(ssh -i $KEY $SERVER "env |grep '${1}'|cut -d'=' -f2") 
    #local OLD=$(ssh -i $KEY $SERVER "cat $DIRECTORY/$APPFILE |grep '${2}'|cut -d':' -f1") 
	local OLD=$(ssh -i $KEY $SERVER "cat $DIRECTORY/$APPFILE |grep '${2}'") 
    ssh -i $KEY $SERVER "sed -i 's?$OLD?'${2}':$NEW?g' $DIRECTORY/$APPFILE" 
	if [ "$?" -eq "0" ];
		then
			echo "Env property replaced"
	fi
	#sed -i 's/$OLD/"${2}":$NEW/g' $DIRECTORY/$APPFILE
}
function writeDateProperties(){

	local NEW=$(ssh -i $KEY $SERVER "date +"%y-%m-%d"") 
    #local OLD=$(ssh -i $KEY $SERVER "cat $DIRECTORY/$APPFILE |grep '${2}'|cut -d':' -f1") 
	local OLD=$(ssh -i $KEY $SERVER "cat $DIRECTORY/$APPFILE |grep '${1}'") 
    ssh -i $KEY $SERVER "sed -i 's/$OLD/'${1}':$NEW/g' $DIRECTORY/$APPFILE" 
	#sed -i 's/$OLD/"${2}":$NEW/g' $DIRECTORY/$APPFILE
}
function writeTimeProperties(){

	local NEW=$(ssh -i $KEY $SERVER "date +"%T"") 
    #local OLD=$(ssh -i $KEY $SERVER "cat $DIRECTORY/$APPFILE |grep '${2}'|cut -d':' -f1") 
	local OLD=$(ssh -i $KEY $SERVER "cat $DIRECTORY/$APPFILE |grep '${1}'") 
    ssh -i $KEY $SERVER "sed -i 's/$OLD/'${1}':$NEW/g' $DIRECTORY/$APPFILE" 
	#sed -i 's/$OLD/"${2}":$NEW/g' $DIRECTORY/$APPFILE
}

function writePathProperties(){

	local NEW=$(ssh -i $KEY $SERVER "pwd") 
	#sed 's?#REPLACE-WITH-PATH?'`pwd`'?'
    #local OLD=$(ssh -i $KEY $SERVER "cat $DIRECTORY/$APPFILE |grep '${2}'|cut -d':' -f1") 
	local OLD=$(ssh -i $KEY $SERVER "cat $DIRECTORY/$APPFILE |grep '${1}'") 
    ssh -i $KEY $SERVER "sed -i 's?$OLD?'${1}':${NEW}?g' $DIRECTORY/$APPFILE" 
	#sed -i 's/$OLD/"${2}":$NEW/g' $DIRECTORY/$APPFILE
}

function writeiPProperties(){

	local NEW=$(ssh -i $KEY $SERVER "hostname -i") 
    #local OLD=$(ssh -i $KEY $SERVER "cat $DIRECTORY/$APPFILE |grep '${2}'|cut -d':' -f1") 
	local OLD=$(ssh -i $KEY $SERVER "cat $DIRECTORY/$APPFILE |grep '${1}'") 
    ssh -i $KEY $SERVER "sed -i 's/$OLD/'${1}':$NEW/g' $DIRECTORY/$APPFILE" 
	#sed -i 's/$OLD/"${2}":$NEW/g' $DIRECTORY/$APPFILE
}

function writeHostProperties(){

	local NEW=$(ssh -i $KEY $SERVER "hostname") 
    #local OLD=$(ssh -i $KEY $SERVER "cat $DIRECTORY/$APPFILE |grep '${2}'|cut -d':' -f1") 
	local OLD=$(ssh -i $KEY $SERVER "cat $DIRECTORY/$APPFILE |grep '${1}'") 
    ssh -i $KEY $SERVER "sed -i 's/$OLD/'${1}':$NEW/g' $DIRECTORY/$APPFILE" 
	#sed -i 's/$OLD/"${2}":$NEW/g' $DIRECTORY/$APPFILE
}
#netstat -vatn | grep ESTABLISHED
function writePortProperties(){

	local NEW=$(ssh -i $KEY $SERVER "netstat -vatn | grep ESTABLISHED | cut -d':' -f2  | cut -d ' ' -f 1") 
    echo $NEW 
	local OLD=$(ssh -i $KEY $SERVER "cat $DIRECTORY/$APPFILE |grep '${1}'") 
    ssh -i $KEY $SERVER "sed -i 's/$OLD/'${1}':$NEW/g' $DIRECTORY/$APPFILE" 
	#sed -i 's/$OLD/"${2}":$NEW/g' $DIRECTORY/$APPFILE
}


createDirectory

if ssh -i $KEY $SERVER '[ -d $DIRECTORY ]'
then
  transferFile
  if ssh -i $KEY $SERVER '[ -e $DIRECTORY/$APPFILE ]'
  then
	
	#server
	writeiPProperties address
	#writePortProperties port
	writeHostProperties hostname
	writeDateProperties date
	writeTimeProperties time
	writePathProperties contextPath

	#environment
	writeEnvProperties USER username
	writeEnvProperties HOME homeDirectory
	writeEnvProperties LANG lang
	changeFilePerm
   fi
fi

#if [[$CREATED -eq "true"]] && [[ $TRANSFERED -eq "true" ]]

#print results
#ip-address:{Success|Fail}:Success?{new|update}:FailReason|date time