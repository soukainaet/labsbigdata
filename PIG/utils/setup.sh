#!/bin/bash
# ============================================
# Script de Configuration pour Apache PIG
# ============================================
# Description : Configure l'environnement et charge les données dans HDFS

echo "🐷 Configuration de l'environnement Apache PIG..."
echo ""

# ============================================
# 1. Vérifier que HDFS est démarré
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
hdfs dfs -mkdir -p input
hdfs dfs -mkdir -p pigout
echo "✅ Répertoires créés"
echo ""

# ============================================
# 3. Copier les données dans HDFS
# ============================================
echo "3️⃣ Chargement des données dans HDFS..."

# Vérifier si les fichiers existent
if [ -f "/tmp/employees.txt" ] && [ -f "/tmp/departments.txt" ]; then
    hdfs dfs -put -f /tmp/employees.txt input/
    hdfs dfs -put -f /tmp/departments.txt input/
    echo "✅ Données copiées depuis /tmp/"
elif [ -f "/shared_volume/pig/data/employees.txt" ]; then
    hdfs dfs -put -f /shared_volume/pig/data/employees.txt input/
    hdfs dfs -put -f /shared_volume/pig/data/departments.txt input/
    echo "✅ Données copiées depuis /shared_volume/pig/data/"
else
    echo "❌ Fichiers de données introuvables!"
    echo "   Veuillez copier employees.txt et departments.txt dans /tmp/ ou /shared_volume/pig/data/"
    exit 1
fi
echo ""

# ============================================
# 4. Vérifier les données
# ============================================
echo "4️⃣ Vérification des données..."
echo ""
echo "Fichiers dans HDFS (input/):"
hdfs dfs -ls input/
echo ""
echo "Aperçu de employees.txt:"
hdfs dfs -cat input/employees.txt | head -5
echo ""
echo "Aperçu de departments.txt:"
hdfs dfs -cat input/departments.txt
echo ""

# ============================================
# 5. Configuration terminée
# ============================================
echo "✅ Configuration terminée avec succès!"
echo ""
echo "📊 Vous pouvez maintenant exécuter les scripts PIG:"
echo "   - pig -x mapreduce /tmp/scripts/employee_analysis.pig"
echo "   - pig -x local /tmp/scripts/wordcount.pig"
echo ""
