# Own Audio Player - Server

Backend API pour Own Audio Player, une plateforme de streaming musical auto-hébergée.

## Installation

### Prérequis

- Node.js 18+
- npm ou yarn

### Configuration

1. Installer les dépendances :

```bash
npm install
```

2. Créer le fichier de configuration :

```bash
cp .env.example .env
```

3. Éditer `.env` et configurer votre bibliothèque musicale :

```env
PORT=3000
MUSIC_LIBRARY_PATH=/path/to/your/music
DATABASE_PATH=./data/database/music.db
```

## Utilisation

### Démarrer le serveur

Mode développement (avec auto-reload) :
```bash
npm run dev
```

Mode production :
```bash
npm start
```

Le serveur sera accessible sur `http://localhost:3000`

### Scanner votre bibliothèque musicale

Avant de pouvoir utiliser l'application, vous devez scanner votre bibliothèque :

```bash
npm run scan
```

Ou via l'API :
```bash
curl http://localhost:3000/api/library/scan
```

Le scan va :
- Parcourir tous les fichiers audio dans `MUSIC_LIBRARY_PATH`
- Extraire les métadonnées (titre, artiste, album, etc.)
- Créer la base de données SQLite
- Indexer tout pour une recherche rapide

Formats supportés : MP3, FLAC, OGG, M4A, WAV, AAC, Opus

## API Endpoints

### Bibliothèque

- `GET /api/library/scan` - Scanner la bibliothèque
- `GET /api/library/stats` - Statistiques de la bibliothèque

### Artistes

- `GET /api/artists` - Liste des artistes
- `GET /api/artists/:id` - Détails d'un artiste
- `GET /api/artists/:id/albums` - Albums d'un artiste
- `GET /api/artists/:id/tracks` - Pistes d'un artiste

### Albums

- `GET /api/albums` - Liste des albums
- `GET /api/albums/:id` - Détails d'un album
- `GET /api/albums/:id/tracks` - Pistes d'un album

### Pistes

- `GET /api/tracks` - Liste des pistes
- `GET /api/tracks/:id` - Détails d'une piste
- `GET /api/tracks/random/tracks` - Pistes aléatoires

### Streaming

- `GET /api/stream/:id` - Streamer une piste audio

### Recherche

- `GET /api/search?q=query` - Rechercher dans la bibliothèque

### Playlists

- `GET /api/playlists` - Liste des playlists
- `GET /api/playlists/:id` - Détails d'une playlist
- `POST /api/playlists` - Créer une playlist
- `PUT /api/playlists/:id` - Modifier une playlist
- `DELETE /api/playlists/:id` - Supprimer une playlist
- `POST /api/playlists/:id/tracks` - Ajouter une piste
- `DELETE /api/playlists/:id/tracks/:trackId` - Retirer une piste

## Exemples d'utilisation

### Obtenir les statistiques

```bash
curl http://localhost:3000/api/library/stats
```

Réponse :
```json
{
  "artists": 42,
  "albums": 156,
  "tracks": 1847,
  "playlists": 5,
  "total_duration": 445320,
  "total_size": 8589934592,
  "scanning": false
}
```

### Lister les artistes

```bash
curl http://localhost:3000/api/artists?limit=10&offset=0
```

### Rechercher

```bash
curl "http://localhost:3000/api/search?q=pink%20floyd"
```

### Créer une playlist

```bash
curl -X POST http://localhost:3000/api/playlists \
  -H "Content-Type: application/json" \
  -d '{"name": "Ma playlist", "description": "Mes morceaux préférés"}'
```

## Structure du projet

```
server/
├── src/
│   ├── api/              # Routes API
│   │   ├── artists.js
│   │   ├── albums.js
│   │   ├── tracks.js
│   │   ├── stream.js
│   │   ├── library.js
│   │   ├── search.js
│   │   └── playlists.js
│   ├── models/           # Modèles de données
│   │   └── database.js
│   ├── services/         # Logique métier
│   │   └── libraryService.js
│   ├── scripts/          # Scripts utilitaires
│   │   └── scanLibrary.js
│   └── index.js          # Point d'entrée
├── data/
│   ├── database/         # Base SQLite
│   └── library/          # Fichiers audio
└── package.json
```

## Base de données

Le serveur utilise SQLite pour stocker les métadonnées. La base est créée automatiquement au premier lancement.

Tables principales :
- `artists` - Artistes
- `albums` - Albums
- `tracks` - Pistes musicales
- `playlists` - Playlists
- `playlist_tracks` - Liaison playlists-pistes

## Streaming

Le serveur supporte les HTTP Range Requests, permettant :
- Lecture progressive (pas de téléchargement complet)
- Seeking dans les pistes
- Support multi-clients
- Cache navigateur

## Déploiement

### Service systemd

Créer `/etc/systemd/system/own-audio-player.service` :

```ini
[Unit]
Description=Own Audio Player Server
After=network.target

[Service]
Type=simple
User=www-data
WorkingDirectory=/opt/own-audio-player/server
Environment=NODE_ENV=production
ExecStart=/usr/bin/node src/index.js
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

Activer et démarrer :
```bash
sudo systemctl enable own-audio-player
sudo systemctl start own-audio-player
```

### Nginx reverse proxy

```nginx
server {
    listen 80;
    server_name music.example.com;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```

## Sécurité

Pour la production :

1. Utiliser HTTPS
2. Configurer CORS proprement
3. Ajouter de l'authentification
4. Limiter les taux de requêtes
5. Valider toutes les entrées

## Support

Consultez la documentation principale dans le dossier racine du projet.
