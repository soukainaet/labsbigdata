# 🎬 Analyse des Films avec Apache PIG

## 📋 Description

Ce projet analyse une base de données de films au format JSON avec Apache PIG. Les données incluent :
- **Films** : informations complètes (titre, année, genre, pays, réalisateur, acteurs)
- **Artistes** : informations des acteurs et réalisateurs

---

## 📂 Structure des Données

### Format JSON - Films (films.json)

```json
{
  "_id": "movie:1",
  "title": "Vertigo",
  "year": 1958,
  "genre": "drama",
  "summary": "...",
  "country": "US",
  "director": {"_id": "artist:3"},
  "actors": [
    {"_id": "artist:15", "role": "John Ferguson"},
    {"_id": "artist:16", "role": "Madeleine Elster"}
  ]
}
```

### Format JSON - Artistes (artists.json)

```json
{
  "_id": "artist:15",
  "last_name": "Stewart",
  "first_name": "James",
  "birth_date": "1908"
}
```

---

## 🚀 I. Configuration et Chargement

### 1. Copier les Fichiers JSON dans le Conteneur

```powershell
# Depuis Windows PowerShell
docker cp "PIG\data\movies\films.json" hadoop-master:/tmp/
docker cp "PIG\data\movies\artists.json" hadoop-master:/tmp/
docker cp "PIG\scripts\movies\" hadoop-master:/tmp/scripts/
```

### 2. Charger dans HDFS

```bash
# Se connecter au conteneur
docker exec -it hadoop-master bash

# Exécuter le script de setup
bash /tmp/scripts/movies/setup_movies.sh
```

**OU manuellement :**

```bash
# Créer les répertoires
hdfs dfs -mkdir -p input/movies

# Copier les fichiers JSON
hdfs dfs -put /tmp/films.json input/movies/
hdfs dfs -put /tmp/artists.json input/movies/

# Vérifier
hdfs dfs -ls input/movies/
hdfs dfs -cat input/movies/films.json | head -2
```

---

## 📊 II. Requêtes PIG Latin

### 3. Ouvrir le Grunt Shell

```bash
# Lancer PIG en mode MapReduce
pig

# OU en mode local (plus rapide pour tests)
pig -x local
```

### 4. Charger les Fichiers JSON

```pig
-- Dans Grunt Shell

-- Charger les films
films_raw = LOAD 'input/movies/films.json' 
    USING JsonLoader('
        _id:chararray,
        title:chararray,
        year:int,
        genre:chararray,
        summary:chararray,
        country:chararray,
        director:(id:chararray),
        actors:{t:(id:chararray,role:chararray)}
    ');

-- Charger les artistes
artists_raw = LOAD 'input/movies/artists.json'
    USING JsonLoader('
        _id:chararray,
        last_name:chararray,
        first_name:chararray,
        birth_date:chararray
    ');

-- Vérifier les données
DESCRIBE films_raw;
DESCRIBE artists_raw;

-- Afficher quelques exemples
films_sample = LIMIT films_raw 2;
DUMP films_sample;
```

---

## 🎯 III. Analyses Demandées

### Requête 1 : Films Américains par Année (mUSA_annee)

```pig
-- Filtrer les films américains
films_usa = FILTER films_raw BY country == 'US';

-- Grouper par année
mUSA_annee = GROUP films_usa BY year;

-- Formater le résultat
result_annee = FOREACH mUSA_annee GENERATE 
    group AS annee,
    COUNT(films_usa) AS nb_films,
    films_usa.(title, genre) AS films;

-- Afficher
DUMP result_annee;

-- Sauvegarder
STORE result_annee INTO 'pigout/movies/mUSA_annee';
```

**Résultat attendu :**
```
(1958, 1, {(Vertigo, drama)})
(1977, 1, {(Star Wars, sci-fi)})
```

---

### Requête 2 : Films Américains par Réalisateur (mUSA_director)

```pig
-- Grouper par réalisateur
mUSA_director = GROUP films_usa BY director.id;

-- Formater
result_director = FOREACH mUSA_director GENERATE 
    group AS id_director,
    COUNT(films_usa) AS nb_films,
    films_usa.(title, year) AS films;

-- Afficher
DUMP result_director;

-- Sauvegarder
STORE result_director INTO 'pigout/movies/mUSA_director';
```

**Résultat attendu :**
```
(artist:1, 4, {(Vertigo,1958), (Psycho,1960), ...})
(artist:9, 3, {(The Godfather,1972), ...})
```

---

### Requête 3 : Triplets (idFilm, idActeur, role) - mUSA_acteurs

**Objectif :** Aplatir la collection `actors` imbriquée

```pig
-- Projection
films_with_actors = FOREACH films_usa GENERATE 
    _id AS film_id,
    title AS film_title,
    actors AS actors_list;

-- FLATTEN : aplatir la collection actors
mUSA_acteurs = FOREACH films_with_actors GENERATE 
    film_id,
    film_title,
    FLATTEN(actors_list) AS (actor_id:chararray, role:chararray);

-- Créer les triplets
acteurs_triplets = FOREACH mUSA_acteurs GENERATE 
    film_id,
    actor_id,
    role;

-- Afficher
DUMP acteurs_triplets;

-- Sauvegarder
STORE acteurs_triplets INTO 'pigout/movies/mUSA_acteurs';
```

**Résultat attendu :**
```
(movie:1, artist:2, John Ferguson)
(movie:1, artist:3, Madeleine Elster)
(movie:8, artist:14, Luke Skywalker)
(movie:8, artist:15, Han Solo)
```

---

### Requête 4 : Association Film → Description Acteur (moviesActors)

**Objectif :** Jointure entre films et artistes

```pig
-- DESCRIBE mUSA_acteurs pour voir les colonnes
DESCRIBE mUSA_acteurs;

-- Jointure
moviesActors = JOIN mUSA_acteurs BY actor_id, artists_raw BY _id;

-- Formater
moviesActors_formatted = FOREACH moviesActors GENERATE 
    mUSA_acteurs::film_id AS film_id,
    mUSA_acteurs::film_title AS film_title,
    artists_raw::_id AS actor_id,
    artists_raw::first_name AS actor_first_name,
    artists_raw::last_name AS actor_last_name,
    mUSA_acteurs::role AS role;

-- Afficher
DUMP moviesActors_formatted;

-- Sauvegarder
STORE moviesActors_formatted INTO 'pigout/movies/moviesActors';
```

**Résultat attendu :**
```
(movie:1, Vertigo, artist:2, James, Stewart, John Ferguson)
(movie:8, Star Wars, artist:14, Mark, Hamill, Luke Skywalker)
```

---

### Requête 5 : Films Complets avec Tous les Acteurs (fullMovies)

**Objectif :** COGROUP entre films et acteurs

```pig
-- Préparer les films
films_for_cogroup = FOREACH films_usa GENERATE 
    _id AS film_id,
    title,
    year,
    genre,
    director.id AS director_id;

-- COGROUP
fullMovies_cogroup = COGROUP films_for_cogroup BY film_id, 
                              moviesActors_formatted BY film_id;

-- Formater
fullMovies = FOREACH fullMovies_cogroup GENERATE 
    group AS film_id,
    FLATTEN(films_for_cogroup.(title, year, genre)) AS (title, year, genre),
    moviesActors_formatted.(actor_first_name, actor_last_name, role) AS actors;

-- Afficher (limité)
fullMovies_sample = LIMIT fullMovies 3;
DUMP fullMovies_sample;

-- Sauvegarder
STORE fullMovies INTO 'pigout/movies/fullMovies';
```

---

### Requête 6 : Acteurs/Réalisateurs (ActeursRealisateurs)

**Objectif :** Pour chaque artiste, liste des films joués ET dirigés

```pig
-- Films dirigés
films_directed = FOREACH films_usa GENERATE 
    director.id AS artist_id,
    _id AS film_id,
    title AS film_title;

directors_grouped = GROUP films_directed BY artist_id;

directors_list = FOREACH directors_grouped GENERATE 
    group AS artist_id,
    films_directed.(film_id, film_title) AS films_directed;

-- Films joués
films_acted_flat = FOREACH films_usa GENERATE 
    _id AS film_id,
    title AS film_title,
    FLATTEN(actors) AS (actor_id:chararray, role:chararray);

films_acted = FOREACH films_acted_flat GENERATE 
    actor_id AS artist_id,
    film_id,
    film_title,
    role;

actors_grouped = GROUP films_acted BY artist_id;

actors_list = FOREACH actors_grouped GENERATE 
    group AS artist_id,
    films_acted.(film_id, film_title, role) AS films_acted;

-- COGROUP
ActeursRealisateurs = COGROUP actors_list BY artist_id FULL OUTER, 
                               directors_list BY artist_id;

ActeursRealisateurs_result = FOREACH ActeursRealisateurs GENERATE 
    group AS artist_id,
    (directors_list IS NULL ? TOBAG(TOTUPLE()) : directors_list.films_directed) AS films_directed,
    (actors_list IS NULL ? TOBAG(TOTUPLE()) : actors_list.films_acted) AS films_acted;

-- Afficher
DUMP ActeursRealisateurs_result;

-- Sauvegarder dans pigout/ActeursRealisateurs
STORE ActeursRealisateurs_result INTO 'pigout/movies/ActeursRealisateurs';
```

**Résultat attendu :**
```
(artist:1, {(movie:1,Vertigo),(movie:2,Psycho)}, {})
(artist:15, {}, {(movie:8,Star Wars,Han Solo),(movie:10,Blade Runner,Deckard)})
```

---

## 🔍 IV. Vérification des Résultats

### Lister les Résultats HDFS

```bash
# Liste tous les dossiers de résultats
hdfs dfs -ls -R pigout/movies/
```

### Vérifier un Résultat Spécifique

```bash
# Requête 6 : ActeursRealisateurs
hdfs dfs -cat pigout/movies/ActeursRealisateurs/part-r-00000
```

### Script de Vérification Automatique

```bash
# Exécuter le script de vérification
bash /tmp/scripts/movies/verify_movies.sh
```

---

## 📥 V. Téléchargement des Résultats

```powershell
# Depuis Windows PowerShell
docker exec hadoop-master bash -c "hdfs dfs -get pigout/movies/* /tmp/"
docker cp hadoop-master:/tmp/mUSA_annee/. "PIG\output\movies\mUSA_annee\"
docker cp hadoop-master:/tmp/ActeursRealisateurs/. "PIG\output\movies\ActeursRealisateurs\"
```

---

## 📚 VI. Résumé des Requêtes

| # | Requête | Description | Script | Sortie HDFS |
|---|---------|-------------|--------|-------------|
| 1 | mUSA_annee | Films US groupés par année | `m01_usa_par_annee.pig` | `pigout/movies/mUSA_annee/` |
| 2 | mUSA_director | Films US groupés par réalisateur | `m02_usa_par_director.pig` | `pigout/movies/mUSA_director/` |
| 3 | mUSA_acteurs | Triplets (film, acteur, rôle) | `m03_acteurs_triplets.pig` | `pigout/movies/mUSA_acteurs/` |
| 4 | moviesActors | Films avec description acteurs | `m04_movies_actors.pig` | `pigout/movies/moviesActors/` |
| 5 | fullMovies | Films complets + acteurs | `m05_full_movies.pig` | `pigout/movies/fullMovies/` |
| 6 | ActeursRealisateurs | Artistes (acteur/réalisateur) | `m06_acteurs_realisateurs.pig` | `pigout/movies/ActeursRealisateurs/` |

---

## 🛠️ VII. Scripts Disponibles

### Exécution Manuelle

```bash
# Script complet d'analyse
pig -x mapreduce /tmp/scripts/movies/movies_analysis.pig

# Requête individuelle (ex: Q6)
pig -x mapreduce /tmp/scripts/movies/m06_acteurs_realisateurs.pig
```

### Scripts PowerShell (Windows)

```powershell
# Configuration
.\PIG\run-movies.ps1 -Action setup

# Analyse complète
.\PIG\run-movies.ps1 -Action analysis

# Vérification
.\PIG\run-movies.ps1 -Action verify
```

---

## ✅ Checklist de Validation

- [ ] Fichiers JSON créés (`films.json`, `artists.json`)
- [ ] Données chargées dans HDFS (`input/movies/`)
- [ ] Grunt Shell ouvert
- [ ] Films et artistes chargés avec `JsonLoader`
- [ ] Requête 1 : mUSA_annee exécutée
- [ ] Requête 2 : mUSA_director exécutée
- [ ] Requête 3 : mUSA_acteurs exécutée (FLATTEN)
- [ ] Requête 4 : moviesActors exécutée (JOIN)
- [ ] Requête 5 : fullMovies exécutée (COGROUP)
- [ ] Requête 6 : ActeursRealisateurs exécutée et sauvegardée
- [ ] Résultats vérifiés dans HDFS

---

## 📖 Ressources

- [PIG JsonLoader](https://pig.apache.org/docs/latest/func.html#jsonloader)
- [PIG FLATTEN](https://pig.apache.org/docs/latest/basic.html#flatten)
- [PIG COGROUP](https://pig.apache.org/docs/latest/basic.html#cogroup)
- [PIG JOIN](https://pig.apache.org/docs/latest/basic.html#join-outer)

---

**Auteur** : Lab Big Data - Apache PIG  
**Date** : Novembre 2025  
**Version** : 1.0
