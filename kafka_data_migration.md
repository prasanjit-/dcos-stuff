# Prelude
**Apache Kafka** is a distributed high-throughput publish-subscribe messaging system with strong ordering guarantees. Kafka clusters are highly available, fault tolerant, and very durable. DC/OS Kafka gives you direct access to the Kafka API so that existing producers and consumers can interoperate. You can configure and install DC/OS Kafka in moments. Multiple Kafka clusters can be installed on DC/OS and managed independently, so you can offer Kafka as a managed service to your organization.

Kafka uses Apache ZooKeeper for coordination. Kafka serves real-time data ingestion systems with high-throughput and low-latency. Kafka is written in Scala.

**Terminology:**
Broker: A Kafka message broker that routes messages to one or more topics.
Topic: A Kafka topic is message filtering mechanism in the pub/sub systems. Subscribers register to receive/consume messages from topics.
Producer: An application that producers messages to a Kafka topic.
Consumer: An application that consumes messages from a Kafka topic.


# The Goal
The goal of this excercise is to create two separate clusters of Kafka (Old & New) and then migrate the data from the old one to the new one using Kafka MirrorMaker on DCOS to migrate from DCOS_Kafka version=1.x (OLD)  to DCOS_Kafka 2.x (NEW)

# The Components
1. Kafka Old Cluster
2. Kafka New Cluster
3. Kafka Mirrormaker

# Steps Followed:

#**Creating Kafka Cluster (Old)**

Install a Kafka cluster with 3 brokers using the DC/OS CLI:

`dcos package install kafka --options=kafka-old.json`

The kafka-old.json file is as below:
```json
{
    "brokers": {
        "count": 3,
        "mem": 512,
        "disk": 1000
    }
}
```

While the DC/OS command line interface (CLI) is immediately available, it takes a few minutes for the Kafka service to start.

Once the cluster is created go to the Mesosphere dashboard and get the "endpoints" for the Kafka Cluster-
```
VIP- broker.kafka.l4lb.thisdcos.directory:9092
ZOO- master.mesos:2181/dcos-service-kafka
```

**Install Kafka client commands to DCOS Client CLI**

`dcos package install kafka --cli`

**Add a topic:**
`dcos kafka topic create topic1 --partitions 1 --replication 1`
`dcos kafka topic create topic2 --partitions 1 --replication 1`

**Install Kafka Client**
Run the following Docker image in the Master Node of DCOS-
`docker run -it mesosphere/kafka-client`

**Create Message via Producer**
```
echo "Venkata is a Champ!" | ./kafka-console-producer.sh --broker-list broker.kafka.l4lb.thisdcos.directory:9092 --topic topic1
```
./kafka-console-consumer.sh --zookeeper master.mesos:2181/dcos-service-kafka --topic topic1 --from-beginning

**Create Message Consumer**
```
root@7d0aed75e582:/bin# ./kafka-console-consumer.sh --zookeeper master.mesos:2181/dcos-service-kafka --topic topic1 --from-beginning
```

**List Topics**
`./kafka-topics.sh --zookeeper master.mesos:2181/dcos-service-kafka -list`

**Create Sample data:**
```
./kafka-verifiable-producer.sh --topic topic2 --max-messages 20000 --broker-list broker.kafka.l4lb.thisdcos.directory:9092
```

#**Creating Kafka Cluster (New)**

The new cluster of Kafka can be installed via the GUI Dashboard or using the json file as mentioned in the above steps. However, it has to be ensured that the 'service name' is different so as to distinguish them.

Here we create it as 'new-kafka' and the endpoints are below:
```
VIP- broker.new-kafka.l4lb.thisdcos.directory:9092
ZOO- master.mesos:2181/dcos-service-new-kafka
```
**List Topics**
`./kafka-topics.sh --zookeeper master.mesos:2181/dcos-service-new-kafka -list`

Above should be emplty at this point.

**Create topics with same name in new cluster**
`./kafka-topics.sh --create --topic topic1 --partitions 1 --replication 1 --zookeeper master.mesos:2181/dcos-service-new-kafka`

`./kafka-topics.sh --create --topic topic2 --partitions 1 --replication 1 --zookeeper master.mesos:2181/dcos-service-new-kafka`

**check consumers**
`./kafka-console-consumer.sh --zookeeper master.mesos:2181/dcos-service-new-kafka --topic topic1 --from-beginning`

`./kafka-console-consumer.sh --zookeeper master.mesos:2181/dcos-service-new-kafka --topic topic2 --from-beginning`

These commands will show the new cluster as empty.


#**Run the Kafka Mirror-maker to Migrate Data**

Deploy the following json via the cli or dashboard to launch the migrator service:

```json
{
  "id": "kafka-mirrormaker",
  "env": {
    "CONSUMER_GROUP_ID": "mirrormaker",
    "CONSUMER_ZK_CONNECT": "master.mesos:2181/dcos-service-kafka",
    "STREAM_COUNT": "2",
    "OFFSET_RESET": "smallest",
    "WHITE_LIST": "topic1,topic2",
    "DOWNSTREAM_BROKERS": "broker.new-kafka.l4lb.thisdcos.directory:9092"
  },
  "cpus": 0.5,
  "mem": 256,
  "instances": 1,
  "container": {
    "type": "DOCKER",
    "docker": {
      "image": "martinthiele/kafka-mirrormaker:latest",
      "network": "HOST",
      "forcePullImage": true
    }
  }
}
```

**Verify the Migration**
Run the below commands to verify the migrated data:

`./kafka-console-consumer.sh --zookeeper master.mesos:2181/dcos-service-new-kafka --topic topic1 --from-beginning`

`./kafka-console-consumer.sh --zookeeper master.mesos:2181/dcos-service-new-kafka --topic topic2 --from-beginning`


**Issues Faced**
- `dcos kafka connection` command is no longer available to list the endpoints. It can be available from the Mesosphere dashboard under services > endpoints.
- Creating topics in the new cluster with the below command doesn't work as it connects to the old cluster by default:
`dcos kafka topic create topic1 --partitions 1 --replication 1`
We had to use the below command instead from the Kafka Cli-
`./kafka-topics.sh --create --topic topic1 --partitions 1 --replication 1 --zookeeper master.mesos:2181/dcos-service-new-kafka`
