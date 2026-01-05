# Solstice Photo Booth

A professional-grade DIY photo booth system using a Panasonic GH5 camera, OBS for live preview, and a web-based iPad interface. Outputs 20MP high-resolution photos with customizable themed overlays.

## Features

- **High-Resolution Capture:** 20MP (5184×3888) JPG photos via Lumix Tether
- **Live Preview:** OBS virtual camera displayed on iPad for subject positioning
- **9 Themed Overlays:** Golden, Minimal, Winter, Forest, Moon, Celestial, Aurora, Candlelight, or None
- **Strip Mode:** 4-photo sequences with dedicated gallery
- **QR Code Sharing:** Instant access to photos on guests' phones
- **Sound Effects:** Countdown beeps, shutter sound, celebration chord
- **Visual Feedback:** Confetti bursts, screen flash, rendering notifications

## Hardware Requirements

- Panasonic GH5 (or compatible Lumix camera)
- USB connection to Mac
- iPad or tablet for guest interface
- Mac running the server (tested on Mac Studio)
- OBS Studio with Virtual Camera

## Software Requirements

- macOS (uses osascript and cliclick for automation)
- Node.js 18+
- [Lumix Tether](https://av.jpn.support.panasonic.com/support/global/cs/soft/download/d_lumixtether.html)
- [OBS Studio](https://obsproject.com/)
- [cliclick](https://github.com/BlueM/cliclick) (`brew install cliclick`)

## Installation

```bash
# Clone the repository
git clone https://github.com/dabirdwell/solstice-photo-booth.git
cd solstice-photo-booth

# Install dependencies
npm install

# Generate overlay PNGs
node generate-overlays.js

# Start the server
node server.js
```

## Setup

### 1. Camera Setup
- Connect GH5 via USB
- Open Lumix Tether, confirm camera connection
- Set camera to appropriate mode (we used Aperture Priority)

### 2. OBS Setup
- Add Lumix Tether window as source
- Crop to show only the live view (not the UI)
- Start Virtual Camera

### 3. Terminal Watcher
The photo booth uses a trigger file system to automate Lumix Tether. The server writes to `/tmp/take_photo_trigger` and waits for new JPG files.

### 4. Access the Interface
- **iPad/Guest Interface:** `http://[your-mac-ip]:3000`
- **OBS Display:** `http://[your-mac-ip]:3000/display.html`
- **Gallery:** `http://[your-mac-ip]:3000/gallery.html`

## Overlays

Overlays are generated as high-resolution PNGs (5184×3888) and composited onto photos using Sharp:

| Overlay | Description |
|---------|-------------|
| ✨ Golden Solstice | Ornate gold border with corner flourishes |
| ◇ Minimal | Clean corner brackets |
| ❄ Winter | Snowflakes with "Happy New Year" |
| 🌿 Forest | Trees, leaves, celtic knots, "Winter Solstice" |
| 🌕 Full Moon | Moon on left side with stars |
| 🔮 Celestial | Purple constellation patterns, "Blessed Solstice" |
| 🌌 Aurora | Northern lights gradient effect |
| 🕯️ Candlelight | Warm amber corner glow, "The Longest Night" |

To regenerate overlays after customization:
```bash
node generate-overlays.js
```

## Architecture

```
┌─────────────┐     USB      ┌──────────────┐
│   GH5       │─────────────▶│ Lumix Tether │
└─────────────┘              └──────┬───────┘
                                    │
                    ┌───────────────┴───────────────┐
                    ▼                               ▼
            ┌──────────────┐               ┌──────────────┐
            │     OBS      │               │ File System  │
            │ Virtual Cam  │               │   Watcher    │
            └──────┬───────┘               └──────┬───────┘
                   │                              │
                   ▼                              ▼
            ┌──────────────┐               ┌──────────────┐
            │ /display.html│◀─────────────▶│  server.js   │
            │  (OBS view)  │   Socket.IO   │   (Node.js)  │
            └──────────────┘               └──────┬───────┘
                                                  │
                   ┌──────────────────────────────┤
                   ▼                              ▼
            ┌──────────────┐               ┌──────────────┐
            │ /index.html  │               │ /gallery.html│
            │ (iPad UI)    │               │ (QR Access)  │
            └──────────────┘               └──────────────┘
```

## Customization

### Adding New Overlays

1. Add overlay definition to `server.js`:
```javascript
const OVERLAYS = {
  // ... existing overlays
  youroverlay: { name: '🎨 Your Overlay', file: 'frame-yours.html', png: 'your-overlay.png' }
};
```

2. Add generator function to `generate-overlays.js`

3. Regenerate: `node generate-overlays.js`

4. Restart server

### Adjusting Countdown Timing

Edit `server.js` - look for the `start-countdown` socket handler to adjust timing values.

## Troubleshooting

**Camera not triggering:**
- Ensure Lumix Tether is running and camera is connected
- Check the trigger file at `/tmp/take_photo_trigger`
- Verify cliclick is installed: `which cliclick`

**Preview not showing on iPad:**
- Confirm OBS Virtual Camera is started
- Check display.html is loading the virtual camera

**Overlays not applying:**
- Check overlays directory has PNG files
- Verify Sharp is installed: `npm list sharp`
- Check server logs for compositing errors

## License

MIT License - See LICENSE file

## Credits

Built collaboratively by David and Claude (Anthropic) during Winter Solstice 2024-2025.

A demonstration of human-AI collaborative development for real-world projects.
