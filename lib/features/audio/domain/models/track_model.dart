class TrackModel {
  final String id;
  final String title;
  final String artist;
  final String album;
  final Duration duration;
  final String uri;
  final bool isLocal;
  final String? artworkPath;

  const TrackModel({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.duration,
    required this.uri,
    this.isLocal = false,
    this.artworkPath,
  });

  TrackModel copyWith({
    String? id,
    String? title,
    String? artist,
    String? album,
    Duration? duration,
    String? uri,
    bool? isLocal,
    String? artworkPath,
  }) {
    return TrackModel(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      duration: duration ?? this.duration,
      uri: uri ?? this.uri,
      isLocal: isLocal ?? this.isLocal,
      artworkPath: artworkPath ?? this.artworkPath,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'album': album,
      'durationMs': duration.inMilliseconds,
      'uri': uri,
      'isLocal': isLocal,
      'artworkPath': artworkPath,
    };
  }

  factory TrackModel.fromJson(Map<String, dynamic> json) {
    return TrackModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Unknown Track',
      artist: json['artist'] as String? ?? 'Unknown Artist',
      album: json['album'] as String? ?? 'Unknown Album',
      duration: Duration(milliseconds: json['durationMs'] as int? ?? 0),
      uri: json['uri'] as String? ?? '',
      isLocal: json['isLocal'] as bool? ?? false,
      artworkPath: json['artworkPath'] as String?,
    );
  }

  // Built-in sample fallback tracks (disabled)
  static List<TrackModel> get sampleTracks => const [];
}
