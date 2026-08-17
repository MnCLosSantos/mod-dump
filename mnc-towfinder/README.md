# 🔍 MNC TowFinder

[![FiveM](https://img.shields.io/badge/FiveM-Ready-green.svg)](https://fivem.net/)
[![QBCore](https://img.shields.io/badge/Framework-QBCore-blue.svg)](https://github.com/qbcore-framework)
[![Version](https://img.shields.io/badge/Version-1.0.0-brightgreen.svg)]()

---

## 🌟 Overview

MNC TowFinder is an admin diagnostic tool that automatically spawns every vehicle model registered in `QBCore.Shared.Vehicles`, one at a time, and inspects its skeleton for tow-hitch bones (`tow_arm`, `attach_female`, `hook`, etc.) to determine whether the vehicle model supports towing/being towed. Results are grouped by bone name, shown in an in-game menu, and written out to a generated Lua file for use in other resources (e.g. tow job configs).

---

## ✨ Key Features

**Automated bone scan**
- Pulls the full vehicle list from `QBCore.Shared.Vehicles`, spawns each model briefly at a configurable coordinate, and checks `GetEntityBoneIndexByName` against a configurable list of tow-related bone names.
- Uses hard timeouts when loading models (5s) and spawning entities (2s) so a single broken model can't hang the whole scan.
- Freezes the player at the spawn point during the scan and shows an `ox_lib` progress circle with the estimated remaining time.
- Progress notifications fire every 15 vehicles scanned via `ox_lib` toast notifications.

**Results output**
- Groups found vehicles by which tow bone they have and displays them in an `ox_lib` context menu (`lib.registerContext` / `lib.showContext`).
- Server writes the results to `output/tow_vehicles.lua` inside the resource folder as a ready-to-use `TowBarVehicles = { ... }` Lua table, commented and grouped by bone, with a generation timestamp. Falls back to dumping the results to console if the file write fails.

**Access control**
- Any player can type the command, but the server checks `QBCore.Functions.HasPermission(src, 'admin')` before returning the vehicle list or accepting scan results — non-admins receive an "Access Denied" notification.

---

## 📋 Requirements

| Dependency | Required |
|---|---|
| qb-core | Yes |
| ox_lib | Yes |

---

## 🚀 Installation

```bash
# Place into your resources folder
[server-data]/resources/[custom]/mnc-towfinder/
```

```lua
# server.cfg
ensure mnc-towfinder
```

No database setup needed. On resource start the script auto-creates an `output/` folder inside its own directory, where scan results are written to `tow_vehicles.lua`.

---

## ⚙️ Configuration Guide

Config is defined inline at the top of `client/main.lua`:

```lua
local Config = {
    SpawnDelay = 300,       -- ms to wait after spawning before checking bones
    SpawnCoords = vector3(87.99, -2723.12, 6.0), -- where vehicles are spawned to be scanned
    TowBones = {
        'tow_arm', 'tow_arm_l', 'tow_arm_r',
        'attach_female', 'attach_male',
        'tow_bar', 'hook', 'hook_l', 'hook_r',
    },
}
```

`SpawnCoords` should point somewhere flat and empty (docks/airport are suggested in comments); `SpawnDelay` can be raised if vehicle models are slow to load on your server; `TowBones` is the list of skeleton bone names checked to flag a vehicle as tow-capable.

---

## 🎮 Controls & Usage

- `/towfinder` (alias `/mnc-towfinder`) — admin-only. Requests the vehicle list from the server, then opens a start menu with a "Start Bone Scan" option. Selecting it freezes the player and runs through every vehicle model, then shows a results menu grouped by detected tow bone.

---

## 🔧 Troubleshooting

- **"You do not have permission to use TowFinder"** — the account needs `admin` (or higher) permission via `QBCore.Functions.HasPermission`.
- **Scan seems to skip vehicles / find nothing** — some custom vehicle add-ons don't use standard tow bone names; adjust `Config.TowBones` to match your vehicle pack's skeleton naming.
- **"File write failed" notification** — the server couldn't write to `output/tow_vehicles.lua` (check filesystem permissions on the resource folder); results are dumped to server console as a fallback.
- **Scan takes a long time** — expected with large vehicle lists, since each model is individually spawned, checked, and deleted; this is inherent to the bone-detection method.

---

## 📝 Credits & License

**Author**: MNC
**Version**: 1.0.0
**Framework**: QBCore

Distributed as part of the MnCLosSantos mod-dump collection — open source, please credit the original author if you edit and re-release.
