#!/bin/bash
gunicorn server:app -b 0.0.0.0:8080 &
gunicorn server:app --certfile=ansibledb.crt --keyfile=ansibledb.key -b 0.0.0.0:443

