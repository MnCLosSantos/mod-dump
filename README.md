# 🗃️ MnCLosSantos Mod Dump

[![FiveM](https://img.shields.io/badge/FiveM-Ready-green.svg)](https://fivem.net/)
[![QBCore](https://img.shields.io/badge/Framework-QBCore-blue.svg)](https://github.com/qbcore-framework)
[![Resources](https://img.shields.io/badge/Resources-17-brightgreen.svg)]()

<img width="1920" height="1080" alt="1" src="https://github.com/user-attachments/assets/ba413c21-76e3-4fb8-8f84-f4cfefc9a2d7" />

---

## 🌟 Overview

A collection of 17 completed, standalone FiveM resources built for QBCore servers — covering vehicle ownership and garages, engine customization, vehicle catalogs and spawners, staff/admin tools, job roleplay systems, and free camera utilities. Each resource lives in its own folder with its own README covering setup, configuration, and usage in detail.

---

## 📦 Resources

### 🚗 Vehicle Ownership & Garages

| Resource | Description |
|---|---|
| [mnc-givecar](./mnc-givecar) | `/givecar` admin (or console/Tebex) command that permanently inserts a vehicle into a player's garage, auto-detecting the installed garage resource and DB schema. |
| [mnc-jobgarage](./mnc-jobgarage) | Advanced per-job vehicle garage system with grade-gated fleets, auto-applied performance/visual mods, vehicle tracking/return, GPS blip marking, and a `/printmyveh` config-generator command. |
| [mnc-seizecar](./mnc-seizecar) | Job-restricted `/seizecar` plus admin `/removecar` and `/removeallcars` commands that delete vehicles from a player's garage record via oxmysql, working even against offline players. |
| [mnc-vehicleplacer](./mnc-vehicleplacer) | Spawns and maintains a fixed set of static decoration vehicles at exact coordinates on server start, with an auto-respawn watchdog for missing/deleted vehicles. |

### 🔧 Engine & Customization
Download engine sounds here - 
```bash
https://drive.google.com/file/d/1iB2lXQN4O5ZIExfgCpvVE7WqYnR08yaP/view?usp=drive_link'
```
| Resource | Description |
|---|---|
| [mnc-engineswap-v1](./mnc-engineswap-v1) | Job-restricted engine shops selling a catalog of engine sounds, with paid delivery, a multi-stage install progress bar/minigame, and per-plate DB persistence. |
| [mnc-engineswap-v2](./mnc-engineswap-v2) | Same shop/purchase/install flow as v1, plus admin `/engineswap` (instant free swap) and `/vehsoundmeta` (per-model default engine sound) commands. |

### 🏪 Vehicle Catalogs, Spawning & Imaging

| Resource | Description |
|---|---|
| [mnc-vehiclecatalog](./mnc-vehiclecatalog) | Multi-dealership NUI vehicle browsing catalog with per-zone theming, qb-target or E-key interaction, shop-based filtering, and an admin "show all vehicles" command. |
| [mnc-vehiclespawner](./mnc-vehiclespawner) | Admin NUI vehicle spawner browsing all QBCore vehicles by category, with configurable color/paint finish, performance mods, random visual mods, and key/fuel system integration. |
| [mnc-vehicle-image-generator](./mnc-vehicle-image-generator) | NUI tool that auto-spawns configured vehicles, captures screenshots via screenshot-basic with a scripted camera, uploads them to a Discord webhook, and saves them locally with a `/vehlist` export command. |
| [mnc-towfinder](./mnc-towfinder) | Admin diagnostic tool that spawns every QBCore vehicle model one at a time, checks its skeleton for tow-hitch bones, and exports the tow-capable list to a generated Lua file. |

### 🎒 Item & Staff Tools

| Resource | Description |
|---|---|
| [mnc-itemluaspawner](./mnc-itemluaspawner) | Staff NUI item spawner that auto-loads every QBCore shared item grouped by type, with job/grade access control and single or cart spawning. |
| [mnc-itemspawner](./mnc-itemspawner) | Same spawner tool but using a hand-curated `Config.Products` catalog with per-item display stock counters instead of pulling all items automatically. |

### 👕 Jobs & Roleplay

| Resource | Description |
|---|---|
| [mnc-jobclothing](./mnc-jobclothing) | Multi-location, job-restricted locker room system with qb-target zones and ox_lib menus to wear/save/update/delete persistent grade-gated outfits. |
| [mnc-safezones](./mnc-safezones) | Database-backed spherical safe zones (ox_lib zones) disabling combat for non-exempt jobs, with an NUI admin panel and HUD indicator. |
| [mnc-muteondeath](./mnc-muteondeath) | Minimal automatic script that mutes a player's pma-voice proximity chat while dead/in last stand and unmutes on revive. |

### 🎥 Camera Tools

| Resource | Description |
|---|---|
| [mnc-freecam-v1](./mnc-freecam-v1) | Standalone toggleable free camera with WASD/mouse-look flight, roll, zoom, and 30 cyclable screen-effect/timecycle filters shown in an NUI HUD. |
| [mnc-freecam-v2](./mnc-freecam-v2) | Expanded free camera adding modifier-key+scroll controls for depth of field, camera shake, cinematic bars, and timecycle strength on top of the v1 flight/filter system. |

---

## 📋 Common Requirements

Most resources in this collection are built for **QBCore** and lean on a shared set of dependencies. Check each resource's own README for its exact list, but across the collection you'll generally need:

| Dependency | Used By |
|---|---|
| QBCore Framework | All resources |
| ox_lib | Most resources (menus, notifications, zones) |
| oxmysql | Resources with database persistence (garages, engine swap, safe zones, etc.) |
| qb-target | Resources with world interaction points (clothing, catalogs) |

---

## 🚀 Installation

```bash
# Clone the full collection
git clone https://github.com/MnCLosSantos/mod-dump.git
```

Copy the specific resource folder(s) you want into your server's resources directory, then add each one to `server.cfg`:

```lua
# server.cfg
ensure mnc-<resource-name>
```

Open each resource's own README for its specific database/items setup before starting it.

---

## 📝 Credits & License

**Author**: Stan Leigh (MnCLosSantos)
**Framework**: QBCore

All resources in this collection are open source. If you edit and redistribute any of them, please credit the original author.
