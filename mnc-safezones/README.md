# 🛡️ MnC Safe Zones

[![FiveM](https://img.shields.io/badge/FiveM-Ready-green.svg)](https://fivem.net/)
[![QBCore](https://img.shields.io/badge/Framework-QBCore-blue.svg)](https://github.com/qbcore-framework)
[![Version](https://img.shields.io/badge/Version-2.0.0-brightgreen.svg)]()

---

## 🌟 Overview

MnC Safe Zones creates spherical, database-backed safe areas where combat is disabled for everyone except exempt job roles. Zones can be created and removed live through an in-game NUI admin panel, with an NUI HUD indicator letting players know when they've entered one.

---

## ✨ Key Features

**Zone Enforcement**
- Built on `lib.zones.sphere` (ox_lib) for enter/exit detection around each zone's center and radius
- `Config.ExemptJobs` (default: `police`, `fire`, `ambulance`, `sheriff`, `swat`) bypasses all restrictions for those jobs
- While inside a zone and not exempt, the script disables attacking, aiming, melee, drive-bys, weapon switching, and grenade throwing every frame, and forces the player's weapon invisible/holstered
- Restrictions and weapon/drive-by state are always restored on zone exit, and the NUI HUD re-syncs automatically on job change or player load

**Admin Management**
- **`/safemenu`** — opens the NUI admin panel (admin permission only) listing all current zones
- **`/addsafepoint`** — captures the player's current coordinates and sends them into the NUI form as a starting point for a new zone
- Zones can be added or removed from the NUI panel, broadcasting the updated zone list to all connected players immediately

**Persistence**
- Zones are stored in an auto-created `mnc_safezones` table (name, center x/y/z, radius, height, timestamp), with automatic `ALTER TABLE` migrations for the `center_z`/`height` columns if upgrading from an older version
- Seeds 4 default zones on first run: City Hall, Hospital, MRPD, and LSIA
- New/removed zones are pushed to all online players in real time, and full-loaded to each player on `QBCore:Server:PlayerLoaded` (with a `playerSpawned` fallback for late joiners)

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
[server-data]/resources/[custom]/mnc-safezones/
```

```lua
# server.cfg
ensure mnc-safezones
```

No manual SQL import needed — the `mnc_safezones` table is created automatically (with column migrations for older versions) and seeded with 4 default zones on first start.

---

## ⚙️ Configuration Guide

```lua
Config = {}

Config.Debug = false

-- Jobs that bypass safe zone restrictions
Config.ExemptJobs = {
    'police',
    'fire',
    'ambulance',
    'sheriff',
    'swat',
}
```

`Config.ExemptJobs` is the main behavioral toggle — any job name listed here skips all combat restrictions while inside a zone. `Config.NotifyOnEnter`/`Config.NotifyOnExit` and `Config.DefaultHeightRange` are also declared in `config.lua` for further customization of the admin/NUI side of the tool.

---

## 🎮 Controls & Usage

- **`/safemenu`** — (admin) open the safe zone management panel
- **`/addsafepoint`** — (admin) capture your current position into the "add zone" form

---

## 🔧 Troubleshooting

- **Zones don't restrict combat** — confirm `ox_lib` is running (`lib.zones.sphere` powers detection) and that the affected player's job isn't in `Config.ExemptJobs`.
- **`/safemenu` says access denied** — the command checks `QBCore.Functions.HasPermission(src, 'admin')`; grant that permission group to the account.
- **New zones don't appear for other players** — zones are broadcast on add/remove and on player load; if a player joined mid-session and doesn't see updates, verify `oxmysql` inserted the row successfully (check server console).
- **Zone still restricts you right at the border** — `lib.zones.sphere` uses radius-based detection; increase or decrease the zone's `radius` from the admin panel if the boundary feels off.

---

## 📝 Credits & License

**Author**: Stan Leigh
**Version**: 2.0.0
**Framework**: QBCore

Distributed as part of the MnCLosSantos mod-dump collection — open source, please credit the original author if you edit and re-release.
