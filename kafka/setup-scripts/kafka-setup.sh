#!/bin/bash

set -e 

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

# Step 6: Create data directory for Kafka
sudo mkdir -p /var/lib/kafka/data

# Step 7: Change access permissions for data directory
sudo chmod 7777 /var/lib/kafka/data

# Step 8: Edit Kafka server properties file
sudo sed -i "/^broker.id=/s/.*/broker.id=$1/" /usr/local/kafka/config/server.properties
sudo sed -i "/listeners=PLAINTEXT/s|.*|listeners=PLAINTEXT://$2:9092|" /usr/local/kafka/config/server.properties
sudo sed -i "s#^log.dirs=/tmp/kafka-logs#log.dirs=/var/lib/kafka/data#" /usr/local/kafka/config/server.properties
sudo sed -i "s#^zookeeper.connect=.*#zookeeper.connect=$3:2181, $4:2181, $5:2181#" /usr/local/kafka/config/server.properties

# Step 9: Download JMX exporter
wget https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/0.16.1/jmx_prometheus_javaagent-0.16.1.jar

# Step 10: Create directory for JMX exporter
sudo mkdir -p /opt/jmx_exporter

# Step 11: Move JAR file to JMX exporter directory
sudo mv jmx_prometheus_javaagent-0.16.1.jar /opt/jmx_exporter/

# Step 12: Create configuration file for JMX exporter
sudo tee /opt/jmx_exporter/kafka-3-0-0.yml >/dev/null <<EOF
lowercaseOutputName: true
whitelistObjectNames:
  - java.lang:*
  - kafka.*:*
pattern:
  - pattern: '.*'
EOF

# Step 13: Set KAFKA_OPTS environment variable
export KAFKA_OPTS="-javaagent:/opt/jmx_exporter/jmx_prometheus_javaagent-0.16.1.jar=7071:/opt/jmx_exporter/kafka-3-0-0.yml"

echo "Kafka setup completed successfully!"