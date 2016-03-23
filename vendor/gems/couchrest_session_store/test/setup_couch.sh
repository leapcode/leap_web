HOST="http://localhost:5984"
echo "couch version :"
curl -X GET $HOST

curl -X PUT $HOST/couchrest_sessions
curl -X PUT $HOST/couchrest_sessions/_design/Session --data @design/Session.json

