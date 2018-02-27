#!/bin/bash
host_conf=$1
properties_file=$2
read_file=$host_conf
read_file=$properties_file
remote_dir="my-projects/demo2"
exit_code=0
exit_message=""

if [ $# -lt 2 ];then
 echo "This scripts needs 2 arguments to run (host configuration file and yml file)" >&2
 exit 1
fi

# read a file to verify it exists and size gt 0

function read_file {
  if [ ! -s $1 ]; then
    echo "File: ${1} is empty, please verify" >&2
    exit 1
  else
    echo "File: ${1} is OK"
  fi
}

# check host config file has correct elements number hostname ipAddress

total_elements=`wc -w ${host_conf} | awk '{print $1}'` # returns NumOfWords textName therefore awk first arg

if [ $total_elements -le 0 ]; then
  echo "Please check file ${host_conf} is correct" >&2
  exit 1
else
  echo "Total elements in ${host_conf} are: ${total_elements}"
fi

# STEP 3: copy yml file with scp
 function check_status {
    if [ $1 -eq 0 ]; then
      echo "-- OK $2"
    else
      echo "-- ERROR $2" >&2
      exit 1
    fi
 }
 function create_dir {
   echo "-- Creating remote dir ${remote_dir}"
   host_addr="${1}@${2}"
   exit_message=$(ssh ${host_addr} bash -c "'
   function get_status {
                if [ $1 -eq 0 ]; then
                        echo "remote dir created"
                        echo "0"
                else
                        echo "-- cannot create remote dir ${remote_dir}" >&2
                        exit 1
                fi
                }

   if [ ! -d $HOME/${remote_dir} ]; then
    mkdir -p $HOME/${remote_dir} && get_status $?
   fi
   '")
   check_status $exit_code $exit_message
 }

 function update_file {
        echo "Here"
        # exit_code=$(ssh ${host_addr} bas -c "'
        #       env | grep -i
        # '")
 }

 function copy_file {
    echo "-- Copying ${properties_file}"
        exit_code=$(ssh ${host_addr} bash -c "'
                function get_status {
                        if [ ! $1 -eq 0 ]; then
                                echo "-- ERR: cannot update ${properties_file}" >&2
                                exit 1
                        fi
                        }


                if [ -s $HOME/${remote_dir}/${properties_file} ]; then
                        date_file=`grep -i "date" ${file_path} | cut -d: -f2`
                        sed -i 's/${date_file}/`date +%Y-%m-%d`/' ${file_path} && get_status $?
                        time_file=`grep -i "time" ${file_path} | cut -d: -f2 | awk '{print $1}'`
                        sed -i 's/${time_file}/`date +%T`/' ${file_path} && get_status $?
                        echo "0"

                else
                        echo "1"
                fi
        '")
        echo "Exit code for copy_file is: $exit_code"
        if [ $exit_code == 1 ]; then
                echo "Copying new ${properties_file} to remote"
                scp ${properties_file} ${host_addr}:${HOME}/${remote_dir}
                check_status $?
                update_file $file_path
        else
                echo "Updates to existing ${properties_file}"
                check_status $exit_code
        fi
 }

 total_lines=`wc -l ${host_conf} | awk '{print $1}'`
 i=1
for i in $total_lines; do
   current_line=`sed -n -e ${i}p ${host_conf}`
   host_user=`echo $current_line | awk '{print $1}'`
   ip_add=`echo $current_line | awk '{print $2}'`
   echo "-- Host is: $host_user and ip is $ip_add"
   create_dir $host_user $ip_add &&
   copy_file $properties_file
done