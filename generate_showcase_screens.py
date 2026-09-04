import os
import subprocess
import base64

CHROME_BIN = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
OUTPUT_DIR = "/Users/christembassyabujazone1/projects/poddrunk/showcase_screens"
ASSETS_DIR = "/Users/christembassyabujazone1/projects/poddrunk/assets"

os.makedirs(OUTPUT_DIR, exist_ok=True)

# Read logo as base64 so HTML is 100% self-contained
logo_path = os.path.join(ASSETS_DIR, "app_icon.jpg")
with open(logo_path, "rb") as f:
    logo_base64 = "data:image/jpeg;base64," + base64.b64encode(f.read()).decode("utf-8")

COMMON_CSS = """
  @import url('https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@600;700;800;900&family=Inter:wght@400;500;600;700;800;900&display=swap');

  * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Inter', -apple-system, sans-serif; -webkit-font-smoothing: antialiased; }
  
  body {
    width: 390px;
    height: 844px;
    background: var(--canvas);
    color: var(--text);
    overflow: hidden;
    position: relative;
    display: flex;
    flex-direction: column;
  }

  /* Status Bar */
  .status-bar {
    height: 48px;
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 10px 28px 0 28px;
    font-size: 13px;
    font-weight: 800;
    color: var(--text);
    z-index: 100;
    flex-shrink: 0;
  }
  .dynamic-island {
    width: 110px;
    height: 28px;
    background: #000;
    border-radius: 20px;
    position: absolute;
    top: 10px;
    left: calc(50% - 55px);
  }

  .content-area {
    flex: 1;
    display: flex;
    flex-direction: column;
    padding: 8px 16px 20px 16px;
    position: relative;
    overflow: hidden;
  }

  .brutalist-card {
    background: var(--card-bg);
    border: 2px solid var(--border);
    box-shadow: 3.5px 3.5px 0 var(--shadow-color);
    border-radius: 6px;
    padding: 12px;
  }

  .btn {
    font-family: 'Space Grotesk', sans-serif;
    font-weight: 900;
    border: 2px solid var(--border);
    box-shadow: 3px 3px 0 var(--shadow-color);
    border-radius: 4px;
    cursor: pointer;
    text-transform: uppercase;
    letter-spacing: 1px;
    display: inline-flex;
    align-items: center;
    justify-content: center;
  }

  .btn-primary { background: var(--primary); color: #111; }
  .btn-accent { background: var(--accent); color: #fff; }
  .btn-card { background: var(--card-bg); color: var(--text); }
"""

LIGHT_TOKENS = """
  :root {
    --primary: #F7CE46;
    --accent: #EE5A24;
    --border: #111111;
    --canvas: #F9F4EB;
    --card-bg: #FFFFFF;
    --text: #111111;
    --muted: #666666;
    --shadow-color: #111111;
  }
"""

DARK_TOKENS = """
  :root {
    --primary: #F7CE46;
    --accent: #FF5722;
    --border: #2E2E36;
    --canvas: #0C0C0E;
    --card-bg: #18181C;
    --text: #F4F4F6;
    --muted: #8E8E98;
    --shadow-color: #000000;
  }
"""

screens = {}

# 1. SPLASH SCREEN
screens["01_splash_screen.html"] = f"""
<!DOCTYPE html>
<html>
<head>
<style>
{LIGHT_TOKENS}
{COMMON_CSS}
.splash-container {{
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #F9F4EB;
}}
.logo-box {{
  width: 160px;
  height: 160px;
  background: #F7CE46;
  border: 3.5px solid #111111;
  box-shadow: 6px 6px 0 #111111;
  border-radius: 20px;
  overflow: hidden;
  display: flex;
  align-items: center;
  justify-content: center;
}}
.logo-box img {{
  width: 100%;
  height: 100%;
  object-fit: cover;
}}
</style>
</head>
<body>
  <div class="dynamic-island"></div>
  <div class="status-bar"><span>9:41</span><span>●●● 5G</span></div>
  <div class="splash-container">
    <div class="logo-box">
      <img src="{logo_base64}" />
    </div>
  </div>
</body>
</html>
"""

# 2. MUSIC LIBRARY
screens["02_library_songs.html"] = f"""
<!DOCTYPE html>
<html>
<head>
<style>
{LIGHT_TOKENS}
{COMMON_CSS}
.header {{
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 6px 0 12px 0;
}}
.header h1 {{
  font-family: 'Space Grotesk', sans-serif;
  font-size: 22px;
  font-weight: 900;
  letter-spacing: 1.5px;
}}
.search-box {{
  display: flex;
  align-items: center;
  gap: 10px;
  background: #fff;
  border: 2px solid #111;
  box-shadow: 3px 3px 0 #111;
  border-radius: 4px;
  padding: 10px 14px;
  font-size: 11px;
  font-weight: 800;
  color: #777;
  margin-bottom: 12px;
}}
.tabs-row {{
  display: flex;
  gap: 6px;
  margin-bottom: 12px;
}}
.tab-chip {{
  font-family: 'Space Grotesk', sans-serif;
  font-size: 11px;
  font-weight: 900;
  padding: 6px 12px;
  border: 2px solid #111;
  border-radius: 4px;
  background: #fff;
}}
.tab-chip.active {{
  background: #F7CE46;
  box-shadow: 2px 2px 0 #111;
}}
.song-list {{
  display: flex;
  flex-direction: column;
  gap: 8px;
}}
.song-card {{
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 10px 12px;
}}
.song-badge {{
  width: 36px;
  height: 36px;
  background: #F7CE46;
  border: 1.5px solid #111;
  border-radius: 4px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 900;
  font-size: 12px;
  flex-shrink: 0;
}}
.song-badge.playing {{
  background: #EE5A24;
  color: #fff;
}}
.song-meta {{
  flex: 1;
  min-width: 0;
}}
.song-title {{
  font-size: 13px;
  font-weight: 900;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}}
.song-sub {{
  font-size: 11px;
  font-weight: 700;
  color: #666;
  margin-top: 2px;
}}
.mini-player {{
  position: absolute;
  bottom: 14px;
  left: 14px;
  right: 14px;
  background: #FFFFFF;
  border: 2.5px solid #111;
  box-shadow: 4px 4px 0 #111;
  border-radius: 8px;
  padding: 10px 12px;
  display: flex;
  align-items: center;
  gap: 10px;
}}
.mini-icon {{
  width: 34px;
  height: 34px;
  background: #EE5A24;
  border: 1.5px solid #111;
  border-radius: 4px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #fff;
  font-size: 15px;
}}
</style>
</head>
<body>
  <div class="dynamic-island"></div>
  <div class="status-bar"><span>9:41</span><span>●●● 5G</span></div>
  <div class="content-area">
    <div class="header">
      <h1>PODDRUNK</h1>
      <div style="font-weight: 900; font-size: 18px; display: flex; gap: 12px;">🔍 ⚙️</div>
    </div>
    <div class="search-box">
      <span>🔍</span>
      <span>SEARCH SONGS, ARTISTS, ALBUMS...</span>
    </div>
    <div class="tabs-row">
      <div class="tab-chip active">SONGS (48)</div>
      <div class="tab-chip">PLAYLISTS</div>
      <div class="tab-chip">ALBUMS</div>
      <div class="tab-chip">ARTISTS</div>
    </div>

    <div class="song-list">
      <div class="brutalist-card song-card" style="background: rgba(247, 206, 70, 0.25);">
        <div class="song-badge playing">▶</div>
        <div class="song-meta">
          <div class="song-title">Midnight Tokyo Drift</div>
          <div class="song-sub">Kavinsky • OutRun</div>
        </div>
        <span style="font-weight: 900; font-size: 12px;">04:18</span>
      </div>

      <div class="brutalist-card song-card">
        <div class="song-badge">02</div>
        <div class="song-meta">
          <div class="song-title">Canary Yellow Horizon</div>
          <div class="song-sub">Analog Echo • Brutal Sound</div>
        </div>
        <span style="font-weight: 700; font-size: 12px; color: #666;">03:45</span>
      </div>

      <div class="brutalist-card song-card">
        <div class="song-badge">03</div>
        <div class="song-meta">
          <div class="song-title">Cassette Tape Memories</div>
          <div class="song-sub">Retro Synthwave Lab</div>
        </div>
        <span style="font-weight: 700; font-size: 12px; color: #666;">05:12</span>
      </div>

      <div class="brutalist-card song-card">
        <div class="song-badge">04</div>
        <div class="song-meta">
          <div class="song-title">Cybernetic Bassline</div>
          <div class="song-sub">Obsidian Orchestra</div>
        </div>
        <span style="font-weight: 700; font-size: 12px; color: #666;">03:30</span>
      </div>

      <div class="brutalist-card song-card">
        <div class="song-badge">05</div>
        <div class="song-meta">
          <div class="song-title">Editorial Repeat Pulse</div>
          <div class="song-sub">Paper & Ink Collective</div>
        </div>
        <span style="font-weight: 700; font-size: 12px; color: #666;">06:04</span>
      </div>
    </div>

    <div class="mini-player">
      <div class="mini-icon">📼</div>
      <div class="song-meta">
        <div class="song-title">Midnight Tokyo Drift</div>
        <div class="song-sub">Kavinsky • OutRun</div>
      </div>
      <div style="font-size: 20px; font-weight: 900; color: #EE5A24;">⏸</div>
    </div>
  </div>
</body>
</html>
"""

# 3. NOW PLAYING PLAYER
screens["03_now_playing_player.html"] = f"""
<!DOCTYPE html>
<html>
<head>
<style>
{LIGHT_TOKENS}
{COMMON_CSS}
.player-header {{
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 4px 0 10px 0;
}}
.player-header h2 {{
  font-family: 'Space Grotesk', sans-serif;
  font-size: 16px;
  font-weight: 900;
  letter-spacing: 1.5px;
}}
.cassette-box {{
  width: 100%;
  height: 200px;
  background: #18181A;
  border: 3.5px solid #111;
  box-shadow: 6px 6px 0 #111;
  border-radius: 12px;
  padding: 14px;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  color: #fff;
  margin: 8px 0 18px 0;
}}
.cassette-top {{
  display: flex;
  justify-content: space-between;
  align-items: center;
  border-bottom: 2px solid #333;
  padding-bottom: 6px;
}}
.cassette-tag {{
  background: #F7CE46;
  color: #111;
  font-family: 'Space Grotesk', sans-serif;
  font-weight: 900;
  font-size: 11px;
  padding: 3px 8px;
  border: 1.5px solid #111;
  border-radius: 3px;
}}
.spool-window {{
  background: #2C2C32;
  border: 2.5px solid #111;
  border-radius: 8px;
  height: 74px;
  display: flex;
  align-items: center;
  justify-content: space-around;
  padding: 0 28px;
  position: relative;
}}
.spool-window::before {{
  content: '';
  position: absolute;
  width: 52px;
  height: 18px;
  background: #EE5A24;
  border: 1.5px solid #111;
  border-radius: 3px;
  z-index: 1;
}}
.spool {{
  width: 46px;
  height: 46px;
  background: #FFFFFF;
  border: 3px solid #111;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  position: relative;
  z-index: 2;
}}
.spool::after {{
  content: '';
  width: 16px;
  height: 16px;
  background: #18181A;
  border: 2px solid #111;
  border-radius: 50%;
}}
.scrubber-bar {{
  width: 100%;
  height: 8px;
  background: rgba(0,0,0,0.15);
  border: 1.5px solid #111;
  border-radius: 4px;
  position: relative;
  margin: 14px 0 6px 0;
}}
.scrubber-fill {{
  width: 44%;
  height: 100%;
  background: #EE5A24;
  border-radius: 2px;
  position: relative;
}}
.scrubber-thumb {{
  width: 18px;
  height: 18px;
  background: #F7CE46;
  border: 2px solid #111;
  box-shadow: 1.5px 1.5px 0 #111;
  border-radius: 50%;
  position: absolute;
  right: -9px;
  top: -6px;
}}
.engine-badge {{
  background: #fff;
  border: 2px solid #111;
  box-shadow: 3.5px 3.5px 0 #111;
  border-radius: 6px;
  padding: 12px 14px;
  margin: 18px 0;
  display: flex;
  justify-content: space-between;
  align-items: center;
}}
.engine-num {{
  font-family: 'Space Grotesk', sans-serif;
  font-weight: 900;
  font-size: 16px;
  color: #EE5A24;
  background: rgba(238, 90, 36, 0.1);
  padding: 4px 8px;
  border: 1.5px solid #EE5A24;
  border-radius: 4px;
}}
.controls-row {{
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 10px;
}}
.ctrl-btn {{
  width: 48px;
  height: 48px;
  background: #fff;
  border: 2px solid #111;
  box-shadow: 3px 3px 0 #111;
  border-radius: 6px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 18px;
  font-weight: 900;
}}
.ctrl-btn.play {{
  width: 62px;
  height: 62px;
  background: #F7CE46;
  font-size: 26px;
}}
</style>
</head>
<body>
  <div class="dynamic-island"></div>
  <div class="status-bar"><span>9:41</span><span>●●● 5G</span></div>
  <div class="content-area">
    <div class="player-header">
      <span style="font-size: 18px; font-weight: 900;">⌄</span>
      <h2>NOW PLAYING</h2>
      <div style="display: flex; gap: 8px; align-items: center;">
        <span class="btn btn-primary" style="padding: 2px 6px; font-size: 10px;">EQ</span>
        <span style="font-size: 18px; font-weight: 900;">•••</span>
      </div>
    </div>

    <div class="cassette-box">
      <div class="cassette-top">
        <span class="cassette-tag">PODDRUNK • SIDE A</span>
        <span style="font-size: 10px; font-weight: 800; opacity: 0.7;">HIGH BIAS 90</span>
      </div>
      <div class="spool-window">
        <div class="spool"></div>
        <div class="spool"></div>
      </div>
      <div style="display: flex; justify-content: space-between; font-size: 9px; font-weight: 900; opacity: 0.7;">
        <span>INDEX: 024</span>
        <span>STEREO AUDIO ENGINE</span>
      </div>
    </div>

    <div style="text-align: center; margin: 4px 0 8px 0;">
      <div style="font-family: 'Space Grotesk', sans-serif; font-size: 20px; font-weight: 900;">Midnight Tokyo Drift</div>
      <div style="font-size: 13px; font-weight: 700; color: #666; margin-top: 3px;">Kavinsky • OutRun (2024)</div>
    </div>

    <div class="scrubber-bar">
      <div class="scrubber-fill"><div class="scrubber-thumb"></div></div>
    </div>
    <div style="display: flex; justify-content: space-between; font-size: 11px; font-weight: 800; color: #666;">
      <span>01:48</span>
      <span>04:18</span>
    </div>

    <div class="engine-badge">
      <div>
        <div style="font-family: 'Space Grotesk', sans-serif; font-size: 11px; font-weight: 900; letter-spacing: 0.8px;">COUNTED REPEAT ENGINE</div>
        <div style="font-size: 11px; font-weight: 700; color: #666; margin-top: 1px;">Finite Loop Protection Active</div>
      </div>
      <div class="engine-num">🔁 3 / 5</div>
    </div>

    <div class="controls-row">
      <div class="ctrl-btn">🔀</div>
      <div class="ctrl-btn">⏮</div>
      <div class="ctrl-btn play">▶</div>
      <div class="ctrl-btn">⏭</div>
      <div class="ctrl-btn">🔁</div>
    </div>
  </div>
</body>
</html>
"""

# 4. 5-BAND EQUALIZER SCREEN
screens["04_equalizer.html"] = f"""
<!DOCTYPE html>
<html>
<head>
<style>
{LIGHT_TOKENS}
{COMMON_CSS}
.eq-header {{
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 6px 0 12px 0;
}}
.eq-header h2 {{
  font-family: 'Space Grotesk', sans-serif;
  font-size: 16px;
  font-weight: 900;
  letter-spacing: 1.5px;
}}
.presets-row {{
  display: flex;
  gap: 6px;
  overflow-x: auto;
  margin-bottom: 14px;
}}
.preset-chip {{
  font-family: 'Space Grotesk', sans-serif;
  font-size: 10px;
  font-weight: 900;
  padding: 6px 12px;
  border: 1.5px solid #111;
  border-radius: 4px;
  background: #fff;
  white-space: nowrap;
}}
.preset-chip.active {{
  background: #EE5A24;
  color: #fff;
  box-shadow: 2px 2px 0 #111;
}}
.eq-grid {{
  display: flex;
  justify-content: space-between;
  align-items: flex-end;
  height: 230px;
  background: #FFFFFF;
  border: 2.5px solid #111;
  box-shadow: 4px 4px 0 #111;
  border-radius: 8px;
  padding: 16px 14px;
  margin-bottom: 14px;
}}
.eq-col {{
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
  height: 100%;
}}
.slider-track {{
  width: 10px;
  flex: 1;
  background: rgba(0,0,0,0.08);
  border: 1.5px solid #111;
  border-radius: 5px;
  position: relative;
  display: flex;
  justify-content: center;
}}
.slider-handle {{
  position: absolute;
  width: 26px;
  height: 14px;
  background: #F7CE46;
  border: 2px solid #111;
  box-shadow: 2px 2px 0 #111;
  border-radius: 3px;
}}
.eq-label {{
  font-family: 'Space Grotesk', sans-serif;
  font-size: 11px;
  font-weight: 900;
}}
.boost-card {{
  background: #fff;
  border: 2px solid #111;
  box-shadow: 3.5px 3.5px 0 #111;
  border-radius: 6px;
  padding: 12px 14px;
  margin-bottom: 10px;
}}
</style>
</head>
<body>
  <div class="dynamic-island"></div>
  <div class="status-bar"><span>9:41</span><span>●●● 5G</span></div>
  <div class="content-area">
    <div class="eq-header">
      <span style="font-size: 18px; font-weight: 900;">←</span>
      <h2>5-BAND EQUALIZER</h2>
      <span class="btn btn-accent" style="padding: 3px 8px; font-size: 10px;">ACTIVE</span>
    </div>

    <div class="presets-row">
      <span class="preset-chip active">BASS BOOST</span>
      <span class="preset-chip">ELECTRONIC</span>
      <span class="preset-chip">ACOUSTIC</span>
      <span class="preset-chip">VOCAL</span>
      <span class="preset-chip">ROCK</span>
    </div>

    <div class="eq-grid">
      <div class="eq-col">
        <span style="font-size: 9px; font-weight: 900; color: #EE5A24;">+6dB</span>
        <div class="slider-track"><div class="slider-handle" style="top: 25%;"></div></div>
        <span class="eq-label">60Hz</span>
      </div>
      <div class="eq-col">
        <span style="font-size: 9px; font-weight: 900; color: #EE5A24;">+4dB</span>
        <div class="slider-track"><div class="slider-handle" style="top: 35%;"></div></div>
        <span class="eq-label">230Hz</span>
      </div>
      <div class="eq-col">
        <span style="font-size: 9px; font-weight: 900;">0dB</span>
        <div class="slider-track"><div class="slider-handle" style="top: 50%;"></div></div>
        <span class="eq-label">910Hz</span>
      </div>
      <div class="eq-col">
        <span style="font-size: 9px; font-weight: 900; color: #EE5A24;">+3dB</span>
        <div class="slider-track"><div class="slider-handle" style="top: 40%;"></div></div>
        <span class="eq-label">3.6kHz</span>
      </div>
      <div class="eq-col">
        <span style="font-size: 9px; font-weight: 900; color: #EE5A24;">+5dB</span>
        <div class="slider-track"><div class="slider-handle" style="top: 30%;"></div></div>
        <span class="eq-label">14kHz</span>
      </div>
    </div>

    <div class="boost-card">
      <div style="font-family: 'Space Grotesk', sans-serif; font-weight: 900; font-size: 12px; margin-bottom: 8px;">BASS BOOST INTENSITY</div>
      <div style="width: 100%; height: 8px; background: rgba(0,0,0,0.1); border: 1.5px solid #111; border-radius: 4px; position: relative;">
        <div style="width: 75%; height: 100%; background: #EE5A24; border-radius: 2px;"></div>
        <div style="width: 16px; height: 16px; background: #F7CE46; border: 2px solid #111; box-shadow: 1.5px 1.5px 0 #111; border-radius: 50%; position: absolute; left: calc(75% - 8px); top: -5px;"></div>
      </div>
      <div style="display: flex; justify-content: space-between; font-size: 10px; font-weight: 800; color: #666; margin-top: 6px;">
        <span>OFF</span>
        <span style="color: #EE5A24; font-weight: 900;">750 / 1000</span>
        <span>MAX</span>
      </div>
    </div>

    <div class="boost-card">
      <div style="font-family: 'Space Grotesk', sans-serif; font-weight: 900; font-size: 12px; margin-bottom: 8px;">VIRTUALIZER & REVERB PRESET</div>
      <div style="display: flex; gap: 6px;">
        <span class="preset-chip active" style="font-size: 9px; padding: 4px 8px;">LARGE HALL</span>
        <span class="preset-chip" style="font-size: 9px; padding: 4px 8px;">STUDIO ROOM</span>
        <span class="preset-chip" style="font-size: 9px; padding: 4px 8px;">PLATE</span>
      </div>
    </div>
  </div>
</body>
</html>
"""

# 5. ALBUM & ARTIST COLLECTION VIEW
screens["05_album_collection.html"] = f"""
<!DOCTYPE html>
<html>
<head>
<style>
{LIGHT_TOKENS}
{COMMON_CSS}
.album-header {{
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 6px 0 12px 0;
}}
.album-header h2 {{
  font-family: 'Space Grotesk', sans-serif;
  font-size: 16px;
  font-weight: 900;
  letter-spacing: 1.5px;
}}
.hero-card {{
  background: #fff;
  border: 2.5px solid #111;
  box-shadow: 4px 4px 0 #111;
  border-radius: 8px;
  padding: 14px;
  display: flex;
  gap: 14px;
  align-items: center;
  margin-bottom: 12px;
}}
.hero-disc {{
  width: 72px;
  height: 72px;
  background: #F7CE46;
  border: 2px solid #111;
  box-shadow: 2px 2px 0 #111;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 36px;
  flex-shrink: 0;
}}
.action-row {{
  display: flex;
  gap: 10px;
  margin-bottom: 14px;
}}
.track-row {{
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 8px 10px;
  margin-bottom: 6px;
}}
.track-num {{
  width: 24px;
  font-weight: 900;
  font-size: 12px;
}}
</style>
</head>
<body>
  <div class="dynamic-island"></div>
  <div class="status-bar"><span>9:41</span><span>●●● 5G</span></div>
  <div class="content-area">
    <div class="album-header">
      <span style="font-size: 18px; font-weight: 900;">←</span>
      <h2>ALBUM</h2>
      <span style="font-size: 18px; font-weight: 900;">•••</span>
    </div>

    <div class="hero-card">
      <div class="hero-disc">💿</div>
      <div>
        <div style="font-family: 'Space Grotesk', sans-serif; font-size: 17px; font-weight: 900;">OutRun Extended</div>
        <div style="font-size: 13px; font-weight: 700; color: #555; margin: 2px 0;">Kavinsky</div>
        <div style="font-size: 11px; font-weight: 800; color: #EE5A24;">12 TRACKS • 54 MIN</div>
      </div>
    </div>

    <div class="action-row">
      <button class="btn btn-primary" style="flex: 1; padding: 10px; font-size: 12px;">▶ PLAY ALL</button>
      <button class="btn btn-card" style="flex: 1; padding: 10px; font-size: 12px;">🔀 SHUFFLE</button>
    </div>

    <div class="brutalist-card track-row">
      <span class="track-num">1</span>
      <div style="flex: 1;">
        <div style="font-weight: 900; font-size: 13px;">Prelude</div>
        <div style="font-size: 11px; font-weight: 700; color: #666;">Kavinsky</div>
      </div>
      <span style="font-size: 11px; font-weight: 800; color: #666;">01:54</span>
      <span style="font-size: 16px; font-weight: 900; margin-left: 6px;">•••</span>
    </div>

    <div class="brutalist-card track-row" style="background: rgba(247, 206, 70, 0.3);">
      <span class="track-num" style="color: #EE5A24;">▶</span>
      <div style="flex: 1;">
        <div style="font-weight: 900; font-size: 13px;">Blizzard (Electronic)</div>
        <div style="font-size: 11px; font-weight: 700; color: #666;">Kavinsky</div>
      </div>
      <span style="font-size: 11px; font-weight: 800; color: #666;">03:28</span>
      <span style="font-size: 16px; font-weight: 900; margin-left: 6px;">•••</span>
    </div>

    <div class="brutalist-card track-row">
      <span class="track-num">3</span>
      <div style="flex: 1;">
        <div style="font-weight: 900; font-size: 13px;">Protovision</div>
        <div style="font-size: 11px; font-weight: 700; color: #666;">Kavinsky</div>
      </div>
      <span style="font-size: 11px; font-weight: 800; color: #666;">03:26</span>
      <span style="font-size: 16px; font-weight: 900; margin-left: 6px;">•••</span>
    </div>

    <div class="brutalist-card track-row">
      <span class="track-num">4</span>
      <div style="flex: 1;">
        <div style="font-weight: 900; font-size: 13px;">Odd Look</div>
        <div style="font-size: 11px; font-weight: 700; color: #666;">Kavinsky feat. The Weeknd</div>
      </div>
      <span style="font-size: 11px; font-weight: 800; color: #666;">04:12</span>
      <span style="font-size: 16px; font-weight: 900; margin-left: 6px;">•••</span>
    </div>
  </div>
</body>
</html>
"""

# 6. TRACK OPTIONS & RINGTONE ACTION SHEET
screens["06_track_options.html"] = f"""
<!DOCTYPE html>
<html>
<head>
<style>
{LIGHT_TOKENS}
{COMMON_CSS}
.backdrop {{
  position: absolute;
  top: 0; left: 0; right: 0; bottom: 0;
  background: rgba(0,0,0,0.55);
  display: flex;
  flex-direction: column;
  justify-content: flex-end;
}}
.sheet {{
  background: #FFFFFF;
  border-top: 3px solid #111;
  box-shadow: 0 -4px 0 rgba(0,0,0,0.1);
  border-radius: 16px 16px 0 0;
  padding: 14px 18px 30px 18px;
}}
.sheet-bar {{
  width: 44px;
  height: 5px;
  background: #CCC;
  border-radius: 3px;
  margin: 0 auto 12px auto;
}}
.track-header {{
  background: #F7CE46;
  border: 2px solid #111;
  box-shadow: 3px 3px 0 #111;
  border-radius: 6px;
  padding: 10px 12px;
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 14px;
}}
.opt-row {{
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 10px 6px;
  font-family: 'Space Grotesk', sans-serif;
  font-size: 13px;
  font-weight: 900;
  border-bottom: 1px solid rgba(0,0,0,0.06);
}}
.opt-badge {{
  background: #EE5A24;
  color: #fff;
  font-size: 10px;
  padding: 2px 6px;
  border-radius: 3px;
  margin-left: auto;
}}
</style>
</head>
<body>
  <div class="dynamic-island"></div>
  <div class="status-bar"><span>9:41</span><span>●●● 5G</span></div>
  <div class="backdrop">
    <div class="sheet">
      <div class="sheet-bar"></div>
      
      <div class="track-header">
        <div style="width: 36px; height: 36px; background: #000; color: #fff; border-radius: 4px; display: flex; align-items: center; justify-content: center; font-size: 16px;">🎵</div>
        <div>
          <div style="font-family: 'Space Grotesk', sans-serif; font-size: 14px; font-weight: 900;">Midnight Tokyo Drift</div>
          <div style="font-size: 11px; font-weight: 700; color: #444;">Kavinsky • OutRun</div>
        </div>
      </div>

      <div class="opt-row"><span>▶</span><span>PLAY NOW</span></div>
      <div class="opt-row"><span>⏭</span><span>PLAY NEXT</span></div>
      <div class="opt-row"><span>➕</span><span>ADD TO QUEUE</span></div>
      <div class="opt-row"><span>❤️</span><span>ADD TO FAVORITES</span></div>
      <div class="opt-row"><span>📁</span><span>ADD TO PLAYLIST...</span></div>
      <div class="opt-row" style="background: rgba(247, 206, 70, 0.2); border-radius: 4px; padding: 10px 10px;">
        <span style="color: #EE5A24;">🔔</span>
        <span style="color: #111;">SET AS RINGTONE / AUDIO TONE...</span>
        <span class="opt-badge">NEW</span>
      </div>
      <div class="opt-row"><span>ℹ️</span><span>TRACK DETAILS & METADATA</span></div>
      <div class="opt-row" style="color: #D32F2F; border: none;"><span>🗑️</span><span>DELETE FILE FROM STORAGE</span></div>
    </div>
  </div>
</body>
</html>
"""

# 7. DARK MODE EDITION - NOW PLAYING
screens["07_dark_now_playing.html"] = f"""
<!DOCTYPE html>
<html>
<head>
<style>
{DARK_TOKENS}
{COMMON_CSS}
.player-header {{
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 4px 0 10px 0;
}}
.player-header h2 {{
  font-family: 'Space Grotesk', sans-serif;
  font-size: 16px;
  font-weight: 900;
  letter-spacing: 1.5px;
}}
.cassette-box {{
  width: 100%;
  height: 200px;
  background: #121215;
  border: 3.5px solid #2E2E36;
  box-shadow: 6px 6px 0 #000;
  border-radius: 12px;
  padding: 14px;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  color: #fff;
  margin: 8px 0 18px 0;
}}
.cassette-top {{
  display: flex;
  justify-content: space-between;
  align-items: center;
  border-bottom: 2px solid #222;
  padding-bottom: 6px;
}}
.cassette-tag {{
  background: #F7CE46;
  color: #111;
  font-family: 'Space Grotesk', sans-serif;
  font-weight: 900;
  font-size: 11px;
  padding: 3px 8px;
  border: 1.5px solid #000;
  border-radius: 3px;
}}
.spool-window {{
  background: #1C1C22;
  border: 2.5px solid #2E2E36;
  border-radius: 8px;
  height: 74px;
  display: flex;
  align-items: center;
  justify-content: space-around;
  padding: 0 28px;
  position: relative;
}}
.spool-window::before {{
  content: '';
  position: absolute;
  width: 52px;
  height: 18px;
  background: #FF5722;
  border: 1.5px solid #000;
  border-radius: 3px;
  z-index: 1;
}}
.spool {{
  width: 46px;
  height: 46px;
  background: #2A2A32;
  border: 3px solid #F7CE46;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  position: relative;
  z-index: 2;
}}
.spool::after {{
  content: '';
  width: 16px;
  height: 16px;
  background: #000;
  border: 2px solid #F7CE46;
  border-radius: 50%;
}}
.scrubber-bar {{
  width: 100%;
  height: 8px;
  background: rgba(255,255,255,0.12);
  border: 1.5px solid #2E2E36;
  border-radius: 4px;
  position: relative;
  margin: 14px 0 6px 0;
}}
.scrubber-fill {{
  width: 44%;
  height: 100%;
  background: #FF5722;
  border-radius: 2px;
  position: relative;
}}
.scrubber-thumb {{
  width: 18px;
  height: 18px;
  background: #F7CE46;
  border: 2px solid #000;
  box-shadow: 1.5px 1.5px 0 #000;
  border-radius: 50%;
  position: absolute;
  right: -9px;
  top: -6px;
}}
.engine-badge {{
  background: #18181C;
  border: 2px solid #2E2E36;
  box-shadow: 3.5px 3.5px 0 #000;
  border-radius: 6px;
  padding: 12px 14px;
  margin: 18px 0;
  display: flex;
  justify-content: space-between;
  align-items: center;
}}
.engine-num {{
  font-family: 'Space Grotesk', sans-serif;
  font-weight: 900;
  font-size: 16px;
  color: #FF5722;
  background: rgba(255, 87, 34, 0.15);
  padding: 4px 8px;
  border: 1.5px solid #FF5722;
  border-radius: 4px;
}}
.controls-row {{
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 10px;
}}
.ctrl-btn {{
  width: 48px;
  height: 48px;
  background: #18181C;
  border: 2px solid #2E2E36;
  box-shadow: 3px 3px 0 #000;
  border-radius: 6px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 18px;
  font-weight: 900;
  color: #fff;
}}
.ctrl-btn.play {{
  width: 62px;
  height: 62px;
  background: #F7CE46;
  color: #111;
  font-size: 26px;
  border-color: #000;
}}
</style>
</head>
<body>
  <div class="dynamic-island"></div>
  <div class="status-bar"><span>9:41</span><span>●●● 5G</span></div>
  <div class="content-area">
    <div class="player-header">
      <span style="font-size: 18px; font-weight: 900;">⌄</span>
      <h2>NOW PLAYING</h2>
      <div style="display: flex; gap: 8px; align-items: center;">
        <span class="btn btn-primary" style="padding: 2px 6px; font-size: 10px;">EQ</span>
        <span style="font-size: 18px; font-weight: 900;">•••</span>
      </div>
    </div>

    <div class="cassette-box">
      <div class="cassette-top">
        <span class="cassette-tag">PODDRUNK • SIDE A</span>
        <span style="font-size: 10px; font-weight: 800; opacity: 0.7;">HIGH BIAS 90</span>
      </div>
      <div class="spool-window">
        <div class="spool"></div>
        <div class="spool"></div>
      </div>
      <div style="display: flex; justify-content: space-between; font-size: 9px; font-weight: 900; opacity: 0.7;">
        <span>INDEX: 024</span>
        <span>OBSIDIAN AUDIO ENGINE</span>
      </div>
    </div>

    <div style="text-align: center; margin: 4px 0 8px 0;">
      <div style="font-family: 'Space Grotesk', sans-serif; font-size: 20px; font-weight: 900; color: #F4F4F6;">Midnight Tokyo Drift</div>
      <div style="font-size: 13px; font-weight: 700; color: #8E8E98; margin-top: 3px;">Kavinsky • OutRun (2024)</div>
    </div>

    <div class="scrubber-bar">
      <div class="scrubber-fill"><div class="scrubber-thumb"></div></div>
    </div>
    <div style="display: flex; justify-content: space-between; font-size: 11px; font-weight: 800; color: #8E8E98;">
      <span>01:48</span>
      <span>04:18</span>
    </div>

    <div class="engine-badge">
      <div>
        <div style="font-family: 'Space Grotesk', sans-serif; font-size: 11px; font-weight: 900; letter-spacing: 0.8px;">COUNTED REPEAT ENGINE</div>
        <div style="font-size: 11px; font-weight: 700; color: #8E8E98; margin-top: 1px;">Finite Loop Protection Active</div>
      </div>
      <div class="engine-num">🔁 3 / 5</div>
    </div>

    <div class="controls-row">
      <div class="ctrl-btn">🔀</div>
      <div class="ctrl-btn">⏮</div>
      <div class="ctrl-btn play">▶</div>
      <div class="ctrl-btn">⏭</div>
      <div class="ctrl-btn">🔁</div>
    </div>
  </div>
</body>
</html>
"""

# Write all HTML templates and render high-res screenshots
for filename, html in screens.items():
    html_path = os.path.join(OUTPUT_DIR, filename)
    with open(html_path, "w") as f:
        f.write(html)
    
    png_name = filename.replace(".html", ".png")
    png_path = os.path.join(OUTPUT_DIR, png_name)
    
    # Render with headless Google Chrome at 2x scale for Retina sharpness
    cmd = [
        CHROME_BIN,
        "--headless=new",
        "--disable-gpu",
        "--hide-scrollbars",
        "--force-device-scale-factor=2",
        f"--window-size=390,844",
        f"--screenshot={png_path}",
        f"file://{html_path}"
    ]
    subprocess.run(cmd, check=True)
    print(f"Generated: {png_name}")

print("All individual screens successfully rendered!")
