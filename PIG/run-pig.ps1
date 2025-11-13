# ============================================
# Script PowerShell - Exécution Apache PIG
# ============================================
# Description : Script d'automatisation pour exécuter les analyses PIG

param(
    [Parameter(Mandatory = $false)]
    [ValidateSet("setup", "wordcount", "analysis", "verify", "cleanup", "all")]
    [string]$Action = "all",
    
    [Parameter(Mandatory = $false)]
    [string]$Container = "hadoop-master"
)

# Configuration
$ErrorActionPreference = "Stop"
$PigDataPath = "PIG\data"
$PigScriptsPath = "PIG\scripts"
$PigUtilsPath = "PIG\utils"
$PigOutputPath = "PIG\output"

# ============================================
# Fonctions Utilitaires
# ============================================

function Write-Step {
    param([string]$Message)
    Write-Host "`n$Message" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "✅ $Message" -ForegroundColor Green
}

function Write-Error-Custom {
    param([string]$Message)
    Write-Host "❌ $Message" -ForegroundColor Red
}

function Test-Container {
    if (-not (docker ps -q -f name=$Container)) {
        Write-Error-Custom "Le conteneur $Container n'est pas démarré!"
        Write-Host "Démarrez-le avec: docker-compose up -d" -ForegroundColor Yellow
        exit 1
    }
}

# ============================================
# Action: Setup (Configuration)
# ============================================

function Invoke-Setup {
    Write-Step "🔧 Configuration de l'environnement PIG..."
    
    # Copier les fichiers de données
    Write-Host "📦 Copie des fichiers de données..." -ForegroundColor Yellow
    docker cp "$PigDataPath\employees.txt" ${Container}:/tmp/
    docker cp "$PigDataPath\departments.txt" ${Container}:/tmp/
    docker cp "$PigDataPath\alice.txt" ${Container}:/tmp/
    Write-Success "Données copiées"
    
    # Copier les scripts
    Write-Host "📦 Copie des scripts PIG..." -ForegroundColor Yellow
    docker cp "$PigScriptsPath" ${Container}:/tmp/
    Write-Success "Scripts copiés"
    
    # Copier les utilitaires
    Write-Host "📦 Copie des utilitaires..." -ForegroundColor Yellow
    docker cp "$PigUtilsPath" ${Container}:/tmp/
    docker exec $Container bash -c "chmod +x /tmp/utils/*.sh"
    Write-Success "Utilitaires copiés"
    
    # Exécuter le script de setup
    Write-Host "⚙️ Exécution du script de configuration..." -ForegroundColor Yellow
    docker exec $Container bash /tmp/utils/setup.sh
    
    Write-Success "Configuration terminée!"
}

# ============================================
# Action: WordCount
# ============================================

function Invoke-WordCount {
    Write-Step "📝 Exécution du WordCount..."
    
    # Copier alice.txt dans le volume partagé
    docker exec $Container bash -c "
        mkdir -p /shared_volume && \
        cp /tmp/alice.txt /shared_volume/ 2>/dev/null || true
    "
    
    # Exécuter le script WordCount
    docker exec $Container pig -x local /tmp/scripts/wordcount.pig
    
    Write-Success "WordCount terminé!"
}

# ============================================
# Action: Analysis (Analyse des employés)
# ============================================

function Invoke-Analysis {
    Write-Step "📊 Analyse des employés..."
    
    # Nettoyer les anciens résultats
    Write-Host "🧹 Nettoyage des anciens résultats..." -ForegroundColor Yellow
    docker exec $Container bash -c "hdfs dfs -rm -r -f pigout 2>/dev/null || true"
    
    # Exécuter le script d'analyse
    Write-Host "🚀 Exécution du script d'analyse complet..." -ForegroundColor Yellow
    docker exec $Container pig -x mapreduce /tmp/scripts/employee_analysis.pig
    
    Write-Success "Analyse terminée!"
}

# ============================================
# Action: Verify (Vérification des résultats)
# ============================================

function Invoke-Verify {
    Write-Step "🔍 Vérification des résultats..."
    
    docker exec $Container bash /tmp/utils/verify_results.sh
    
    Write-Success "Vérification terminée!"
}

# ============================================
# Action: Cleanup (Nettoyage)
# ============================================

function Invoke-Cleanup {
    Write-Step "🧹 Nettoyage des résultats..."
    
    docker exec $Container bash -c "hdfs dfs -rm -r -f pigout 2>/dev/null || true"
    docker exec $Container bash -c "rm -rf /tmp/pigout /tmp/pig_* /tmp/temp-* 2>/dev/null || true"
    
    Write-Success "Nettoyage terminé!"
}

# ============================================
# Action: Download (Télécharger les résultats)
# ============================================

function Invoke-Download {
    Write-Step "📥 Téléchargement des résultats..."
    
    # Créer le dossier de sortie
    New-Item -ItemType Directory -Force -Path $PigOutputPath | Out-Null
    
    # Copier les résultats depuis HDFS vers /tmp
    docker exec $Container bash -c "
        hdfs dfs -get pigout/* /tmp/ 2>/dev/null || true
    "
    
    # Copier depuis le conteneur vers Windows
    docker cp ${Container}:/tmp/pigout/. "$PigOutputPath\"
    
    Write-Success "Résultats téléchargés dans $PigOutputPath\"
}

# ============================================
# Exécution Principale
# ============================================

Write-Host @"
╔═══════════════════════════════════════╗
║   🐷 Apache PIG - Script PowerShell   ║
╚═══════════════════════════════════════╝
"@ -ForegroundColor Magenta

# Vérifier que le conteneur est démarré
Test-Container

# Exécuter l'action demandée
switch ($Action) {
    "setup" {
        Invoke-Setup
    }
    "wordcount" {
        Invoke-WordCount
    }
    "analysis" {
        Invoke-Analysis
    }
    "verify" {
        Invoke-Verify
    }
    "cleanup" {
        Invoke-Cleanup
    }
    "all" {
        Invoke-Setup
        Start-Sleep -Seconds 2
        Invoke-Analysis
        Start-Sleep -Seconds 2
        Invoke-Verify
        Start-Sleep -Seconds 2
        Invoke-Download
    }
}

Write-Host "`n════════════════════════════════════════" -ForegroundColor Magenta
Write-Host "✅ Opération terminée avec succès!" -ForegroundColor Green
Write-Host "════════════════════════════════════════`n" -ForegroundColor Magenta

# Afficher les commandes disponibles
if ($Action -eq "all" -or $Action -eq "setup") {
    Write-Host "📚 Commandes disponibles:" -ForegroundColor Cyan
    Write-Host "  .\run-pig.ps1 -Action setup      # Configuration initiale" -ForegroundColor White
    Write-Host "  .\run-pig.ps1 -Action wordcount  # Exécuter WordCount" -ForegroundColor White
    Write-Host "  .\run-pig.ps1 -Action analysis   # Analyser les employés" -ForegroundColor White
    Write-Host "  .\run-pig.ps1 -Action verify     # Vérifier les résultats" -ForegroundColor White
    Write-Host "  .\run-pig.ps1 -Action cleanup    # Nettoyer les résultats" -ForegroundColor White
    Write-Host "  .\run-pig.ps1 -Action all        # Tout exécuter" -ForegroundColor White
    Write-Host ""
}
