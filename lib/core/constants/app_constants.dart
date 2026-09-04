class AppConstants {
  static const String appName = 'PodDrunk';
  static const String appVersion = '1.0.0';

  static const List<String> categories = [
    'All',
    'Comedy',
    'News',
    'Technology',
    'Business',
    'Health',
    'Sports',
    'Music',
    'Education',
    'Arts',
    'Science',
    'Society & Culture',
  ];

  static const List<Map<String, String>> featuredPodcasts = [
    {
      'title': 'Syntax - Web Development',
      'feedUrl': 'https://feed.syntax.fm/rss',
    },
    {
      'title': 'The Changelog',
      'feedUrl': 'https://changelog.com/podcast/feed',
    },
    {
      'title': 'Software Engineering Daily',
      'feedUrl': 'https://softwareengineeringdaily.com/feed/podcast/',
    },
  ];
}

class HiveBoxes {
  static const String settings = 'settings';
  static const String podcasts = 'podcasts';
  static const String episodes = 'episodes';
  static const String downloads = 'downloads';
  static const String subscriptions = 'subscriptions';
  static const String playbackState = 'playback_state';
}