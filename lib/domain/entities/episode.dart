class Episode {
  final String id;
  final String podcastId;
  final String title;
  final String description;
  final String audioUrl;
  final String? videoUrl;
  final String imageUrl;
  final Duration duration;
  final DateTime publishedAt;
  final Duration? position;
  final bool isDownloaded;
  final String? localPath;

  Episode({
    required this.id,
    required this.podcastId,
    required this.title,
    required this.description,
    required this.audioUrl,
    this.videoUrl,
    required this.imageUrl,
    required this.duration,
    required this.publishedAt,
    this.position,
    this.isDownloaded = false,
    this.localPath,
  });

  Episode copyWith({
    String? id,
    String? podcastId,
    String? title,
    String? description,
    String? audioUrl,
    String? videoUrl,
    String? imageUrl,
    Duration? duration,
    DateTime? publishedAt,
    Duration? position,
    bool? isDownloaded,
    String? localPath,
  }) {
    return Episode(
      id: id ?? this.id,
      podcastId: podcastId ?? this.podcastId,
      title: title ?? this.title,
      description: description ?? this.description,
      audioUrl: audioUrl ?? this.audioUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      duration: duration ?? this.duration,
      publishedAt: publishedAt ?? this.publishedAt,
      position: position ?? this.position,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      localPath: localPath ?? this.localPath,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'podcastId': podcastId,
      'title': title,
      'description': description,
      'audioUrl': audioUrl,
      'videoUrl': videoUrl,
      'imageUrl': imageUrl,
      'duration': duration.inSeconds,
      'publishedAt': publishedAt.toIso8601String(),
      'position': position?.inSeconds,
      'isDownloaded': isDownloaded,
      'localPath': localPath,
    };
  }

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      id: json['id'] as String,
      podcastId: json['podcastId'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      audioUrl: json['audioUrl'] as String,
      videoUrl: json['videoUrl'] as String?,
      imageUrl: json['imageUrl'] as String? ?? '',
      duration: Duration(seconds: json['duration'] as int? ?? 0),
      publishedAt: DateTime.parse(json['publishedAt'] as String),
      position: json['position'] != null
          ? Duration(seconds: json['position'] as int)
          : null,
      isDownloaded: json['isDownloaded'] as bool? ?? false,
      localPath: json['localPath'] as String?,
    );
  }

  String get formattedDuration {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }
}