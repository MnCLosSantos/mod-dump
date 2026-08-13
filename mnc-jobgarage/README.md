# 🚗 MNC Job Garage System

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![FiveM](https://img.shields.io/badge/FiveM-Ready-green.svg)](https://fivem.net/)
[![QBCore](https://img.shields.io/badge/Framework-QBCore-blue.svg)](https://github.com/qbcore-framework)
[![Version](https://img.shields.io/badge/Version-1.3.8-brightgreen.svg)]()

---

## 🌟 Overview

A **dynamic job garage system** for QBCore-based FiveM servers, tailored for **multiple roles** including police, ambulance, track marshall, and custom jobs like vinewoodrecords, lafesta, and more.  
This script provides **job-specific vehicle garages** with advanced features like **performance and visual upgrades**, **inventory integration**, **vehicle tracking**, **interactive garage props**, and **automatic vehicle documentation** (insurance, registration, and inspection). Fully optimized for **qb-target**, **ox_target**, **ox_lib**, **qb-menu**, and **qb-core** frameworks, it enhances roleplay with seamless vehicle management for services.

---

## ✨ Key Features

- 🚑🚓 **Multi-Job Garages**  
  - Dedicated garages for jobs like `police` (Mission Row PD), `ambulance` (Pillbox Hill Medical Center), `trackmarshall`, `vinewoodrecords`, `lafesta`, `autoexotics`, `ssmco`, `gruppe6`, `yachtclub`, and `mncracing`.  
  - Spawn and return vehicles via interactive props (e.g., parking pay stations).

- 🛠️ **Vehicle Customization**  
  - Apply **performance upgrades** (engine, brakes, transmission, suspension, turbo).  
  - Extensive **visual upgrades** (bumpers, neon lights, liveries, etc.).  
  - Configurable options like bulletproof tires, window tints, and custom plates.  
  - Neon lights with customizable colors and layouts for select vehicles.

- 📦 **Inventory Integration**  
  - Add items to vehicle trunks using `ox_inventory` or `qb-inventory`.  
  - Configurable trunk items per vehicle for roleplay scenarios (e.g., medical or police gear).

- 📍 **Vehicle Tracking & Blips**  
  - Track spawned vehicles with map blips that toggle on/off.  
  - Blips auto-remove when near the vehicle or if the vehicle is deleted.  
  - Optional despawn animations for immersive vehicle returns.

- 📄 **Automatic Vehicle Documentation**  
  - Auto-generates **insurance**, **registration**, and **inspection** records for spawned job vehicles.  
  - Stores data in MySQL tables (e.g., insured_vehicles) with details like plate, owner, dates, and colors.  
  - Documents are deleted when vehicles are returned or on resource stop for cleanup.

- 🔧 **Developer Tools**  
  - Command: `/printmyveh` - Prints your current vehicle's config to the F8 console for easy copy-paste into `config.lua`.

- 🧹 **Cleanup & Optimization**  
  - Automatic cleanup of vehicles, props, and database records on resource stop or vehicle return.  
  - Robust vehicle tracking to prevent duplicates or leaks.  
  - Debug mode for detailed logging and error prevention.

- 🎯 **Interactive Targets**  
  - Supports `qb-target` and `ox_target` for garage interactions.  
  - Dynamic garage props with job-restricted access.  
  - Configurable return radius for vehicle returns (default: 15m).

---

## 📋 Requirements

```bash
Dependency             Version   Required
---------------------- --------- ----------
QBCore Framework       Latest    ✅ Yes
ox_lib                 Latest    ✅ Yes
oxmysql                Latest    ✅ Yes
qb-target              Latest    ❌ Optional (for qb-target support)
ox_target              Latest    ❌ Optional (for ox_target support)
qb-menu                Latest    ❌ Optional (for qb-menu support)
LegacyFuel             Latest    ❌ Optional (for fuel integration)
ox_inventory           Latest    ❌ Optional (for inventory support)
qb-inventory           Latest    ❌ Optional (for inventory support)
```

---

## 🚀 Installation

### 1️⃣ Download & Extract

```bash
# Clone from GitHub
git clone https://github.com/YourUsername/mnc-jobgarage.git

# OR download ZIP from Releases
```

Place into your resources folder:

```bash
[server-data]/resources/[custom]/mnc-jobgarage/
```

### 3️⃣ Add to Server Config

```lua
# server.cfg
ensure oxmysql
ensure mnc-jobgarage
```

### 4️⃣ Configure Settings

Edit `config.lua` to customize:

```lua
Config = {
    Debug = false,               -- Enable debug prints
    Notify = "ox",              -- Notification system: "qb" or "ox"
    Menu = "qb",                -- Menu system: "qb" or "ox"
    Target = "qb",              -- Target system: "qb" or "ox"
    Fuel = "LegacyFuel",        -- Fuel script (set to your fuel script folder)
    CarDespawn = false,         -- Enable despawn animation
    ReturnDistanceCheck = true, -- Enable/disable distance check for returns
    ReturnRadius = 15.0,        -- Return radius in meters
}
```

### 5️⃣ Verify Garage Locations

The default `config.lua` includes garages for multiple jobs. Update coordinates or vehicle lists as needed:

```lua
Config.Locations = {
    -- Example: Police Garage
    {
        zoneEnable = true,
        job = "police",
        garage = {
            spawn = vec4(436.2, -976.03, 24.9, 138.13),
            out = vec4(461.14, -975.53, 25.7, 0.29),
            list = { ... } -- Vehicle list with customizations
        }
    },
    -- Add more jobs as per your config
}
```

---

## ⚙️ Configuration

### 🎯 Vehicle Customization

```lua
["dubsta2"] = {
    CustomName = "Dubsta OG",
    colors = {12, 12}, -- Matte Black (primary and secondary)
    performance = "max", -- Max performance upgrades (excluding armor)
    bulletproof = false, -- Bulletproof tires
    livery = 1, -- Sample livery
    windowTint = 3, -- Pure black tint
    plate = "DUBSTAOG", -- Custom plate (max 8 characters)
    extras = {1, 2}, -- Sample extras
    visualUpgrades = {
        spoiler = 3, -- Mod 0: Racing Spoiler
        -- ... more mods
        neon = { -- Neon lights
          enabled = true,
          color = {255, 0, 255}, -- Magenta
          layout = 2, -- All sides
        },
    },
}
```

### ⏳ Garage Settings

```lua
garage = {
    spawn = vec4(294.25, -608.75, 43.32, 70.0), -- Spawn coordinates
    out = vec4(299.15, -610.45, 43.32, 160.0), -- Interaction point
    list = { ... } -- Vehicle list
}
```

---

## 🎮 Controls & Commands

| Action/Command | Description |
|----------------|-------------|
| Interact | Use `qb-target` or `ox_target` at garage props to spawn/return vehicles |
| Toggle Blip | Trigger `qb-menu` or `ox_lib menu` to mark vehicle on map |
| `/printmyveh` | Prints your current vehicle's config to F8 console for config.lua |

---

## 📞 Support & Community

[![Discord](https://img.shields.io/badge/Discord-Join%20Server-7289da?style=for-the-badge&logo=discord&logoColor=white)](https://discord.gg/your-link)

---

## 📜 License

This project is licensed under the [MIT License](https://opensource.org/licenses/MIT).