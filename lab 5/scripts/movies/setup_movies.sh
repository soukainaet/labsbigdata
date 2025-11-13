#!/bin/bash
# ============================================
# Setup Script - Analyse des Films
# ============================================

echo "🎬 Configuration de l'environnement pour l'analyse des films..."
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
hdfs dfs -mkdir -p input/movies
hdfs dfs -mkdir -p pigout/movies
echo "✅ Répertoires créés"
echo ""

# ============================================
# 3. Copier les fichiers JSON dans HDFS
# ============================================
echo "3️⃣ Chargement des données JSON dans HDFS..."

# Vérifier les emplacements possibles des fichiers
if [ -f "/tmp/films.json" ] && [ -f "/tmp/artists.json" ]; then
    hdfs dfs -put -f /tmp/films.json input/movies/
    hdfs dfs -put -f /tmp/artists.json input/movies/
    echo "✅ Données copiées depuis /tmp/"
elif [ -f "/shared_volume/pig/data/movies/films.json" ]; then
    hdfs dfs -put -f /shared_volume/pig/data/movies/films.json input/movies/
    hdfs dfs -put -f /shared_volume/pig/data/movies/artists.json input/movies/
    echo "✅ Données copiées depuis /shared_volume/pig/data/movies/"
else
    echo "❌ Fichiers JSON introuvables!"
    echo "   Veuillez copier films.json et artists.json dans /tmp/ ou /shared_volume/pig/data/movies/"
    exit 1
fi
echo ""

# ============================================
# 4. Vérifier les données
# ============================================
echo "4️⃣ Vérification des données JSON..."
echo ""
echo "Fichiers dans HDFS (input/movies/):"
hdfs dfs -ls input/movies/
echo ""

echo "Nombre de films:"
hdfs dfs -cat input/movies/films.json | wc -l
echo ""

echo "Nombre d'artistes:"
hdfs dfs -cat input/movies/artists.json | wc -l
echo ""

echo "Aperçu de films.json (2 premiers):"
hdfs dfs -cat input/movies/films.json | head -2
echo ""

echo "Aperçu de artists.json (2 premiers):"
hdfs dfs -cat input/movies/artists.json | head -2
echo ""

# ============================================
# 5. Configuration terminée
# ============================================
echo "✅ Configuration terminée avec succès!"
echo ""
echo "📊 Vous pouvez maintenant exécuter les scripts PIG:"
echo "   - pig -x mapreduce /tmp/scripts/movies/movies_analysis.pig"
echo "   - pig -x mapreduce /tmp/scripts/movies/m06_acteurs_realisateurs.pig"
echo ""
