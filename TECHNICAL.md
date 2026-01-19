# Technical Documentation

## How Poolsuite FM's Web Player Works

### Architecture Discovery

After reverse-engineering [poolsuite.net](https://poolsuite.net/), we discovered:

1. **Frontend Stack**
   - Framework: Vue.js 3
   - State Management: Vuex
   - Build: Webpack/Vite
   - API: `api.poolsuite.net` (authenticated with API key)

2. **Audio Source**
   - **Host**: SoundCloud
   - **Delivery**: HLS/DASH streaming protocol
   - **Format**: AAC 160kbps in `.m4s` segments
   - **CDN**: `playback.media-streaming.soundcloud.cloud`

3. **Streaming URLs**
   ```
   https://playback.media-streaming.soundcloud.cloud/
     {HASH}/aac_160k/{UUID}/data{NNN}.m4s
     ?expires={TIMESTAMP}&Policy={...}&Signature={...}&Key-Pair-Id={...}
   ```

4. **Authentication**
   - SoundCloud uses signed URLs with expiring tokens
   - Web player fetches these via their API
   - Public playlists accessible without Poolsuite API

## Our CLI Approach

Instead of replicating the entire web stack, we:

### 1. Found the Source

Discovered their SoundCloud account with public playlists:
- Account: https://soundcloud.com/poolsuite
- 8 curated playlists (officially maintained)
- All publicly accessible

### 2. Simplified Streaming

```bash
# Instead of:
# Browser → Vue.js → Poolsuite API → SoundCloud API → Stream

# We do:
# CLI → mpv (with yt-dlp) → SoundCloud → Stream
```

### 3. Leveraged Existing Tools

**mpv** handles all complexity:
- SoundCloud URL parsing
- Authentication/token management
- HLS/DASH segment streaming
- Audio decoding and playback

## Streaming vs Downloading

### Streaming (default behavior)

```bash
poolsuite tokyo
```

**What happens:**
1. mpv fetches playlist metadata from SoundCloud
2. Gets authenticated stream URLs (handled by yt-dlp integration)
3. Buffers ~5-10 seconds of audio
4. Streams `.m4s` segments as needed
5. **Nothing saved to disk** (except small cache)

**Technical flow:**
```
poolsuite script
  ↓
mpv --no-video {url}
  ↓
Built-in yt-dlp extractor
  ↓ 
SoundCloud HLS manifest
  ↓
Stream segments: data000.m4s, data001.m4s, data002.m4s...
  ↓
Audio output
```

**Bandwidth:** ~160 kbps (AAC)
**Disk usage:** Minimal (mpv's cache only, ~10-20 MB)

### Downloading (optional)

For offline listening:

```bash
yt-dlp -x --audio-format mp3 {soundcloud-url}
```

**What happens:**
1. Downloads all segments
2. Concatenates them
3. Transcodes to MP3/M4A
4. Saves to disk

## Available Playlists

Extracted via yt-dlp:

```bash
yt-dlp --flat-playlist --print url "https://soundcloud.com/poolsuite"
```

Found 8 official playlists:

| Playlist | URL | Tracks |
|----------|-----|--------|
| Official FM | `/sets/poolsuite-fm-official-playlist` | ~30-50 |
| Official FM 2 | `/sets/poolsuite-fm-official-playlist-two` | ~30-50 |
| Mixtapes | `/sets/poolsuite-mixtapes` | ~15-20 |
| Balearic Sundown | `/sets/balearic-sundown` | ~20-30 |
| Indie Summer | `/sets/indie-summer` | ~20-30 |
| Tokyo Disco | `/sets/tokyo-disco` | ~20-30 |
| Friday Nite Heat | `/sets/friday-nite-heat` | ~20-30 |
| Hangover Club | `/sets/hangover-club` | ~20-30 |

## Why This Works

1. **Public Playlists** - SoundCloud playlists are public
2. **No DRM** - SoundCloud streams are not DRM-protected
3. **Standard Protocol** - Uses standard HLS/DASH
4. **Existing Tools** - mpv/yt-dlp handle all complexity
5. **No API Key Needed** - Direct SoundCloud streaming

## Performance Comparison

| Method | Memory | CPU | Startup | Bandwidth |
|--------|--------|-----|---------|-----------|
| Web Browser | ~200-500 MB | 5-15% | 3-5s | 160 kbps + overhead |
| **CLI (this tool)** | ~30-50 MB | 1-3% | 1-2s | 160 kbps |

## Code Structure

```bash
poolsuite (main script)
├── show_banner()      # ASCII art + branding
├── show_help()        # Help text
├── list_playlists()   # List available playlists
├── play_playlist()    # Main playback function
└── main()             # Argument parsing

Flow:
1. Parse arguments (playlist name, options)
2. Validate playlist exists
3. Check for available player (mpv/ffplay)
4. Execute player with URL
5. Handle playback
```

## Dependencies

**Runtime:**
- Bash 4.0+
- mpv (with built-in yt-dlp support) OR
- yt-dlp + ffplay

**Optional:**
- vlc (alternative player)
- ffmpeg (for transcoding if downloading)

## Limitations

1. **SoundCloud Dependent** - If Poolsuite moves playlists, URLs must be updated
2. **Public Only** - Only works with public playlists
3. **No Offline Mode** - Streaming requires internet (but can download separately)
4. **No Web UI Features** - No visualizer, track history, etc.

## Security & Ethics

**This tool is ethical because:**
- ✓ Only accesses public content
- ✓ No authentication bypass
- ✓ No paid content circumvention
- ✓ No DRM circumvention
- ✓ No terms of service violation
- ✓ Gives full credit to Poolsuite FM
- ✓ Encourages users to support official service

**What we don't do:**
- ✗ Access private/members-only content
- ✗ Bypass authentication
- ✗ Scrape or store user data
- ✗ Redistribute downloaded content
- ✗ Claim ownership of music/curation

## Future Improvements

Potential enhancements (PRs welcome):

- [ ] Add more playlists as Poolsuite publishes them
- [ ] Implement local caching for offline playback
- [ ] Add track metadata display
- [ ] Create visualizer mode (ASCII art spectrum)
- [ ] Add favorites/history tracking
- [ ] Integration with Last.fm scrobbling
- [ ] Configuration file support (~/.poolsuiterc)

## References

- [mpv Documentation](https://mpv.io/manual/master/)
- [yt-dlp Documentation](https://github.com/yt-dlp/yt-dlp)
- [SoundCloud API](https://developers.soundcloud.com/)
- [HLS Streaming Protocol](https://en.wikipedia.org/wiki/HTTP_Live_Streaming)

---

Last updated: January 2026
