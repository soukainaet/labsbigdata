# ✈️ Guide de Démarrage Rapide - Analyse des Vols

## 🚀 Installation Rapide (5 minutes)

### 1. Préparer les Données

```powershell
# Copier les fichiers dans le conteneur
docker cp "PIG\data\flights\sample_flights.csv" hadoop-master:/tmp/
docker cp "PIG\scripts\flights\" hadoop-master:/tmp/scripts/
```

### 2. Configuration

```bash
# Se connecter au conteneur
docker exec -it hadoop-master bash

# Exécuter le setup
bash /tmp/scripts/flights/setup_flights.sh
```

### 3. Exécuter les Analyses

```bash
# Top 20 aéroports
pig -x mapreduce /tmp/scripts/flights/f01_top_airports.pig

# Itinéraires populaires
pig -x mapreduce /tmp/scripts/flights/f05_popular_routes.pig
```

### 4. Vérifier les Résultats

```bash
bash /tmp/scripts/flights/verify_flights.sh
```

---

## 📊 Analyses Disponibles

| Script | Analyse | Résultat HDFS |
|--------|---------|---------------|
| `f01_top_airports.pig` | Top 20 aéroports | `pigout/flights/top20_airports/` |
| `f02_carrier_popularity.pig` | Popularité transporteurs | `pigout/flights/carrier_popularity/` |
| `f03_delayed_flights.pig` | Proportion retards | `pigout/flights/delays_by_*` |
| `f04_carrier_delays.pig` | Retards transporteurs | `pigout/flights/carrier_delays_*` |
| `f05_popular_routes.pig` | Itinéraires fréquentés | `pigout/flights/popular_routes/` |

---

## 🛑 Arrêt des Conteneurs

```bash
# Sortir du conteneur
exit
```

```powershell
# Arrêter les conteneurs Hadoop
docker stop hadoop-master hadoop-slave1 hadoop-slave2

# Vérifier
docker ps -a | grep hadoop
```

---

## 📥 Télécharger le Dataset Complet

Pour analyser toutes les années (1987-2008) :

1. **Visiter** : http://stat-computing.org/dataexpo/2009/the-data.html
2. **Télécharger** : Les fichiers CSV par année
3. **Placer** dans `PIG/data/flights/`
4. **Charger** dans HDFS avec le script setup

---

## ✅ Checklist

- [ ] Données sample_flights.csv copiées
- [ ] Scripts copiés dans le conteneur
- [ ] Setup exécuté
- [ ] Données dans HDFS
- [ ] Au moins une analyse exécutée
- [ ] Résultats vérifiés
- [ ] Conteneurs arrêtés

---

Pour plus de détails, voir [`README_FLIGHTS.md`](README_FLIGHTS.md)
