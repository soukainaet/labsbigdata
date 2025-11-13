#!/bin/bash
# ============================================
# Vérification des Résultats - Analyse Vols
# ============================================

echo "===================================="
echo "✈️ VÉRIFICATION DES RÉSULTATS"
echo "===================================="
echo ""

# Vérifier si les résultats existent
if ! hdfs dfs -test -d pigout/flights; then
    echo "❌ Aucun résultat trouvé dans HDFS (pigout/flights/)"
    echo "   Veuillez exécuter les scripts PIG d'abord."
    exit 1
fi

echo "📂 Liste des résultats disponibles:"
hdfs dfs -ls pigout/flights/
echo ""

# Fonction pour afficher un résultat
show_result() {
    local title=$1
    local path=$2
    local limit=$3
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "$title"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    if hdfs dfs -test -d "$path"; then
        if [ -z "$limit" ]; then
            hdfs dfs -cat "$path/part-r-00000" 2>/dev/null || \
            hdfs dfs -cat "$path/part-m-00000" 2>/dev/null || \
            echo "❌ Fichier de résultat introuvable"
        else
            hdfs dfs -cat "$path/part-r-00000" 2>/dev/null | head -n "$limit" || \
            hdfs dfs -cat "$path/part-m-00000" 2>/dev/null | head -n "$limit" || \
            echo "❌ Fichier de résultat introuvable"
        fi
    else
        echo "❌ Résultat non disponible"
    fi
    echo ""
}

# Afficher tous les résultats
show_result "1️⃣  TOP 20 AÉROPORTS PAR VOLUME" "pigout/flights/top20_airports" 10
show_result "2️⃣  POPULARITÉ DES TRANSPORTEURS (5 premiers)" "pigout/flights/carrier_popularity" 5
show_result "3️⃣  PROPORTION DE VOLS RETARDÉS PAR ANNÉE" "pigout/flights/delays_by_year" 
show_result "4️⃣  RETARDS PAR TRANSPORTEUR (10 premiers)" "pigout/flights/carrier_delays_total" 10
show_result "5️⃣  ITINÉRAIRES LES PLUS FRÉQUENTÉS (10 premiers)" "pigout/flights/popular_routes" 10

echo "===================================="
echo "✅ VÉRIFICATION TERMINÉE"
echo "===================================="
echo ""

# Statistiques
echo "📊 Statistiques:"
echo "  - Nombre d'aéroports analysés: $(hdfs dfs -cat pigout/flights/top20_airports/part-r-00000 2>/dev/null | wc -l || echo 0)"
echo "  - Nombre de transporteurs: $(hdfs dfs -cat pigout/flights/carrier_popularity/part-r-00000 2>/dev/null | wc -l || echo 0)"
echo "  - Nombre d'itinéraires fréquentés: $(hdfs dfs -cat pigout/flights/popular_routes/part-r-00000 2>/dev/null | wc -l || echo 0)"
echo ""

# Analyse des retards
if hdfs dfs -test -d pigout/flights/delays_by_year; then
    echo "📈 Analyse des retards:"
    echo "  - Proportion moyenne de retards par année:"
    hdfs dfs -cat pigout/flights/delays_by_year/part-r-00000 2>/dev/null | awk -F',' '{print "    Année " $1 ": " ($4 * 100) "% de vols retardés"}'
    echo ""
fi
