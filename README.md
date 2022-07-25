# MONGODB REPLICASET WITH AUTH,NGINX AS REVERSE PROXY & LOAD BALANCER #

These scripts show show to use docker and setup mongodb as a replica set.You can more add more replica sets as your need arises.

Nginx is also used as a reverse proxy and load balance for a sample backend application written in node.js

### MONGODB REPLICA SET ###

We have 3 databases. 

All these databases can only be accesed by authenticated accounts. The authenticated account(s) is created on the primary database.

Mmembers in the replica set communicate through a trusted key. [Key File](https://www.mongodb.com/docs/manual/tutorial/deploy-replica-set-with-keyfile-access-control/)

You can modify the docker-compose-scripts/mongo/scripts/setup.sh file to suit your needs.

* Primary db
* 2 Secondary dbs



### How do I get set up? ###

* Summary of set up
* Configuration
* Dependencies
* Database configuration
* How to run tests
* Deployment instructions

### Contribution guidelines ###

* Writing tests
* Code review
* Other guidelines

### Who do I talk to? ###

* Repo owner or admin
* Other community or team contact