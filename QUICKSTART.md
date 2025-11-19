# Guide de démarrage rapide - Own Audio Player

Ce guide vous permet de démarrer rapidement avec Own Audio Player.

## Prérequis

- **Serveur** : Node.js 18+, npm
- **Client** : Flutter SDK 3.0+
- **Bibliothèque musicale** : Fichiers MP3, FLAC, OGG, M4A, WAV, etc.

## Installation en 5 minutes

### 1. Cloner le projet

```bash
git clone <repository-url>
cd own-audio-player
```

### 2. Configurer le serveur

```bash
cd server
npm install
cp .env.example .env
```

Éditez `.env` et configurez le chemin de votre bibliothèque :

```env
MUSIC_LIBRARY_PATH=/path/to/your/music
```

### 3. Scanner votre bibliothèque

```bash
npm run scan
```

Cette opération va :
- Parcourir tous vos fichiers audio
- Extraire les métadonnées (artiste, album, titre, etc.)
- Créer la base de données SQLite
- Indexer votre collection

### 4. Démarrer le serveur

```bash
npm run dev
```

Le serveur démarre sur `http://localhost:3000`

Vérifiez qu'il fonctionne :
```bash
curl http://localhost:3000/health
```

### 5. Configurer le client

```bash
cd ../client
flutter pub get
```

Éditez `lib/config/api_config.dart` :

```dart
static const String baseUrl = 'http://localhost:3000';
// Ou l'IP de votre serveur si sur réseau local
```

### 6. Lancer l'application

```bash
# Sur Android/iOS (avec émulateur/appareil connecté)
flutter run

# Sur desktop
flutter run -d windows  # Windows
flutter run -d linux    # Linux
flutter run -d macos    # macOS
```

## Structure de votre bibliothèque musicale

Organisez vos fichiers comme vous voulez ! Le scanner détecte automatiquement :

```
/path/to/music/
├── Artist1/
│   ├── Album1/
│   │   ├── 01-track1.mp3
│   │   ├── 02-track2.mp3
│   │   └── cover.jpg
│   └── Album2/
│       └── ...
├── Artist2/
│   └── ...
└── ...
```

Les métadonnées sont extraites des tags ID3/FLAC/etc.

## Configuration réseau

### Accès depuis un appareil mobile

1. Trouvez l'IP de votre serveur :
   ```bash
   # Linux/Mac
   ip addr show
   # ou
   ifconfig

   # Windows
   ipconfig
   ```

2. Configurez cette IP dans le client :
   ```dart
   static const String baseUrl = 'http://192.168.1.X:3000';
   ```

3. Assurez-vous que le firewall autorise le port 3000

### Avec Docker (optionnel)

```bash
cd server
docker build -t own-audio-player .
docker run -d \
  -p 3000:3000 \
  -v /path/to/music:/music \
  -e MUSIC_LIBRARY_PATH=/music \
  --name own-audio-player \
  own-audio-player
```

## Commandes utiles

### Serveur

```bash
cd server

# Développement avec auto-reload
npm run dev

# Production
npm start

# Re-scanner la bibliothèque
npm run scan

# Voir les stats
curl http://localhost:3000/api/library/stats
```

### Client

```bash
cd client

# Hot reload (développement)
flutter run

# Build APK Android
flutter build apk --release

# Build iOS
flutter build ios --release

# Build Windows
flutter build windows --release

# Build Linux
flutter build linux --release
```

## Dépannage rapide

### Le serveur ne démarre pas

```bash
# Vérifier que le port est libre
lsof -i :3000  # Linux/Mac
netstat -ano | findstr :3000  # Windows

# Changer le port dans .env si nécessaire
PORT=3001
```

### La bibliothèque est vide

1. Vérifiez le chemin dans `.env`
2. Vérifiez les permissions du dossier
3. Re-lancez le scan : `npm run scan`
4. Vérifiez les logs pour les erreurs

### Le client ne se connecte pas

1. Vérifiez que le serveur est démarré
2. Vérifiez l'URL dans `api_config.dart`
3. Testez la connexion : `curl http://IP:3000/health`
4. Vérifiez le firewall

### Pas de son sur l'application

1. Vérifiez le volume de l'appareil
2. Vérifiez que le streaming fonctionne :
   ```bash
   curl http://localhost:3000/api/tracks
   # Notez un ID de track
   curl http://localhost:3000/api/stream/TRACK_ID --output test.mp3
   ```
3. Sur Android : vérifiez les permissions audio

## Fonctionnalités actuelles

- ✅ Bibliothèque musicale complète
- ✅ Streaming audio
- ✅ Contrôles de lecture
- ✅ Recherche
- ✅ File d'attente
- ✅ Mode shuffle/repeat
- ⏳ Notifications système (en cours)
- ⏳ Support Bluetooth (en cours)
- ⏳ Playlists (en cours)

## Prochaines étapes

1. Personnaliser l'interface selon vos goûts
2. Configurer les notifications système
3. Ajouter l'authentification (si besoin)
4. Déployer sur un serveur distant
5. Profiter de votre musique ! 🎵

## Support

- Documentation complète : `CLAUDE.md`
- Architecture technique : `ARCHITECTURE.md`
- README serveur : `server/README.md`
- README client : `client/README.md`

## Contributeurs

Contributions bienvenues ! Voir `CONTRIBUTING.md` (si disponible)

## Licence

MIT - Voir `LICENSE`
