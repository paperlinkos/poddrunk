import '../../../audio/domain/models/track_model.dart';

class PlaylistModel {
  final String id;
  final String name;
  final String description;
  final List<TrackModel> tracks;
  final DateTime createdAt;
  final int colorIndex;

  const PlaylistModel({
    required this.id,
    required this.name,
    this.description = '',
    this.tracks = const [],
    required this.createdAt,
    this.colorIndex = 0,
  });

  Duration get totalDuration {
    return tracks.fold(Duration.zero, (prev, track) => prev + track.duration);
  }

  PlaylistModel copyWith({
    String? id,
    String? name,
    String? description,
    List<TrackModel>? tracks,
    DateTime? createdAt,
    int? colorIndex,
  }) {
    return PlaylistModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      tracks: tracks ?? this.tracks,
      createdAt: createdAt ?? this.createdAt,
      colorIndex: colorIndex ?? this.colorIndex,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'tracks': tracks.map((t) => t.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'colorIndex': colorIndex,
    };
  }

  factory PlaylistModel.fromJson(Map<String, dynamic> json) {
    return PlaylistModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Untitled Playlist',
      description: json['description'] as String? ?? '',
      tracks: (json['tracks'] as List<dynamic>?)
              ?.map((t) => TrackModel.fromJson(t as Map<String, dynamic>))
              .toList() ??
          const [],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      colorIndex: json['colorIndex'] as int? ?? 0,
    );
  }
}
