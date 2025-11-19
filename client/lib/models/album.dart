import 'track.dart';

class Album {
  final String id;
  final String title;
  final String artistId;
  final String artistName;
  final int? year;
  final int trackCount;
  final String? coverPath;
  final int duration;
  final DateTime createdAt;
  final List<Track>? tracks;

  Album({
    required this.id,
    required this.title,
    required this.artistId,
    required this.artistName,
    this.year,
    this.trackCount = 0,
    this.coverPath,
    this.duration = 0,
    required this.createdAt,
    this.tracks,
  });

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      id: json['id'] as String,
      title: json['title'] as String,
      artistId: json['artist_id'] as String,
      artistName: json['artist_name'] as String,
      year: json['year'] as int?,
      trackCount: json['track_count'] as int? ?? 0,
      coverPath: json['cover_path'] as String?,
      duration: json['duration'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      tracks: json['tracks'] != null
          ? (json['tracks'] as List).map((t) => Track.fromJson(t)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist_id': artistId,
      'artist_name': artistName,
      'year': year,
      'track_count': trackCount,
      'cover_path': coverPath,
      'duration': duration,
      'created_at': createdAt.toIso8601String(),
      if (tracks != null) 'tracks': tracks!.map((t) => t.toJson()).toList(),
    };
  }

  String get durationFormatted {
    final hours = duration ~/ 3600;
    final minutes = (duration % 3600) ~/ 60;
    if (hours > 0) {
      return '$hours h $minutes min';
    }
    return '$minutes min';
  }

  @override
  String toString() => 'Album(id: $id, title: $title, artist: $artistName)';
}
