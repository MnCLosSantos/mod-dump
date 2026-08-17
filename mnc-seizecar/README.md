# 🚔 MNC Seize Car

[![FiveM](https://img.shields.io/badge/FiveM-Ready-green.svg)](https://fivem.net/)
[![QBCore](https://img.shields.io/badge/Framework-QBCore-blue.svg)](https://github.com/qbcore-framework)
[![Version](https://img.shields.io/badge/Version-1.3.2-brightgreen.svg)]()

---

## 🌟 Overview

MNC Seize Car adds three admin/job-restricted commands for removing vehicles from a player's `player_vehicles` garage record. It can permanently seize a specific plate (job-gated, e.g. for police), wipe a single vehicle as an admin action, or wipe every vehicle a player owns. It auto-detects which garage resource (`qb-garages`, `cdn-garage`, or `jg-advancedgarages`) is running on start-up for informational logging.

---

## ✨ Key Features

**Commands**
- `/seizecar [id] [plate]` — job-restricted (via `Config.SeizeCarJob`) deletion of one vehicle from a player's garage, notifies both the acting officer and the target player with the seizing officer's name and job.
- `/removecar [id] [plate]` — admin command to delete a single vehicle by plate from any player, works even if the target is offline (looks up citizenid/license from the `players` table).
- `/removeallcars [id]` — admin command that wipes every vehicle record belonging to a player.

**Behavior**
- Permission checks use `QBCore.Functions.HasPermission` (admin/god) or ACE permissions for the admin commands; `/seizecar` checks the caller's current job against `Config.SeizeCarJob`.
- Works against offline players by querying the `players` table directly with `oxmysql` when the target isn't connected.
- All deletions go straight against the `player_vehicles` table (`DELETE ... WHERE citizenid = ? AND plate = ?`), so removed vehicles disappear from garages immediately.
- Notifications are sent through `ox_lib:notify` to both the command issuer and the affected player (with server console fallback for console-issued commands).
- Auto-detects installed garage resource (`qb-garages`, `cdn-garage`, `jg-advancedgarages`) at startup purely for a console log message.

---

## 📋 Requirements

| Dependency | Required |
|---|---|
| qb-core | Yes |
| ox_lib | Yes |
| oxmysql | Yes |

---

## 🚀 Installation

```bash
# Place into your resources folder
[server-data]/resources/[custom]/mnc-seizecar/
```

```lua
# server.cfg
ensure mnc-seizecar
```

No database import is required — the script only performs `DELETE` queries against the existing QBCore `player_vehicles` table.

---

## ⚙️ Configuration Guide

Configuration lives inline at the top of `server.lua`:

```lua
Config = {
    DefaultFuel = 100,
    DefaultEngineHealth = 1000,
    DefaultBodyHealth = 1000,
    -- Jobs allowed to use /seizecar (e.g. police, mechanic, etc.)
    SeizeCarJob = { ['police'] = true, ['mechanic'] = false },
}
```

`SeizeCarJob` is a whitelist of job names allowed to run `/seizecar` — set a job to `true` to grant access, `false` (or omit it) to deny it.

---

## 🎮 Controls & Usage

- `/seizecar [id] [plate]` — usable by players whose job is whitelisted in `Config.SeizeCarJob`.
- `/removecar [id] [plate]` — admin only.
- `/removeallcars [id]` — admin only.

---

## 🔧 Troubleshooting

- **"No vehicle found with plate"** — plates are matched uppercase against `player_vehicles`; double-check the plate was typed correctly.
- **"Your job cannot use this command"** — the caller's current job isn't set to `true` in `Config.SeizeCarJob`.
- **Player not found (offline target)** — the script falls back to a lookup by server ID in the `players` table; if the target ID has never connected to this server it won't resolve.
- **Garage detection log says "unknown"** — this is informational only and doesn't block functionality; it just means none of `qb-garages`, `cdn-garage`, or `jg-advancedgarages` were detected as started.

---

## 📝 Credits & License

**Author**: Stan Leigh
**Version**: 1.3.2
**Framework**: QBCore

Distributed as part of the MnCLosSantos mod-dump collection — open source, please credit the original author if you edit and re-release.
