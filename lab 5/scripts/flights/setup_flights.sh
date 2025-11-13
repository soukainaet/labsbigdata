#!/bin/bash
# ============================================
# Setup Script - Analyse des Vols
# ============================================

echo "✈️ Configuration de l'environnement pour l'analyse des vols..."
echo ""

# ============================================
# 1. Vérifier HDFS
# ============================================
echo "1️⃣ Vérification de HDFS..."
if ! hdfs dfsadmin -report &> /dev/null; then
    echo "❌ HDFS n'est pas démarré. Démarrage..."
    start-dfs.sh
    sleep 5
fi
echo "✅ HDFS est opérationnel"
echo ""

# ============================================
# 2. Créer les répertoires HDFS
# ============================================
echo "2️⃣ Création des répertoires HDFS..."
hdfs dfs -mkdir -p input/flights
hdfs dfs -mkdir -p pigout/flights
echo "✅ Répertoires créés"
echo ""

# ============================================
# 3. Copier les fichiers CSV dans HDFS
# ============================================
echo "3️⃣ Chargement des données CSV dans HDFS..."

# Vérifier les emplacements possibles des fichiers
if [ -f "/tmp/sample_flights.csv" ]; then
    hdfs dfs -put -f /tmp/sample_flights.csv input/flights/
    echo "✅ Données copiées depuis /tmp/"
elif [ -f "/shared_volume/pig/data/flights/sample_flights.csv" ]; then
    hdfs dfs -put -f /shared_volume/pig/data/flights/sample_flights.csv input/flights/
    echo "✅ Données copiées depuis /shared_volume/pig/data/flights/"
else
    echo "❌ Fichiers CSV introuvables!"
    echo "   Veuillez copier sample_flights.csv dans /tmp/ ou /shared_volume/pig/data/flights/"
    exit 1
fi
echo ""

# ============================================
# 4. Vérifier les données
# ============================================
echo "4️⃣ Vérification des données CSV..."
echo ""
echo "Fichiers dans HDFS (input/flights/):"
hdfs dfs -ls input/flights/
echo ""

echo "Nombre de vols (lignes):"
hdfs dfs -cat input/flights/sample_flights.csv | wc -l
echo ""

echo "Aperçu des données (5 premières lignes):"
hdfs dfs -cat input/flights/sample_flights.csv | head -5
echo ""

echo "Aperçu de l'en-tête:"
hdfs dfs -cat input/flights/sample_flights.csv | head -1
echo ""

# ============================================
# 5. Configuration terminée
# ============================================
echo "✅ Configuration terminée avec succès!"
echo ""
echo "📊 Vous pouvez maintenant exécuter les scripts PIG:"
echo "   - pig -x mapreduce /tmp/scripts/flights/f01_top_airports.pig"
echo "   - pig -x mapreduce /tmp/scripts/flights/f05_popular_routes.pig"
echo ""
echo "ℹ️ Pour télécharger le dataset complet :"
echo "   http://stat-computing.org/dataexpo/2009/the-data.html"
echo ""
