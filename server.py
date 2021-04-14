from pymongo import MongoClient
from flask import Flask, request
from dotenv import load_dotenv
import os
import json
import ssl

app = Flask(__name__)
load_dotenv()

MONGO_HOST = os.environ.get("MONGOHOST")
MONGO_USER = os.environ.get("MONGO_USERNAME")
MONGO_PASS = os.environ.get("MONGO_PASSWORD")
MONGO_PORT=27017
MONGO_DB = "ansibledb"
uri = "mongodb://{}:{}@{}:{}/?authSource=admin".format(MONGO_USER, MONGO_PASS, MONGO_HOST, MONGO_PORT)
client = MongoClient(uri)

db = client['ansibledb']
servers = db.servers

@app.route('/api/setup')
def setup():
    servers.create_index("ansible_facts.ansible_fqdn")
    return servers.index_information()

@app.route('/api/ansiblefacts', methods=['POST'])
def ansiblefacts():
    if request.method == 'POST':
        content = json.loads(request.data)
        if 'ansible_fqdn' in content["ansible_facts"].keys():
          fqdn =  content["ansible_facts"]["ansible_fqdn"]
          servers.update({"ansible_facts.ansible_fqdn":fqdn}, {"$set": content }, True)
        if 'ansible_net_hostname' in content["ansible_facts"].keys():
          fqdn =  content["ansible_facts"]["ansible_net_hostname"]
          servers.update({"ansible_facts.ansible_net_hostname":fqdn}, {"$set": content }, True)
    return content


@app.route('/api/servers', methods=['GET'])
def ansibleservers():
    cursor = servers.find({}, {'_id': False})
    list_result = list(cursor)
    result = json.dumps(list_result,default=str)
    return result

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=443)

