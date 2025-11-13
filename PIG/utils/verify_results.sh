#!/bin/bash
# ============================================
# Script de Vérification des Résultats PIG
# ============================================
# Description : Affiche tous les résultats des requêtes PIG

echo "===================================="
echo "📊 VÉRIFICATION DES RÉSULTATS PIG"
echo "===================================="
echo ""

# Vérifier si les résultats existent
if ! hdfs dfs -test -d pigout; then
    echo "❌ Aucun résultat trouvé dans HDFS (pigout/)"
    echo "   Veuillez exécuter les scripts PIG d'abord."
    exit 1
fi

echo "📂 Liste des résultats disponibles:"
hdfs dfs -ls pigout/
echo ""

# ============================================
# Fonction pour afficher un résultat
# ============================================
show_result() {
    local title=$1
    local path=$2
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "$title"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    if hdfs dfs -test -d "$path"; then
        hdfs dfs -cat "$path/part-r-00000" 2>/dev/null || hdfs dfs -cat "$path/part-m-00000" 2>/dev/null || echo "❌ Fichier de résultat introuvable"
    else
        echo "❌ Résultat non disponible"
    fi
    echo ""
}

# ============================================
# Afficher tous les résultats
# ============================================

show_result "1️⃣  SALAIRE MOYEN PAR DÉPARTEMENT" "pigout/avg_salary_by_dept"
show_result "2️⃣  NOMBRE D'EMPLOYÉS PAR DÉPARTEMENT" "pigout/count_by_dept"
show_result "3️⃣  EMPLOYÉS AVEC LEURS DÉPARTEMENTS (5 premiers)" "pigout/emp_with_dept"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "3️⃣  EMPLOYÉS AVEC LEURS DÉPARTEMENTS (5 premiers)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
hdfs dfs -cat pigout/emp_with_dept/part-r-00000 2>/dev/null | head -5 || echo "❌ Résultat non disponible"
echo ""

show_result "4️⃣  EMPLOYÉS AVEC SALAIRE > 60000" "pigout/high_salary_emp"
show_result "5️⃣  DÉPARTEMENT AVEC LE SALAIRE LE PLUS ÉLEVÉ" "pigout/top_salary_dept"
show_result "6️⃣  DÉPARTEMENTS SANS EMPLOYÉS" "pigout/empty_depts"
show_result "7️⃣  NOMBRE TOTAL D'EMPLOYÉS" "pigout/total_employees"
show_result "8️⃣  EMPLOYÉS DE PARIS" "pigout/paris_employees"
show_result "9️⃣  SALAIRE TOTAL PAR VILLE" "pigout/total_salary_by_city"
show_result "🔟 DÉPARTEMENTS AVEC FEMMES EMPLOYÉES" "pigout/employes_femmes"

echo "===================================="
echo "✅ VÉRIFICATION TERMINÉE"
echo "===================================="
echo ""
