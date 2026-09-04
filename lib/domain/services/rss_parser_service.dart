import 'package:dio/dio.dart';
import 'package:xml/xml.dart';
import '../entities/podcast.dart';
import '../entities/episode.dart';
import 'package:uuid/uuid.dart';

class RssParserService {
  final Dio _dio = Dio();
  final Uuid _uuid = const Uuid();

  Future<({Podcast podcast, List<Episode> episodes})> parseFeed(
      String feedUrl) async {
    try {
      final response = await _dio.get(
        feedUrl,
        options: Options(
          headers: {
            'User-Agent': 'PodDrunk/1.0',
          },
          responseType: ResponseType.plain,
        ),
      );

      final document = XmlDocument.parse(response.data);
      final channel = document.findAllElements('channel').first;

      final podcast = _parsePodcast(channel, feedUrl);
      final items = channel.findAllElements('item');
      final episodes = items.map((item) => _parseEpisode(item, podcast.id, podcast.imageUrl)).toList();

      return (podcast: podcast, episodes: episodes);
    } catch (e) {
      throw Exception('Failed to parse RSS feed: $e');
    }
  }

  Podcast _parsePodcast(XmlElement channel, String feedUrl) {
    final title = _getElementText(channel, 'title') ?? 'Unknown Podcast';
    final author = _getElementText(channel, 'itunes:author') ??
        _getElementText(channel, 'author') ??
        'Unknown';
    final description = _getElementText(channel, 'description') ?? '';
    final imageUrl = _getImageUrl(channel);
    final category = _getCategory(channel);

    return Podcast(
      id: _uuid.v5(Uuid.NAMESPACE_URL, feedUrl),
      title: title,
      author: author,
      description: _stripHtml(description),
      imageUrl: imageUrl,
      feedUrl: feedUrl,
      category: category,
      lastUpdated: DateTime.now(),
    );
  }

  Episode _parseEpisode(XmlElement item, String podcastId, String fallbackImage) {
    final title = _getElementText(item, 'title') ?? 'Untitled Episode';
    final description = _getElementText(item, 'description') ??
        _getElementText(item, 'itunes:summary') ??
        '';
    final audioUrl = _getAudioUrl(item);
    final videoUrl = _getVideoUrl(item);
    final imageUrl = _getEpisodeImage(item) ?? fallbackImage;
    final duration = _getDuration(item);
    final publishedAt = _getPublishedDate(item);
    final guid = _getElementText(item, 'guid') ?? '$podcastId-${DateTime.now().millisecondsSinceEpoch}';

    return Episode(
      id: _uuid.v5(Uuid.NAMESPACE_URL, guid),
      podcastId: podcastId,
      title: title,
      description: _stripHtml(description),
      audioUrl: audioUrl,
      videoUrl: videoUrl,
      imageUrl: imageUrl,
      duration: duration,
      publishedAt: publishedAt,
    );
  }

  String? _getElementText(XmlElement parent, String name) {
    try {
      final elements = parent.findAllElements(name);
      if (elements.isNotEmpty) {
        return elements.first.innerText.trim();
      }
    } catch (_) {}
    return null;
  }

  String _getImageUrl(XmlElement channel) {
    try {
      final itunesImage = channel.findAllElements('itunes:image');
      if (itunesImage.isNotEmpty) {
        return itunesImage.first.getAttribute('href') ?? '';
      }
      final image = channel.findAllElements('image');
      if (image.isNotEmpty) {
        final url = image.first.findAllElements('url');
        if (url.isNotEmpty) {
          return url.first.innerText.trim();
        }
      }
    } catch (_) {}
    return '';
  }

  String? _getEpisodeImage(XmlElement item) {
    try {
      final itunesImage = item.findAllElements('itunes:image');
      if (itunesImage.isNotEmpty) {
        return itunesImage.first.getAttribute('href');
      }
    } catch (_) {}
    return null;
  }

  String _getAudioUrl(XmlElement item) {
    try {
      final enclosure = item.findAllElements('enclosure');
      if (enclosure.isNotEmpty) {
        return enclosure.first.getAttribute('url') ?? '';
      }
    } catch (_) {}
    return '';
  }

  String? _getVideoUrl(XmlElement item) {
    try {
      final enclosure = item.findAllElements('enclosure');
      if (enclosure.isNotEmpty) {
        final type = enclosure.first.getAttribute('type') ?? '';
        if (type.startsWith('video/')) {
          return enclosure.first.getAttribute('url');
        }
      }
    } catch (_) {}
    return null;
  }

  Duration _getDuration(XmlElement item) {
    try {
      final duration = _getElementText(item, 'itunes:duration');
      if (duration != null) {
        final parts = duration.split(':');
        if (parts.length == 3) {
          return Duration(
            hours: int.tryParse(parts[0]) ?? 0,
            minutes: int.tryParse(parts[1]) ?? 0,
            seconds: int.tryParse(parts[2]) ?? 0,
          );
        } else if (parts.length == 2) {
          return Duration(
            minutes: int.tryParse(parts[0]) ?? 0,
            seconds: int.tryParse(parts[1]) ?? 0,
          );
        } else {
          final seconds = int.tryParse(duration);
          if (seconds != null) {
            return Duration(seconds: seconds);
          }
        }
      }
    } catch (_) {}
    return Duration.zero;
  }

  DateTime _getPublishedDate(XmlElement item) {
    try {
      final dateStr = _getElementText(item, 'pubDate');
      if (dateStr != null) {
        return _parseDate(dateStr);
      }
    } catch (_) {}
    return DateTime.now();
  }

  DateTime _parseDate(String dateStr) {
    try {
      return DateTime.parse(dateStr);
    } catch (_) {
      try {
        final formats = [
          RegExp(r'(\d{1,2}) (\w{3}) (\d{4}) (\d{2}):(\d{2}):(\d{2})'),
        ];
        for (final format in formats) {
          final match = format.firstMatch(dateStr);
          if (match != null) {
            final months = {
              'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4,
              'May': 5, 'Jun': 6, 'Jul': 7, 'Aug': 8,
              'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12,
            };
            return DateTime(
              int.parse(match.group(3)!),
              months[match.group(2)!] ?? 1,
              int.parse(match.group(1)!),
              int.parse(match.group(4)!),
              int.parse(match.group(5)!),
              int.parse(match.group(6)!),
            );
          }
        }
      } catch (_) {}
    }
    return DateTime.now();
  }

  String _getCategory(XmlElement channel) {
    try {
      final category = _getElementText(channel, 'itunes:category');
      if (category != null) {
        return category;
      }
    } catch (_) {}
    return 'Other';
  }

  String _stripHtml(String html) {
    return html
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .trim();
  }
}