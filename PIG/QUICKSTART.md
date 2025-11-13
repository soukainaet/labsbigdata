# Guide de Démarrage Rapide - Apache PIG

## 🚀 Démarrage Rapide (5 minutes)

### 1. Configuration Initiale

```powershell
# Copier les données dans le conteneur
.\PIG\run-pig.ps1 -Action setup
```

### 2. Exécuter l'Analyse Complète

```powershell
# Analyser les données des employés
.\PIG\run-pig.ps1 -Action analysis
```

### 3. Vérifier les Résultats

```powershell
# Afficher tous les résultats
.\PIG\run-pig.ps1 -Action verify
```

---

## 📋 Commandes Disponibles

| Commande | Description |
|----------|-------------|
| `.\PIG\run-pig.ps1 -Action setup` | Configuration initiale |
| `.\PIG\run-pig.ps1 -Action wordcount` | Exécuter WordCount |
| `.\PIG\run-pig.ps1 -Action analysis` | Analyser les employés |
| `.\PIG\run-pig.ps1 -Action verify` | Vérifier les résultats |
| `.\PIG\run-pig.ps1 -Action cleanup` | Nettoyer les résultats |
| `.\PIG\run-pig.ps1 -Action all` | **Tout exécuter** |

---

## 📊 Exécution Manuelle dans le Conteneur

### Se connecter au conteneur

```powershell
docker exec -it hadoop-master bash
```

### Exécuter un script PIG

```bash
# Script complet d'analyse
pig -x mapreduce /tmp/scripts/employee_analysis.pig

# Requête individuelle (ex: Q10)
pig -x mapreduce /tmp/scripts/q10_femmes_employees.pig

# WordCount en mode local
pig -x local /tmp/scripts/wordcount.pig
```

### Vérifier les résultats

```bash
# Lister les résultats
hdfs dfs -ls -R pigout/

# Afficher un résultat
hdfs dfs -cat pigout/employes_femmes/part-r-00000
```

---

## 🔧 Scripts Utilitaires

### setup.sh - Configuration

```bash
bash /tmp/utils/setup.sh
```

### verify_results.sh - Vérification

```bash
bash /tmp/utils/verify_results.sh
```

### cleanup.sh - Nettoyage

```bash
bash /tmp/utils/cleanup.sh
```

---

## 📁 Structure des Fichiers

```
PIG/
├── README.md                      # Documentation complète
├── QUICKSTART.md                  # Ce fichier
├── run-pig.ps1                    # Script PowerShell principal
├── data/
│   ├── employees.txt              # 20 employés
│   ├── departments.txt            # 6 départements
│   └── alice.txt                  # Texte pour WordCount
├── scripts/
│   ├── wordcount.pig              # WordCount
│   ├── employee_analysis.pig      # Analyse complète
│   └── q01-q10_*.pig              # Requêtes individuelles
├── output/                        # Résultats (généré)
└── utils/
    ├── setup.sh                   # Configuration
    ├── verify_results.sh          # Vérification
    └── cleanup.sh                 # Nettoyage
```

---

## ✅ Checklist

- [ ] Conteneur Hadoop démarré
- [ ] Configuration exécutée (`setup`)
- [ ] Données chargées dans HDFS
- [ ] Analyse exécutée (`analysis`)
- [ ] Résultats vérifiés (`verify`)
- [ ] 10 dossiers créés dans `pigout/`

---

## 🆘 Dépannage

### Erreur: "Container not running"

```powershell
docker-compose up -d
```

### Erreur: "HDFS not found"

```bash
# Dans le conteneur
start-dfs.sh
```

### Nettoyer et recommencer

```powershell
.\PIG\run-pig.ps1 -Action cleanup
.\PIG\run-pig.ps1 -Action all
```

---

## 📖 Pour en savoir plus

Consultez le fichier `README.md` pour la documentation complète.
