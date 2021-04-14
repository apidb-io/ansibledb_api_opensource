mongo_install()
{

apt-get install gnupg
wget -qO - https://www.mongodb.org/static/pgp/server-4.4.asc | sudo apt-key add -

if [[ $osversion = 18* ]]; then
	echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/4.4 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.4.list
  elif [[ $osversion = 20* ]]; then
	echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/4.4 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.4.list
  else
    echo "Unknown Version"
    exit 1
  fi

apt-get update
apt-get install -y mongodb-org

}


packages()
{
  apt-get install -y python3-pip git python3
}

mongo_services()
{
  systemctl enable --now mongod
}


