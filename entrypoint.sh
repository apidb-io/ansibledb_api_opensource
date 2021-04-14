#!/bin/bash
gunicorn server:app --certfile=ansibledb.crt --keyfile=ansibledb.key -b 0.0.0.0:443

