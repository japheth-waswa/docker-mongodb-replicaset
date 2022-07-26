# MONGODB REPLICASET WITH AUTH,NGINX AS REVERSE PROXY & LOAD BALANCER #

These scripts show show to use docker and setup mongodb as a replica set.You can more add more replica sets as your need arises.

Nginx is also used as a reverse proxy and load balance for a sample backend application written in node.js


### MONGODB REPLICA SET ###

We have 3 databases. 

All these databases can only be accesed by authenticated accounts. The authenticated account(s) is created on the primary database.

Members in the replica set communicate through a trusted key. [Key File](https://www.mongodb.com/docs/manual/tutorial/deploy-replica-set-with-keyfile-access-control/)

You can modify the docker-compose-scripts/mongo/scripts/setup.sh file to suit your needs.

* Primary db
* 2 Secondary dbs


### NGINX REVERSE PROXY & LOAD BALANCER ###

Edit the file ./docker-compose-scripts/nginx/nginx.conf and set your  domain name. NOTE:- replace 2246-102-219-249-59.ngrok.io with your domain name

Also change check docker-compose.yml to edit the hostname thus requiring you to edit the same in ./docker-compose-scripts/nginx/nginx.conf

You can then hit the following address for backend without nginx [Backend](http://localhost:4000/api/v1/users)

Backend with nginx [Backend](https://2246-102-219-249-59.ngrok.io/api/v1/users)  NOTE:- replace 2246-102-219-249-59.ngrok.io with your domain name
