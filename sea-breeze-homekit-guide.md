# Sea Breeze+ Mini-Split HomeKit Integration Guide

**TL;DR:** Sea Breeze+ mini-splits use Midea's OSK105 WiFi dongle and work with `homebridge-midea-platform` for full HomeKit control.

## The Discovery

Sea Breeze+ (sold by International Refrigeration Products / irpsales.com) appears to be a white-label product using Midea's standard WiFi infrastructure. The USB WiFi dongle (model US-OSK105) speaks the Midea V3 protocol on TCP port 6444.

This means:
- ✅ Works with `homebridge-midea-platform` plugin
- ✅ Works with `msmart-ng` for token retrieval and CLI control
- ✅ Local LAN control (no cloud dependency after initial token retrieval)
- ✅ Full feature support (modes, temps, fan speeds, swing)

## Prerequisites

- Sea Breeze+ mini-split with WiFi dongle connected and configured via Sea Breeze+ app
- Mac/Linux/Raspberry Pi for Homebridge
- Node.js 18+
- Python 3.8+ (for msmart-ng)

## Step 1: Install Homebridge

```bash
# Install Homebridge and UI
sudo npm install -g homebridge homebridge-config-ui-x

# Install as service (macOS)
sudo hb-service install --user $(whoami)

# Or on Raspberry Pi
sudo hb-service install --user homebridge
```

Access UI at http://localhost:8581 (default: admin/admin)

## Step 2: Get Device IP

Find your AC's IP address. Check your router's DHCP client list for a device with MAC starting with `B8:0B:DA` (Midea's OUI).

Or scan your network:
```bash
# macOS
arp -a | grep -i "b8:0b:da"

# Or use nmap
nmap -sn 192.168.1.0/24
```

## Step 3: Retrieve Authentication Tokens

Midea uses encrypted V3 protocol. You need a token and key for local control.

```bash
# Install msmart-ng
pip3 install msmart-ng

# Discover device and get tokens (use your Sea Breeze+ app credentials)
msmart-ng discover YOUR_AC_IP --account your-seabreeze-email@example.com --password 'YourSeaBreezePassword' -d
```

**Important:** The Sea Breeze+ credentials work with Midea's API! You'll get output like:

```
Discovered device:
  IP: 10.0.1.141
  ID: 150633095102895
  Token: 3c2c2a4bbaf40a87f6f49be63fe02dda...
  Key: 3c72e1e7d5cd4cc9a87793efa9cd44cc...
```

**Save these tokens!** Midea has been disabling cloud API access. Once you have tokens, you have pure local control.

## Step 4: Install Homebridge Plugin

In Homebridge UI:
1. Go to Plugins tab
2. Search "midea-platform"
3. Install `homebridge-midea-platform`

Or via command line:
```bash
sudo npm install -g homebridge-midea-platform
```

## Step 5: Configure Plugin

Edit your Homebridge config (`~/.homebridge/config.json`):

```json
{
    "bridge": {
        "name": "Homebridge",
        "username": "XX:XX:XX:XX:XX:XX",
        "port": 51826,
        "pin": "031-45-154"
    },
    "platforms": [
        {
            "platform": "midea-platform",
            "refreshInterval": 30,
            "devices": [
                {
                    "type": "Air Conditioner",
                    "name": "Living Room AC",
                    "id": 150633095102895,
                    "advanced_options": {
                        "ip": "10.0.1.141",
                        "token": "YOUR_TOKEN_HERE",
                        "key": "YOUR_KEY_HERE",
                        "verbose": true
                    }
                }
            ]
        }
    ]
}
```

Replace:
- `id` with your device ID from msmart-ng
- `ip` with your device IP
- `token` and `key` with values from msmart-ng

## Step 6: Restart and Pair

```bash
sudo hb-service restart
```

In iOS Home app:
1. Tap + → Add Accessory
2. Choose "More Options"
3. Select your Homebridge
4. Enter the PIN from your config

Your Sea Breeze+ AC should appear as a thermostat!

## Supported Features

| Feature | Works? |
|---------|--------|
| Power On/Off | ✅ |
| Mode (Cool/Heat/Auto/Dry/Fan) | ✅ |
| Temperature (16-30°C) | ✅ |
| Fan Speed | ✅ |
| Swing (H/V/Both) | ✅ |
| Eco Mode | ✅ |
| Turbo/Boost Mode | ✅ |
| Current Temperature | ✅ |
| Outdoor Temperature | ✅ |

## CLI Control (Optional)

You can control the AC directly via command line:

```bash
# Query status
msmart-ng query YOUR_AC_IP \
  --token 'YOUR_TOKEN' \
  --key 'YOUR_KEY' \
  --id YOUR_DEVICE_ID

# Set to cool mode at 22°C
msmart-ng control YOUR_AC_IP \
  --token 'YOUR_TOKEN' \
  --key 'YOUR_KEY' \
  --id YOUR_DEVICE_ID \
  target_temperature=22 operational_mode=cool
```

## Troubleshooting

**"Token retrieval failed"**
- Double-check Sea Breeze+ credentials
- Ensure device is online in Sea Breeze+ app first
- Try power cycling the AC unit

**"Device not responding"**
- Verify IP address is correct
- Check if port 6444 is accessible: `nc -zv YOUR_AC_IP 6444`
- Ensure Homebridge can reach the device (no VLAN isolation)

**"Protocol error" warnings**
- Warnings about `MessageNewProtocolQuery` are normal and can be ignored
- The plugin falls back to standard queries automatically

## Architecture

```
┌─────────────────┐      WiFi       ┌──────────────┐
│ Sea Breeze+ AC  │◄───────────────►│ OSK105 Dongle│
└─────────────────┘                 └──────┬───────┘
                                           │ LAN (port 6444)
                                           │ Midea V3 Protocol
                                           ▼
                                    ┌──────────────┐
                                    │  Homebridge  │
                                    │ midea-platform│
                                    └──────┬───────┘
                                           │ HAP
                                           ▼
                                    ┌──────────────┐
                                    │   HomeKit    │
                                    │  (iOS/Mac)   │
                                    └──────────────┘
```

## Credits

- [homebridge-midea-platform](https://github.com/kovapatrik/homebridge-midea-platform) by kovapatrik
- [msmart-ng](https://github.com/mill1000/midea-msmart) by mill1000
- [midea_ac_lan](https://github.com/georgezhao2010/midea_ac_lan) for protocol research

## License

MIT

---

*Guide created by David (Humanity and AI) after successfully integrating Sea Breeze+ units into HomeKit, December 2024.*