# 🚓 MnC Job Garage

[![FiveM](https://img.shields.io/badge/FiveM-Ready-green.svg)](https://fivem.net/)
[![QBCore](https://img.shields.io/badge/Framework-QBCore-blue.svg)](https://github.com/qbcore-framework)
[![Version](https://img.shields.io/badge/Version-1.3.8-brightgreen.svg)]()

---

## 🌟 Overview

MnC Job Garage is an advanced, multi-job vehicle garage system. Each job gets its own target-interactable garage prop where members can spawn grade-gated fleet vehicles (with full performance and visual mods pre-applied), track and return them, and mark them on the map. It ships with an extensive default fleet covering police, track marshall, ambulance, vinewood records, la festa, auto exotics, ssmco, gruppe6, yacht club, and mnc racing.

---

## ✨ Key Features

**Per-Job Garages**
- `Config.Locations` defines each job's garage: spawn point, return/out point, a `zoneEnable` toggle, and a `list` of vehicle models available to that job
- Each vehicle in the list has a required job `grade`, an `order` for menu sorting, a `CustomName`, and optional `colors`, `livery`, `windowTint`, `extras`, `bulletproof`, `performance`, and `visualUpgrades` (spoiler, bumpers, wheels, neon, roof, fender, etc.)

**Interaction**
- A `prop_parkingpay` prop is spawned at each garage's `out` point and made targetable via **qb-target or ox_target** (`Config.Target`)
- Opens a vehicle list menu through **qb-menu or ox_lib** (`Config.Menu`), showing only vehicles the player's grade allows

**Spawning & Mods**
- On spawn, the script automatically applies the configured performance tier ("max" or a custom 4-part array) and any detailed visual upgrades defined for that vehicle
- Fuel is topped up through a configurable fuel resource (`Config.Fuel`, defaults to `LegacyFuel`)

**Vehicle Tracking**
- Server tracks each spawned vehicle's network ID and plate while it's out
- Vehicles can be returned to the garage, optionally requiring the player to be within `Config.ReturnRadius` of the return point (`Config.ReturnDistanceCheck`)
- **Mark Vehicle** creates a GPS blip and route to your currently spawned job vehicle that automatically removes itself once you're close

**Admin/Builder Tool**
- **`/printmyveh`** command prints the current vehicle's model, colors, mods, and plate to the F8 console in a ready-to-paste `Config.Locations` entry format, making it fast to add new fleet vehicles

**Notifications**
- `Config.Notify` switches all player-facing notifications between `qb-core` and `ox_lib` styles

---

## 📋 Requirements

| Dependency | Required |
|---|---|
| qb-core | ✅ Yes |
| ox_lib | ✅ Yes |
| oxmysql | ✅ Yes |
| qb-target | ✅ Yes (default `Config.Target`, swappable to `ox_target`) |
| qb-menu | ✅ Yes (default `Config.Menu`, swappable to `ox_lib` menus) |

Vehicle insurance data is read/written to an existing `insured_vehicles` table — this resource does **not** create that table, so it expects a compatible insurance/vehicle resource to already own that schema.

---

## 🚀 Installation

```bash
# Place into your resources folder
[server-data]/resources/[custom]/mnc-jobgarage/
```

```lua
# server.cfg
ensure mnc-jobgarage
```

No table is auto-created by this script for its core garage functionality (vehicle spawning is transient/network-ID based), but it does read and write to an `insured_vehicles` table that must already exist from another resource on your server.

---

## ⚙️ Configuration Guide

```lua
Config = {
    Notify = "ox",
    Menu = "qb",
    Target = "qb",
    Fuel = "LegacyFuel",
    ReturnDistanceCheck = false,
    ReturnRadius = 15.0,

    Locations = {
        {
            zoneEnable = true,
            job = "police",
            garage = {
                spawn = vec4(436.2, -976.03, 24.9, 138.13),
                out   = vec4(461.14, -975.53, 25.7, 0.29),
                list = {
                    polnscout = { grade = 0, CustomName = "police patrol 1", performance = "max", order = 1 },
                }
            }
        },
    }
}
```

`Notify`/`Menu`/`Target` let you swap the notification, menu, and targeting backend independently. Each job block under `Locations` defines its own spawn/out coordinates and a keyed vehicle `list` gated by `grade`.

---

## 🎮 Controls & Usage

- Interact with a job's garage prop (via qb-target/ox_target) to open the vehicle list
- **`/printmyveh`** — while seated in a vehicle, prints a ready-to-paste config entry (model, colors, mods, plate) to the F8 console for quickly expanding the fleet

---

## 🔧 Troubleshooting

- **Garage prop has no interaction** — confirm `Config.Target` matches an installed targeting resource (`qb-target` or `ox_target`), and that `zoneEnable` is `true` for that location.
- **Vehicle spawns without the right mods** — some visual mod indexes are vehicle-model-specific; use `/printmyveh` on a correctly modded reference vehicle to generate an accurate config entry instead of guessing indexes.
- **Insurance-related errors in console** — this script assumes an `insured_vehicles` table already exists from another resource; if you don't run vehicle insurance, those queries will fail silently or error — remove/ignore that integration if unused.
- **Wrong menu system shows up** — double check `Config.Menu` and that the corresponding resource (`qb-menu` or `ox_lib`) is started before this one.

---

## 📝 Credits & License

**Author**: Stan Leigh
**Version**: 1.3.8
**Framework**: QBCore

Distributed as part of the MnCLosSantos mod-dump collection — open source, please credit the original author if you edit and re-release.
