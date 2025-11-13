````markdown
# Portfolio de Projets Big Data (Labs 1-6)

Ce dépôt documente une série de 6 laboratoires pratiques couvrant l'écosystème Hadoop, du stockage de base HDFS au traitement de données en temps réel. L'ensemble de l'environnement est configuré à l'aide de Docker.

## 🚀 Technologie et Environnement

* **Conteneurisation :** Docker & Docker Compose
* **Cluster :** Apache Hadoop 3.2.0 (HDFS, YARN)
* **Base de Données :** Apache HBase 1.4.12
* **Traitement :** Apache Spark, Hadoop MapReduce, Apache Pig, Apache Hive
* **Messagerie/Streaming :** Apache Kafka 3.5.1
* **Langage :** Java 1.8 & Apache Maven

---

## ⚙️ Configuration du Cluster (Valable pour tous les Labs)

Cet environnement est conçu pour s'exécuter sur un cluster Hadoop de 3 nœuds (1 master, 2 slaves) géré par Docker.

### 1. Démarrage du Cluster
La plupart des services (Hadoop, HBase, Spark) sont inclus dans l'image `yassern1/hadoop-spark-jupyter:1.0.3`. D'autres, comme Hive, nécessitent un conteneur séparé.

```bash
# Démarrer tous les conteneurs (hadoop, hbase, kafka-ui, etc.)
docker-compose up -d
````

[cite\_start]Si vous n'utilisez pas `docker-compose`, démarrez les conteneurs manuellement[cite: 16, 351, 934]:

```bash
docker start hadoop-master hadoop-slave1 hadoop-slave2
```

### 2\. Accès au Conteneur Master

```bash
docker exec -it hadoop-master bash
```

### 3\. Démarrage des Services (dans le conteneur)

```bash
# (Dans le conteneur hadoop-master)

# [cite_start]Démarrer HDFS (NameNode, DataNodes) et YARN (ResourceManager, NodeManagers) [cite: 19, 356]
./start-hadoop.sh

# [cite_start]Démarrer HBase (HMaster, HRegionServers) [cite: 940]
/usr/local/hbase/bin/start-hbase.sh

# [cite_start]Démarrer Kafka et Zookeeper [cite: 21]
./start-kafka-zookeeper.sh

# IMPORTANT : Désactiver le mode sécurisé de HDFS pour les tests
hdfs dfsadmin -safemode leave
```

### 4\. Volume Partagé

Un volume partagé est configuré pour un échange facile des fichiers JAR et des données :

  * **Chemin Hôte (Windows) :** `C:/Users/DELL/Documents/hadoop_project`
  * **Chemin Conteneur :** `/shared_volume`

### 5\. Interfaces Web

  * [cite\_start]**Hadoop NameNode (HDFS) :** `http://localhost:9870` [cite: 359]
  * [cite\_start]**Hadoop ResourceManager (YARN) :** `http://localhost:8088` [cite: 358]
  * **HBase Master UI :** `http://localhost:16010` (Vérifiez le port sur votre `docker-compose.yml`)
  * [cite\_start]**Kafka UI :** `http://localhost:8081` [cite: 329]
  * [cite\_start]**HiveServer2 UI :** `http://localhost:10002` [cite: 1176]

-----

## [cite\_start]🔬 Lab 1 : API Java HDFS [cite: 341]

[cite\_start]**Objectif :** S'initier à la programmation avec l'API HDFS pour lire, écrire et manipuler des fichiers. [cite: 343, 344]

### Applications

  * [cite\_start]**`HDFSWrite.java`** : Crée un fichier dans HDFS et y écrit du contenu[cite: 513, 525].
  * [cite\_start]**`ReadHDFS.java`** : Lit le contenu d'un fichier sur HDFS[cite: 482].
  * [cite\_start]**`HadoopFileStatus.java`** : Lit les métadonnées détaillées d'un fichier (taille, blocs, permissions) et le renomme [cite: 428-429, 446-448, 460].

### Build (Projet `hadoop_lab`)

1.  [cite\_start]Configurer `pom.xml` avec les dépendances `hadoop-hdfs`, `hadoop-common`, et `hadoop-mapreduce-client-core` (version 3.2.0) [cite: 383-399].
2.  [cite\_start]Compiler le projet en JAR (ex: `hadoop-app.jar`)[cite: 416].
3.  Copier le JAR dans le volume partagé.

### Exécution (dans le conteneur)

```bash
# 1. Exécuter HDFSWrite (Crée /user/root/input/bonjour.txt)
hadoop jar /shared_volume/hadoop-app.jar edu.ensias.hadoop.hdfslab.HDFSWrite /user/root/input/bonjour.txt "Hello HDFS!"

# 2. Préparer les données pour FileStatus
hdfs dfs -mkdir -p /user/root/input
hdfs dfs -put /shared_volume/purchases.txt /user/root/input/

# 3. Exécuter HadoopFileStatus
# (Lit /user/root/input/purchases.txt et le renomme en achats.txt) [cite_start][cite: 460]
hadoop jar /shared_volume/hadoop-app.jar edu.ensias.hadoop.hdfslab.HadoopFileStatus
```

-----

## [cite\_start]📊 Lab 2 : MapReduce [cite: 341]

[cite\_start]**Objectif :** Implémenter le programme "WordCount" en Java (MapReduce) et en Python (Hadoop Streaming)[cite: 346, 347].

### Partie 1 : WordCount en Java

  * [cite\_start]**`TokenizerMapper.java`** : Mappe chaque mot à une paire `(mot, 1)`[cite: 538, 547].
  * [cite\_start]**`IntSumReducer.java`** : Agrège les comptes pour chaque mot [cite: 539-540, 568].
  * [cite\_start]**`WordCount.java`** : Configure et lance le job MapReduce[cite: 587, 589].

#### Exécution (dans le conteneur)

```bash
# 1. Préparer les données d'entrée
echo "hello world hello hadoop" > /shared_volume/test.txt
hdfs dfs -mkdir -p /input
hdfs dfs -put /shared_volume/test.txt /input/textfile.txt

# 2. Supprimer le dossier de sortie (obligatoire)
hdfs dfs -rm -r /output

# 3. Lancer le job MapReduce
hadoop jar /shared_volume/WordCount.jar edu.ensias.hadoop.mapreducelab.WordCount /input/textfile.txt /output

# 4. Voir les résultats
hdfs dfs -cat /output/part-r-00000
```

**Résultat attendu :**

```
hadoop	1
hello	2
world	1
```

### [cite\_start]Partie 2 : WordCount en Python (Streaming) [cite: 611]

  * [cite\_start]**`mapper.py`** : Lit depuis STDIN, sépare les mots, et écrit `(mot, 1)` sur STDOUT[cite: 612, 620].
  * [cite\_start]**`reducer.py`** : Lit depuis STDIN, agrège les comptes par mot, et écrit `(mot, total)` sur STDOUT[cite: 623, 647, 652].

#### Exécution (dans le conteneur)

```bash
# 1. Trouver le JAR de streaming
# [cite_start]ex: /opt/hadoop-3.2.1/share/hadoop/tools/lib/hadoop-streaming-3.2.1.jar [cite: 659]

# 2. Lancer le job de streaming
hadoop jar /opt/hadoop-3.2.1/share/hadoop/tools/lib/hadoop-streaming-3.2.1.jar \
 -files /shared_volume/mapper.py,/shared_volume/reducer.py \
 -mapper "python3 /shared_volume/mapper.py" \
 -reducer "python3 /shared_volume/reducer.py" \
 -input /input/textfile.txt \
 -output /output_python
```

-----

## [cite\_start]📩 Lab 3 : Apache Kafka [cite: 3]

[cite\_start]**Objectif :** Utiliser Kafka pour le publish/subscribe, créer des producers/consumers en Java, et utiliser Kafka Streams pour une application WordCount en temps réel [cite: 5-7].

### Partie 1 : Kafka CLI

```bash
# 1. Créer un topic
kafka-topics.sh --create --bootstrap-server localhost:9092 \
[cite_start]--replication-factor 1 --partitions 1 --topic Hello-Kafka [cite: 26-28]

# 2. Lancer un producteur console (Terminal 1)
[cite_start]kafka-console-producer.sh --bootstrap-server localhost:9092 --topic Hello-Kafka [cite: 42]
> Hello
> Kafka

# 3. Lancer un consommateur console (Terminal 2)
[cite_start]kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic Hello-Kafka --from-beginning [cite: 45]
Hello
Kafka
```

### Partie 2 : Java API (Producer/Consumer)

  * [cite\_start]**`EventProducer.java`** : Se connecte au broker et envoie 10 messages (0 à 9) dans un topic [cite: 50, 61, 73, 75-76].
  * [cite\_start]**`EventConsumer.java`** : S'abonne à un topic et écoute les messages en boucle [cite: 164, 176, 185, 188-190].
  * [cite\_start]**Build :** Le `pom.xml` nécessite `kafka-clients`[cite: 97].

#### Exécution (dans le conteneur)

```bash
# 1. Lancer le consommateur (Terminal 1)
[cite_start]java -jar /shared_volume/kafka/kafka-consumer-app-jar-with-dependencies.jar Hello-Kafka [cite: 202]

# 2. Lancer le producteur (Terminal 2)
[cite_start]java -jar /shared_volume/kafka/kafka-producer-app-jar-with-dependencies.jar Hello-Kafka [cite: 161]

# 3. (Résultat dans Terminal 1)
# Souscris au topic Hello-Kafka
# offset = 0, key = 0, value = 0
# offset = 1, key = 1, value = 1
# ...
```

### Partie 3 : Kafka Connect

[cite\_start]Pipe Fichier -\> Kafka -\> Fichier en utilisant Kafka Connect[cite: 204].

```bash
# 1. Préparer le fichier source
[cite_start]echo "Bonjour Kafka" > /tmp/test-source.txt [cite: 228]

# 2. Lancer Kafka Connect en mode standalone
$KAFKA_HOME/bin/connect-standalone.sh \
$KAFKA_HOME/config/connect-standalone.properties \
$KAFKA_HOME/config/connect-file-source.properties \
[cite_start]$KAFKA_HOME/config/connect-file-sink.properties [cite: 234-237]

# 3. Vérifier le fichier de destination
[cite_start]more /tmp/test-sink.txt [cite: 245]
# Bonjour Kafka
```

### Partie 4 : Kafka Streams (WordCount)

[cite\_start]Application temps réel qui lit de `input-topic`, compte les mots, et écrit dans `output-topic` [cite: 249-250].

  * [cite\_start]**`WordCountApp.java`** : Utilise `StreamsBuilder` pour définir la logique de streaming (`flatMapValues`, `groupBy`, `count`, `toStream`) [cite: 271-279].
  * [cite\_start]**Build :** Le `pom.xml` nécessite `kafka-streams`[cite: 253].

#### Exécution (dans le conteneur)

```bash
# 1. Créer les topics
[cite_start]kafka-topics.sh --create ... --topic input-topic [cite: 287]
[cite_start]kafka-topics.sh --create ... --topic output-topic [cite: 287]

# 2. Lancer l'application Streams (Terminal 1)
[cite_start]java -jar /shared_volume/kafka/kafka-wordcount-app-jar-with-dependencies.jar input-topic output-topic [cite: 289]

# 3. Lancer un consommateur sur le topic de sortie (Terminal 2)
kafka-console-consumer.sh --topic output-topic --from-beginning \
[cite_start]--bootstrap-server localhost:9092 --property print.key=true [cite: 290]

# [cite_start]4. Lancer un producteur sur le topic d'entrée (Terminal 3) [cite: 290]
kafka-console-producer.sh --bootstrap-server localhost:9092 --topic input-topic
> hello kafka
> hello world
```

**Résultat (dans Terminal 2) :**

```
hello	1
kafka	1
hello	2
world	1
```

-----

## [cite\_start]🏛️ Lab 4 : Apache HBase & Spark [cite: 921]

[cite\_start]**Objectif :** Manipuler une base de données NoSQL (HBase) et l'intégrer avec Spark pour l'analyse [cite: 924-927].

### Partie 1 : Shell HBase

[cite\_start]Manipulation de base des données via le shell interactif [cite: 946-947].

```bash
hbase shell

# Créer une table
[cite_start]create 'sales_ledger', 'customer', 'sales' [cite: 954]

# Insérer des données
[cite_start]put 'sales_ledger', '101', 'customer:name', 'John White' [cite: 958]
[cite_start]put 'sales_ledger', '101', 'sales:product', 'Chairs' [cite: 959]

# Scanner la table
[cite_start]scan 'sales_ledger' [cite: 967]

# Récupérer une ligne
get 'sales_ledger', '101'

# Utiliser un filtre (ex: RowFilter)
[cite_start]scan 'sales_ledger', {FILTER => "RowFilter(>, 'binary:102')"} [cite: 974]
```

### Partie 2 : Importation de Données (ImportTsv)

[cite\_start]Chargement en masse de données d'un fichier `.csv`/`.txt` (séparé par virgule ou tabulation) depuis HDFS vers une table HBase [cite: 1090, 1105-1106].

```bash
# 1. Préparer le fichier de données (ex: purchases2.txt)
#    IMPORTANT : Le fichier DOIT avoir un ID unique comme première colonne.
#    Ex: 1,2012-01-01,09:00,San Jose,...

# 2. Envoyer le fichier sur HDFS
[cite_start]hdfs dfs -put /shared_volume/purchases2.txt input/ [cite: 1101]

# 3. Créer la table HBase
hbase shell
[cite_start]create 'products', 'cf' [cite: 1104]
exit

# 4. Lancer ImportTsv (en corrigeant le ClassNotFoundException avec -libjars)
hbase org.apache.hadoop.hbase.mapreduce.ImportTsv \
-libjars /usr/local/hbase/lib/commons-lang-2.6.jar \
-Dimporttsv.separator=',' \
-Dimporttsv.columns=HBASE_ROW_KEY,cf:date,cf:time,cf:town,cf:product,cf:price,cf:payment \
products \
input/purchases2.txt
```

### Partie 3 : Traitement avec Spark

[cite\_start]Lire les données de la table HBase (`products`) dans un RDD Spark pour compter les enregistrements [cite: 1117-1118].

  * [cite\_start]**`HbaseSparkProcess.java`** : Configure une `SparkConf` et utilise `newAPIHadoopRDD` pour se connecter à HBase [cite: 1119-1144].

<!-- end list -->

```bash
# 1. Copier les bibliothèques HBase vers Spark (correction de classpath)
[cite_start]cp -r $HBASE_HOME/lib/* $SPARK_HOME/jars [cite: 1151]

# 2. Copier le JAR du projet dans le conteneur (via volume partagé)
cp /shared_volume/processing-hbase.jar /root/

# 3. Lancer le job Spark
spark-submit --class bigdata.hbase.tp.HbaseSparkProcess \
--master yarn \
--deploy-mode client \
[cite_start]/root/processing-hbase.jar [cite: 1153]
```

**Résultat attendu :**

```
----------------------------------------
nombre d'enregistrements: [votre_nombre_de_lignes]
----------------------------------------
```

-----

## [cite\_start]🐖 Lab 5 : Apache Pig [cite: 703]

[cite\_start]**Objectif :** Installer et utiliser Apache Pig (Pig Latin) pour des traitements de données complexes [cite: 704-705, 707].

### Installation (dans le conteneur)

```bash
# 1. Télécharger Pig
[cite_start]wget [https://dlcdn.apache.org/pig/pig-0.17.0/pig-0.17.0.tar.gz](https://dlcdn.apache.org/pig/pig-0.17.0/pig-0.17.0.tar.gz) [cite: 714]

# 2. Extraire et déplacer
[cite_start]tar -zxvf pig-0.17.0.tar.gz [cite: 716]
[cite_start]mv pig-0.17.0 /usr/local/pig [cite: 717]
[cite_start]rm pig-0.17.0.tar.gz [cite: 719]

# 3. Configurer l'environnement
[cite_start]echo "export PIG_HOME=/usr/local/pig" >> ~/.bashrc [cite: 722]
[cite_start]echo "export PATH=\$PATH:\$PIG_HOME/bin" >> ~/.bashrc [cite: 723]
[cite_start]source ~/.bashrc [cite: 725]
```

### Exécution (Grunt Shell)

[cite\_start]Lancer le shell interactif Grunt[cite: 755]:

```bash
pig -x local
# ou pour le mode MapReduce
pig
```

#### Exemple Script Pig Latin (WordCount)

```pig
-- 1. Charger les données
[cite_start]Lines = LOAD '/shared_volume/alice.txt'; [cite: 759]

-- 2. Séparer les mots
[cite_start]words = FOREACH Lines GENERATE FLATTEN(TOKENIZE((chararray)$0)) AS word; [cite: 761]

-- 3. Filtrer
[cite_start]clean_w = FILTER words BY word MATCHES '\\w+'; [cite: 762]

-- 4. Grouper
[cite_start]D = GROUP clean_w BY word; [cite: 764]

-- 5. Compter
[cite_start]E = FOREACH D GENERATE group, COUNT(clean_w); [cite: 766]

-- 6. Stocker le résultat
[cite_start]STORE E INTO '/shared_volume/pig_out/WORD_COUNT/'; [cite: 769]
```

### Analyses (Problématiques du Lab)

  * [cite\_start]**Employés :** Analyse de `employees.txt` pour calculer le salaire moyen, le nombre d'employés par département, et filtrer les salaires \> 60k [cite: 777, 781-782].
  * **Films (JSON) :** Analyse de `films.json` et `artists.json`. [cite\_start]Utilisation de `JsonLoader`, `FLATTEN` sur les acteurs imbriqués, et `JOIN` ou `COGROUP` pour lier les films, acteurs et réalisateurs[cite: 792, 808, 811, 814, 821].
  * [cite\_start]**Vols :** Analyse d'un jeu de données de vols pour trouver le top 20 des aéroports, la popularité des transporteurs, et la proportion des retards [cite: 828-841].

-----

## [cite\_start]🐝 Lab 6 : Apache Hive [cite: 1160]

[cite\_start]**Objectif :** Utiliser Apache Hive comme un Data Warehouse sur HDFS, permettant des requêtes de type SQL[cite: 1164].

### Installation & Accès

Ce lab utilise un conteneur Hive séparé.

```bash
# 1. (Sur l'hôte) Lancer le conteneur Hive
docker run -v ~/Documents/hadoop_project/:/shared_volume -d -p 10000:10000 -p 10002:10002 \
[cite_start]-env SERVICE_NAME=hiveserver2 --name hiveserver2-standalone apache/hive:4.0.0-alpha-2 [cite: 1175]

# 2. Accéder au shell du conteneur Hive
[cite_start]docker exec -it hiveserver2-standalone bash [cite: 1181]

# 3. (Dans le conteneur Hive) Se connecter à HiveServer2 via Beeline
[cite_start]beeline -u jdbc:hive2://localhost:10000 scott tiger [cite: 1191]
```

### Exécution (Shell Beeline)

[cite\_start]Analyse des réservations d'hôtels[cite: 1195].

#### 1\. Création de Tables

```sql
-- Créer la base de données
[cite_start]CREATE DATABASE hotel_booking; [cite: 1200]
[cite_start]USE hotel_booking; [cite: 1201]

-- Activer les partitions dynamiques
[cite_start]set hive.exec.dynamic.partition=true; [cite: 1206]
[cite_start]set hive.exec.dynamic.partition.mode=nonstrict; [cite: 1207]
[cite_start]set hive.enforce.bucketing = true; [cite: 1210]

-- Table simple
CREATE TABLE clients (client_id INT, nom STRING, email STRING, telephone STRING)
[cite_start]ROW FORMAT DELIMITED FIELDS TERMINATED BY ',' [cite: 1211-1212]
[cite_start]STORED AS TEXTFILE; [cite: 1213]

-- Table partitionnée
CREATE TABLE hotels_partitioned (
  hotel_id INT, nom STRING, etoiles INT
)
[cite_start]PARTITIONED BY (ville STRING) [cite: 1227-1232]
[cite_start]ROW FORMAT DELIMITED FIELDS TERMINATED BY ','; [cite: 1233-1234]

-- Table "bucketée" (optimisée pour les jointures)
CREATE TABLE reservations_bucketed (
  reservation_id INT, client_id INT, hotel_id INT, ...
)
[cite_start]CLUSTERED BY (client_id) INTO 4 BUCKETS [cite: 1236-1244]
STORED AS TEXTFILE;
```

#### 2\. Chargement de Données

```sql
-- Charger des données depuis le système de fichiers local (du conteneur)
[cite_start]LOAD DATA LOCAL INPATH '/path/to/clients.txt' INTO TABLE clients; [cite: 1218]

-- Charger des données dans une table partitionnée
[cite_start]LOAD DATA LOCAL INPATH '/path/to/reservations.txt' INTO TABLE reservations PARTITION (date_debut); [cite: 1220]
```

#### 3\. Requêtes (HQL)

```sql
-- Requête simple
[cite_start]SELECT * FROM clients; [cite: 1251]

-- Requête sur partition
[cite_start]SELECT * FROM hotels_partitioned WHERE ville = 'Paris'; [cite: 1252]

-- Jointure
SELECT c.nom, h.nom, r.date_debut
FROM reservations r
JOIN clients c ON r.client_id = c.client_id
[cite_start]JOIN hotels h ON r.hotel_id = h.hotel_id; [cite: 1253]

-- Agrégation
SELECT client_id, COUNT(*)
FROM reservations
[cite_start]GROUP BY client_id; [cite: 1255]

-- Requête imbriquée
SELECT * FROM clients
WHERE client_id IN (
  SELECT client_id FROM reservations r
  JOIN hotels h ON r.hotel_id = h.hotel_id
  WHERE h.etoiles > 4
[cite_start]); [cite: 1261]
```

```
```