# PodDrunk - Podcast App Specification

## 1. Project Overview

- **Project Name**: PodDrunk
- **Type**: Cross-platform Mobile Podcast App (iOS, Android)
- **Core Functionality**: A full-featured podcast player supporting audio/video podcasts from RSS feeds and local files, with cloud sync capabilities similar to Spotify/Apple Podcasts

## 2. Technology Stack & Choices

### Framework & Language
- **Flutter**: 3.x (latest stable)
- **Dart**: 3.x with null safety

### Key Dependencies
| Package | Version | Purpose |
|---------|---------|---------|
| flutter_riverpod | ^2.4.0 | State management |
| just_audio | ^0.9.36 | Audio playback |
| video_player | ^2.8.0 | Video playback |
| supabase_flutter | ^1.10.0 | Backend (Auth, DB, Storage) |
| hive_flutter | ^1.1.0 | Local storage |
| dio | ^5.3.0 | HTTP client |
| xml | ^6.4.0 | RSS feed parsing |
| cached_network_image | ^3.3.0 | Image caching |
| go_router | ^12.1.0 | Navigation |
| audio_service | ^0.18.12 | Background playback |

### Architecture
- **Clean Architecture** with 3 layers:
  - **Data Layer**: Repositories, data sources, models
  - **Domain Layer**: Entities, use cases, repository interfaces
  - **Presentation Layer**: Screens, widgets, providers

### State Management
- **Riverpod** for reactive state management

## 3. Feature List

### Authentication
- [x] Email/password signup & login
- [x] OAuth (Google, Apple)
- [x] Guest mode (local-only)

### Home / Discover
- [x] Featured podcasts carousel
- [x] Categories (Comedy, News, Tech, etc.)
- [x] Trending/Popular podcasts
- [x] Search functionality

### Library / Your Podcasts
- [x] Subscribed podcasts
- [x] Downloaded episodes (offline)
- [x] Recently played
- [x] History

### Podcast Detail Page
- [x] Show info/description
- [x] Episode list
- [x] Subscribe button
- [x] Share option

### Episode Detail
- [x] Episode description
- [x] Show notes
- [x] Download/Stream options

### Player Screen
- [x] Full-screen player (like Spotify)
- [x] Play/Pause, Skip, Seek
- [x] Playback speed (0.5x - 2x)
- [x] Sleep timer
- [x] Queue management

### Mini Player
- [x] Persistent bottom bar
- [x] Quick controls
- [x] Progress indicator

### Settings
- [x] Playback preferences
- [x] Storage management
- [x] Theme (Dark/Light)
- [x] Notifications

## 4. UI/UX Design Direction

### Overall Visual Style
- Modern, clean interface similar to Spotify/Apple Podcasts
- Card-based layouts for podcasts and episodes
- Smooth animations and transitions

### Color Scheme
- **Primary**: Deep Purple (#6B4EFF)
- **Secondary**: Coral/Orange accent (#FF6B6B)
- **Dark Theme**: Background #121212, Surface #1E1E1E
- **Light Theme**: Background #FFFFFF, Surface #F5F5F5

### Layout Approach
- Bottom navigation with 4 tabs: Home, Search, Library, Settings
- Persistent mini-player above bottom nav
- Full-screen player accessible by tapping mini-player

### Navigation Structure
```
Splash → Onboarding → Auth (if needed) → Main App
Main App Tabs:
  - Home (Discover)
  - Search
  - Library
  - Settings

Full-screen Player (modal from mini-player)
Podcast Detail (push from any list)
Episode Detail (push from podcast detail)
```

## 5. Database Schema (Supabase)

### Tables
- **users**: id, email, created_at, avatar_url
- **podcasts**: id, title, author, description, image_url, feed_url, category
- **episodes**: id, podcast_id, title, description, audio_url, video_url, duration, published_at
- **subscriptions**: user_id, podcast_id, created_at
- **downloads**: user_id, episode_id, local_path, downloaded_at
- **playback_state**: user_id, episode_id, position, updated_at

## 6. Development Phases

| Phase | Features |
|-------|----------|
| **Phase 1** | Project setup, basic UI, audio playback |
| **Phase 2** | RSS feed parsing, subscriptions |
| **Phase 3** | Download management, offline mode |
| **Phase 4** | User auth, cloud sync |
| **Phase 5** | Video player, polish & optimization |

## 7. App Pages

| Page | Description |
|------|-------------|
| Splash | App loading, initial auth check |
| Onboarding | First-time user welcome |
| Auth | Login/Register |
| Home | Discover podcasts |
| Search | Search podcasts/episodes |
| Library | User's subscriptions/downloads |
| Podcast Detail | Show info + episodes |
| Episode Detail | Single episode view |
| Player | Full-screen audio/video |
| Settings | App preferences |