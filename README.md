# ansibledb_api_opensource

ansibledb_api_opensource is a simple mongoDB that stores ansible 'setup' JSON files. Once **ansibledb_api_opensource** has been setup, go over to our ansibledb-opensource collection on Ansible galaxy and configure it to point to your ansibledb_API_opensource server.

**You can find the Galaxy collection here: https://galaxy.ansible.com/apidb/ansibledb_opensource**.

This makes it very easy to collect and store all your server facts and retrieve them using the API and JQ.

The ansibledb_API_opensource Server recieves requests from Ansible and offers an end point to get your data.

## Installation
We have 2 options for installation. You can install it on a standalone VM/server or download and run the docker image.

-------------------------------------------------------------------

## Installation on a VM/Server
<details>
 <summary>Expand for details</summary>
  <p>
   
One Line Install
```bash
wget -O - https://get.apidb.io/ansibledb_opensource | bash
```

<details>
 <summary>Expand for manual setup per OS</summary>
  <p>
    
Clone the Repository
```bash
$ git clone https://github.com/apidb-io/ansibledb_api_opensource.git
$ cd ansibledb_api_opensource/
```

## Install python3 and requirements

### YUM based Insturctions:
```bash
$ yum install python3
$ pip3 install -r requirements.txt
```

#### Install MongoDB Server (Community) from:
```url
https://www.mongodb.com/try/download/community
```

#### Example: Centos 8 (Mongo version 4.4)
```bash
wget https://repo.mongodb.org/yum/redhat/8/mongodb-org/4.4/x86_64/RPMS/mongodb-org-server-4.4.3-1.el8.x86_64.rpm
yum localinstall mongodb-org-server-4.4.3-1.el8.x86_64.rpm
systemctl start mongod 
systemctl enable mongod
systemctl status mongodb
```


### APT based Instructions:
```bash
$ apt-get update
$ apt install python3 python3-pip
$ pip3 install -r requirements.txt
```

#### Install MongoDB Server (Community) from:
```url
https://www.mongodb.com/try/download/community
```

#### Example: Ubuntu 18.04 (Mongo version 3.6)
```bash
apt install mongodb
systemctl enable --now mongodb
systemctl status mongodb
```
</p></details>

<details>
 <summary>Expand for ansible setup to collect facts</summary>
  <p>
AnsibleDB will listen on port :5000. If you are running AnsibleDB on a remote server, remember to open up the FW to allow traffic on that port. If you're testing it out and running it on localhost, you'll be fine. You can always run this in the background ````nohup python3 server.py &````

```bash
python3 server.py
````

### Check port :5000 is listening:
````
$ netstat -tnlp
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name
tcp        0      0 0.0.0.0:5000            0.0.0.0:*               LISTEN      19421/python3
tcp        0      0 127.0.0.1:27017         0.0.0.0:*               LISTEN      -
tcp        0      0 127.0.0.53:53           0.0.0.0:*               LISTEN      -
tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN      -
tcp6       0      0 :::22                   :::*                    LISTEN      -
````
  * Do you need to open the FW for port :5000 to allow remote connectivity?


## Now setup ansibledb_opensource:
ansibledb_opensource is a collection of ansible roles to collect facts from all your servers and store them in the mongoDB. With a small amount of setup, you'll be up and running.
**You can find the Galaxy collection here: https://galaxy.ansible.com/apidb/ansibledb_opensource**

### Usage
Once you've send over some data, install JQ and run the following JQ commands to pull out the data you want:

#### Get Server Versions (using JQ to filter)

Install JQ:
````
apt/yum install jq
````

Now use JQ to pull out the data you want to see.

  NOTE: ansibledb_api_IP_address = the IP or servername of where you are running mongoDB
  
#### Pull out all data:
```bash
curl -s http://ansibledb_api_IP_address:5000/api/servers | jq
````

#### List all servernames, distribution and version:
````
curl -s http://ansibledb_api_IP_address:5000/api/servers | jq '[.[] | {name:.ansible_facts.ansible_fqdn, distribution:.ansible_facts.ansible_distribution, version: .ansible_facts.ansible_distribution_version}]'
````

#### Generate a list of servernames that match a specific fact (in this case ubuntu 18.04):
````
curl -s http://ansibledb_api_IP_address:5000/api/servers | jq --arg INPUT "$INPUT" -r '.[] | select(.ansible_facts.ansible_distribution_version | tostring | contains("18.04")) | (.ansible_facts.ansible_fqdn+"\"")'
````

#### Count all OS distributions:
````
curl -s http://ansibledb_api_IP_address:5000/api/servers | jq  "group_by(.ansible_facts.ansible_distribution_version) | map({([0].ansible_facts.ansible_distribution_version):length})"
````

#### (custom local fact) List all Instance types:
````
curl -s http://54.75.0.84:5000/api/servers | jq  "group_by(.ansible_facts.ansible_local.local.local_facts.instance_type) | map({(.[0].ansible_facts.ansible_local.local.local_facts.instance_type):length})"
````

## How to clear all data out of mongodb
if you get into issues with the database, run the following to clear out all data from mongodb and start again:
````
$ ssh mongodb_server
$ mongo ansibledb --eval 'db.servers.drop()'
MongoDB shell version v3.6.3
connecting to: mongodb://127.0.0.1:27017/ansibledb
MongoDB server version: 3.6.3
true
````

## Production
In order to use this in production, we suggest using uwsgi and something like nginx in front of it.

CentOS 7
```url
https://www.digitalocean.com/community/tutorials/how-to-serve-flask-applications-with-uwsgi-and-nginx-on-centos-7
``` 
Ubuntu 20
```url
https://www.digitalocean.com/community/tutorials/how-to-serve-flask-applications-with-uwsgi-and-nginx-on-ubuntu-20-04
```

</p></details>

</p></details>

-------------------------------------------------------------------

## Container Image Installation
<details>
 <summary>Expand for details</summary>
  <p>

<details>
 <summary>Docker setup</summary>
  <p>
   
### Pre-reqs
  * Install [Docker](https://docs.docker.com/engine/install/) for your OS distribution
  * Install [Docker-compose](https://docs.docker.com/compose/install/) for your Linux Distribution

Once you have the pre-reqs in place, create this docker-compose.yml file or download it [here](https://github.com/apidb-io/ansibledb_api_opensource/raw/master/docker-compose.yaml):
````
version: '3.7'
services:
  mongodb:
    image: mongo:latest
    environment:
      MONGO_INITDB_ROOT_USERNAME: root
      MONGO_INITDB_ROOT_PASSWORD: rootpassword
    ports:
      - 27017:27017
    volumes:
      - mongodb_data_container:/data/db

  ansibledb_opensource:
    image: apidb/ansibledb_opensource
    ports:
      - 443:443
    environment:
      MONGOHOST: mongodb
      MONGO_USERNAME: root
      MONGO_PASSWORD: rootpassword

volumes:
  mongodb_data_container:
````

Now, from the same directory, run the docker compose command:
````
docker-compose up -d
````
This command will pull down the image from DockerHub and run the image in the background. Thats it. You can check the port is listening on port 8080 using ````netstat -tnlp````.

</p></details>

<details>
 <summary>Expand for ansible setup to collect facts</summary>
  <p>
   
## Now setup ansibledb_opensource:
ansibledb_opensource is a collection of ansible roles to collect facts from all your servers and store them in the mongoDB. With a small amount of setup, you'll be up and running.
**You can find the Galaxy collection here: https://galaxy.ansible.com/apidb/ansibledb_opensource**

FOLLOW THE README.md ON THE ANSIBLE-GALAXY PAGE.

### Usage
Once you've send over some data, install JQ and run the following JQ commands to pull out the data you want:

#### Get Server Versions (using JQ to filter)

Install JQ:
````
apt/yum install jq
````

Now use JQ to pull out the data you want to see.

  NOTE: ansibledb_api_IP_address = the IP or servername of where you are running mongoDB
  
#### Advice on the dataset
To limit access to the API, you can create a copy of the data in a json format and just run your queries against that. 
I.E:
````
curl -s http://AnsibleDB_IP:8080/api/servers > dataset.json
````
Now you can just query this Dataset instead of always using the API.

Alternatively, you can still access the data via the API like this.
```bash
curl -s http://ansibledb_api_IP_address:8080/api/servers | jq
````
### Examples:
Here are some examples to pull out interesting pieces of information.

#### pull out the whole dataset
``cat dataset.json | jq``

#### List all servernames, distribution and OS version:
``cat dataset.json | jq '[.[] | {name:.ansible_facts.ansible_fqdn, distribution:.ansible_facts.ansible_distribution, version: .ansible_facts.ansible_distribution_version}]'``

#### List all servernames, distribution and kernel version:
``cat dataset.json | jq '[.[] | {name:.ansible_facts.ansible_fqdn, distribution:.ansible_facts.ansible_distribution, version: .ansible_facts.ansible_kernel}]'``

#### List and count all OS types:
``cat dataset.json | jq  "group_by(.ansible_facts.ansible_distribution_version) | map({(.[0].ansible_facts.ansible_distribution_version):length})"``

#### Generate a list of servernames that match a specific fact (in this case ubuntu 18.04):
``cat dataset.json | jq --arg INPUT "$INPUT" -r '.[] | select(.ansible_facts.ansible_distribution_version | tostring | contains("18.04")) | (.ansible_facts.ansible_fqdn)'``


## Custom facts
If you want to collect custom facts, I've created some ansible code to do this for you. You can find the custom extensions code [here](https://github.com/apidb-io/custom_extensions). I've set them up to collect certain facts from different OS's. These are fully customisable by yourself.

** Whenever you refresh the facts (run ansible again) you must update the dataset otherwise you'll setill be looking at old data. IF you go direct to the API, you can ignore this.

#### if you've generated local facts, access them like this:
``cat dataset.json | jq -r '.[].ansible_facts.ansible_local.local'``

#### And to get to specific region (custom) facts:
``cat dataset.json | jq -r '.[].ansible_facts.ansible_local.local.local_facts.avail_zone'``

#### And to get to specific region (custom) facts (COUNT):
``cat dataset.json | jq  "group_by(.ansible_facts.ansible_local.local.local_facts.avail_zone) | map({(.[0].ansible_facts.ansible_local.local.local_facts.avail_zone):length})"``

#### Generate a list of servers in a particular region:
``cat dataset.json | jq --arg INPUT "$INPUT" -r '.[] | select(.ansible_facts.ansible_local.local.local_facts.avail_zone | tostring | contains("ap-south-1")) | (.ansible_facts.ansible_fqdn)'``

#### List All AWS Instance types and totals:
``cat dataset.json | jq  "group_by(.ansible_facts.ansible_local.local.local_facts.instance_type) | map({(.[0].ansible_facts.ansible_local.local.local_facts.instance_type):length})"``

#### Generate a list of instance type and region?
``cat dataset.json | jq 'group_by(.ansible_facts.ansible_local.local.local_facts.instance_type) | map({region: map(.ansible_facts.ansible_local.local.local_facts.avail_zone) | unique, (.[0].ansible_facts.ansible_local.local.local_facts.instance_type): map(.ansible_facts.ansible_local.local.local_facts.instance_type) | length})'``

</p></details>


-------------------------------------------------------------------

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.

## License
[GNU](https://choosealicense.com/licenses/gpl-3.0/)
