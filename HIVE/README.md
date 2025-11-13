# Apache Hive Lab - Analyse de Données de Réservation d'Hôtels

## 📋 Structure du Projet
```
HIVE/
├── README.md
├── data/
│   ├── clients.txt          # Données des clients
│   ├── hotels.txt           # Données des hôtels
│   └── reservations.txt     # Données des réservations
└── scripts/
    ├── Creation.hql         # Création de la BD et des tables
    ├── Loading.hql          # Chargement des données
    ├── Queries.hql          # Requêtes d'analyse
    └── Cleanup.hql          # Nettoyage et suppression
```

---

## 🚀 I. Installation Apache Hive

### 1. Pull l'image Docker
```powershell
docker pull apache/hive:4.0.0-alpha-2
```

### 2. Configuration dans docker-compose.yml
Le service HiveServer2 est déjà configuré dans votre `docker-compose.yml` :
```yaml
hiveserver2:
  image: apache/hive:4.0.0-alpha-2
  container_name: hiveserver2-standalone
  ports:
    - "10000:10000"  # JDBC
    - "10002:10002"  # Web UI
    - "9083:9083"    # Metastore
```

### 3. Démarrer les services
```powershell
cd "c:\Users\mouad\OneDrive - um5.ac.ma\Desktop\Lab Big data 0"
docker-compose up -d
```

### 4. Accéder à HiveServer2 Web UI
Ouvrez votre navigateur : **http://localhost:10002**

---

## 🔧 II. Première Utilisation de Beeline

### 1. Accéder au conteneur Hive
```powershell
docker exec -it hiveserver2-standalone bash
```

### 2. Vérifier HDFS
```bash
hadoop fs -ls /
```

### 3. Visualiser la configuration Hive
```bash
cat /opt/hive/conf/hive-site.xml
```

### 4. Se connecter à Beeline
```bash
beeline -u jdbc:hive2://localhost:10000 scott tiger
```

### 5. Commandes de base
```sql
-- Afficher les bases de données
SHOW DATABASES;

-- Quitter Beeline
!quit
```

---

## 📊 III. Analyse des Données de Réservation d'Hôtels

### Préparation des données

#### 1. Copier les données dans le volume partagé
```powershell
# Depuis Windows PowerShell
Copy-Item -Path "HIVE\data\*" -Destination "C:\Users\mouad\OneDrive - um5.ac.ma\Documents\hadoop_project\hive\data\" -Recurse

# Créer le dossier si nécessaire
New-Item -ItemType Directory -Force -Path "C:\Users\mouad\OneDrive - um5.ac.ma\Documents\hadoop_project\hive\data"
```

#### 2. Copier les scripts HQL
```powershell
Copy-Item -Path "HIVE\scripts\*" -Destination "C:\Users\mouad\OneDrive - um5.ac.ma\Documents\hadoop_project\hive\scripts\" -Recurse

# Créer le dossier si nécessaire
New-Item -ItemType Directory -Force -Path "C:\Users\mouad\OneDrive - um5.ac.ma\Documents\hadoop_project\hive\scripts"
```

---

## 📝 Exécution des Scripts HQL

### Méthode 1 : Depuis Beeline (Ligne par ligne)

```bash
# Se connecter à Beeline
docker exec -it hiveserver2-standalone beeline -u jdbc:hive2://localhost:10000 scott tiger

# Exécuter les commandes directement
```

### Méthode 2 : Exécution des scripts complets

#### 1. Créer la base de données et les tables
```bash
docker exec -it hiveserver2-standalone bash
beeline -u jdbc:hive2://localhost:10000 scott tiger -f /shared_volume/hive/scripts/Creation.hql
```

#### 2. Charger les données
```bash
beeline -u jdbc:hive2://localhost:10000 scott tiger -f /shared_volume/hive/scripts/Loading.hql
```

#### 3. Exécuter les requêtes d'analyse
```bash
beeline -u jdbc:hive2://localhost:10000 scott tiger -f /shared_volume/hive/scripts/Queries.hql
```

#### 4. Nettoyer (optionnel)
```bash
beeline -u jdbc:hive2://localhost:10000 scott tiger -f /shared_volume/hive/scripts/Cleanup.hql
```

### Méthode 3 : Script unique
```bash
# Exécuter tout en une fois
docker exec -it hiveserver2-standalone bash -c "
  beeline -u jdbc:hive2://localhost:10000 scott tiger -f /shared_volume/hive/scripts/Creation.hql && \
  beeline -u jdbc:hive2://localhost:10000 scott tiger -f /shared_volume/hive/scripts/Loading.hql && \
  beeline -u jdbc:hive2://localhost:10000 scott tiger -f /shared_volume/hive/scripts/Queries.hql
"
```

---

## 📚 Description des Données

### Table `clients`
| Colonne      | Type   | Description              |
|--------------|--------|--------------------------|
| client_id    | INT    | Identifiant du client    |
| nom          | STRING | Nom du client            |
| email        | STRING | Email du client          |
| telephone    | STRING | Téléphone du client      |

### Table `hotels`
| Colonne      | Type   | Description              |
|--------------|--------|--------------------------|
| hotel_id     | INT    | Identifiant de l'hôtel   |
| nom          | STRING | Nom de l'hôtel           |
| etoiles      | INT    | Nombre d'étoiles (1-5)   |
| ville        | STRING | Ville de l'hôtel         |

### Table `reservations`
| Colonne         | Type          | Description                    |
|-----------------|---------------|--------------------------------|
| reservation_id  | INT           | Identifiant de la réservation  |
| client_id       | INT           | Référence au client            |
| hotel_id        | INT           | Référence à l'hôtel            |
| date_debut      | DATE          | Date de début (PARTITION)      |
| date_fin        | DATE          | Date de fin                    |
| prix_total      | DECIMAL(10,2) | Prix total de la réservation   |

---

## 🔍 Exemples de Requêtes

### Requêtes Simples

```sql
-- Lister tous les clients
SELECT * FROM clients;

-- Hôtels à Paris
SELECT * FROM hotels WHERE ville = 'Paris';
```

### Requêtes avec Jointures

```sql
-- Nombre de réservations par client
SELECT c.nom, COUNT(r.reservation_id) AS nb_reservations
FROM clients c
LEFT JOIN reservations r ON c.client_id = r.client_id
GROUP BY c.nom;

-- Clients avec plus de 2 nuitées
SELECT c.nom, DATEDIFF(r.date_fin, r.date_debut) AS nuitees
FROM clients c
JOIN reservations r ON c.client_id = r.client_id
WHERE DATEDIFF(r.date_fin, r.date_debut) > 2;
```

### Requêtes Imbriquées

```sql
-- Clients ayant réservé un hôtel 5 étoiles
SELECT DISTINCT c.nom
FROM clients c
WHERE c.client_id IN (
    SELECT r.client_id
    FROM reservations r
    JOIN hotels h ON r.hotel_id = h.hotel_id
    WHERE h.etoiles > 4
);

-- Revenus par hôtel
SELECT h.nom, SUM(r.prix_total) AS revenus_totaux
FROM hotels h
LEFT JOIN reservations r ON h.hotel_id = r.hotel_id
GROUP BY h.nom
ORDER BY revenus_totaux DESC;
```

---

## 🎯 Concepts Clés Abordés

### 1. **Partitionnement** (Partitions)
- Division des données en sous-ensembles basés sur une colonne
- Table `reservations` partitionnée par `date_debut`
- Améliore les performances des requêtes filtrées par date

```sql
PARTITIONED BY (date_debut DATE)
```

### 2. **Bucketing** (Buckets)
- Division des données en fichiers de taille fixe basée sur le hash d'une colonne
- Table `reservations_bucketed` avec 4 buckets par `client_id`
- Optimise les jointures et l'échantillonnage

```sql
CLUSTERED BY (client_id) INTO 4 BUCKETS
```

### 3. **Partitions Dynamiques**
- Création automatique de partitions lors du chargement
- Configuration nécessaire :

```sql
SET hive.exec.dynamic.partition=true;
SET hive.exec.dynamic.partition.mode=nonstrict;
```

---

## 📦 Vérification du Warehouse

### Lister le contenu du warehouse
```bash
# Dans le conteneur Hive
hadoop fs -ls /opt/hive/data/warehouse
hadoop fs -ls /opt/hive/data/warehouse/hotel_booking.db/
```

### Structure attendue
```
/opt/hive/data/warehouse/hotel_booking.db/
├── clients/
├── hotels/
├── reservations/
│   ├── date_debut=2024-01-15/
│   ├── date_debut=2024-01-20/
│   └── ...
├── hotels_partitioned/
│   ├── ville=Paris/
│   ├── ville=Lyon/
│   └── ville=Marseille/
└── reservations_bucketed/
    ├── 000000_0
    ├── 000001_0
    ├── 000002_0
    └── 000003_0
```

---

## 🛠️ Commandes Utiles Beeline

```sql
-- Afficher les bases de données
SHOW DATABASES;

-- Utiliser une base de données
USE hotel_booking;

-- Afficher les tables
SHOW TABLES;

-- Décrire une table
DESCRIBE clients;
DESCRIBE FORMATTED reservations;

-- Afficher les partitions
SHOW PARTITIONS reservations;

-- Compter les enregistrements
SELECT COUNT(*) FROM clients;

-- Quitter Beeline
!quit
```

---

## 🐛 Troubleshooting

### Erreur : "Database does not exist"
```sql
-- Créer la base de données manuellement
CREATE DATABASE hotel_booking;
USE hotel_booking;
```

### Erreur : "File not found"
```bash
# Vérifier le chemin des fichiers
docker exec -it hiveserver2-standalone ls -la /shared_volume/hive/data/

# Copier les fichiers si nécessaire
docker cp HIVE/data/clients.txt hiveserver2-standalone:/shared_volume/hive/data/
```

### Erreur : "Permission denied"
```bash
# Changer les permissions dans le conteneur
docker exec -it hiveserver2-standalone chmod -R 777 /shared_volume/hive/
```

### Vérifier les logs
```bash
docker logs hiveserver2-standalone
```

---

## 📊 Résultats Attendus

### Statistiques Globales
- **10 clients** enregistrés
- **10 hôtels** (Paris, Lyon, Marseille)
- **15 réservations** au total
- **3 villes** différentes

### Top Résultats
- **Ville la plus rentable** : Marseille
- **Client le plus actif** : Client ayant fait le plus de réservations
- **Hôtel le plus populaire** : Hôtel avec le plus de réservations

---

## 📖 Ressources

- [Documentation Apache Hive](https://hive.apache.org/)
- [Hive Language Manual](https://cwiki.apache.org/confluence/display/Hive/LanguageManual)
- [Beeline CLI](https://cwiki.apache.org/confluence/display/Hive/HiveServer2+Clients#HiveServer2Clients-Beeline–CommandLineShell)
- [Hive Partitioning](https://cwiki.apache.org/confluence/display/Hive/LanguageManual+DDL#LanguageManualDDL-PartitionedTables)

---

## ✅ Checklist de Validation

- [ ] Docker Compose démarré avec Hive
- [ ] Accès à HiveServer2 Web UI (http://localhost:10002)
- [ ] Connexion Beeline réussie
- [ ] Base de données `hotel_booking` créée
- [ ] Tables créées (clients, hotels, reservations)
- [ ] Données chargées avec succès
- [ ] Partitions créées automatiquement
- [ ] Buckets générés (4 fichiers)
- [ ] Requêtes simples exécutées
- [ ] Jointures fonctionnelles
- [ ] Requêtes imbriquées réussies
- [ ] Warehouse Hive exploré

---

**Auteur**: Lab Big Data - Apache Hive  
**Date**: 2025  
**Version**: 1.0
