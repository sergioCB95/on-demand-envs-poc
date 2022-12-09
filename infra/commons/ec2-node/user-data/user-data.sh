#!/usr/bin/env bash
set -x
apt-get update -y

echo "installing git"
apt-get install -y git
/usr/bin/yum install -y git

echo "cloning repo"
mkdir /app
git clone "https://github.com/sergioCB95/on-demand-envs-poc.git" /app
cd /app/$APP_DIR

echo "installing npm packages"
make install

echo "running the app"
make start
