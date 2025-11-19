# Architecture technique - Own Audio Player

## Vue d'ensemble

Own Audio Player est une application de streaming musical auto-hébergée composée de deux parties principales :
1. **Serveur Backend** : API REST pour gérer la bibliothèque musicale et streamer l'audio
2. **Client Multi-plateforme** : Application Flutter pour Android, iOS, Windows et Linux

## Diagramme d'architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        CLIENTS                                   │
├──────────────┬──────────────┬──────────────┬───────────────────┤
│   Android    │     iOS      │   Windows    │      Linux        │
│   (Flutter)  │  (Flutter)   │  (Flutter)   │    (Flutter)      │
└──────┬───────┴──────┬───────┴──────┬───────┴───────┬───────────┘
       │              │              │               │
       └──────────────┴──────────────┴───────────────┘
                      │
              ┌───────▼────────┐
              │   REST API     │
              │  (HTTPS/HTTP)  │
              └───────┬────────┘
                      │
       ┌──────────────▼──────────────┐
       │      SERVEUR BACKEND        │
       │       (Node.js)             │
       ├─────────────────────────────┤
       │  ┌─────────────────────┐   │
       │  │   API Routes        │   │
       │  │   (Express)         │   │
       │  └──────────┬──────────┘   │
       │             │               │
       │  ┌──────────▼──────────┐   │
       │  │   Services Layer    │   │
       │  │  - Library Service  │   │
       │  │  - Stream Service   │   │
       │  │  - Metadata Service │   │
       │  └──────────┬──────────┘   │
       │             │               │
       │  ┌──────────▼──────────┐   │
       │  │   Data Layer        │   │
       │  │  - SQLite DB        │   │
       │  │  - File System      │   │
       │  └─────────────────────┘   │
       └─────────────────────────────┘
                │         │
        ┌───────▼───┐ ┌──▼──────────┐
        │ SQLite DB │ │ Music Files │
        │(Metadata) │ │(.mp3, .flac)│
        └───────────┘ └─────────────┘
```

## Backend - Serveur Node.js

### Architecture en couches

```
┌─────────────────────────────────────┐
│         HTTP Layer                  │
│  (Express, CORS, Body Parser)       │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│       Middleware Layer              │
│  - Authentication                   │
│  - Error Handling                   │
│  - Request Validation               │
│  - Logging                          │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│        API Routes Layer             │
│  /api/artists                       │
│  /api/albums                        │
│  /api/tracks                        │
│  /api/stream/:id                    │
│  /api/search                        │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│      Business Logic Layer           │
│  - LibraryService                   │
│  - StreamService                    │
│  - MetadataExtractor                │
│  - SearchService                    │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│       Data Access Layer             │
│  - DatabaseManager (SQLite)         │
│  - FileSystemManager                │
└─────────────────────────────────────┘
```

### Modèle de données (SQLite)

```sql
-- Table des artistes
CREATE TABLE artists (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  album_count INTEGER DEFAULT 0,
  track_count INTEGER DEFAULT 0,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Table des albums
CREATE TABLE albums (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  artist_id TEXT NOT NULL,
  artist_name TEXT NOT NULL,
  year INTEGER,
  track_count INTEGER DEFAULT 0,
  cover_path TEXT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (artist_id) REFERENCES artists(id)
);

-- Table des pistes
CREATE TABLE tracks (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  artist_id TEXT NOT NULL,
  artist_name TEXT NOT NULL,
  album_id TEXT NOT NULL,
  album_name TEXT NOT NULL,
  duration INTEGER NOT NULL,
  track_number INTEGER,
  disc_number INTEGER DEFAULT 1,
  year INTEGER,
  genre TEXT,
  file_path TEXT NOT NULL,
  file_size INTEGER,
  bitrate INTEGER,
  sample_rate INTEGER,
  format TEXT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (artist_id) REFERENCES artists(id),
  FOREIGN KEY (album_id) REFERENCES albums(id)
);

-- Table des playlists
CREATE TABLE playlists (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  track_count INTEGER DEFAULT 0,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Table de liaison playlists-tracks
CREATE TABLE playlist_tracks (
  playlist_id TEXT NOT NULL,
  track_id TEXT NOT NULL,
  position INTEGER NOT NULL,
  added_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (playlist_id, track_id),
  FOREIGN KEY (playlist_id) REFERENCES playlists(id),
  FOREIGN KEY (track_id) REFERENCES tracks(id)
);

-- Index pour performance
CREATE INDEX idx_tracks_artist ON tracks(artist_id);
CREATE INDEX idx_tracks_album ON tracks(album_id);
CREATE INDEX idx_tracks_title ON tracks(title);
CREATE INDEX idx_albums_artist ON albums(artist_id);
CREATE INDEX idx_playlist_tracks_playlist ON playlist_tracks(playlist_id);
```

### Service de streaming

Le streaming audio utilise les HTTP Range Requests pour permettre :
- Lecture progressive (pas besoin de télécharger tout le fichier)
- Support du seeking (avance/recul dans la piste)
- Optimisation de la bande passante

```javascript
// Exemple de réponse streaming
app.get('/api/stream/:trackId', async (req, res) => {
  const { trackId } = req.params;
  const track = await db.getTrack(trackId);
  const range = req.headers.range;

  if (range) {
    // Support des Range Requests
    const [start, end] = parseRange(range, track.file_size);
    res.status(206)
       .header('Content-Range', `bytes ${start}-${end}/${track.file_size}`)
       .header('Accept-Ranges', 'bytes')
       .header('Content-Length', end - start + 1)
       .header('Content-Type', 'audio/mpeg');

    const stream = fs.createReadStream(track.file_path, { start, end });
    stream.pipe(res);
  } else {
    // Streaming complet
    res.header('Content-Length', track.file_size)
       .header('Content-Type', 'audio/mpeg');

    const stream = fs.createReadStream(track.file_path);
    stream.pipe(res);
  }
});
```

## Frontend - Application Flutter

### Architecture MVVM (Model-View-ViewModel)

```
┌─────────────────────────────────────┐
│            VIEW LAYER               │
│  (Screens & Widgets)                │
│  - HomeScreen                       │
│  - LibraryScreen                    │
│  - PlayerScreen                     │
│  - SearchScreen                     │
└──────────────┬──────────────────────┘
               │ UI Events
               │ (User interactions)
               │
┌──────────────▼──────────────────────┐
│       VIEWMODEL LAYER               │
│  (Providers / State Management)     │
│  - PlayerProvider                   │
│  - LibraryProvider                  │
│  - PlaylistProvider                 │
└──────────────┬──────────────────────┘
               │ Business Logic
               │
┌──────────────▼──────────────────────┐
│       SERVICE LAYER                 │
│  - ApiService (HTTP)                │
│  - AudioService (Playback)          │
│  - NotificationService              │
│  - BluetoothService                 │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│         MODEL LAYER                 │
│  - Track                            │
│  - Album                            │
│  - Artist                           │
│  - Playlist                         │
└─────────────────────────────────────┘
```

### Flux de données

```
User Action → Widget → Provider → Service → API/Audio
                ↓                     ↓
              Update ← State Change ← Response
                ↓
           UI Rebuild
```

### Gestion de l'audio

L'application utilise le package `audio_service` qui permet :
- Lecture en arrière-plan
- Contrôles depuis les notifications
- Support des contrôles Bluetooth
- Intégration avec l'OS (Android Auto, CarPlay, etc.)

```dart
// Architecture du service audio
AudioService
  ├── AudioHandler (Gestion des commandes)
  │   ├── play()
  │   ├── pause()
  │   ├── skipToNext()
  │   ├── skipToPrevious()
  │   └── seek(position)
  │
  ├── AudioPlayer (just_audio)
  │   ├── setUrl()
  │   ├── play()
  │   ├── pause()
  │   └── Stream<PlayerState>
  │
  └── Queue Management
      ├── currentTrack
      ├── queue[]
      └── history[]
```

### Contrôles multimédia

```
┌──────────────────────────────────────┐
│      Media Controls Sources          │
├──────────┬───────────┬───────────────┤
│ In-App UI│Notification│   Bluetooth  │
│ Buttons  │  Controls  │   Headset    │
└────┬─────┴─────┬─────┴───────┬───────┘
     │           │             │
     └───────────┴─────────────┘
                 │
        ┌────────▼─────────┐
        │  Audio Handler   │
        │  (Unified API)   │
        └────────┬─────────┘
                 │
        ┌────────▼─────────┐
        │   Audio Player   │
        │   (just_audio)   │
        └──────────────────┘
```

## Communication Client-Serveur

### API REST

Toutes les communications utilisent JSON via HTTP/HTTPS :

```
Client                           Server
  │                                │
  ├─ GET /api/tracks ─────────────>│
  │                                │ Query DB
  │<──────── JSON Response ────────┤
  │                                │
  ├─ GET /api/stream/:id ─────────>│
  │                                │ Open file stream
  │<──────── Audio Stream ─────────┤
  │     (chunked transfer)         │
```

### Gestion du cache

```
┌────────────────────────────────┐
│         Client Cache           │
├────────────────────────────────┤
│  - Metadata (SQLite local)     │
│  - Album covers (File cache)   │
│  - Recent tracks (Memory)      │
└────────────────────────────────┘
```

## Sécurité

### Couches de sécurité

```
1. Transport Layer
   └─ HTTPS (TLS 1.3)

2. Application Layer
   ├─ JWT Authentication
   ├─ API Rate Limiting
   └─ Input Validation

3. Data Layer
   ├─ Path Sanitization
   ├─ SQL Prepared Statements
   └─ File Access Control
```

### Authentification (Phase 2)

```
┌─────────┐                    ┌─────────┐
│ Client  │                    │ Server  │
└────┬────┘                    └────┬────┘
     │                              │
     │  POST /auth/login            │
     │  {username, password}        │
     ├─────────────────────────────>│
     │                              │ Verify credentials
     │                              │ Generate JWT
     │         JWT Token            │
     │<─────────────────────────────┤
     │                              │
     │  GET /api/tracks             │
     │  Authorization: Bearer JWT   │
     ├─────────────────────────────>│
     │                              │ Verify JWT
     │         Tracks data          │
     │<─────────────────────────────┤
```

## Performance et scalabilité

### Optimisations Backend
- Streaming par chunks (évite le chargement en mémoire)
- Index de base de données optimisés
- Cache des métadonnées fréquemment demandées
- Compression gzip des réponses JSON
- Pagination des résultats (limite 50 par défaut)

### Optimisations Frontend
- Lazy loading des listes
- Image caching (album covers)
- Debouncing de la recherche
- Prefetching des pistes suivantes
- State management optimisé (updates minimaux)

## Déploiement

### Architecture de déploiement

```
┌─────────────────────────────────────┐
│      Serveur Debian                 │
├─────────────────────────────────────┤
│  ┌──────────────────────────────┐  │
│  │  Nginx (Reverse Proxy)       │  │
│  │  - HTTPS termination         │  │
│  │  - Static files              │  │
│  └────────────┬─────────────────┘  │
│               │                     │
│  ┌────────────▼─────────────────┐  │
│  │  Node.js App (PM2)           │  │
│  │  - Port 3000                 │  │
│  │  - Auto-restart              │  │
│  └────────────┬─────────────────┘  │
│               │                     │
│  ┌────────────▼─────────────────┐  │
│  │  SQLite Database             │  │
│  │  /var/lib/own-audio-player   │  │
│  └──────────────────────────────┘  │
│               │                     │
│  ┌────────────▼─────────────────┐  │
│  │  Music Library               │  │
│  │  /srv/music                  │  │
│  └──────────────────────────────┘  │
└─────────────────────────────────────┘
```

## Monitoring et logs

```
Server Logs → Journald (systemd)
            → /var/log/own-audio-player/

Client Logs → Sentry (crash reporting)
            → Local file (debug mode)

Metrics     → Prometheus (optionnel)
```

## Extensions futures

### Phase 3+
- Transcoding à la volée (FLAC → MP3 pour mobile)
- Support de nouveaux formats (AAC, Opus)
- Synchronisation multi-appareils
- Mode hors-ligne avec synchronisation
- Recommandations intelligentes
- Visualisations audio
- Égaliseur intégré
- Support des podcasts
