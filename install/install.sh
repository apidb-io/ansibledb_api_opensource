#!/bin/bash

if ! [ $(id -u) = 0 ]; then
   echo "This script must be run as root" 
   exit 1
fi

install_folder=/opt/ansibledb_api_opensource

if [ ! -f "/etc/os-release" ]; then
    echo "/etc/os-release is not present - Exiting"
    exit 1
fi

ostype=$(cat /etc/os-release  | grep "^ID==*" | awk -F= '{print $2}'| sed 's/"//g')
osversion=$(cat /etc/os-release  | grep "^VERSION_ID==*" | awk -F= '{print $2}'| sed 's/"//g')

if [ $ostype = "centos" ] ||  [ $ostype = "rhel" ] ; then
   wget https://get.apidb.io/ansibledb_opensource_centos -O centos.sh
   source centos.sh
elif [ $ostype = "ubuntu" ]; then
   wget https://get.apidb.io/ansibledb_opensource_ubuntu -O ubuntu.sh
   source ubuntu.sh
else
  echo "OS Unknown"
  exit 1
fi


app_setup()
{
  mkdir -p $install_folder
  git clone https://github.com/apidb-io/ansibledb_api_opensource.git $install_folder
  pip3 install -r  $install_folder/requirements.txt
}

setup_complete()
{
echo ""
echo "---------------------------------------------"
echo "Now run - # python3 /opt/ansibledb_api_opensource/server.py"
echo ""
}

mongo_install
mongo_services
packages
app_setup
setup_complete
