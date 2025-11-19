import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/library_provider.dart';
import '../providers/player_provider.dart';
import '../models/artist.dart';
import '../models/album.dart';
import '../models/track.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  Map<String, dynamic>? _results;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _results = null;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final library = context.read<LibraryProvider>();
      final results = await library.search(query);
      setState(() {
        _results = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _isSearching = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Search error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search music...',
            border: InputBorder.none,
          ),
          onSubmitted: _performSearch,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _searchController.clear();
              setState(() {
                _results = null;
              });
            },
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_results == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            const Text('Search for artists, albums, or tracks'),
          ],
        ),
      );
    }

    final artists = _results!['artists'] as List<Artist>;
    final albums = _results!['albums'] as List<Album>;
    final tracks = _results!['tracks'] as List<Track>;

    if (artists.isEmpty && albums.isEmpty && tracks.isEmpty) {
      return const Center(child: Text('No results found'));
    }

    return ListView(
      children: [
        if (artists.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Artists',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          ...artists.map((artist) => ListTile(
                leading: CircleAvatar(
                  child: Text(artist.name[0].toUpperCase()),
                ),
                title: Text(artist.name),
                subtitle: Text('${artist.albumCount} albums'),
              )),
          const Divider(),
        ],
        if (albums.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Albums',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          ...albums.map((album) => ListTile(
                leading: const Icon(Icons.album),
                title: Text(album.title),
                subtitle: Text(album.artistName),
              )),
          const Divider(),
        ],
        if (tracks.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Tracks',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          ...tracks.map((track) => Consumer<PlayerProvider>(
                builder: (context, player, child) {
                  return ListTile(
                    leading: const Icon(Icons.music_note),
                    title: Text(track.title),
                    subtitle: Text('${track.artistName} • ${track.albumName}'),
                    trailing: Text(track.durationFormatted),
                    onTap: () {
                      player.playTrack(track, queue: tracks);
                    },
                  );
                },
              )),
        ],
      ],
    );
  }
}
