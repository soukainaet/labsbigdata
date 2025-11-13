#!/bin/bash
# ============================================
# Vérification des Résultats - Analyse Films
# ============================================

echo "===================================="
echo "🎬 VÉRIFICATION DES RÉSULTATS"
echo "===================================="
echo ""

# Vérifier si les résultats existent
if ! hdfs dfs -test -d pigout/movies; then
    echo "❌ Aucun résultat trouvé dans HDFS (pigout/movies/)"
    echo "   Veuillez exécuter les scripts PIG d'abord."
    exit 1
fi

echo "📂 Liste des résultats disponibles:"
hdfs dfs -ls pigout/movies/
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
show_result "1️⃣  FILMS AMÉRICAINS PAR ANNÉE (5 premiers)" "pigout/movies/mUSA_annee" 5
show_result "2️⃣  FILMS AMÉRICAINS PAR RÉALISATEUR (5 premiers)" "pigout/movies/mUSA_director" 5
show_result "3️⃣  TRIPLETS (film, acteur, rôle) (10 premiers)" "pigout/movies/mUSA_acteurs" 10
show_result "4️⃣  FILMS AVEC DESCRIPTION ACTEURS (10 premiers)" "pigout/movies/moviesActors" 10
show_result "5️⃣  FILMS COMPLETS AVEC TOUS LES ACTEURS (3 premiers)" "pigout/movies/fullMovies" 3
show_result "6️⃣  ACTEURS/RÉALISATEURS (10 premiers)" "pigout/movies/ActeursRealisateurs" 10

echo "===================================="
echo "✅ VÉRIFICATION TERMINÉE"
echo "===================================="
echo ""

# Statistiques
echo "📊 Statistiques:"
echo "  - Nombre de films américains par année: $(hdfs dfs -cat pigout/movies/mUSA_annee/part-r-00000 2>/dev/null | wc -l || echo 0)"
echo "  - Nombre de réalisateurs: $(hdfs dfs -cat pigout/movies/mUSA_director/part-r-00000 2>/dev/null | wc -l || echo 0)"
echo "  - Nombre de triplets (film, acteur, rôle): $(hdfs dfs -cat pigout/movies/mUSA_acteurs/part-r-00000 2>/dev/null | wc -l || echo 0)"
echo ""
