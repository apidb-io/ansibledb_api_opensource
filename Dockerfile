FROM python:3.8-alpine

WORKDIR /app

COPY requirements.txt requirements.txt

COPY ansibledb.crt ansibledb.crt
COPY ansibledb.key ansibledb.key 

RUN pip3 install -r requirements.txt
COPY . .
ENTRYPOINT ["sh","entrypoint.sh"]
