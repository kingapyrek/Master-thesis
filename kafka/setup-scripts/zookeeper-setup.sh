# Step 1: Update system packages
sudo apt-get update

# Step 2: Install Java
sudo apt-get install openjdk-11-jdk

# Step 3: Download Kafka
wget https://archive.apache.org/dist/kafka/3.0.0/kafka_2.13-3.0.0.tgz

# Step 4: Extract Kafka
tar -xzf kafka_2.13-3.0.0.tgz

# Step 5: Move Kafka to the installation directory
sudo mv kafka_2.13-3.0.0 /usr/local/kafka

# Step 6: Create data directory for ZooKeeper
sudo mkdir -p /var/lib/zookeeper/data

# Step 7: Change access permissions for data directory
sudo chmod 7777 /var/lib/zookeeper/data

# Step 8: Edit ZooKeeper configuration file
sudo sed -i '/^dataDir=/s|^.*|dataDir=/var/lib/zookeeper/data|' /usr/local/kafka/config/zookeeper.properties
sudo tee -a /usr/local/kafka/config/zookeeper.properties >/dev/null <<EOF
server.1=$1:2888:3888
server.2=$2:2888:3888
server.3=$3:2888:3888
initLimit=5
syncLimit=2
EOF

# Step 9: Create myid file in data directory
echo "$4" | sudo tee /var/lib/zookeeper/data/myid >/dev/null

echo "Zookeeper setup completed successfully!"