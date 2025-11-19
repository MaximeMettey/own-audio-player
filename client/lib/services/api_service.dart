import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/artist.dart';
import '../models/album.dart';
import '../models/track.dart';
import '../models/playlist.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  late final Dio _dio;

  ApiService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Add interceptors for logging
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
    ));
  }

  // Artists
  Future<List<Artist>> getArtists({int limit = 50, int offset = 0}) async {
    try {
      final response = await _dio.get(
        ApiConfig.artists,
        queryParameters: {'limit': limit, 'offset': offset},
      );
      final data = response.data['data'] as List;
      return data.map((json) => Artist.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Artist> getArtist(String id) async {
    try {
      final response = await _dio.get('${ApiConfig.artists}/$id');
      return Artist.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<Album>> getArtistAlbums(String artistId) async {
    try {
      final response = await _dio.get('${ApiConfig.artists}/$artistId/albums');
      final data = response.data['data'] as List;
      return data.map((json) => Album.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<Track>> getArtistTracks(String artistId) async {
    try {
      final response = await _dio.get('${ApiConfig.artists}/$artistId/tracks');
      final data = response.data['data'] as List;
      return data.map((json) => Track.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Albums
  Future<List<Album>> getAlbums({int limit = 50, int offset = 0}) async {
    try {
      final response = await _dio.get(
        ApiConfig.albums,
        queryParameters: {'limit': limit, 'offset': offset},
      );
      final data = response.data['data'] as List;
      return data.map((json) => Album.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Album> getAlbum(String id) async {
    try {
      final response = await _dio.get('${ApiConfig.albums}/$id');
      return Album.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<Track>> getAlbumTracks(String albumId) async {
    try {
      final response = await _dio.get('${ApiConfig.albums}/$albumId/tracks');
      final data = response.data['data'] as List;
      return data.map((json) => Track.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Tracks
  Future<List<Track>> getTracks({int limit = 50, int offset = 0}) async {
    try {
      final response = await _dio.get(
        ApiConfig.tracks,
        queryParameters: {'limit': limit, 'offset': offset},
      );
      final data = response.data['data'] as List;
      return data.map((json) => Track.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Track> getTrack(String id) async {
    try {
      final response = await _dio.get('${ApiConfig.tracks}/$id');
      return Track.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<Track>> getRandomTracks({int limit = 20}) async {
    try {
      final response = await _dio.get(
        '${ApiConfig.tracks}/random/tracks',
        queryParameters: {'limit': limit},
      );
      final data = response.data['data'] as List;
      return data.map((json) => Track.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Search
  Future<Map<String, dynamic>> search(String query, {int limit = 20}) async {
    try {
      final response = await _dio.get(
        ApiConfig.search,
        queryParameters: {'q': query, 'limit': limit},
      );
      return {
        'artists': (response.data['results']['artists'] as List)
            .map((json) => Artist.fromJson(json))
            .toList(),
        'albums': (response.data['results']['albums'] as List)
            .map((json) => Album.fromJson(json))
            .toList(),
        'tracks': (response.data['results']['tracks'] as List)
            .map((json) => Track.fromJson(json))
            .toList(),
        'playlists': (response.data['results']['playlists'] as List)
            .map((json) => Playlist.fromJson(json))
            .toList(),
      };
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Playlists
  Future<List<Playlist>> getPlaylists() async {
    try {
      final response = await _dio.get(ApiConfig.playlists);
      final data = response.data['data'] as List;
      return data.map((json) => Playlist.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Playlist> getPlaylist(String id) async {
    try {
      final response = await _dio.get('${ApiConfig.playlists}/$id');
      return Playlist.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Playlist> createPlaylist(String name, {String? description}) async {
    try {
      final response = await _dio.post(
        ApiConfig.playlists,
        data: {
          'name': name,
          if (description != null) 'description': description,
        },
      );
      return Playlist.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Playlist> updatePlaylist(
    String id, {
    String? name,
    String? description,
  }) async {
    try {
      final response = await _dio.put(
        '${ApiConfig.playlists}/$id',
        data: {
          if (name != null) 'name': name,
          if (description != null) 'description': description,
        },
      );
      return Playlist.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deletePlaylist(String id) async {
    try {
      await _dio.delete('${ApiConfig.playlists}/$id');
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> addTrackToPlaylist(String playlistId, String trackId) async {
    try {
      await _dio.post(
        '${ApiConfig.playlists}/$playlistId/tracks',
        data: {'track_id': trackId},
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> removeTrackFromPlaylist(
    String playlistId,
    String trackId,
  ) async {
    try {
      await _dio.delete('${ApiConfig.playlists}/$playlistId/tracks/$trackId');
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Library
  Future<void> scanLibrary() async {
    try {
      await _dio.get('${ApiConfig.library}/scan');
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getLibraryStats() async {
    try {
      final response = await _dio.get('${ApiConfig.library}/stats');
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Error handling
  Exception _handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return Exception('Connection timeout. Please check your internet connection.');
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          final message = error.response?.data['error'] ?? 'Server error';
          return Exception('Server error ($statusCode): $message');
        case DioExceptionType.cancel:
          return Exception('Request cancelled');
        default:
          return Exception('Network error: ${error.message}');
      }
    }
    return Exception('Unexpected error: $error');
  }
}
