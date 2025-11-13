# Kafka Lab - Applications Complètes

## Structure du Projet
```
LAB KAFKA/
├── pom.xml
├── README.md
├── config/
│   ├── connect-file-source.properties
│   ├── connect-file-sink.properties
│   ├── server-one.properties
│   └── server-two.properties
└── src/
    └── main/
        └── java/
            └── edu/
                └── ensias/
                    └── kafka/
                        ├── EventProducer.java
                        ├── EventConsumer.java
                        ├── WordCountApp.java
                        ├── WordProducer.java
                        └── WordCountConsumer.java
```

## Étapes de Construction et Exécution

### 1. Compiler le Projet
```powershell
cd "c:\Users\mouad\OneDrive - um5.ac.ma\Desktop\Lab Big data 0\LAB KAFKA"
mvn clean package
```

Cela va créer **5 JARs** dans le dossier `target/`:
- `kafka-producer-app-jar-with-dependencies.jar`
- `kafka-consumer-app-jar-with-dependencies.jar`
- `kafka-wordcount-app-jar-with-dependencies.jar`
- `kafka-word-producer-app-jar-with-dependencies.jar`
- `kafka-word-count-consumer-app-jar-with-dependencies.jar`

### 2. Copier les JARs dans le Container Docker
```powershell
docker cp target\kafka-producer-app-jar-with-dependencies.jar hadoop-master:/root/
docker cp target\kafka-consumer-app-jar-with-dependencies.jar hadoop-master:/root/
docker cp target\kafka-wordcount-app-jar-with-dependencies.jar hadoop-master:/root/
docker cp target\kafka-word-producer-app-jar-with-dependencies.jar hadoop-master:/root/
docker cp target\kafka-word-count-consumer-app-jar-with-dependencies.jar hadoop-master:/root/
```

---

## 📋 PARTIE 1 : Producer & Consumer Basiques

### 3. Exécuter le Producer
```bash
docker exec -it hadoop-master bash

# Créer le topic si nécessaire
kafka-topics.sh --create --bootstrap-server localhost:9092 --replication-factor 1 --partitions 1 --topic Hello-Kafka

# Lancer le producer
java -jar /root/kafka-producer-app-jar-with-dependencies.jar Hello-Kafka
```

**Résultat attendu**: `Message envoye avec succes`

### 4. Vérifier les Messages avec le Consumer
```bash
# Dans un autre terminal
docker exec -it hadoop-master bash
java -jar /root/kafka-consumer-app-jar-with-dependencies.jar Hello-Kafka
```

**Ou utiliser le consumer en ligne de commande:**
```bash
kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic Hello-Kafka --from-beginning
```

### 5. Exemple de Sortie

**Producer:**
```
Message envoye avec succes
```

**Consumer:**
```
Souscris au topic Hello-Kafka
offset = 0, key = 0, value = 0
offset = 1, key = 1, value = 1
offset = 2, key = 2, value = 2
...
offset = 9, key = 9, value = 9
```

---

## 📊 PARTIE 2 : Kafka Connect - Ingestion de Données

### 1. Configurer Kafka Connect
```bash
docker exec -it hadoop-master bash

# Ajouter le plugin path
echo "plugin.path=/usr/local/kafka/libs/" >> $KAFKA_HOME/config/connect-standalone.properties
```

### 2. Copier les Fichiers de Configuration
```powershell
# Sur Windows, copier les fichiers de configuration
docker cp config\connect-file-source.properties hadoop-master:$KAFKA_HOME/config/
docker cp config\connect-file-sink.properties hadoop-master:$KAFKA_HOME/config/
```

### 3. Créer le Topic et le Fichier Source
```bash
# Créer le topic
kafka-topics.sh --create --bootstrap-server localhost:9092 --replication-factor 1 --partitions 1 --topic connect-topic

# Créer le fichier source
echo "Bonjour Kafka" > /tmp/test-source.txt
echo "Bienvenue dans le monde du streaming" >> /tmp/test-source.txt
```

### 4. Démarrer Kafka Connect
```bash
$KAFKA_HOME/bin/connect-standalone.sh \
  $KAFKA_HOME/config/connect-standalone.properties \
  $KAFKA_HOME/config/connect-file-source.properties \
  $KAFKA_HOME/config/connect-file-sink.properties
```

### 5. Vérifier le Résultat
```bash
# Visualiser le contenu du fichier de destination
more /tmp/test-sink.txt

# Ajouter des données et voir le pipeline en action
echo "Exercice Kafka Connect simple" >> /tmp/test-source.txt
```

---

## 🔄 PARTIE 3 : Kafka Streams - Word Count Application

### 1. Créer les Topics
```bash
docker exec -it hadoop-master bash

kafka-topics.sh --create --bootstrap-server localhost:9092 --replication-factor 1 --partitions 1 --topic input-topic
kafka-topics.sh --create --bootstrap-server localhost:9092 --replication-factor 1 --partitions 1 --topic output-topic
```

### 2. Lancer l'Application Kafka Streams
```bash
java -jar /root/kafka-wordcount-app-jar-with-dependencies.jar input-topic output-topic
```

### 3. Envoyer des Messages au Topic Input
```bash
# Dans un autre terminal
docker exec -it hadoop-master bash

kafka-console-producer.sh --bootstrap-server localhost:9092 --topic input-topic
# Tapez vos phrases, par exemple:
# > hello world
# > hello kafka
# > kafka streams example
```

### 4. Lire les Résultats du Topic Output
```bash
# Dans un troisième terminal
docker exec -it hadoop-master bash

kafka-console-consumer.sh --topic output-topic --from-beginning \
  --bootstrap-server localhost:9092 \
  --property print.key=true \
  --property key.separator=" : "
```

**Exemple de sortie:**
```
hello : 2
world : 1
kafka : 2
streams : 1
example : 1
```

---

## 💬 PARTIE 4 : Word Count Interactif avec Clavier

### 1. Créer le Topic
```bash
kafka-topics.sh --create --bootstrap-server localhost:9092 --replication-factor 1 --partitions 1 --topic WordCount-Topic
```

### 2. Lancer le Producer Interactif
```bash
# Terminal 1: Lancer le producer
java -jar /root/kafka-word-producer-app-jar-with-dependencies.jar WordCount-Topic

# Tapez vos mots au clavier
```

### 3. Lancer le Consumer Word Count
```bash
# Terminal 2: Lancer le consumer qui compte les mots
java -jar /root/kafka-word-count-consumer-app-jar-with-dependencies.jar WordCount-Topic
```

**Exemple d'interaction:**
```
# Terminal 1 (Producer):
=== Word Producer - Kafka ===
Topic: WordCount-Topic
Entrez des mots (Ctrl+C pour quitter):
> hello world
Envoyé: hello world
> hello kafka
Envoyé: hello kafka

# Terminal 2 (Consumer):
=== Word Count Consumer - Kafka ===
Topic: WordCount-Topic
En attente des messages...

=== Fréquence des mots ===
hello: 1
world: 1
==========================

=== Fréquence des mots ===
hello: 2
world: 1
kafka: 1
==========================
```

---

## 🔧 PARTIE 5 : Cluster Kafka Multi-Brokers

### 1. Copier les Fichiers de Configuration
```powershell
docker cp config\server-one.properties hadoop-master:$KAFKA_HOME/config/
docker cp config\server-two.properties hadoop-master:$KAFKA_HOME/config/
```

### 2. Démarrer les Brokers Additionnels
```bash
docker exec -it hadoop-master bash

# Démarrer broker 1 (port 9093)
$KAFKA_HOME/bin/kafka-server-start.sh $KAFKA_HOME/config/server-one.properties &

# Démarrer broker 2 (port 9094)
$KAFKA_HOME/bin/kafka-server-start.sh $KAFKA_HOME/config/server-two.properties &
```

### 3. Créer un Topic Répliqué
```bash
kafka-topics.sh --create --bootstrap-server localhost:9092 \
  --replication-factor 2 \
  --partitions 3 \
  --topic WordCount-Topic-Replicated
```

### 4. Vérifier la Configuration du Topic
```bash
kafka-topics.sh --describe --topic WordCount-Topic-Replicated --bootstrap-server localhost:9092
```

**Exemple de sortie:**
```
Topic: WordCount-Topic-Replicated	PartitionCount: 3	ReplicationFactor: 2
	Topic: WordCount-Topic-Replicated	Partition: 0	Leader: 0	Replicas: 0,1	Isr: 0,1
	Topic: WordCount-Topic-Replicated	Partition: 1	Leader: 1	Replicas: 1,2	Isr: 1,2
	Topic: WordCount-Topic-Replicated	Partition: 2	Leader: 2	Replicas: 2,0	Isr: 2,0
```

---

## 🎨 PARTIE 6 : Kafka UI (Interface Web)

### 1. Ajouter Kafka UI au docker-compose.yml
```yaml
# À ajouter dans votre fichier docker-compose.yml
kafka-ui:
  image: provectuslabs/kafka-ui:latest
  container_name: kafka-ui
  hostname: kafka-ui
  networks:
    - hadoop
  ports:
    - 8081:8080
  environment:
    - KAFKA_CLUSTERS_0_NAME=local
    - KAFKA_CLUSTERS_0_BOOTSTRAPSERVERS=hadoop-master:9092
    - KAFKA_CLUSTERS_0_ZOOKEEPER=hadoop-master:2181
```

### 2. Redémarrer Docker Compose
```powershell
docker-compose down
docker-compose up -d
```

### 3. Accéder à Kafka UI
Ouvrez votre navigateur: **http://localhost:8081**

Vous pourrez visualiser:
- 📊 Liste des topics
- 📈 Métriques des brokers
- 💬 Messages dans les topics
- ⚙️ Configuration des consumers groups
- 🔍 Exploration des données

---

## 📦 Configuration des Applications

### EventProducer
- Envoie 10 messages (clé et valeur de 0 à 9)
- **bootstrap.servers**: localhost:9092
- **acks**: all (garantit que tous les réplicas ont reçu le message)
- **batch.size**: 16384 bytes
- **buffer.memory**: 33554432 bytes (32 MB)

### EventConsumer
- Lit continuellement les messages
- **bootstrap.servers**: localhost:9092
- **group.id**: test
- **enable.auto.commit**: true

### WordCountApp (Kafka Streams)
- Lit depuis `input-topic`
- Compte la fréquence des mots
- Écrit dans `output-topic`
- Utilise un state store pour le comptage

### WordProducer
- Lit les mots depuis le clavier
- Envoie chaque ligne au topic spécifié
- Mode interactif

### WordCountConsumer
- Compte la fréquence des mots en temps réel
- Maintient un compteur local
- Affiche les statistiques après chaque message

---

## 🚀 Résumé des Commandes Utiles

### Gestion des Topics
```bash
# Créer un topic
kafka-topics.sh --create --bootstrap-server localhost:9092 --replication-factor 1 --partitions 1 --topic <topic-name>

# Lister les topics
kafka-topics.sh --list --bootstrap-server localhost:9092

# Décrire un topic
kafka-topics.sh --describe --topic <topic-name> --bootstrap-server localhost:9092

# Supprimer un topic
kafka-topics.sh --delete --topic <topic-name> --bootstrap-server localhost:9092
```

### Producer/Consumer en Ligne de Commande
```bash
# Producer
kafka-console-producer.sh --bootstrap-server localhost:9092 --topic <topic-name>

# Consumer
kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic <topic-name> --from-beginning

# Consumer avec clé
kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic <topic-name> --from-beginning --property print.key=true
```

### Vérifier l'État du Cluster
```bash
# Lister les brokers
kafka-broker-api-versions.sh --bootstrap-server localhost:9092

# Vérifier les consumer groups
kafka-consumer-groups.sh --bootstrap-server localhost:9092 --list

# Décrire un consumer group
kafka-consumer-groups.sh --bootstrap-server localhost:9092 --describe --group <group-name>
```

---

## 📝 Notes Importantes

1. **Kafka Connect** permet l'ingestion de données depuis des sources externes vers Kafka et vice-versa
2. **Kafka Streams** est une bibliothèque pour le traitement de flux de données en temps réel
3. **Réplication** assure la haute disponibilité et la tolérance aux pannes
4. **Partitioning** permet la scalabilité horizontale
5. **Consumer Groups** permettent le load balancing entre consommateurs

---

## 🐛 Troubleshooting

### Erreur: "Topic already exists"
```bash
# Vérifier si le topic existe
kafka-topics.sh --list --bootstrap-server localhost:9092
```

### Erreur: "Connection refused"
```bash
# Vérifier que Kafka est démarré
docker ps
docker logs hadoop-master
```

### Kafka Connect ne démarre pas
```bash
# Vérifier le plugin path
grep plugin.path $KAFKA_HOME/config/connect-standalone.properties
```

---

## 📚 Ressources

- [Documentation Kafka](https://kafka.apache.org/documentation/)
- [Kafka Streams API](https://kafka.apache.org/documentation/streams/)
- [Kafka Connect Guide](https://docs.confluent.io/platform/current/connect/index.html)
- [Kafka UI GitHub](https://github.com/provectus/kafka-ui)
