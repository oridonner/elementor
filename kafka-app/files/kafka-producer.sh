#!/bin/bash
INTERVAL="${INTERVAL:-60}"
TOPIC="${TOPIC:-cpu-metrics}"
BOOTSTRAP_SERVERS="${BOOTSTRAP_SERVERS:-kafka.ori.svc.cluster.local:9092}"
CLIENT_CONFIG_PATH="/kafka/config/client.properties"

# Command to run mpstat and parse its output for CPU usage.
# mpstat outputs CPU idle time by default, we're reversing it to get CPU usage.
capture_cpu_usage() {
    mpstat 1 1 | awk '/Average:/ && NR>1 {print 100 - $NF"%"}'
}

# Main loop
while true; do
    # Capture CPU usage
    CPU_USAGE=$(capture_cpu_usage)

    # Generate a timestamp for when the metric was captured.
    TIMESTAMP=$(date --rfc-3339=seconds | sed 's/ /T/')

    # Create a JSON payload with the metric.
    METRIC_JSON="{\"timestamp\": \"$TIMESTAMP\", \"cpu_usage\": $CPU_USAGE}"

    # Send the metric to the Kafka topic.
    echo "$METRIC_JSON" | kafka-console-producer.sh \
    --broker-list $BOOTSTRAP_SERVERS \
    --topic $TOPIC \
    --producer.config $CLIENT_CONFIG_PATH

    # Wait for the specified interval before capturing the metric again.
    sleep $INTERVAL
done