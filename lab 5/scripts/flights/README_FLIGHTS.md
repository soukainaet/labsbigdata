# ✈️ Analyse des Vols Aériens avec Apache PIG

## 📋 Description

Ce projet analyse des données de vols aériens américains (1987-2008) avec Apache PIG.
Dataset original : http://stat-computing.org/dataexpo/2009/the-data.html

---

## 📊 Structure des Données

### Format CSV (29 colonnes)

| # | Colonne | Description | Type |
|---|---------|-------------|------|
| 1 | Year | Année (1987-2008) | int |
| 2 | Month | Mois (1-12) | int |
| 3 | DayofMonth | Jour du mois (1-31) | int |
| 4 | DayOfWeek | Jour de la semaine (1=Lundi, 7=Dimanche) | int |
| 5 | DepTime | Heure de départ réelle (hhmm) | int |
| 6 | CRSDepTime | Heure de départ prévue (hhmm) | int |
| 7 | ArrTime | Heure d'arrivée réelle (hhmm) | int |
| 8 | CRSArrTime | Heure d'arrivée prévue (hhmm) | int |
| 9 | UniqueCarrier | Code transporteur | chararray |
| 10 | FlightNum | Numéro de vol | int |
| 11 | TailNum | Numéro de queue d'avion | chararray |
| 12 | ActualElapsedTime | Temps réel (minutes) | int |
| 13 | CRSElapsedTime | Temps prévu (minutes) | int |
| 14 | AirTime | Temps de vol (minutes) | int |
| 15 | ArrDelay | Retard à l'arrivée (minutes) | int |
| 16 | DepDelay | Retard au départ (minutes) | int |
| 17 | Origin | Code aéroport de départ (IATA) | chararray |
| 18 | Dest | Code aéroport d'arrivée (IATA) | chararray |
| 19 | Distance | Distance (miles) | int |
| 20 | TaxiIn | Temps taxi entrée (minutes) | int |
| 21 | TaxiOut | Temps taxi sortie (minutes) | int |
| 22 | Cancelled | Vol annulé ? (0/1) | int |
| 23 | CancellationCode | Raison annulation (A/B/C/D) | chararray |
| 24 | Diverted | Vol dérouté ? (0/1) | int |
| 25 | CarrierDelay | Retard transporteur (minutes) | int |
| 26 | WeatherDelay | Retard météo (minutes) | int |
| 27 | NASDelay | Retard NAS (minutes) | int |
| 28 | SecurityDelay | Retard sécurité (minutes) | int |
| 29 | LateAircraftDelay | Retard avion en retard (minutes) | int |

---

## 🎯 Analyses à Réaliser

### 1. Top 20 des Aéroports par Volume de Vols
- Volume total de vols (entrants + sortants)
- Par jour, semaine, mois, année

### 2. Popularité des Transporteurs
- Volume de vols par année et transporteur
- Croissance en échelle logarithmique (base 10)
- Classement par volume médian

### 3. Proportion de Vols Retardés
- Vol retardé si retard > 15 minutes
- Par heure, jour, semaine, mois, année

### 4. Retards par Transporteur
- Proportion de vols retardés par transporteur
- À différentes granularités temporelles

### 5. Itinéraires les Plus Fréquentés
- Paires d'aéroports (origine, destination)
- Tableau de fréquences

---

## 📂 Fichiers Nécessaires

### Fichiers de Données

```
PIG/data/flights/
├── sample_flights.csv          # Échantillon pour tests
└── README.md                   # Description des données
```

**Note** : Pour les données complètes, télécharger depuis :
http://stat-computing.org/dataexpo/2009/the-data.html

### Scripts PIG

```
PIG/scripts/flights/
├── README_FLIGHTS.md           # Ce fichier
├── flights_analysis.pig        # Script complet d'analyse
├── f01_top_airports.pig        # Top 20 aéroports
├── f02_carrier_popularity.pig  # Popularité transporteurs
├── f03_delayed_flights.pig     # Proportion vols retardés
├── f04_carrier_delays.pig      # Retards par transporteur
├── f05_popular_routes.pig      # Itinéraires fréquentés
├── setup_flights.sh            # Configuration
└── verify_flights.sh           # Vérification résultats
```

---

## 🚀 I. Configuration et Chargement

### 1. Préparer les Données

```powershell
# Copier les fichiers dans le conteneur
docker cp "PIG\data\flights\sample_flights.csv" hadoop-master:/tmp/
docker cp "PIG\scripts\flights\" hadoop-master:/tmp/scripts/
```

### 2. Charger dans HDFS

```bash
# Se connecter au conteneur
docker exec -it hadoop-master bash

# Exécuter le script de setup
bash /tmp/scripts/flights/setup_flights.sh
```

**OU manuellement :**

```bash
# Créer les répertoires HDFS
hdfs dfs -mkdir -p input/flights

# Copier les fichiers
hdfs dfs -put /tmp/sample_flights.csv input/flights/

# Vérifier
hdfs dfs -ls input/flights/
hdfs dfs -cat input/flights/sample_flights.csv | head -5
```

---

## 📊 II. Analyses PIG Latin

### Script de Chargement des Données

```pig
-- Charger les données des vols
flights = LOAD 'input/flights/sample_flights.csv' 
    USING PigStorage(',') 
    AS (
        year:int,
        month:int,
        day:int,
        day_of_week:int,
        dep_time:int,
        crs_dep_time:int,
        arr_time:int,
        crs_arr_time:int,
        carrier:chararray,
        flight_num:int,
        tail_num:chararray,
        actual_elapsed_time:int,
        crs_elapsed_time:int,
        air_time:int,
        arr_delay:int,
        dep_delay:int,
        origin:chararray,
        dest:chararray,
        distance:int,
        taxi_in:int,
        taxi_out:int,
        cancelled:int,
        cancellation_code:chararray,
        diverted:int,
        carrier_delay:int,
        weather_delay:int,
        nas_delay:int,
        security_delay:int,
        late_aircraft_delay:int
    );

-- Filtrer les vols non annulés
valid_flights = FILTER flights BY cancelled == 0;

-- Afficher quelques vols
sample = LIMIT valid_flights 5;
DUMP sample;
```

---

## 🎯 III. Requêtes Détaillées

### Analyse 1 : Top 20 Aéroports par Volume

```pig
-- Vols sortants par aéroport
departures = FOREACH valid_flights GENERATE origin AS airport;
dep_grouped = GROUP departures BY airport;
dep_counts = FOREACH dep_grouped GENERATE 
    group AS airport,
    COUNT(departures) AS dep_count;

-- Vols entrants par aéroport
arrivals = FOREACH valid_flights GENERATE dest AS airport;
arr_grouped = GROUP arrivals BY airport;
arr_counts = FOREACH arr_grouped GENERATE 
    group AS airport,
    COUNT(arrivals) AS arr_count;

-- Joindre et calculer le total
airport_traffic = JOIN dep_counts BY airport FULL OUTER, arr_counts BY airport;

airport_volumes = FOREACH airport_traffic GENERATE 
    (dep_counts::airport IS NOT NULL ? dep_counts::airport : arr_counts::airport) AS airport,
    (dep_counts::dep_count IS NOT NULL ? dep_counts::dep_count : 0) AS departures,
    (arr_counts::arr_count IS NOT NULL ? arr_counts::arr_count : 0) AS arrivals,
    ((dep_counts::dep_count IS NOT NULL ? dep_counts::dep_count : 0) + 
     (arr_counts::arr_count IS NOT NULL ? arr_counts::arr_count : 0)) AS total_flights;

-- Trier et prendre le top 20
sorted_airports = ORDER airport_volumes BY total_flights DESC;
top20_airports = LIMIT sorted_airports 20;

-- Afficher et sauvegarder
DUMP top20_airports;
STORE top20_airports INTO 'pigout/flights/top20_airports';
```

---

### Analyse 2 : Popularité des Transporteurs

```pig
-- Grouper par année et transporteur
carrier_year = FOREACH valid_flights GENERATE year, carrier;
carrier_grouped = GROUP carrier_year BY (year, carrier);

-- Calculer le volume
carrier_volume = FOREACH carrier_grouped GENERATE 
    FLATTEN(group) AS (year, carrier),
    COUNT(carrier_year) AS flight_count,
    LOG10(COUNT(carrier_year)) AS log_volume;

-- Calculer le volume médian par transporteur (sur 4 ans)
carrier_only = FOREACH carrier_volume GENERATE carrier, log_volume;
carrier_stats = GROUP carrier_only BY carrier;

carrier_median = FOREACH carrier_stats {
    sorted = ORDER carrier_only BY log_volume;
    GENERATE 
        group AS carrier,
        AVG(carrier_only.log_volume) AS median_volume;
}

-- Trier par volume médian
sorted_carriers = ORDER carrier_median BY median_volume DESC;

-- Afficher et sauvegarder
DUMP sorted_carriers;
STORE sorted_carriers INTO 'pigout/flights/carrier_popularity';
```

---

### Analyse 3 : Proportion de Vols Retardés

```pig
-- Déterminer si un vol est retardé (> 15 minutes)
flights_with_delay_status = FOREACH valid_flights GENERATE 
    year,
    month,
    day,
    arr_delay,
    (arr_delay > 15 ? 1 : 0) AS is_delayed;

-- Par année
by_year = GROUP flights_with_delay_status BY year;
delay_by_year = FOREACH by_year GENERATE 
    group AS year,
    COUNT(flights_with_delay_status) AS total_flights,
    SUM(flights_with_delay_status.is_delayed) AS delayed_flights,
    (double)SUM(flights_with_delay_status.is_delayed) / COUNT(flights_with_delay_status) AS delay_proportion;

-- Par mois
by_month = GROUP flights_with_delay_status BY (year, month);
delay_by_month = FOREACH by_month GENERATE 
    FLATTEN(group) AS (year, month),
    COUNT(flights_with_delay_status) AS total_flights,
    SUM(flights_with_delay_status.is_delayed) AS delayed_flights,
    (double)SUM(flights_with_delay_status.is_delayed) / COUNT(flights_with_delay_status) AS delay_proportion;

-- Trier et afficher
sorted_delay_year = ORDER delay_by_year BY year;
DUMP sorted_delay_year;

STORE delay_by_year INTO 'pigout/flights/delays_by_year';
STORE delay_by_month INTO 'pigout/flights/delays_by_month';
```

---

### Analyse 4 : Retards par Transporteur

```pig
-- Statut de retard par transporteur
carrier_delays = FOREACH valid_flights GENERATE 
    carrier,
    year,
    month,
    (arr_delay > 15 ? 1 : 0) AS is_delayed;

-- Par transporteur et année
carrier_year_grouped = GROUP carrier_delays BY (carrier, year);
carrier_delay_stats = FOREACH carrier_year_grouped GENERATE 
    FLATTEN(group) AS (carrier, year),
    COUNT(carrier_delays) AS total_flights,
    SUM(carrier_delays.is_delayed) AS delayed_flights,
    (double)SUM(carrier_delays.is_delayed) / COUNT(carrier_delays) AS delay_rate;

-- Trier par taux de retard décroissant
sorted_carrier_delays = ORDER carrier_delay_stats BY delay_rate DESC;

-- Afficher et sauvegarder
DUMP sorted_carrier_delays;
STORE sorted_carrier_delays INTO 'pigout/flights/carrier_delays';
```

---

### Analyse 5 : Itinéraires les Plus Fréquentés

```pig
-- Créer des paires d'aéroports (non ordonnées)
routes = FOREACH valid_flights GENERATE 
    (origin < dest ? origin : dest) AS airport1,
    (origin < dest ? dest : origin) AS airport2,
    origin,
    dest;

-- Grouper par paire
routes_grouped = GROUP routes BY (airport1, airport2);

-- Compter les vols
route_frequencies = FOREACH routes_grouped GENERATE 
    FLATTEN(group) AS (airport1, airport2),
    COUNT(routes) AS flight_count;

-- Trier par fréquence
sorted_routes = ORDER route_frequencies BY flight_count DESC;

-- Top 20 itinéraires
top20_routes = LIMIT sorted_routes 20;

-- Afficher et sauvegarder
DUMP top20_routes;
STORE top20_routes INTO 'pigout/flights/popular_routes';
```

---

## 🔍 IV. Vérification des Résultats

### Lister tous les Résultats

```bash
hdfs dfs -ls -R pigout/flights/
```

### Afficher un Résultat

```bash
# Top 20 aéroports
hdfs dfs -cat pigout/flights/top20_airports/part-r-00000

# Itinéraires populaires
hdfs dfs -cat pigout/flights/popular_routes/part-r-00000 | head -20
```

### Script de Vérification

```bash
bash /tmp/scripts/flights/verify_flights.sh
```

---

## 📥 V. Téléchargement des Résultats

```powershell
# Copier tous les résultats sur Windows
docker exec hadoop-master bash -c "hdfs dfs -get pigout/flights/* /tmp/"
docker cp hadoop-master:/tmp/top20_airports/. "PIG\output\flights\top20_airports\"
docker cp hadoop-master:/tmp/popular_routes/. "PIG\output\flights\popular_routes\"
```

---

## 📚 VI. Résumé des Analyses

| # | Analyse | Description | Script | Sortie HDFS |
|---|---------|-------------|--------|-------------|
| 1 | Top Aéroports | Volume total de vols | `f01_top_airports.pig` | `pigout/flights/top20_airports/` |
| 2 | Popularité Transporteurs | Volume log par année | `f02_carrier_popularity.pig` | `pigout/flights/carrier_popularity/` |
| 3 | Vols Retardés | Proportion retards > 15min | `f03_delayed_flights.pig` | `pigout/flights/delays_by_*` |
| 4 | Retards Transporteurs | Taux retard par transporteur | `f04_carrier_delays.pig` | `pigout/flights/carrier_delays/` |
| 5 | Itinéraires Populaires | Top routes fréquentées | `f05_popular_routes.pig` | `pigout/flights/popular_routes/` |

---

## 🛑 VII. Arrêt des Conteneurs

### Sortir du Conteneur

```bash
# Dans le conteneur
exit
```

### Arrêter les Conteneurs Hadoop

```powershell
# Depuis Windows PowerShell
docker stop hadoop-master hadoop-slave1 hadoop-slave2

# Vérifier l'arrêt
docker ps -a | grep hadoop
```

### Redémarrer Plus Tard

```powershell
# Redémarrer les conteneurs
docker start hadoop-master hadoop-slave1 hadoop-slave2

# Vérifier qu'ils sont actifs
docker ps
```

---

## 🎓 VIII. Concepts Clés

### FLATTEN
- Aplatit les structures imbriquées
- Transforme un sac en lignes individuelles

### COGROUP vs JOIN
- **JOIN** : Association de tuples
- **COGROUP** : Regroupe avant de joindre

### Calculs Statistiques
- **COUNT** : Nombre d'éléments
- **SUM** : Somme
- **AVG** : Moyenne
- **LOG10** : Logarithme base 10

### Filtrage et Conditions
```pig
-- Filtrer
valid_flights = FILTER flights BY cancelled == 0;

-- Condition ternaire
is_delayed = (arr_delay > 15 ? 1 : 0);
```

---

## ✅ Checklist de Validation

- [ ] Fichiers CSV créés/téléchargés
- [ ] Données chargées dans HDFS (`input/flights/`)
- [ ] Schéma des données vérifié (29 colonnes)
- [ ] Analyse 1 : Top 20 aéroports calculé
- [ ] Analyse 2 : Popularité transporteurs calculée
- [ ] Analyse 3 : Proportion retards calculée
- [ ] Analyse 4 : Retards par transporteur calculés
- [ ] Analyse 5 : Itinéraires populaires calculés
- [ ] Tous les résultats sauvegardés dans HDFS
- [ ] Résultats vérifiés
- [ ] Conteneurs arrêtés proprement

---

## 📖 Ressources

- [Dataset Original](http://stat-computing.org/dataexpo/2009/the-data.html)
- [PIG Aggregate Functions](https://pig.apache.org/docs/latest/func.html#aggregate-functions)
- [PIG Math Functions](https://pig.apache.org/docs/latest/func.html#math-functions)

---

**Auteur** : Lab Big Data - Apache PIG  
**Date** : Novembre 2025  
**Version** : 1.0
