import 'track.dart';

class Playlist {
  final String id;
  final String name;
  final String? description;
  final int trackCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Track>? tracks;

  Playlist({
    required this.id,
    required this.name,
    this.description,
    this.trackCount = 0,
    required this.createdAt,
    required this.updatedAt,
    this.tracks,
  });

  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      trackCount: json['track_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      tracks: json['tracks'] != null
          ? (json['tracks'] as List).map((t) => Track.fromJson(t)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'track_count': trackCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      if (tracks != null) 'tracks': tracks!.map((t) => t.toJson()).toList(),
    };
  }

  @override
  String toString() => 'Playlist(id: $id, name: $name, tracks: $trackCount)';
}
