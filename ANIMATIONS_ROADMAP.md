# 🎬 Poddrunk Micro-Animations Roadmap

This living document tracks subtle micro-animations designed to elevate Poddrunk's premium feel while preserving its signature Neo-Brutalist, tactile aesthetic.

## Evaluation Protocol (One-by-One)
For every animation on this list:
1. **Implement**: Code the specific animation cleanly with zero regressions.
2. **Verify**: Run `flutter analyze` and `flutter test`.
3. **User Test**: The user tests the interaction live on device or simulator.
4. **Decision**:
   - **KEEP**: Mark as `[x] ACCEPTED`, commit the change.
   - **REVERT**: If not liked, cleanly revert the code back to the previous git state.

---

## Proposed Animations & Micro-Interactions

### Phase 1: Global Tactile Physics
| # | Target Element | Screen / Component | Animation Type & Physics | Status |
|---|---|---|---|---|
| **A1** | **Mechanical Push-Down & Haptic Click** | All Buttons (`BrutalistButton`) | When pressed down, button translates `+2px, +2px` while shadow collapses with a crisp `HapticFeedback.lightImpact()`. Spring release `60ms`. | `[x] ACCEPTED` |
| **A2** | **Card Press Depth Reaction** | Clickable Cards (`BrutalistCard`) | Subtle translation `+1.5px, +1.5px` on tap with shadow reduction on interactive cards (Settings tiles, Queue items). | `[x] ACCEPTED` |

---

### Phase 2: Cassette Player & Playback Screen
| # | Target Element | Screen / Component | Animation Type & Physics | Status |
|---|---|---|---|---|
| **A3** | **Cassette Reel Inertia & Friction** | Now Playing Cassette (`RetroCassetteWidget`) | Reels accelerate smoothly over `350ms` upon Play, and coast to a natural friction stop over `450ms` upon Pause instead of freezing abruptly. | `[-] REVERTED (Laggy/Jittery)` |
| **A4** | **Seek Gesture Flash & Ripple** | Artwork Double-Tap (`NowPlayingScreen`) | When double-tapping left/right sides of cassette to skip `10s/15s`, an animated Neo-Brutalist chevron ripple (`<< 10s` / `>> 10s`) bursts and fades out smoothly. | `[ ] PENDING` |
| **A5** | **Play/Pause Morphing Toggle** | Main Playback Button (`NowPlayingScreen`) | Smooth animated vector rotation/morph between Play (▶) and Pause (⏸) icons with subtle scale spring. | `[ ] PENDING` |

---

### Phase 3: Signature Features & Library
| # | Target Element | Screen / Component | Animation Type & Physics | Status |
|---|---|---|---|---|
| **A6** | **Counted Repeat Countdown Spring Pop** | Counted Repeat Badge (`NowPlayingScreen`) | Whenever a loop finishes and the counter decrements (e.g. `5 ➔ 4 ➔ 3`), the badge scales up `1.2x` and snaps back with a bounce curve. | `[ ] PENDING` |
| **A7** | **Now-Playing Rhythmic Equalizer Bars** | Library Songs List (`LibraryScreen`) | 3 small monochrome vertical bars dancing to simulated audio rhythm next to the currently playing song in the list. | `[ ] PENDING` |
| **A8** | **Mini-Player to Full-Player Slide Expansion** | Bottom Navigation (`MainNavigationScreen`) | Smooth vertical swipe-up sheet transition from bottom mini-bar to full Now Playing cassette. | `[ ] PENDING` |

---

### Phase 4: Equalizer & Controls
| # | Target Element | Screen / Component | Animation Type & Physics | Status |
|---|---|---|---|---|
| **A9** | **Equalizer Slider Magnetic Snap** | 5-Band Sliders (`EqualizerScreen`) | Sliders provide subtle haptic tick and magnetic snap when crossing `0 dB` (center). | `[ ] PENDING` |
| **A10** | **Weather Badge Refresh Shimmer** | Library Header (`WeatherBadge`) | Gentle rotation/breeze wave on the weather icon when fetching or tapping to refresh live weather. | `[ ] PENDING` |
