# Sound Alert Pro

A Roblox script executor GUI that watches specific sounds in a game and pings a Discord webhook the moment they play. Dark UI, per-sound toggles, persistent config, and fast detection — no metatable hooks that get you kicked.

Built for **Potassium** and **Volt**, but works with any executor that exposes `syn.request` / `request` / `http_request`.

---

## Features

- **Discord webhook alerts** with sound name, SoundId, location, and timestamp
- **Persistent config** — webhook and watched sounds saved to `sound_alert_config.json` in your executor's workspace
- **Interactive GUI** — search, filter, and toggle individual sounds with checkboxes
- **Per-sound watch list** — only ping for the sounds you care about
- **Two views** — `All` shows every sound, `Watched` shows only your selections
- **Statistics panel** — alerts sent counter and last alert time
- **Master toggle** — pause/resume monitoring without closing the GUI
- **Safe detection** — no metatable hooks, no anti-cheat kicks

---

## How it works

1. Scans the game for every `Sound` instance and groups them by category (Workspace / ReplicatedStorage / SoundService / StarterGui / Other)
2. Caches the list and only rescans when a sound is added or removed
3. Runs a lightweight detection loop that checks **only the sounds you've ticked** — not the entire game tree
4. On detection, fires a `POST` request to your webhook with an embed containing the sound's details

The sound cache + watched-instance filter is what keeps it smooth even in games with hundreds of sounds.

---

## Setup

### 1. Create a Discord webhook

1. Discord → **Server Settings** → **Integrations** → **Webhooks**
2. Click **New Webhook**
3. Pick a channel, click **Copy Webhook URL**

### 2. Run the script

Paste the script into your executor and execute it in-game. The GUI opens with a webhook prompt.

### 3. Configure

1. Paste your webhook URL and click **Save**
2. Click **Test** to confirm it works — a test embed should hit your channel
3. Search/browse the sound list and tick the ones you want alerts for
4. Every time a ticked sound plays, you'll get a Discord ping

Your selections and webhook persist across sessions.

---

## GUI Overview

| Section | What it does |
|---|---|
| **Discord Webhook** | Shows your configured webhook (masked). **Configure** reopens the modal, **Test** sends a test ping |
| **Monitoring Active** | Master on/off switch. Turns the label gray and stops detection when off |
| **Statistics** | Alerts sent counter + last alert timestamp |
| **Search** | Filter sounds by name, path, or SoundId |
| **All / Watched** | Toggle between every sound and just your selections |
| **↻** | Force a rescan if the game spawns new sounds |

---

## Config File

Stored at `workspace/sound_alert_config.json` (inside your executor's folder):

```json
{
  "webhook": "https://discord.com/api/webhooks/...",
  "watched": ["rbxassetid://1234567890", "rbxassetid://0987654321"],
  "stats": {
    "detected": 42,
    "lastAlert": "14:25:14"
  }
}
```

Delete the file to reset everything.

---

## Detection Notes

- **Watched by `SoundId`, not name.** This is intentional — many games clone a generic `Sound` instance and swap the `SoundId` at runtime, so name matching alone misses everything. Matching by ID catches originals, clones, and anything the game spawns mid-session.
- **New sounds are auto-added.** `DescendantAdded` fires → if you've already ticked that SoundId, it goes straight into the watch list.
- **Debounce.** Each sound has a 2-second cooldown so rapid-fire replays don't spam your webhook.

---

## Troubleshooting

**Nothing sends / no ping**
- Make sure the sound is **actually playing** — the script watches for playback events, not sound existence
- Check the **Statistics** panel — if "Alerts Sent" isn't incrementing, the sound isn't being detected (wrong SoundId, or it's client-side only)
- Run the **Test** button to confirm the webhook itself works

**Kicked from the game (error 140 / 267)**
- You're running an old version with the `__namecall` hook. Update to the current version — the hook was removed because it breaks the game's remote events and triggers anti-cheat.

**Executed but nothing happened**
- Your executor may not support `request` / `http_request`. Both Potassium and Volt do; some free executors don't.

**Lag / frame drops**
- Current version only iterates your watched sounds, so this shouldn't happen. If it does, your watch list is huge — try trimming it.

---

## Compatibility

| Executor | Status |
|---|---|
| Potassium | ✅ |
| Volt | ✅ |
| Others with `request` support | ✅ |

---

## License

Do whatever you want with it.

---

## Disclaimer

This is an external script intended to run through a Roblox script executor. Using executors may violate Roblox's Terms of Service depending on the game and how you use it. Use at your own risk. The author is not responsible for any bans, kicks, or account actions resulting from use of this script.
