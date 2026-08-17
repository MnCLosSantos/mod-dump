# 🚗 MnC Give Car

[![FiveM](https://img.shields.io/badge/FiveM-Ready-green.svg)](https://fivem.net/)
[![QBCore](https://img.shields.io/badge/Framework-QBCore-blue.svg)](https://github.com/qbcore-framework)
[![Version](https://img.shields.io/badge/Version-1.3.1-brightgreen.svg)]()

---

## 🌟 Overview

MnC Give Car is an advanced `/givecar` admin command that permanently grants a vehicle to a player by inserting it directly into `player_vehicles`. It auto-detects your installed garage resource, works for offline players, and is safe to trigger from the server console — making it ideal for Tebex/webstore purchase delivery as well as manual admin use.

---

## ✨ Key Features

- **Command**: `/givecar [id] [model]` registered via `QBCore.Commands.Add`
- Permission check requires the caller to have the `admin` or `god` QBCore permission group (or the `command` ace) — but the check is skipped entirely for console/source `0`, so Tebex or other server-side scripts can call it directly
- **Auto garage detection** — checks for `qb-garages`, `cdn-garage`, or `jg-advancedgarages` at startup and picks a sensible default garage name for the new vehicle
- **Offline-safe target lookup** — resolves the target's `citizenid`/`license` from the live player object if online, or queries the `players` table directly if offline
- **Schema-safe insert** — checks whether `player_vehicles` has a `mileage` column and builds the correct `INSERT` query either way, so it works across different QBCore database versions
- Generates a random 8-character plate automatically
- Applies configurable default fuel/engine/body health to the new vehicle
- Sends ox_lib notifications to both the admin and the recipient (recipient notification lasts 2 minutes)

---

## 📋 Requirements

| Dependency | Required |
|---|---|
| qb-core | ✅ Yes |
| ox_lib | ✅ Yes |
| oxmysql | ✅ Yes |

---

## 🚀 Installation

```bash
# Place into your resources folder
[server-data]/resources/[custom]/mnc-givecar/
```

```lua
# server.cfg
ensure mnc-givecar
```

No database import is needed — the script writes directly into your existing `player_vehicles` table using your standard QBCore schema.

---

## ⚙️ Configuration Guide

There is no separate `config.lua`; a small inline table at the top of `server.lua` controls the defaults applied to every vehicle it gives:

```lua
Config = {
    DefaultFuel = 100,
    DefaultEngineHealth = 1000,
    DefaultBodyHealth = 1000,
}
```

---

## 🎮 Controls & Usage

```
/givecar [server id] [vehicle model/spawn name]
```

Example: `/givecar 3 adder` gives player server ID 3 an Adder in the auto-detected default garage.

---

## 🔧 Troubleshooting

- **"Invalid player ID or player not found"** — the target ID doesn't match an online player or a row in the `players` table; double-check the server ID.
- **Vehicle appears in the wrong garage** — the script auto-detects `qb-garages` / `cdn-garage` / `jg-advancedgarages` at resource start; if you use a different garage script, the vehicle will default to `pillboxgarage`/`A` — edit `DetectGarageSystem()` in `server.lua` to add your garage.
- **Insert fails silently** — confirm `oxmysql` is running before this resource starts, and that your `player_vehicles` table matches standard QBCore column names.
- **Console/Tebex calls are being blocked** — only calls from an actual player (source ≠ 0) are permission-checked; console-triggered calls always bypass the check by design.

---

## 📝 Credits & License

**Author**: Stan Leigh
**Version**: 1.3.1
**Framework**: QBCore

Distributed as part of the MnCLosSantos mod-dump collection — open source, please credit the original author if you edit and re-release.
