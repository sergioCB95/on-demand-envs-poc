#!/usr/bin/env bash
set -x
apt-get update -y

echo "installing git"
apt-get install -y git
/usr/bin/yum install -y git

echo "installing NodeJS"
curl --silent --location https://rpm.nodesource.com/setup_16.x | bash -
yum -y install nodejs


echo "cloning repo"
mkdir /app
git clone "https://github.com/sergioCB95/on-demand-envs-poc.git" /app
cd /app/${APP_DIR}

export DB_URL="${DB_URL}"

echo "installing npm packages"
make install

echo "running the app"
make start
