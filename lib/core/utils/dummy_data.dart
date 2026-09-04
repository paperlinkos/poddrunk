import '../../domain/entities/podcast.dart';
import '../../domain/entities/episode.dart';

class DummyData {
  static List<Podcast> getPodcasts() {
    return [
      Podcast(
        id: 'podcast_1',
        title: 'The Joe Rogan Experience',
        author: 'Joe Rogan',
        description: 'Joe Rogan is a comedian, podcaster, and martial artist. He hosts The Joe Rogan Experience, one of the most popular podcasts in the world.',
        imageUrl: 'https://i.scdn.co/image/ab6765630000f5e7367efb51d7abf1a9d9f52da8',
        feedUrl: 'https://feeds.simplecast.com/dHoohVNH',
        category: 'Comedy',
        isSubscribed: true,
      ),
      Podcast(
        id: 'podcast_2',
        title: 'Crime Junkie',
        author: 'Ashley Flowers',
        description: 'For those who are obsessed with all things true crime.',
        imageUrl: 'https://i.scdn.co/image/ab6765630000f5e6a5a6f7d7d3a0a0a0a0a0a0a0',
        feedUrl: 'https://feeds.simplecast.com/54nAGcIl',
        category: 'True Crime',
        isSubscribed: true,
      ),
      Podcast(
        id: 'podcast_3',
        title: 'The Daily',
        author: 'The New York Times',
        description: 'This is what the news should sound like. The biggest stories of our time, told by the best journalists in the world.',
        imageUrl: 'https://i.scdn.co/image/ab6765630000f5e67388c1c1c1c1c1c1c1c1c1c1',
        feedUrl: 'https://feeds.simplecast.com/54nAGcIl',
        category: 'News',
        isSubscribed: false,
      ),
      Podcast(
        id: 'podcast_4',
        title: 'Tech Junkies',
        author: 'Tech Daily',
        description: 'The latest in tech news, gadgets, and innovation.',
        imageUrl: 'https://i.scdn.co/image/ab6765630000f5e6722722222222222222222222',
        feedUrl: 'https://feeds.example.com/tech',
        category: 'Technology',
        isSubscribed: false,
      ),
      Podcast(
        id: 'podcast_5',
        title: 'Health & Wellness',
        author: 'Dr. Smith',
        description: 'Tips for living a healthier, happier life.',
        imageUrl: 'https://i.scdn.co/image/ab6765630000f5e6733333333333333333333333',
        feedUrl: 'https://feeds.example.com/health',
        category: 'Health',
        isSubscribed: false,
      ),
      Podcast(
        id: 'podcast_6',
        title: 'Music Now',
        author: 'Music Weekly',
        description: 'The latest in music, artists, and industry news.',
        imageUrl: 'https://picsum.photos/seed/podcast6/300/300',
        feedUrl: 'https://feeds.example.com/music',
        category: 'Music',
        isSubscribed: false,
      ),
    ];
  }

  static List<Episode> getEpisodesForPodcast(String podcastId) {
    final now = DateTime.now();
    
    if (podcastId == 'podcast_1') {
      return [
        Episode(
          id: 'ep_1_1',
          podcastId: 'podcast_1',
          title: 'Elon Musk - The Future of AI and Space',
          description: 'Elon Musk joins Joe Rogan to discuss the future of artificial intelligence, SpaceX, and what lies ahead for humanity.',
          audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
          imageUrl: 'https://i.scdn.co/image/ab6765630000f5e7367efb51d7abf1a9d9f52da8',
          duration: const Duration(hours: 2, minutes: 45),
          publishedAt: now.subtract(const Duration(days: 1)),
        ),
        Episode(
          id: 'ep_1_2',
          podcastId: 'podcast_1',
          title: 'Jordan Peterson - Life Lessons',
          description: 'Jordan Peterson shares deep insights on life, psychology, and finding meaning.',
          audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
          imageUrl: 'https://i.scdn.co/image/ab6765630000f5e7367efb51d7abf1a9d9f52da8',
          duration: const Duration(hours: 3, minutes: 10),
          publishedAt: now.subtract(const Duration(days: 3)),
        ),
        Episode(
          id: 'ep_1_3',
          podcastId: 'podcast_1',
          title: 'Andrew Yang - Future of Work',
          description: 'Andrew Yang discusses automation, UBI, and the changing economy.',
          audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3',
          imageUrl: 'https://i.scdn.co/image/ab6765630000f5e7367efb51d7abf1a9d9f52da8',
          duration: const Duration(hours: 2, minutes: 30),
          publishedAt: now.subtract(const Duration(days: 7)),
        ),
        Episode(
          id: 'ep_1_4',
          podcastId: 'podcast_1',
          title: 'Lex Fridman - AI & Deep Learning',
          description: 'A deep dive into artificial intelligence and machine learning.',
          audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3',
          imageUrl: 'https://i.scdn.co/image/ab6765630000f5e7367efb51d7abf1a9d9f52da8',
          duration: const Duration(hours: 4, minutes: 5),
          publishedAt: now.subtract(const Duration(days: 14)),
        ),
      ];
    } else if (podcastId == 'podcast_2') {
      return [
        Episode(
          id: 'ep_2_1',
          podcastId: 'podcast_2',
          title: 'The Mysterious Disappearance of Flight 370',
          description: 'A deep dive into one of the biggest aviation mysteries of our time.',
          audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-5.mp3',
          imageUrl: 'https://i.scdn.co/image/ab6765630000f5e6a5a6f7d7d3a0a0a0a0a0a0a0',
          duration: const Duration(minutes: 45),
          publishedAt: now.subtract(const Duration(days: 2)),
        ),
        Episode(
          id: 'ep_2_2',
          podcastId: 'podcast_2',
          title: 'The Zodiac Killer Part 1',
          description: 'Who was the Zodiac Killer? We break down the evidence.',
          audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-6.mp3',
          imageUrl: 'https://i.scdn.co/image/ab6765630000f5e6a5a6f7d7d3a0a0a0a0a0a0a0',
          duration: const Duration(minutes: 55),
          publishedAt: now.subtract(const Duration(days: 5)),
        ),
        Episode(
          id: 'ep_2_3',
          podcastId: 'podcast_2',
          title: 'The Golden State Killer',
          description: 'How investigators finally caught one of America\'s most notorious serial killers.',
          audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-7.mp3',
          imageUrl: 'https://i.scdn.co/image/ab6765630000f5e6a5a6f7d7d3a0a0a0a0a0a0a0',
          duration: const Duration(minutes: 50),
          publishedAt: now.subtract(const Duration(days: 10)),
        ),
      ];
    } else if (podcastId == 'podcast_3') {
      return [
        Episode(
          id: 'ep_3_1',
          podcastId: 'podcast_3',
          title: 'The News Roundup - May 2026',
          description: 'Today\'s top stories from around the world.',
          audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-8.mp3',
          imageUrl: 'https://i.scdn.co/image/ab6765630000f5e67388c1c1c1c1c1c1c1c1c1c1',
          duration: const Duration(minutes: 25),
          publishedAt: now.subtract(const Duration(hours: 12)),
        ),
        Episode(
          id: 'ep_3_2',
          podcastId: 'podcast_3',
          title: 'The Economy in Flux',
          description: 'What the latest economic indicators mean for you.',
          audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-9.mp3',
          imageUrl: 'https://i.scdn.co/image/ab6765630000f5e67388c1c1c1c1c1c1c1c1c1c1',
          duration: const Duration(minutes: 20),
          publishedAt: now.subtract(const Duration(days: 1)),
        ),
      ];
    } else if (podcastId == 'podcast_4') {
      return [
        Episode(
          id: 'ep_4_1',
          podcastId: 'podcast_4',
          title: 'The Future of iPhone',
          description: 'What to expect from the next generation of iPhones.',
          audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-10.mp3',
          imageUrl: 'https://i.scdn.co/image/ab6765630000f5e6722722222222222222222222',
          duration: const Duration(minutes: 35),
          publishedAt: now.subtract(const Duration(days: 3)),
        ),
        Episode(
          id: 'ep_4_2',
          podcastId: 'podcast_4',
          title: 'AI Assistants Everywhere',
          description: 'How AI is changing the way we interact with technology.',
          audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-11.mp3',
          imageUrl: 'https://i.scdn.co/image/ab6765630000f5e6722722222222222222222222',
          duration: const Duration(minutes: 40),
          publishedAt: now.subtract(const Duration(days: 7)),
        ),
      ];
    } else if (podcastId == 'podcast_5') {
      return [
        Episode(
          id: 'ep_5_1',
          podcastId: 'podcast_5',
          title: 'Sleep Better Tonight',
          description: 'Science-backed tips for getting better sleep.',
          audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-12.mp3',
          imageUrl: 'https://i.scdn.co/image/ab6765630000f5e6733333333333333333333333',
          duration: const Duration(minutes: 30),
          publishedAt: now.subtract(const Duration(days: 4)),
        ),
        Episode(
          id: 'ep_5_2',
          podcastId: 'podcast_5',
          title: 'Nutrition Myths Debunked',
          description: 'Separating fact from fiction in the world of nutrition.',
          audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-13.mp3',
          imageUrl: 'https://i.scdn.co/image/ab6765630000f5e6733333333333333333333333',
          duration: const Duration(minutes: 25),
          publishedAt: now.subtract(const Duration(days: 8)),
        ),
        Episode(
          id: 'ep_5_3',
          podcastId: 'podcast_5',
          title: 'Stress Management 101',
          description: 'Practical techniques for managing daily stress.',
          audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-14.mp3',
          imageUrl: 'https://i.scdn.co/image/ab6765630000f5e6733333333333333333333333',
          duration: const Duration(minutes: 35),
          publishedAt: now.subtract(const Duration(days: 12)),
        ),
      ];
    } else if (podcastId == 'podcast_6') {
      return [
        Episode(
          id: 'ep_6_1',
          podcastId: 'podcast_6',
          title: 'Top 10 Albums of 2026',
          description: 'Our picks for the best albums released this year.',
          audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-15.mp3',
          imageUrl: 'https://picsum.photos/seed/ep61/300/300',
          duration: const Duration(minutes: 45),
          publishedAt: now.subtract(const Duration(days: 1)),
        ),
        Episode(
          id: 'ep_6_2',
          podcastId: 'podcast_6',
          title: 'Interview with Rising Star',
          description: 'A conversation with the hottest new artist in town.',
          audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-16.mp3',
          imageUrl: 'https://picsum.photos/seed/ep62/300/300',
          duration: const Duration(minutes: 50),
          publishedAt: now.subtract(const Duration(days: 5)),
        ),
        Episode(
          id: 'ep_6_3',
          podcastId: 'podcast_6',
          title: 'Behind the Charts',
          description: 'How songs become hits - an inside look at the music industry.',
          audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-17.mp3',
          imageUrl: 'https://picsum.photos/seed/ep63/300/300',
          duration: const Duration(minutes: 35),
          publishedAt: now.subtract(const Duration(days: 10)),
        ),
      ];
    }
    
    return [];
  }
}