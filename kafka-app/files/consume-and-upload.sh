#!/bin/bash
TOPIC="${TOPIC:-cpu-metrics}"
GROUP_ID="${GROUP_ID:-cpu-metrics-consumer-group}"
BUCKET="${AWS_BUCKET:-elementor-data-candidates-bucket}"
BOOTSTRAP_SERVERS="${BOOTSTRAP_SERVERS:-kafka.ori.svc.cluster.local:9092}"
CLIENT_CONFIG_PATH="/kafka/config/client.properties"

# Function to upload a message to S3
upload_to_s3() {
    local message=$1
    local timestamp=$(date +%s)
    local filename="cpu-metrics-${timestamp}.json"
    
    echo "$message" > "/tmp/${filename}"
    aws s3 cp "/tmp/${filename}" "s3://${BUCKET}/${filename}"
    
    # Clean up the temp file
    rm "/tmp/${filename}"
}

# Consume messages from Kafka and upload them to S3
kafka-console-consumer.sh \
    --bootstrap-server $BOOTSTRAP_SERVERS \
    --topic $TOPIC \
    --consumer.config $CLIENT_CONFIG_PATH \
    --group $GROUP_ID \
    --from-beginning | while read -r line
do
    upload_to_s3 "$line"
done