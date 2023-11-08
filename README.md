# 1. Install Apache Kafka 

    helm repo add bitnami https://charts.bitnami.com/bitnami
    helm repo update
    helm install kafka bitnami/kafka -n ori

## 1.1 Access Kafka cluster

Helm chart Kafka installation instructions to access kafka cluster.
**client.properties** file is located ar kafka-app/config, kafka password is encoded and hardcoded in script, should be saved as AWS Secret and mounted to kafka pods.  

>    NAME: kafka
>    LAST DEPLOYED: Tue Nov  7 11:58:13 2023
>    NAMESPACE: ori
>    STATUS: deployed
>    REVISION: 1
>    TEST SUITE: None
>    NOTES:
>    CHART NAME: kafka
>    CHART VERSION: 26.3.0
>    APP VERSION: 3.6.0
>
>    ** Please be patient while the chart is being deployed **
>
>    Kafka can be accessed by consumers via port 9092 on the following DNS name from within your cluster:
>
>        kafka.ori.svc.cluster.local
>
>    Each Kafka broker can be accessed by producers via port 9092 on the following DNS name(s) from within your cluster:
>
>        kafka-controller-0.kafka-controller-headless.ori.svc.cluster.local:9092
>        kafka-controller-1.kafka-controller-headless.ori.svc.cluster.local:9092
>        kafka-controller-2.kafka-controller-headless.ori.svc.cluster.local:9092
>
>    The CLIENT listener for Kafka client connections from within your cluster have been configured with the following security settings:
>        - SASL authentication
>
>    To connect a client to your Kafka, you need to create the **client.properties** configuration files with the content below:
>
>    security.protocol=SASL_PLAINTEXT
>    sasl.mechanism=SCRAM-SHA-256
>    sasl.jaas.config=org.apache.kafka.common.security.scram.ScramLoginModule required \
>        username="user1" \
>        password="$(kubectl get secret kafka-user-passwords --namespace ori -o jsonpath='{.data.client-passwords}' | base64 -d | cut -d , -f 1)";
>
>    To create a pod that you can use as a Kafka client run the following commands:
>
>        kubectl run kafka-client --restart='Never' --image docker.io/bitnami/kafka:3.6.0-debian-11-r0 --namespace ori --command -- sleep infinity
>        kubectl cp --namespace ori /path/to/client.properties kafka-client:/tmp/client.properties
>        kubectl exec --tty -i kafka-client --namespace ori -- bash
>
>        PRODUCER:
>            kafka-console-producer.sh \
>                --producer.config /tmp/client.properties \
>                --broker-list kafka-controller-0.kafka-controller-headless.ori.svc.cluster.local:9092,kafka-controller-1.kafka-controller-headless.ori.svc.cluster.local:9092,kafka-controller-2, kafka-controller-headless.ori.svc.cluster.local:9092 \
>                --topic test
>
>        CONSUMER:
>            kafka-console-consumer.sh \
>                --consumer.config /tmp/client.properties \
>                --bootstrap-server kafka.ori.svc.cluster.local:9092 \
>                --topic test \
>                --from-beginning

## 1.2 Create Kafka topic

Launch a kafka client as instructed above. Inside the kafka client pod, execute the following commands:

Create a 3 replica, 3 partitioned cpu-metric topic:

    kafka-topics.sh \
    --create \
    --bootstrap-server kafka.ori.svc.cluster.local:9092 \
    --command-config /tmp/client.properties \
    --topic cpu-metrics \
    --partitions 3 \
    --replication-factor 3

Check topic was created:

    kafka-topics.sh \
    --list \
    --bootstrap-server kafka.ori.svc.cluster.local:9092 \
    --command-config /tmp/client.properties


# 1. Install kafka-app

Assignment application is packaged as Helm chart in **kafka-app** folder:

    helm install kafka-app .\kafka-app -n ori
