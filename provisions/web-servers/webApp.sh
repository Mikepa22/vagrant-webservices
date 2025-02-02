#!/bin/bash

#Manage errors.
set -e

#Scope variables
ip_address=$(hostname -I | awk '{print $2}')
server_port=3000

echo "
 ___   _______  __   __      ___  _______  _______  _______  _______  ______    _______  _______  __    _  _______  ___   __    _  _______ 
|   | |   _   ||  |_|  |    |   ||       ||       ||       ||       ||    _ |  |       ||       ||  |  | ||       ||   | |  |  | ||       |
|   | |  |_|  ||       |    |   ||    ___||    ___||    ___||    ___||   | ||  |  _____||   _   ||   |_| ||    _  ||   | |   |_| ||   _   |
|   | |       ||       |    |   ||   |___ |   |___ |   |___ |   |___ |   |_||_ | |_____ |  | |  ||       ||   |_| ||   | |       ||  | |  |
|   | |       ||       | ___|   ||    ___||    ___||    ___||    ___||    __  ||_____  ||  |_|  ||  _    ||    ___||   | |  _    ||  |_|  |
|   | |   _   || ||_|| ||       ||   |___ |   |    |   |    |   |___ |   |  | | _____| ||       || | |   ||   |    |   | | | |   ||       |
|___| |__| |__||_|   |_||_______||_______||___|    |___|    |_______||___|  |_||_______||_______||_|  |__||___|    |___| |_|  |__||_______|
 " 
echo -e "\n\n🚀 Install and configure our web service in the server $ip_address... 🛠️"

echo -e "\n\nUpdating our server repo..."
sudo apt update -y && sudo apt upgrade -y

echo -e "\n\nInstalling nodeJs..."
sudo apt install nodejs -y

echo -e "\n\nInstalling and npm..."
sudo apt install npm -y

echo -e "\n\nCopying our demo nodeJs example into our server..."
sudo cp -r /home/vagrant/sharedFolder/webService /home/
sed -i "s/const HOST='.*'/const HOST='$ip_address'/" /home/webService/app/index.js
cd /home/webService/app

echo -e "\n\nInstalling express..."
sudo npm install express -y

echo -e "\n\nInstalling consul..."
sudo npm install consul

echo -e "\n\nInstalling pm2 to manage our nodejs demon....."
npm install -g pm2 -y

echo -e "\n\nStarting our nodeJs web server in the port $server_port"
pm2 start index.js --name "web-service" --watch -- $server_port

#verificar version
CONSUL_VERSION = "1.14.0"

echo "Instalando Consul..."

wget https://releases.hashicorp.com/consul/#{CONSUL_VERSION}/consul_#{CONSUL_VERSION}_linux_amd64.zip
unzip consul_#{CONSUL_VERSION}_linux_amd64.zip
sudo mv consul /usr/local/bin/
sudo chmod +x /usr/local/bin/consul
sudo mkdir -p /etc/consul.d

# Configuración de Consul para el agente
echo '{
  "node_name": "consul-agent-NOMBRE",
  "data_dir": "/tmp/consul",
  "bind_addr": "IP_DEL_AGENTE",
  "client_addr": "0.0.0.0",
  "retry_join": ["192.168.100.20"]
}' | sudo tee /etc/consul.d/config.json

# Iniciar Consul como agente
consul agent -config-dir=/etc/consul.d &
