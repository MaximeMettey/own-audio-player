class Track {
  final String id;
  final String title;
  final String artistId;
  final String artistName;
  final String albumId;
  final String albumName;
  final int duration;
  final int? trackNumber;
  final int discNumber;
  final int? year;
  final String? genre;
  final String filePath;
  final int? fileSize;
  final int? bitrate;
  final int? sampleRate;
  final String? format;
  final DateTime createdAt;

  Track({
    required this.id,
    required this.title,
    required this.artistId,
    required this.artistName,
    required this.albumId,
    required this.albumName,
    required this.duration,
    this.trackNumber,
    this.discNumber = 1,
    this.year,
    this.genre,
    required this.filePath,
    this.fileSize,
    this.bitrate,
    this.sampleRate,
    this.format,
    required this.createdAt,
  });

  factory Track.fromJson(Map<String, dynamic> json) {
    return Track(
      id: json['id'] as String,
      title: json['title'] as String,
      artistId: json['artist_id'] as String,
      artistName: json['artist_name'] as String,
      albumId: json['album_id'] as String,
      albumName: json['album_name'] as String,
      duration: json['duration'] as int,
      trackNumber: json['track_number'] as int?,
      discNumber: json['disc_number'] as int? ?? 1,
      year: json['year'] as int?,
      genre: json['genre'] as String?,
      filePath: json['file_path'] as String,
      fileSize: json['file_size'] as int?,
      bitrate: json['bitrate'] as int?,
      sampleRate: json['sample_rate'] as int?,
      format: json['format'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist_id': artistId,
      'artist_name': artistName,
      'album_id': albumId,
      'album_name': albumName,
      'duration': duration,
      'track_number': trackNumber,
      'disc_number': discNumber,
      'year': year,
      'genre': genre,
      'file_path': filePath,
      'file_size': fileSize,
      'bitrate': bitrate,
      'sample_rate': sampleRate,
      'format': format,
      'created_at': createdAt.toIso8601String(),
    };
  }

  String get durationFormatted {
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  String toString() => 'Track(id: $id, title: $title, artist: $artistName)';
}
