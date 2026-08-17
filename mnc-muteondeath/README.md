# 🔇 MnC Mute On Death

[![FiveM](https://img.shields.io/badge/FiveM-Ready-green.svg)](https://fivem.net/)
[![QBCore](https://img.shields.io/badge/Framework-QBCore-blue.svg)](https://github.com/qbcore-framework)
[![Version](https://img.shields.io/badge/Version-1.0.0-brightgreen.svg)]()

---

## 🌟 Overview

A tiny, fully automatic utility that mutes a player's proximity voice chat while they're dead or in last stand, and restores it the moment they're revived. No config, no commands — it just runs.

---

## ✨ Key Features

- Polls the local player's QBCore metadata (`isdead`, `inlaststand`) once per second
- On death: calls `exports['pma-voice']:overrideProximityCheck(...)` with a function that always returns `false`, blocking proximity voice for that player
- On revive: calls `exports['pma-voice']:resetProximityCheck()` to restore normal voice behavior
- Logs "Muted: player is dead" / "Unmuted: player revived" to the client console for confirmation

---

## 📋 Requirements

| Dependency | Required |
|---|---|
| qb-core | ✅ Yes |
| pma-voice | ✅ Yes |

---

## 🚀 Installation

```bash
# Place into your resources folder
[server-data]/resources/[custom]/mnc-muteondeath/
```

```lua
# server.cfg
ensure mnc-muteondeath
```

No database or item setup required.

---

## 🔧 Troubleshooting

- **Player still audible while dead** — confirm `pma-voice` is the voice resource actually running on your server; this script calls `pma-voice`-specific exports and won't work with other voice systems without modification.
- **Player stays muted after revive** — check that your medical/revive script actually clears `isdead`/`inlaststand` in player metadata; this script only reacts to those two flags.

---

## 📝 Credits & License

**Author**: David Longhorn
**Version**: 1.0.0
**Framework**: QBCore

Distributed as part of the MnCLosSantos mod-dump collection — open source, please credit the original author if you edit and re-release.
