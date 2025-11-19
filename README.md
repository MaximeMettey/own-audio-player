# Own Audio Player 🎵

Une plateforme de streaming musical auto-hébergée, type Spotify, pour écouter votre propre bibliothèque musicale depuis n'importe quel appareil.

## Caractéristiques

- 📱 **Cross-platform** : Android, iOS, Windows, Linux
- 🎵 **Streaming audio** : Lecture fluide depuis votre serveur
- 🎛️ **Contrôles complets** : Play/Pause/Suivant/Précédent
- 🔔 **Notifications** : Contrôle depuis les notifications système
- 🎧 **Bluetooth** : Support des casques et systèmes audio Bluetooth
- 📚 **Bibliothèque** : Navigation par artistes, albums, pistes
- 🔍 **Recherche** : Recherche rapide dans votre bibliothèque
- 📝 **Playlists** : Créez et gérez vos playlists personnalisées

## Stack technique

### Backend
- Node.js + Express
- SQLite pour les métadonnées
- Support MP3, FLAC, OGG, M4A, WAV

### Frontend
- Flutter (iOS, Android, Windows, Linux)
- just_audio pour la lecture
- audio_service pour les contrôles multimédia

## Documentation

- 📖 [Guide de développement (CLAUDE.md)](./CLAUDE.md)
- 🏗️ [Architecture technique (ARCHITECTURE.md)](./ARCHITECTURE.md)

## Installation rapide

### Serveur (Debian/Linux)

```bash
cd server
npm install
cp .env.example .env
# Éditer .env avec le chemin de votre bibliothèque musicale
npm run dev
```

### Client

```bash
cd client
flutter pub get
# Configurer l'URL du serveur dans lib/config/api_config.dart
flutter run
```

## Structure du projet

```
own-audio-player/
├── server/          # Backend Node.js
│   ├── src/         # Code source
│   └── data/        # Données (DB + musique)
├── client/          # Application Flutter
│   ├── lib/         # Code source Dart
│   ├── android/     # Config Android
│   ├── ios/         # Config iOS
│   ├── windows/     # Config Windows
│   └── linux/       # Config Linux
└── docs/            # Documentation
```

## Roadmap

- [x] Architecture et documentation
- [ ] Serveur backend fonctionnel
- [ ] Client Flutter de base
- [ ] Lecteur audio avec contrôles
- [ ] Notifications système
- [ ] Support Bluetooth
- [ ] Playlists
- [ ] Mode hors-ligne

## Licence

MIT