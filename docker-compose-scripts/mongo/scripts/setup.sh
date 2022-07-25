#!/bin/bash

#mongodb clusters/replica set
MONGODB_REPLICA_SET_NAME=bnbjumbo-mongo-set
MONGODB1=mongo1
MONGODB2=mongo2
MONGODB3=mongo3

#mongodb users
MONGODB_APP_DATABASE=bnbjumbo
MONGODB_ROOT_USERNAME=jwnrcl50
MONGODB_ROOT_PASSWORD=j4w1n6r5c8l450
MONGODB_NORMAL_USER_USERNAME=jwbjd50
MONGODB_NORMAL_USER_PASSWORD=j9w1b6jd450


waitMongoshToStart(){
until mongosh --eval "print(\"$1\")"
do
  echo "waiting mongosh conn....."
  sleep 5
done
}

waitForMongoDbServerInit(){
until false
do
  echo $2
  MONGODBUP="false"
  LOCALRES=$(mongosh "mongodb://$1:27017" --eval "db.stats()" 2>&1)

  #check for all responses that is not MongoNetworkError to confirm the server is up
  case "$LOCALRES" in 
  *"MongoNetworkError"* ) MONGODBUP="false";;
  *) MONGODBUP="true";
  esac
  if [ $MONGODBUP = "true" ]; 
      then
      break
  fi
  
  sleep 5
done 
}


echo "======================================================>starting mongoddb in non-auth mode with replication in background"
#start mongodb in non-auth mode
/usr/bin/mongod --bind_ip_all --replSet bnbjumbo-mongo-set --journal --dbpath /data/db & #the & sends it to background


#waiting for mongosh to start & be ready
waitMongoshToStart "waited for mongosh connection loop"


#check if replica set 2 is ready by ensuring ther response is not MongoNetworkError:
echo "======================================================>polling for replica-set-2 to start"
waitForMongoDbServerInit ${MONGODB2} "=====================> replica set 2 checking"


#check if replica set 3 is ready by ensuring ther response is not MongoNetworkError:
echo "======================================================>polling for replica-set-3 to start"
waitForMongoDbServerInit ${MONGODB3} "=====================> replica set 3 checking"
    

#initialize replication,register primary
echo "======================================================>Intializing replication and register primary"
mongosh --port 27017 <<EOF
var cfg = {
    "_id": "${MONGODB_REPLICA_SET_NAME}",
    "protocolVersion": 1,
    "version": 1,
    "members": [
        {
            "_id": 0,
            "host": "${MONGODB1}:27017",
            "priority": 2
        }
    ],settings: {chainingAllowed: true}
};
rs.initiate(cfg, { force: true });
rs.status();
rs.reconfig(cfg, { force: true });
rs.setReadPref("primaryPreferred");
db.getMongo().setReadPref('nearest');
EOF


#create admin user
echo "======================================================>creating admin mongodb user"
mongosh --port 27017 <<EOF
use admin;
db.createUser(
    {
    user: "${MONGODB_ROOT_USERNAME}",
    pwd: "${MONGODB_ROOT_PASSWORD}",
    roles: [ { role: "root", db: "admin" } ]
    });
db.getSiblingDB("admin").auth("${MONGODB_ROOT_USERNAME}", "${MONGODB_ROOT_PASSWORD}");
EOF


#create normal user for a specific database
echo "======================================================>creating normal mongodb user for a specific database"
mongosh --port 27017 <<EOF
use ${MONGODB_APP_DATABASE};
db.createUser(
    {
    user: "${MONGODB_NORMAL_USER_USERNAME}",
    pwd: "${MONGODB_NORMAL_USER_PASSWORD}",
    roles: [ { role: "readWrite", db: "${MONGODB_APP_DATABASE}" } ],
    passwordDigestor: "server",
    });
    db.getSiblingDB("${MONGODB_APP_DATABASE}").auth("${MONGODB_NORMAL_USER_USERNAME}", "${MONGODB_NORMAL_USER_PASSWORD}");
EOF


echo "======================================================> chmod of replica.key"
#change file properties of the replica key
chmod 400 /keys/replica.key


echo "======================================================> shutdown mongodb"
#shut down the mongodb
/usr/bin/mongod --shutdown


echo "======================================================> start mongodb in auth-mode in background"
#start mongodb in auth mode in background
/usr/bin/mongod --bind_ip_all --replSet bnbjumbo-mongo-set --journal --dbpath /data/db --auth --keyFile /keys/replica.key & #& send it the backgroud


#waiting for mongosh to start & be ready
waitMongoshToStart "waited for mongosh connection loop  after auth initialization"


# initialize replication and attach other members
echo "======================================================>Intializing replication again and attach other members"
mongosh --port 27017 --authenticationDatabase -u ${MONGODB_ROOT_USERNAME} -p "${MONGODB_ROOT_PASSWORD}" <<EOF
rs.add( { host: "${MONGODB2}:27017", priority: 0 } );
rs.add( { host: "${MONGODB3}:27017", priority: 0 } );
rs.status();
EOF


echo "======================================================> shutdown mongodb again"
#shut down the mongodb
/usr/bin/mongod --shutdown


echo "======================================================> start mongodb in auth-mode in foreground"
#start mongodb in auth mode in foreground
/usr/bin/mongod --bind_ip_all --replSet bnbjumbo-mongo-set --journal --dbpath /data/db --auth --keyFile /keys/replica.key
