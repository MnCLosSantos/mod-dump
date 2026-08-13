# 🚗 MNC Vehicle Placer

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![FiveM](https://img.shields.io/badge/FiveM-Ready-green.svg)](https://fivem.net/)
[![QBCore](https://img.shields.io/badge/Framework-QBCore-blue.svg)](https://github.com/qbcore-framework)
[![Version](https://img.shields.io/badge/Version-1.0.8-brightgreen.svg)]()

---

## 🌟 Overview

A **dynamic vehicle placement system** for QBCore-based FiveM servers.  
This script enables **pre-configured vehicle spawning** at specific locations with automatic cleanup and proximity-based vehicle management. Designed for events, showcases, or roleplay scenarios, it ensures vehicles are spawned, configured, and maintained efficiently. Fully optimized for **ox_lib**, **oxmysql**, and **qb-core** frameworks.

---

## ✨ Key Features

- 🚘 **Pre-Configured Vehicle Placements**  
  - Spawn vehicles at defined coordinates with specific models and headings.  
  - Supports multiple placements (e.g., limos, police vehicles, custom cars).  
  - Vehicles are frozen in place for display or event purposes.

- 🔄 **Automatic Vehicle Management**  
  - Vehicles spawn on resource start and are cleaned up on resource stop.  
  - Proximity-based checks ensure vehicles are re-spawned if missing.  
  - Client-side synchronization for players within 50 meters of spawn points.

- 🧹 **Cleanup & Optimization**  
  - Automatic cleanup of orphaned or misplaced vehicles.  
  - Robust tracking of spawned vehicles to prevent duplicates.  
  - Debug mode for detailed logging of spawn and cleanup events.

- 🛠️ **Flexible Configuration**  
  - Define vehicle models, spawn coordinates, and names in `config.lua`.  
  - Supports any vehicle model available in your server.  
  - Easy to expand for additional placements or events.

---

## 📋 Requirements

```bash
Dependency             Version   Required
---------------------- --------- ----------
QBCore Framework       Latest    ✅ Yes
ox_lib                 Latest    ✅ Yes
oxmysql                Latest    ✅ Yes
```

---

## 🚀 Installation

### 1️⃣ Download & Extract

```bash
# Clone from GitHub
git clone https://github.com/YourUsername/mnc-vehicleplacer.git

# OR download ZIP from Releases
```

Place into your resources folder:

```bash
[server-data]/resources/[custom]/mnc-vehicleplacer/
```

### 2️⃣ Database Setup

No manual database setup is required. The script uses in-memory storage (`spawnedVehicles` table) for tracking vehicles, which clears on resource stop.

### 3️⃣ Add to Server Config

```lua
# server.cfg
ensure oxmysql
ensure mnc-vehicleplacer
```

### 4️⃣ Configure Settings

Edit `config.lua` to customize vehicle placements:

```lua
Config = {
    Debug = false, -- Set to true to enable debug prints
    Placements = {
        [1] = {
            name = "LA FESTA LIMO",
            vehicleModel = "Stretch",
            vehicleSpawn = vector4(1353.09, 1156.52, 113.57, 130.81)
        },
        [2] = {
            name = "LA FESTA asbo",
            vehicleModel = "asbo",
            vehicleSpawn = vector4(1447.67, 1180.78, 114.13, 277.71)
        }
        -- Add more placements as needed
    }
}
```

---

## ⚙️ Configuration

### 🎯 Vehicle Placements

```lua
Config.Placements = {
    [1] = {
        name = "LA FESTA LIMO",
        vehicleModel = "Stretch",
        vehicleSpawn = vector4(1353.09, 1156.52, 113.57, 130.81) -- x, y, z, heading
    }
}
```

- **name**: Display name for the placement (used in debug logs).
- **vehicleModel**: The vehicle model to spawn (must exist in your server).
- **vehicleSpawn**: A `vector4` with x, y, z coordinates and heading for spawning.

### ⏳ Runtime Settings

- Vehicles are checked every 60 seconds for existence and player proximity.
- Missing vehicles are re-spawned after 30 seconds.
- Client-side configuration is triggered for players within 50 meters of a spawn point.

---

## 🎮 Controls

| Action | Description |
|--------|-------------|
| None | Vehicles are automatically managed with no player interaction required |

---

## 📞 Support & Community

[![Discord](https://img.shields.io/badge/Discord-Join%20Server-7289da?style=for-the-badge&logo=discord&logoColor=white)](https://discord.gg/your-link)

---

## 📜 License

This project is licensed under the [MIT License](https://opensource.org/licenses/MIT).