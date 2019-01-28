#!/bin/bash
set -x
#set -n

yum update -y
yum -y install git

username="ec2-user"

## install java 1.8
yum -y remove java-1.7.0-openjdk*
yum -y install java-1.8.0-openjdk*

## install docker
amazon-linux-extras install docker
yum install docker -y
usermod -a -G docker $username
service docker start

# install docker-compose
curl -L "https://github.com/docker/compose/releases/download/1.23.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

## pull redis image
docker pull redislabs/rejson
docker run --name ec2-redis -d -p 6379:6379 redislabs/rejson

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
sleep 15
tar -zxvf elasticsearch-6.5.4.tar.gz
sleep 20
rm -rf elasticsearch-6.5.4.tar.gz
# bind IP
sed -i 's/#network.host: 192.168.0.1/network.host: 0.0.0.0/g' /root/ELK/elasticsearch-6.5.4/elasticsearch.yml

#free the memory
freeMemory

# setup memory setting that starting need
cd /root/ELK/elasticsearch-6.5.4/config
sed -i 's/-Xmx1g/-Xmx512m/g' jvm.options
sed -i 's/-Xms1g/-Xms512m/g' jvm.options
cd ~/ELK

#free the memory
freeMemory

# Kibana
wget https://artifacts.elastic.co/downloads/kibana/kibana-6.5.4-linux-x86_64.tar.gz
sleep 30
tar -zxvf kibana-6.5.4-linux-x86_64.tar.gz
sleep 90
rm -rf kibana-6.5.4-linux-x86_64.tar.gz

#free the memory
freeMemory

# Metricbeat
wget https://artifacts.elastic.co/downloads/beats/metricbeat/metricbeat-6.5.4-linux-x86_64.tar.gz
sleep 10
tar -zxvf metricbeat-6.5.4-linux-x86_64.tar.gz
sleep 20
rm -rf metricbeat-6.5.4-linux-x86_64.tar.gz


#free the memory
freeMemory

# Grafana
wget https://dl.grafana.com/oss/release/grafana-5.4.3.linux-amd64.tar.gz
sleep 10
tar -zxvf grafana-5.4.3.linux-amd64.tar.gz
sleep 20
rm -rf grafana-5.4.3.linux-amd64.tar.gz

#free the memory
freeMemory

# append server.host: "0.0.0.0" and elasticsearch.url: "http://localhost:9200" to kibana.yml
echo "server.host: \"0.0.0.0\"" >> /root/ELK/kibana-6.5.4-linux-x86_64/config/kibana.yml
echo "elasticsearch.url: \"http://localhost:9200\"" >> /root/ELK/kibana-6.5.4-linux-x86_64/config/kibana.yml

# change owner
chown -R $username elasticsearch-6.5.4/
chown -R $username kibana-6.5.4-linux-x86_64
chown -R $username metricbeat-6.5.4-linux-x86_64
chown -R $username grafana-5.4.3.linux-amd64

# setuo PATH
echo "export PATH=\"\$PATH:/root/ELK/elasticsearch-6.5.4/bin\"" >> /etc/profile
echo "export PATH=\"\$PATH:/root/ELK/kibana-6.5.4-linux-x86_64/bin\"" >> /etc/profile
echo "export PATH=\"\$PATH:/root/ELK/metricbeat-6.5.4-linux-x86_64\"" >> /etc/profile
echo "export PATH=\"\$PATH:/root/ELK/grafana-5.4.3/bin\"" >> /etc/profile

## pull line chatbot from github
cd ~
git clone https://github.com/uuboyscy/NobodyChatbot.git
sleep 5
# change owner
chown -R $username NobodyChatbot/
chown -R $username /root
chmod 777 -R NobodyChatbot
cd NobodyChatbot
docker-compose up -d
sleep 60
docker-compose down
sleep 5

#free the memory
freeMemory

#setup swap space
dd if=/dev/zero of=/swapfile bs=1M count=1024
sleep 10
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
sleep 10
echo "/swapfile swap swap defaults 0 0" >> /etc/fstab

# set alias
echo "alias freemem=\"sudo sh -c 'echo 1 >/proc/sys/vm/drop_caches';sudo sh -c 'echo 2 >/proc/sys/vm/drop_caches';sudo sh -c 'echo 3 >/proc/sys/vm/drop_caches'\"" >> /etc/profile
echo "alias redis-cli='docker exec -it ec2-redis redis-cli'" >> /etc/profile
echo "alias redis-cli--raw='docker exec -it ec2-redis redis-cli --raw'" >> /etc/profile
echo "alias chatbot-start='docker-compose -f /root/NobodyChatbot/docker-compose.yml up --build -d;sleep 3;\
  sh /root/NobodyChatbot/ngurl.sh'" >> /etc/profile
echo "alias chatbot-stop='docker-compose -f /root/NobodyChatbot/docker-compose.yml down'" >> /etc/profile
echo "alias ngrok-url='sh /root/NobodyChatbot/ngurl.sh'"

source /etc/profile
