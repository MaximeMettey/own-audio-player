import 'package:flutter/foundation.dart';
import '../models/artist.dart';
import '../models/album.dart';
import '../models/track.dart';
import '../services/api_service.dart';

class LibraryProvider with ChangeNotifier {
  final ApiService _api = ApiService();

  List<Artist> _artists = [];
  List<Album> _albums = [];
  List<Track> _tracks = [];
  Map<String, dynamic>? _stats;

  bool _isLoadingArtists = false;
  bool _isLoadingAlbums = false;
  bool _isLoadingTracks = false;
  bool _isLoadingStats = false;

  String? _error;

  // Getters
  List<Artist> get artists => _artists;
  List<Album> get albums => _albums;
  List<Track> get tracks => _tracks;
  Map<String, dynamic>? get stats => _stats;

  bool get isLoadingArtists => _isLoadingArtists;
  bool get isLoadingAlbums => _isLoadingAlbums;
  bool get isLoadingTracks => _isLoadingTracks;
  bool get isLoadingStats => _isLoadingStats;

  String? get error => _error;

  // Load artists
  Future<void> loadArtists({int limit = 50, int offset = 0}) async {
    try {
      _isLoadingArtists = true;
      _error = null;
      notifyListeners();

      _artists = await _api.getArtists(limit: limit, offset: offset);

      _isLoadingArtists = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoadingArtists = false;
      notifyListeners();
      rethrow;
    }
  }

  // Load albums
  Future<void> loadAlbums({int limit = 50, int offset = 0}) async {
    try {
      _isLoadingAlbums = true;
      _error = null;
      notifyListeners();

      _albums = await _api.getAlbums(limit: limit, offset: offset);

      _isLoadingAlbums = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoadingAlbums = false;
      notifyListeners();
      rethrow;
    }
  }

  // Load tracks
  Future<void> loadTracks({int limit = 50, int offset = 0}) async {
    try {
      _isLoadingTracks = true;
      _error = null;
      notifyListeners();

      _tracks = await _api.getTracks(limit: limit, offset: offset);

      _isLoadingTracks = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoadingTracks = false;
      notifyListeners();
      rethrow;
    }
  }

  // Load library stats
  Future<void> loadStats() async {
    try {
      _isLoadingStats = true;
      _error = null;
      notifyListeners();

      _stats = await _api.getLibraryStats();

      _isLoadingStats = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoadingStats = false;
      notifyListeners();
      rethrow;
    }
  }

  // Load specific artist
  Future<Artist> loadArtist(String id) async {
    try {
      return await _api.getArtist(id);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Load specific album
  Future<Album> loadAlbum(String id) async {
    try {
      return await _api.getAlbum(id);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Load specific track
  Future<Track> loadTrack(String id) async {
    try {
      return await _api.getTrack(id);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Load random tracks
  Future<List<Track>> loadRandomTracks({int limit = 20}) async {
    try {
      return await _api.getRandomTracks(limit: limit);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Scan library
  Future<void> scanLibrary() async {
    try {
      await _api.scanLibrary();
      // Reload stats after scan
      await loadStats();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Search
  Future<Map<String, dynamic>> search(String query) async {
    try {
      _error = null;
      return await _api.search(query);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Refresh all
  Future<void> refreshAll() async {
    await Future.wait([
      loadArtists(),
      loadAlbums(),
      loadTracks(),
      loadStats(),
    ]);
  }
}
