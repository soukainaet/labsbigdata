#!/bin/bash
# ============================================
# Script de Nettoyage Apache PIG
# ============================================
# Description : Supprime tous les résultats et fichiers temporaires

echo "🧹 Nettoyage des résultats Apache PIG..."
echo ""

# ============================================
# 1. Supprimer les résultats HDFS
# ============================================
echo "1️⃣ Suppression des résultats dans HDFS..."

if hdfs dfs -test -d pigout; then
    hdfs dfs -rm -r -f pigout
    echo "✅ Dossier pigout/ supprimé"
else
    echo "ℹ️  Aucun résultat à supprimer dans HDFS"
fi
echo ""

# ============================================
# 2. Nettoyer les fichiers temporaires locaux
# ============================================
echo "2️⃣ Nettoyage des fichiers temporaires locaux..."

rm -rf /tmp/pigout 2>/dev/null
rm -rf /tmp/pig_* 2>/dev/null
rm -rf /tmp/temp-* 2>/dev/null

echo "✅ Fichiers temporaires supprimés"
echo ""

# ============================================
# 3. Optionnel : Supprimer les données d'entrée
# ============================================
read -p "❓ Voulez-vous aussi supprimer les données d'entrée (input/) ? (y/N) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    hdfs dfs -rm -r -f input
    echo "✅ Dossier input/ supprimé"
else
    echo "ℹ️  Données d'entrée conservées"
fi
echo ""

# ============================================
# 4. Afficher l'état final
# ============================================
echo "📊 État final de HDFS:"
hdfs dfs -ls / 2>/dev/null
echo ""

echo "✅ Nettoyage terminé!"
echo ""
echo "💡 Pour recharger les données, exécutez:"
echo "   bash setup.sh"
echo ""
