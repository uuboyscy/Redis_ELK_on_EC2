
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

## setup ELK+Grafana
cd ~
mkdir ELK
cd ELK

# Elasticsearch
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-6.5.4.tar.gz
tar -zxvf elasticsearch-6.5.4.tar.gz
rm -rf elasticsearch-6.5.4.tar.gz

# Kibana
wget https://artifacts.elastic.co/downloads/kibana/kibana-6.5.4-linux-x86_64.tar.gz
tar -zxvf kibana-6.5.4-linux-x86_64.tar.gz
rm -rf kibana-6.5.4-linux-x86_64.tar.gz

# Metricbeat
wget https://artifacts.elastic.co/downloads/beats/metricbeat/metricbeat-6.5.4-linux-x86_64.tar.gz
tar -zxvf metricbeat-6.5.4-linux-x86_64.tar.gz
rm -rf metricbeat-6.5.4-linux-x86_64.tar.gz

# Grafana
wget https://dl.grafana.com/oss/release/grafana-5.4.3.linux-amd64.tar.gz
tar -zxvf grafana-5.4.3.linux-amd64.tar.gz
rm -rf grafana-5.4.3.linux-amd64.tar.gz

# setuo PATH
export PATH="$PATH:/root/ELK/elasticsearch-6.5.4/bin"
export PATH="$PATH:/root/ELK/kibana-6.5.4-linux-x86_64/bin"
export PATH="$PATH:/root/ELK/metricbeat-6.5.4-linux-x86_64"
export PATH="$PATH:/root/ELK/grafana-5.4.3/bin"

## pull line chatbot from github
cd ~
git clone https://github.com/uuboyscy/NobodyChatbot.git
chmod 777 -R NobodyChatbot



