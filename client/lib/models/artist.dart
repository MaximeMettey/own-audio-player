import 'album.dart';
import 'track.dart';

class Artist {
  final String id;
  final String name;
  final int albumCount;
  final int trackCount;
  final DateTime createdAt;
  final List<Album>? albums;
  final List<Track>? tracks;

  Artist({
    required this.id,
    required this.name,
    this.albumCount = 0,
    this.trackCount = 0,
    required this.createdAt,
    this.albums,
    this.tracks,
  });

  factory Artist.fromJson(Map<String, dynamic> json) {
    return Artist(
      id: json['id'] as String,
      name: json['name'] as String,
      albumCount: json['album_count'] as int? ?? 0,
      trackCount: json['track_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      albums: json['albums'] != null
          ? (json['albums'] as List).map((a) => Album.fromJson(a)).toList()
          : null,
      tracks: json['tracks'] != null
          ? (json['tracks'] as List).map((t) => Track.fromJson(t)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'album_count': albumCount,
      'track_count': trackCount,
      'created_at': createdAt.toIso8601String(),
      if (albums != null) 'albums': albums!.map((a) => a.toJson()).toList(),
      if (tracks != null) 'tracks': tracks!.map((t) => t.toJson()).toList(),
    };
  }

  @override
  String toString() =>
      'Artist(id: $id, name: $name, albums: $albumCount, tracks: $trackCount)';
}
