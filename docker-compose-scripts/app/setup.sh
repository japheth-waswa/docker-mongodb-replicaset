#!/bin/bash

#update 
apt-get update -y

#install curl
apt-get install -y curl

#install nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash

#to start using nvm immediately
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

#install nodejs LTS 
nvm install 18.6.0

#wait for mongodb connection success
chmod +x /scripts/app/wait-mongo-conn-temp.sh
/scripts/app/wait-mongo-conn-temp.sh

echo "starting node server"
npm run dev