# CLAUDE.md - Guide de développement

## Vue d'ensemble du projet

**Own Audio Player** est une plateforme de streaming musical auto-hébergée, similaire à Spotify, permettant de lire votre propre bibliothèque musicale depuis n'importe quel appareil.

### Objectifs
- Application cross-platform (Android, iOS, Windows, Debian/Linux)
- Serveur auto-hébergé sur Debian
- Streaming audio avec contrôles multimédia complets
- Support Bluetooth et notifications système
- Navigation fluide dans la bibliothèque musicale

## Stack Technique

### Serveur (Backend)
- **Runtime**: Node.js 20+
- **Framework**: Express.js
- **Base de données**: SQLite (métadonnées) + Système de fichiers (audio)
- **API**: REST + Server-Sent Events pour les updates en temps réel
- **Streaming**: Support MP3, FLAC, OGG, M4A, WAV
- **Métadonnées**: music-metadata pour l'extraction des tags ID3

### Client (Frontend)
- **Framework**: Flutter 3.x
- **Plateformes cibles**: Android, iOS, Windows, Linux
- **Audio**: just_audio (lecture multi-plateforme)
- **Notifications**: flutter_local_notifications
- **Contrôles Bluetooth**: audio_service
- **État**: Provider ou Riverpod
- **HTTP**: Dio pour les requêtes API

## Architecture

```
own-audio-player/
├── server/                  # Backend Node.js
│   ├── src/
│   │   ├── api/            # Routes API REST
│   │   ├── services/       # Logique métier
│   │   ├── models/         # Modèles de données
│   │   ├── middleware/     # Middlewares Express
│   │   └── utils/          # Utilitaires
│   ├── data/               # Données persistantes
│   │   ├── library/        # Bibliothèque musicale
│   │   └── database/       # Fichiers SQLite
│   └── package.json
│
└── client/                  # Application Flutter
    ├── lib/
    │   ├── main.dart
    │   ├── models/         # Modèles de données
    │   ├── services/       # Services API et audio
    │   ├── providers/      # Gestion d'état
    │   ├── screens/        # Écrans de l'app
    │   ├── widgets/        # Composants réutilisables
    │   └── utils/          # Utilitaires
    ├── android/
    ├── ios/
    ├── windows/
    ├── linux/
    └── pubspec.yaml
```

## Fonctionnalités principales

### Phase 1 - MVP (Minimum Viable Product)
- [x] Configuration du serveur backend
- [x] API de bibliothèque musicale (lecture, recherche)
- [x] Streaming audio basique
- [x] Application client Flutter
- [x] Lecteur audio avec contrôles (play/pause/next/prev)
- [x] Interface de navigation (artistes, albums, pistes)

### Phase 2 - Contrôles avancés
- [ ] Notifications système avec contrôles
- [ ] Support Bluetooth (casques, voitures)
- [ ] Lecture en arrière-plan
- [ ] Gestion de la file d'attente

### Phase 3 - Fonctionnalités avancées
- [ ] Playlists personnalisées
- [ ] Recherche avancée et filtres
- [ ] Mode hors-ligne (cache local)
- [ ] Gestion multi-utilisateurs
- [ ] Statistiques d'écoute

## API Backend

### Endpoints principaux

```
GET    /api/library/scan           - Scanner la bibliothèque
GET    /api/artists                - Liste des artistes
GET    /api/artists/:id            - Détails d'un artiste
GET    /api/albums                 - Liste des albums
GET    /api/albums/:id             - Détails d'un album
GET    /api/tracks                 - Liste des pistes
GET    /api/tracks/:id             - Détails d'une piste
GET    /api/stream/:trackId        - Streaming d'une piste
GET    /api/cover/:albumId         - Pochette d'album
GET    /api/search?q=...           - Recherche globale
POST   /api/playlists              - Créer une playlist
GET    /api/playlists              - Liste des playlists
```

### Format de données

**Track**
```json
{
  "id": "uuid",
  "title": "Nom de la piste",
  "artist": "Nom de l'artiste",
  "album": "Nom de l'album",
  "duration": 245,
  "trackNumber": 3,
  "year": 2023,
  "genre": "Rock",
  "filePath": "/path/to/file.mp3"
}
```

## Configuration du serveur

### Variables d'environnement (.env)
```
PORT=3000
MUSIC_LIBRARY_PATH=/path/to/your/music
DATABASE_PATH=./data/database/music.db
ALLOWED_ORIGINS=*
```

### Installation
```bash
cd server
npm install
npm run dev
```

### Scanner la bibliothèque
```bash
curl http://localhost:3000/api/library/scan
```

## Configuration du client

### Installation
```bash
cd client
flutter pub get
flutter run
```

### Configuration API
Modifier `lib/config/api_config.dart` :
```dart
class ApiConfig {
  static const String baseUrl = 'http://your-server:3000';
}
```

## Développement

### Conventions de code

**Backend**
- ESLint + Prettier
- Async/await pour les opérations asynchrones
- Gestion d'erreurs systématique
- Logs structurés

**Frontend**
- Dart lint rules
- Widgets réutilisables
- Séparation logique/présentation
- Gestion d'état centralisée

### Tests

**Backend**
```bash
npm test
```

**Frontend**
```bash
flutter test
```

## Déploiement

### Serveur Debian
```bash
# Installation Node.js
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# Clone et setup
git clone <repo>
cd own-audio-player/server
npm install --production
npm run build

# Service systemd
sudo cp deploy/own-audio-player.service /etc/systemd/system/
sudo systemctl enable own-audio-player
sudo systemctl start own-audio-player
```

### Clients

**Android**
```bash
flutter build apk --release
```

**iOS**
```bash
flutter build ipa
```

**Windows**
```bash
flutter build windows --release
```

**Linux**
```bash
flutter build linux --release
```

## Sécurité

- [ ] Authentification JWT
- [ ] HTTPS obligatoire en production
- [ ] Rate limiting
- [ ] Validation des entrées
- [ ] Sanitization des chemins de fichiers

## Performance

- Streaming par chunks (évite le chargement complet)
- Cache des métadonnées
- Pagination des listes
- Lazy loading des images
- Compression des réponses API

## Troubleshooting

### Le serveur ne démarre pas
- Vérifier que le port 3000 est disponible
- Vérifier les permissions sur MUSIC_LIBRARY_PATH

### Pas de son sur l'application
- Vérifier la connexion au serveur
- Vérifier les permissions audio de l'OS
- Consulter les logs du serveur

### Bluetooth ne fonctionne pas
- Permissions Bluetooth accordées
- Service audio_service actif
- Appareil Bluetooth connecté avant lecture

## Contribution

1. Créer une branche feature
2. Développer avec tests
3. Commit avec messages clairs
4. Push et créer une PR

## Ressources

- [Flutter Audio Service](https://pub.dev/packages/audio_service)
- [Just Audio](https://pub.dev/packages/just_audio)
- [Express.js](https://expressjs.com/)
- [Music Metadata](https://github.com/Borewit/music-metadata)

## Changelog

### v0.1.0 (en cours)
- Initialisation du projet
- Architecture de base
- Documentation
