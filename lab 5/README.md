# 🐷 Apache PIG Lab - Analyse de Données

## 📋 Description
Ce projet contient des exemples d'analyse de données avec Apache PIG Latin, incluant :
- WordCount (comptage de mots)
- Analyse des employés (10 requêtes business)

---

## 📂 Structure du Projet

```
PIG/
├── README.md                      # Ce fichier
├── data/                          # Données d'entrée
│   ├── alice.txt                  # Texte pour WordCount
│   ├── employees.txt              # Données des employés
│   └── departments.txt            # Données des départements
├── scripts/                       # Scripts PIG Latin
│   ├── wordcount.pig              # WordCount complet
│   ├── employee_analysis.pig      # Analyse complète des employés
│   └── q*.pig                     # Requêtes individuelles
├── output/                        # Résultats (généré)
└── utils/                         # Scripts utilitaires
    ├── setup.sh                   # Configuration initiale
    ├── verify_results.sh          # Vérification des résultats
    └── cleanup.sh                 # Nettoyage
```

---

## 🚀 I. Installation et Configuration

### Prérequis
- Docker installé
- Conteneur Hadoop/Hive démarré
- Apache PIG installé dans le conteneur

### Configuration Initiale

```powershell
# Copier les données dans le conteneur
docker cp PIG/data/employees.txt hadoop-master:/tmp/
docker cp PIG/data/departments.txt hadoop-master:/tmp/
docker cp PIG/scripts/ hadoop-master:/tmp/
```

### Charger les données dans HDFS

```bash
# Se connecter au conteneur
docker exec -it hadoop-master bash

# Créer les répertoires
hdfs dfs -mkdir -p input

# Copier les fichiers
hdfs dfs -put /tmp/employees.txt input/
hdfs dfs -put /tmp/departments.txt input/

# Vérifier
hdfs dfs -ls input/
```

---

## 📊 II. Exemples d'Utilisation

### WordCount (alice.txt)

```bash
# Copier alice.txt dans HDFS
hdfs dfs -put /tmp/alice.txt /shared_volume/

# Exécuter le WordCount
pig -x local /tmp/scripts/wordcount.pig

# Vérifier les résultats
hdfs dfs -cat pigout/WORD_COUNT/part-r-00000 | head -20
```

### Analyse des Employés

#### Exécution du Script Complet

```bash
# Nettoyer les anciens résultats
hdfs dfs -rm -r -f pigout

# Exécuter l'analyse complète
pig -x mapreduce /tmp/scripts/employee_analysis.pig
```

#### Exécution de Requêtes Individuelles

```bash
# Requête 1 : Salaire moyen par département
pig -x mapreduce /tmp/scripts/q01_avg_salary.pig

# Requête 10 : Départements avec femmes employées
pig -x mapreduce /tmp/scripts/q10_femmes_employees.pig
```

---

## 🔍 III. Vérification des Résultats

### Lister tous les résultats

```bash
hdfs dfs -ls -R pigout/
```

### Afficher un résultat spécifique

```bash
# Exemple : Départements avec femmes employées
hdfs dfs -cat pigout/employes_femmes/part-r-00000
```

### Script de vérification automatique

```bash
# Dans le conteneur
bash /tmp/utils/verify_results.sh
```

---

## 📥 IV. Téléchargement des Résultats

```powershell
# Copier tous les résultats sur Windows
docker exec hadoop-master bash -c "hdfs dfs -get pigout/* /tmp/"
docker cp hadoop-master:/tmp/pigout/. "PIG\output\"
```

---

## 📚 V. Description des Requêtes

| Requête | Description | Fichier Script | Sortie HDFS |
|---------|-------------|----------------|-------------|
| Q1 | Salaire moyen par département | `q01_avg_salary.pig` | `pigout/avg_salary_by_dept/` |
| Q2 | Nombre d'employés par département | `q02_count_employees.pig` | `pigout/count_by_dept/` |
| Q3 | Liste employés avec départements | `q03_emp_with_dept.pig` | `pigout/emp_with_dept/` |
| Q4 | Employés avec salaire > 60000 | `q04_high_salary.pig` | `pigout/high_salary_emp/` |
| Q5 | Département avec salaire le plus élevé | `q05_top_dept.pig` | `pigout/top_salary_dept/` |
| Q6 | Départements sans employés | `q06_empty_depts.pig` | `pigout/empty_depts/` |
| Q7 | Nombre total d'employés | `q07_total_count.pig` | `pigout/total_employees/` |
| Q8 | Employés de Paris | `q08_paris_employees.pig` | `pigout/paris_employees/` |
| Q9 | Salaire total par ville | `q09_salary_by_city.pig` | `pigout/total_salary_by_city/` |
| Q10 | Départements avec femmes employées | `q10_femmes_employees.pig` | `pigout/employes_femmes/` |

---

## 🛠️ VI. Scripts Utilitaires

### setup.sh
Configure l'environnement et charge les données dans HDFS.

```bash
bash PIG/utils/setup.sh
```

### verify_results.sh
Vérifie et affiche tous les résultats des requêtes.

```bash
bash PIG/utils/verify_results.sh
```

### cleanup.sh
Nettoie tous les résultats et fichiers temporaires.

```bash
bash PIG/utils/cleanup.sh
```

---

## 📖 VII. Ressources

- [Documentation Apache PIG](https://pig.apache.org/)
- [PIG Latin Reference](https://pig.apache.org/docs/latest/basic.html)
- [PIG Built-in Functions](https://pig.apache.org/docs/latest/func.html)
- [Tutoriel PIG](https://pig.apache.org/docs/latest/start.html)

---

## 📊 VIII. Résultats Attendus

### Q1 - Salaire moyen par département
```
10,57833.33
20,58000.0
30,63500.0
40,58000.0
50,63000.0
```

### Q10 - Départements avec femmes employées
```
Informatique,3
Marketing,3
Ventes,1
Ressources Humaines,2
Finance,1
```

---

## ✅ Checklist de Validation

- [ ] Données créées (`employees.txt`, `departments.txt`)
- [ ] Données chargées dans HDFS (`input/`)
- [ ] Script complet exécuté (`employee_analysis.pig`)
- [ ] 10 dossiers de résultats créés (`pigout/`)
- [ ] Résultat `employes_femmes` vérifié
- [ ] Tous les résultats cohérents
- [ ] Résultats téléchargés sur Windows

---

**Auteur** : Lab Big Data - Apache PIG  
**Date** : Novembre 2025  
**Version** : 1.0
