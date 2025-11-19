# Own Audio Player - Client

Application Flutter cross-platform pour Own Audio Player.

## Plateformes supportées

- Android
- iOS
- Windows
- Linux

## Prérequis

- Flutter SDK 3.0+
- Dart 3.0+

## Installation

1. Installer les dépendances :

```bash
flutter pub get
```

2. Configurer l'URL du serveur dans `lib/config/api_config.dart` :

```dart
static const String baseUrl = 'http://your-server-ip:3000';
```

## Lancement

### Mode développement

```bash
flutter run
```

### Choisir une plateforme spécifique

```bash
# Android
flutter run -d android

# iOS
flutter run -d ios

# Windows
flutter run -d windows

# Linux
flutter run -d linux
```

## Build

### Android (APK)

```bash
flutter build apk --release
```

Le fichier APK sera dans `build/app/outputs/flutter-apk/app-release.apk`

### Android (App Bundle)

```bash
flutter build appbundle --release
```

### iOS

```bash
flutter build ios --release
```

### Windows

```bash
flutter build windows --release
```

Le fichier exécutable sera dans `build/windows/runner/Release/`

### Linux

```bash
flutter build linux --release
```

Le fichier exécutable sera dans `build/linux/x64/release/bundle/`

## Structure du projet

```
lib/
├── main.dart                 # Point d'entrée
├── config/
│   └── api_config.dart      # Configuration API
├── models/
│   ├── track.dart           # Modèle Track
│   ├── album.dart           # Modèle Album
│   ├── artist.dart          # Modèle Artist
│   └── playlist.dart        # Modèle Playlist
├── services/
│   ├── api_service.dart     # Service API REST
│   └── audio_service.dart   # Service audio (just_audio)
├── providers/
│   ├── player_provider.dart   # Provider du lecteur audio
│   └── library_provider.dart  # Provider de la bibliothèque
├── screens/
│   ├── home_screen.dart       # Écran d'accueil
│   ├── library_screen.dart    # Bibliothèque musicale
│   ├── player_screen.dart     # Lecteur en plein écran
│   ├── search_screen.dart     # Recherche
│   └── playlists_screen.dart  # Playlists
└── widgets/
    └── mini_player.dart       # Mini lecteur (barre du bas)
```

## Fonctionnalités

### Implémentées

- Navigation dans la bibliothèque (artistes, albums, pistes)
- Lecture audio avec streaming
- Contrôles de lecture (play/pause/next/previous)
- Recherche globale
- File d'attente
- Mini lecteur persistant
- Lecteur en plein écran
- Mode shuffle et repeat

### À venir

- Notifications système avec contrôles
- Support Bluetooth
- Gestion des playlists
- Mode hors-ligne
- Téléchargement de pistes
- Equalizer

## Configuration

### Android

Pour que l'audio fonctionne en arrière-plan sur Android, les permissions sont déjà configurées dans `android/app/src/main/AndroidManifest.xml`.

### iOS

Pour iOS, configurez les permissions dans `ios/Runner/Info.plist` :

```xml
<key>UIBackgroundModes</key>
<array>
    <string>audio</string>
</array>
```

### Windows/Linux

Aucune configuration supplémentaire requise.

## Dépendances principales

- `provider` - Gestion d'état
- `dio` - Client HTTP
- `just_audio` - Lecteur audio
- `audio_service` - Service audio en arrière-plan
- `cached_network_image` - Cache d'images

## Développement

### Hot reload

Flutter supporte le hot reload pour un développement rapide :

```bash
# Dans le terminal où flutter run est lancé
r  # Hot reload
R  # Hot restart
```

### Debug

```bash
# Activer le mode debug
flutter run --debug

# Profiling
flutter run --profile
```

### Tests

```bash
flutter test
```

## Troubleshooting

### Impossible de se connecter au serveur

Vérifiez que :
1. Le serveur backend est démarré
2. L'URL dans `api_config.dart` est correcte
3. Pas de firewall bloquant la connexion
4. Si sur émulateur/simulateur, utilisez l'IP de votre machine (pas localhost)

### Pas de son

Vérifiez que :
1. Le volume n'est pas à 0
2. Les permissions audio sont accordées
3. Le streaming fonctionne (vérifier les logs)

### Build échoue

```bash
# Nettoyer le projet
flutter clean

# Récupérer les dépendances
flutter pub get

# Rebuild
flutter build <platform>
```

## Configuration réseau

### Pour émulateur Android

Utilisez `10.0.2.2` au lieu de `localhost` :

```dart
static const String baseUrl = 'http://10.0.2.2:3000';
```

### Pour appareil physique

Utilisez l'IP locale de votre machine :

```dart
static const String baseUrl = 'http://192.168.1.X:3000';
```

## Contribution

Voir le fichier principal README.md du projet.

## Licence

MIT
