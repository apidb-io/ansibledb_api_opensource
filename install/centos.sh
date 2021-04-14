mongo_install()
{
  if [[ $osversion = 8* ]]; then
    yum -y localinstall https://repo.mongodb.org/yum/redhat/8/mongodb-org/4.4/x86_64/RPMS/mongodb-org-server-4.4.3-1.el8.x86_64.rpm
  elif [[ $osversion = 7* ]]; then
    yum -y localinstall https://repo.mongodb.org/yum/redhat/7/mongodb-org/4.4/x86_64/RPMS/mongodb-org-server-4.4.3-1.el7.x86_64.rpm
  else
    echo "Unknown Version"
    exit 1
  fi

}


packages()
{
  yum -y install python3 git
}

mongo_services()
{
  systemctl enable --now mongod
}

