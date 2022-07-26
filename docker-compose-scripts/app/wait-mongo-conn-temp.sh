#!/bin/bash

echo "loading mongo secrets..."
#load mongo secrets
. /secrets/mongo/mongo.secrets

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% MONGODB TEMP START %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

#wait for mongodb to start and be ready,ie auth-mode started
echo "mongodb ==================================================>XXXXXXXXXXXXXXXXXXXXXXstart"

echo "install gnupg..."
# install gnupg
apt-get install -y gnupg

echo "install wget..."
# install gnupg
apt-get install -y wget

echo "import the MongoDB public GPG..."
# import the MongoDB public GPG
wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | apt-key add -

echo "Create a list file for MongoDB..."
# Create a list file for MongoDB.
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/6.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-6.0.list

echo "update apt-get..."
#update apt-get
apt-get update -y

echo "install mongodb..."
#install mongodb
apt-get install -y mongodb-org

echo "mkdir /data/db for mongodb"
mkdir /data
mkdir /data/db

echo "start mongodb..."
#start mongodb
/usr/bin/mongod --dbpath /data/db & #the & sends it to background


#waiting for mongosh to start & be ready
until mongosh --eval "print(\"waited for connection\")"
  do
    echo "waiting mongosh conn....."
    sleep 5
  done

#check if the 3rd replica set member has been set
echo "======================================================>check if the 3rd replica set member has been set"
until false
  do
    echo '=====================> replica set 3 checking...'
    REPLICASET_UP="false"
    LOCALRES=$(mongosh "mongodb://${MONGODB_ROOT_USERNAME}:${MONGODB_ROOT_PASSWORD}@${MONGODB1}:27017" --eval "rs.status()" 2>&1)
    echo $LOCALRES

    #check for a response containing mongo3
    case "$LOCALRES" in 
    *"${MONGODB3}"* ) REPLICASET_UP="true";;
    *) REPLICASET_UP="false";
    esac
    if [ $REPLICASET_UP = "true" ]; 
        then
        sleep 10 # this is to allow the primary server to restart and initialize the secondary dbs
        break
    fi
    
    sleep 5
  done


#check if primary db is ready by ensuring ther response is not MongoNetworkError:
echo "======================================================>check if primary db is ready"
until false
  do
    echo '=====================> checking primay db...'
    MONGODB3UP="false"
    LOCALRES=$(mongosh "mongodb://${MONGODB1}:27017" --eval "db.stats()" 2>&1)
    echo $LOCALRES

    #check for all responses that is not MongoNetworkError to confirm the server is up
    case "$LOCALRES" in 
    *"MongoNetworkError"* ) MONGODB3UP="false";;
    *) MONGODB3UP="true";
    esac
    if [ $MONGODB3UP = "true" ]; 
        then
        break
    fi
    
    sleep 5
  done

#shut down the mongodb
echo "======================================================>shut down the mongodb"
/usr/bin/mongod --shutdown

#uninstall mongodb
echo "======================================================>uninstall mongodb"
apt-get purge -y mongodb-org*
rm -r /var/log/mongodb
rm -r /var/lib/mongodb
rm -r /data

# uninstall mongodb
echo "mongodb ==================================================>XXXXXXXXXXXXXXXXXXXXXXend"
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% MONGODB TEMP END %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
