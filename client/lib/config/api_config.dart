class ApiConfig {
  // Change this to your server's IP address or domain
  static const String baseUrl = 'http://localhost:3000';
  static const String apiPrefix = '/api';

  // Endpoints
  static const String artists = '$apiPrefix/artists';
  static const String albums = '$apiPrefix/albums';
  static const String tracks = '$apiPrefix/tracks';
  static const String stream = '$apiPrefix/stream';
  static const String library = '$apiPrefix/library';
  static const String search = '$apiPrefix/search';
  static const String playlists = '$apiPrefix/playlists';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Helper methods
  static String getFullUrl(String endpoint) => '$baseUrl$endpoint';

  static String getStreamUrl(String trackId) =>
      '$baseUrl$stream/$trackId';

  static String getArtistUrl(String artistId) =>
      '$baseUrl$artists/$artistId';

  static String getAlbumUrl(String albumId) =>
      '$baseUrl$albums/$albumId';

  static String getTrackUrl(String trackId) =>
      '$baseUrl$tracks/$trackId';

  static String getSearchUrl(String query) =>
      '$baseUrl$search?q=${Uri.encodeComponent(query)}';
}
