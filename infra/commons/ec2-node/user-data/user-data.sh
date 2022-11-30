#!/usr/bin/env bash
set -x
apt-get update -y

echo "installing git"
apt-get install -y git
/usr/bin/yum install -y git

echo "cloning repo"
mkdir /app
git clone "" /app
cd /app/$APP_DIR

echo "installing npm packages"
npm install

echo "running the app"
make start
