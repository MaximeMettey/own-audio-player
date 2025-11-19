import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/library_provider.dart';
import '../providers/player_provider.dart';
import '../models/track.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final library = context.read<LibraryProvider>();
    try {
      await Future.wait([
        library.loadArtists(),
        library.loadAlbums(),
        library.loadTracks(),
      ]);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading library: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Library'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Artists'),
            Tab(text: 'Albums'),
            Tab(text: 'Tracks'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          ArtistsTab(),
          AlbumsTab(),
          TracksTab(),
        ],
      ),
    );
  }
}

class ArtistsTab extends StatelessWidget {
  const ArtistsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LibraryProvider>(
      builder: (context, library, child) {
        if (library.isLoadingArtists && library.artists.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (library.artists.isEmpty) {
          return const Center(child: Text('No artists found'));
        }

        return ListView.builder(
          itemCount: library.artists.length,
          itemBuilder: (context, index) {
            final artist = library.artists[index];
            return ListTile(
              leading: CircleAvatar(
                child: Text(artist.name[0].toUpperCase()),
              ),
              title: Text(artist.name),
              subtitle: Text('${artist.albumCount} albums • ${artist.trackCount} tracks'),
              onTap: () {
                // TODO: Navigate to artist details
              },
            );
          },
        );
      },
    );
  }
}

class AlbumsTab extends StatelessWidget {
  const AlbumsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LibraryProvider>(
      builder: (context, library, child) {
        if (library.isLoadingAlbums && library.albums.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (library.albums.isEmpty) {
          return const Center(child: Text('No albums found'));
        }

        return ListView.builder(
          itemCount: library.albums.length,
          itemBuilder: (context, index) {
            final album = library.albums[index];
            return ListTile(
              leading: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.album),
              ),
              title: Text(album.title),
              subtitle: Text(album.artistName),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(album.year?.toString() ?? ''),
                  Text('${album.trackCount} tracks'),
                ],
              ),
              onTap: () {
                // TODO: Navigate to album details
              },
            );
          },
        );
      },
    );
  }
}

class TracksTab extends StatelessWidget {
  const TracksTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<LibraryProvider, PlayerProvider>(
      builder: (context, library, player, child) {
        if (library.isLoadingTracks && library.tracks.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (library.tracks.isEmpty) {
          return const Center(child: Text('No tracks found'));
        }

        return ListView.builder(
          itemCount: library.tracks.length,
          itemBuilder: (context, index) {
            final track = library.tracks[index];
            final isPlaying = player.currentTrack?.id == track.id;

            return ListTile(
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isPlaying
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isPlaying ? Icons.graphic_eq : Icons.music_note,
                  color: isPlaying
                      ? Theme.of(context).colorScheme.onPrimary
                      : null,
                ),
              ),
              title: Text(
                track.title,
                style: TextStyle(
                  fontWeight: isPlaying ? FontWeight.bold : null,
                  color: isPlaying
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
              ),
              subtitle: Text('${track.artistName} • ${track.albumName}'),
              trailing: Text(track.durationFormatted),
              onTap: () {
                player.playTrack(track, queue: library.tracks);
              },
            );
          },
        );
      },
    );
  }
}
