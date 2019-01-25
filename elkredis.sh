#!/bin/bash

yum update -y
yum -y install git

## install java 1.8
yum -y remove java-1.7.0-openjdk*
yum -y install java-1.8.0-openjdk*

## install docker
amazon-linux-extras install docker
yum install docker -y
usermod -a -G docker ec2-user
service docker start

# install docker-compose
curl -L "https://github.com/docker/compose/releases/download/1.23.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

## pull redis image
docker pull redislabs/rejson
docker run --name ec2-redis -d -p 6379:6379 redislabs/rejson
echo "alias redis-cli='docker exec -it ec2-redis redis-cli'" >> /etc/profile
echo "alias redis-cli--raw='docker exec -it ec2-redis redis-cli --raw'" >> /etc/profile

sleep 3


#free the memory
freeMemory()
{
  sh -c 'echo 1 >/proc/sys/vm/drop_caches'
  sh -c 'echo 2 >/proc/sys/vm/drop_caches'
  sh -c 'echo 3 >/proc/sys/vm/drop_caches'
}


## setup ELK+Grafana
cd ~
mkdir ELK
cd ELK

# Elasticsearch
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-6.5.4.tar.gz
sleep 3
tar -zxvf elasticsearch-6.5.4.tar.gz
sleep 10
rm -rf elasticsearch-6.5.4.tar.gz


#free the memory
freeMemory

# Kibana
wget https://artifacts.elastic.co/downloads/kibana/kibana-6.5.4-linux-x86_64.tar.gz
sleep 3
tar -zxvf kibana-6.5.4-linux-x86_64.tar.gz
sleep10
rm -rf kibana-6.5.4-linux-x86_64.tar.gz


#free the memory
freeMemory

# Metricbeat
wget https://artifacts.elastic.co/downloads/beats/metricbeat/metricbeat-6.5.4-linux-x86_64.tar.gz
sleep3
tar -zxvf metricbeat-6.5.4-linux-x86_64.tar.gz
sleep 10
rm -rf metricbeat-6.5.4-linux-x86_64.tar.gz


#free the memory
freeMemory

# Grafana
wget https://dl.grafana.com/oss/release/grafana-5.4.3.linux-amd64.tar.gz
sleep 3
tar -zxvf grafana-5.4.3.linux-amd64.tar.gz
sleep 10
rm -rf grafana-5.4.3.linux-amd64.tar.gz

#free the memory
freeMemory

# setuo PATH
export PATH="$PATH:/root/ELK/elasticsearch-6.5.4/bin"
export PATH="$PATH:/root/ELK/kibana-6.5.4-linux-x86_64/bin"
export PATH="$PATH:/root/ELK/metricbeat-6.5.4-linux-x86_64"
export PATH="$PATH:/root/ELK/grafana-5.4.3/bin"

## pull line chatbot from github
cd ~
git clone https://github.com/uuboyscy/NobodyChatbot.git
sleep 5
chmod 777 -R NobodyChatbot


#free the memory
freeMemory
