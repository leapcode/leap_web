#!/bin/bash

HOST="http://localhost:5984"
echo "creating user :"
curl -HContent-Type:application/json -XPUT $HOST/_users/org.couchdb.user:me --data-binary '{"_id": "org.couchdb.user:me","name": "me","roles": [],"type": "user","password": "pwd"}'
echo "creating databases :"
curl -X PUT $HOST/sessions
curl -X PUT $HOST/users
curl -X PUT $HOST/tickets
echo "restricting database access :"
curl -X PUT $HOST/sessions/_security -Hcontent-type:application/json --data-binary '{"admins":{"names":[],"roles":[]},"members":{"names":["me"],"roles":[]}}'
curl -X PUT $HOST/users/_security -Hcontent-type:application/json --data-binary '{"admins":{"names":[],"roles":[]},"members":{"names":["me"],"roles":[]}}'
curl -X PUT $HOST/tickets/_security -Hcontent-type:application/json --data-binary '{"admins":{"names":[],"roles":[]},"members":{"names":["me"],"roles":[]}}'
echo "adding admin :"
curl -X PUT $HOST/_config/admins/anna -d '"secret"'
