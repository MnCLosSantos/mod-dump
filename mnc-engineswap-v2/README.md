# ⚙️ MnC Engine Swap (Admin Edition)

[![FiveM](https://img.shields.io/badge/FiveM-Ready-green.svg)](https://fivem.net/)
[![QBCore](https://img.shields.io/badge/Framework-QBCore-blue.svg)](https://github.com/qbcore-framework)
[![Version](https://img.shields.io/badge/Version-1.9.4-brightgreen.svg)]()

---

## 🌟 Overview

This is the expanded build of MnC Engine Swap. It keeps the full player-facing shop/purchase/delivery/install workflow from v1, and adds two admin-only tools: an instant free engine-swap command for the vehicle you're sitting in, and a "model sound meta" manager that lets staff set a default engine sound for an entire vehicle model, so every spawn of that model sounds right even before a plate-specific swap is purchased.

---

## ✨ Key Features

**Player Shop Flow (unchanged from base)**
- `Config.EngineShops` job-restricted shop locations with blips, delivery points, and install markers
- Large categorized engine sound catalog (Supercars, Sports Cars, Muscle, Lowriders, Sports Classics, Motorcycles, Sedans, Offroad, Commercial, Formula)
- Server-validated bank payment, timed crate delivery, three-stage progress bar/circle install sequence, optional skill-check minigame, and automatic refunds on failure

**Admin: Instant Engine Swap**
- `/engineswap` command opens a category → engine `lib.registerContext` menu
- Requires QBCore permission group `admin`/`god`, or the `command.adminengineswap` ace permission
- Applies the chosen engine sound (`ForceVehicleEngineAudio`, called three times for reliability) and a matching handling profile (drive force, top speed, traction) to the vehicle the admin is currently in — free and instant, no delivery/payment
- Saves the change to the same `vehicle_engines` table used by the paid flow

**Admin: Vehicle Model Sound Meta**
- `/vehsoundmeta` command (same permission check) opens a menu to set a **default** engine sound for the current vehicle's model
- Overrides are stored in an auto-created `vehicle_model_sounds` table (`model`, `engine_sound`) and can be listed/removed from the same menu
- On vehicle entry, if no plate-specific swap is saved, the client automatically checks for and applies a model-level default sound

**Persistence**
- Auto-creates `vehicle_engines` (per-plate) and `vehicle_model_sounds` (per-model) tables on startup

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
[server-data]/resources/[custom]/mnc-engineswap-v2/
```

```lua
# server.cfg
ensure mnc-engineswap-v2
```

No SQL import needed — `vehicle_engines` and `vehicle_model_sounds` tables are created automatically with `CREATE TABLE IF NOT EXISTS` on first start.

---

## ⚙️ Configuration Guide

```lua
Config.EnginePrice = 2500
Config.EngineDeliveryTime = 5000
Config.RequiredItem = 'toolbox'
```

Shop locations and the full engine catalog use the exact same `Config.EngineShops` / `Config.EngineSounds` structure as v1 — see that catalog to add or reprice engines. Admin permission group is hard-coded near the top of `server.lua` as `ADMIN_GROUP = 'admin'` if you need to change it.

---

## 🎮 Controls & Usage

- **[E]** at a shop marker — open the paid engine catalog
- **[E]** at delivery point / vehicle — pick up crate / begin install
- **/engineswap** — (admin) instantly apply any engine to your current vehicle for free
- **/vehsoundmeta** — (admin) set or clear the default engine sound for a vehicle model

---

## 🔧 Troubleshooting

- **`/engineswap` says access denied** — the caller needs the `admin`/`god` QBCore permission group, or grant the `command.adminengineswap` ace.
- **Model default sound isn't applying** — it only applies when the vehicle has **no** per-plate swap saved; per-plate swaps always take priority.
- **Payment fails for the normal shop flow** — price is validated server-side against `Config.EngineSounds`; keep both sides of `config.lua` in sync.
- **DB errors on startup** — confirm `oxmysql` is connected before this resource starts (`ensure oxmysql` above it in server.cfg).

---

## 📝 Credits & License

**Author**: Stan Leigh
**Version**: 1.9.4
**Framework**: QBCore

Distributed as part of the MnCLosSantos mod-dump collection — open source, please credit the original author if you edit and re-release.
