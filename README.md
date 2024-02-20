# The Wave

C'est un projet informatique L2, qui consiste à fair une une platform de distribution de musique.

![logo](static/asserts/logo.png)

## Introduction

The Wave est une platform de distribution de musique, qui permet à utilisateur
d’écouter librement des musiques. Elle permettra aussi aussi aux utilisateurs
d’écouter nouvelles albums des groupes, créer et partager leurs playlist.Avec
des suggestions personnalisées.

## Demo

[Screencast from 02-20-2024 02:45:47 PM.webm](https://github.com/Vinesh-R/thewave/assets/113302604/a936affb-a087-49dc-880e-8f9f515a408d)

## Manuel d’utilisation

Au début, utilisateur se trouve dans landing page. Il peut s’inscrire et connecter.
Pour la raison de test, un utilisateur a été déjà créer. Pseudonyme : user , mot
de passe : user (même que pseudonyme).

**Page Accueil** :
Une fois connecter, l’utilisateur se trouve dans la page accueil. Dans cette page,
il aura des morceaux personnalisées, grâce à ces historiques.

**Page Explorer** :
Cette page permet aux utilisateur de découvrir les morceaux, les albums et les
playlists publiques.

**Page Historique** :
Cette page permet de voir les historique utilisateur connecter.

**Page Playlist** :
Cette page permet aux utilisateur de créer sa propre playlist, et gérer playlist
déjà créer.

**Page de Recherche** :
Grace à la barre de recherche, utilisateur peut rechercher la morceau, album,
artiste, groupe et playlist.

**Page de Morceau** :
Cette page permet d’écouter la musique,consulter les parloes et les informatiquons de la musique. Peut ajouter cette musique à playlist.

**Page de groupe** :
Grace à cette page, on peut obtenir les information sur les groupes, et suivre
cette groupe.


## Run Locally

Cette projet demande d'installtion postgresql et python3.

Clone cette projet

`git clone https://github.com/Vinesh-R/thewave.git`

Installer les bibliothèques python

`pip install -r requirements.txt`

Creer base de données **theWave** puis import la dump de BDD

`psql -h <hostname> -U <username> -d theWave -f dump.sql`

Modifiler les coordonnes de base de données dans la fichier `db.py` et executer la programme

`python3 main.py`

## Tech Stack

### Client
- HTML
- Bootstrap
- Javascript

### Server
- Pyhton
- flask
- postgresql
