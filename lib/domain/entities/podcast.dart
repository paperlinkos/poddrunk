class Podcast {
  final String id;
  final String title;
  final String author;
  final String description;
  final String imageUrl;
  final String feedUrl;
  final String category;
  final DateTime? lastUpdated;
  final bool isSubscribed;

  Podcast({
    required this.id,
    required this.title,
    required this.author,
    required this.description,
    required this.imageUrl,
    required this.feedUrl,
    this.category = 'Other',
    this.lastUpdated,
    this.isSubscribed = false,
  });

  Podcast copyWith({
    String? id,
    String? title,
    String? author,
    String? description,
    String? imageUrl,
    String? feedUrl,
    String? category,
    DateTime? lastUpdated,
    bool? isSubscribed,
  }) {
    return Podcast(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      feedUrl: feedUrl ?? this.feedUrl,
      category: category ?? this.category,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isSubscribed: isSubscribed ?? this.isSubscribed,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'description': description,
      'imageUrl': imageUrl,
      'feedUrl': feedUrl,
      'category': category,
      'lastUpdated': lastUpdated?.toIso8601String(),
      'isSubscribed': isSubscribed,
    };
  }

  factory Podcast.fromJson(Map<String, dynamic> json) {
    return Podcast(
      id: json['id'] as String,
      title: json['title'] as String,
      author: json['author'] as String? ?? 'Unknown',
      description: json['description'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      feedUrl: json['feedUrl'] as String,
      category: json['category'] as String? ?? 'Other',
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.tryParse(json['lastUpdated'] as String)
          : null,
      isSubscribed: json['isSubscribed'] as bool? ?? false,
    );
  }
}