# 🔧 MNC Engine Swap System

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![FiveM](https://img.shields.io/badge/FiveM-Ready-green.svg)](https://fivem.net/)
[![QBCore](https://img.shields.io/badge/Framework-QBCore-blue.svg)](https://github.com/qbcore-framework)
[![Version](https://img.shields.io/badge/Version-1.9.3-brightgreen.svg)]()

---

## 🌟 Overview

A **fully-featured engine swap system** for QBCore-based FiveM servers. Players can browse a polished in-game shop UI, order salvaged engines from a choice of 80+ vehicle sound profiles across 8 categories, wait for delivery, and have the engine professionally installed — complete with progress animations, handling adjustments, and persistent database storage per vehicle plate.

---

## ✨ Key Features

### 🛒 Engine Shop UI
- **Themed NUI shop interface** with configurable accent colors (blue, red, green, purple, orange)
- **Category filtering and live search** to browse 80+ engine options
- **Per-engine image, name, description, and price** displayed on card layouts
- **Order confirmation modal** with optional target player ID field for charging another player
- **ESC key and close button** support for clean UI dismissal

### 🚗 Engine Selection & Categories
- **8 vehicle categories** out of the box: Supercars, Sports Cars, Muscle Cars, Motorcycles, Sedans, Offroad, Commercial, and Formula
- **80+ engine sound profiles** sourced directly from GTA V vehicle audio hashes
- **Custom engine support** — add any vehicle audio hash as a selectable engine
- **Per-engine pricing** configurable individually in `Config.EngineSounds`

### 📦 Delivery System
- **Configurable delivery delay** (`Config.EngineDeliveryTime`) before the engine crate arrives
- **Physical prop spawning** — an engine crate (`prop_car_engine_01`) and pallet (`prop_pallet_02a`) appear at the shop's designated delivery point
- **Plate-tracked vehicle confirmation** — player must confirm which vehicle is receiving the swap before installation begins

### 🔨 Installation System
- **Three-stage progress sequence**: removing stock engine → installing conversion kit → installing chosen engine
- **Choice of progress style**: bar or circle (configurable via `Config.Installation.progressType`)
- **Optional repair minigame** integration via ox_lib skill check (`requireMinigame`, `minigameMode`)
- **Mechanic animation** plays during installation (`mini@repair / fixing_a_ped`)
- **Hood opens automatically** during the swap and closes on completion
- **Proximity check** — player must be near the vehicle's front/headlight area to begin

### 💰 Payment & Refund System
- **Server-side payment validation** — prices are verified against config before processing
- **Bank account deduction** via QBCore money functions
- **Third-party charging** — mechanic players can charge a target player's ID rather than themselves
- **Automatic refund** issued if installation fails at any stage
- **Detailed notifications** sent to both the mechanic and the charged player

### 🔊 Engine Audio & Handling
- **`ForceVehicleEngineAudio`** applies the chosen engine's sound to the target vehicle
- **Handling modifiers applied** based on the source vehicle's stats (`fInitialDriveForce`, `fInitialDriveMaxFlatVel`, `fTractionCurveMax`)
- **Persistent engine storage** — engine sound saved to database by license plate and reapplied on next session

### 🗺️ Multi-Shop Support
- **Multiple shop locations** each with independent coordinates, delivery points, install zones, themes, and job restrictions
- **Map blips** per shop with configurable sprite, color, scale, and label (or disabled entirely)
- **Per-shop job whitelisting** — restrict access to specific job names

### 🛡️ Security & Validation
- **Server-side price validation** on every purchase — no client-side price tampering
- **Job and item requirement checks** before shop access is granted
- **Concurrent installation guard** — prevents double-installs from rapid clicks
- **`isProcessingOrder` flag** on the NUI side prevents duplicate order submissions

---

## 📋 Requirements

| Dependency | Version | Required |
|------------|---------|----------|
| QBCore Framework | Latest | ✅ Yes |
| ox_lib | Latest | ✅ Yes |
| oxmysql | Latest | ✅ Yes |

---

## 🚀 Installation

### 1️⃣ Download & Extract

```bash
# Clone from GitHub
git clone https://github.com/YourUsername/mnc-engineswap.git

# OR download ZIP from Releases
```

Place into your resources folder:
```
[server-data]/resources/[custom]/mnc-engineswap/
```

### 2️⃣ Database Setup

The script **automatically creates** the required table on first start:

- `vehicle_engines` — stores engine sound by vehicle plate

No manual SQL import needed!

### 3️⃣ Add to Server Config

```lua
# server.cfg
ensure oxmysql
ensure ox_lib
ensure mnc-engineswap
```

### 4️⃣ Configure Settings

Edit `config.lua` to customise shops, engines, and installation behaviour.

---

## ⚙️ Configuration Guide

### 🏪 Shop Configuration

```lua
Config.EngineShops = {
    {
        title = "LSC Salvage",                           -- Shop UI title
        location = vector3(-340.53, -141.85, 38.93),    -- Interaction point
        theme = "purple",                                -- UI accent color
        delivery = vector3(-358.95, -128.34, 38.71),    -- Engine crate spawn point
        install = vector3(-329.75, -143.7, 39.06),      -- Install zone
        jobs = {'mechanic', 'mechanic2', 'mechanic3'},   -- Job whitelist (empty = public)
        blip = { sprite = 446, color = 27, scale = 0.8, name = "LSC Salvage" }
        -- Set blip = false to disable the map blip
    },
}
```

**Available themes:** `blue`, `red`, `green`, `purple`, `orange`

### ⚙️ Installation Settings

```lua
Config.Installation = {
    requireMinigame = false,       -- Enable ox_lib skill check minigame
    minigameMode = 'easy',         -- 'easy' or 'medium'
    progressDuration = 25000,      -- Total install time in ms (split across 3 stages)
    progressType = 'bar',          -- 'bar' or 'circle'
    useAnimation = true,           -- Play mechanic repair animation
    animDict = 'mini@repair',
    animClip = 'fixing_a_ped',
}
```

### 🔧 General Settings

```lua
Config.EngineDeliveryTime = 5000  -- Delivery delay in ms before crate spawns
Config.RequiredItem = 'toolbox'   -- Item required to use shop (set to false to disable)
Config.Debug = false              -- Enable debug prints to server/client console
```

### 🔊 Engine Sound Entry Format

```lua
{
    category = "Supercars",
    engines = {
        {
            name = "Adder",             -- Display name in shop UI
            sound = "ADDER",            -- GTA V vehicle audio hash
            price = 5000,               -- Cost in bank balance
            image = "https://...",      -- Card thumbnail URL
            description = "Supercar V8" -- Short description shown in UI
        },
    }
}
```

---

## 🗂️ Engine Categories

| Category | Example Engines |
|----------|----------------|
| Supercars | Adder, Cheetah, T20, Turismo R, Entity XF |
| Sports Cars | Jester, Sultan, Massacro, Kuruma |
| Muscle Cars | Gauntlet, Dominator, Vigero, Tampa |
| Motorcycles | Bati, Hakuchou, Carbon RS, Gargoyle |
| Sedans | Schafter, Tailgater, Washington, Cognoscenti |
| Offroad | Sandking, Trophy Truck, Brawler, Kalahari |
| Commercial | Mule, Pounder, Stockade, Boxville |
| Formula | BR8, DR1, PR4, R88 |

Custom real-world engine sounds (e.g. Cummins, BMW M57, Scania DC) are also included and can be expanded freely.

---

## 🔄 How It Works

1. Player approaches a configured shop location
2. Job and item checks are performed
3. Shop NUI opens — player browses engines by category or search
4. Player selects an engine and confirms order (optionally charging another player by ID)
5. Server validates price, deducts bank funds, and triggers delivery timer
6. Engine crate and pallet props spawn at the shop's delivery point
7. Player picks up the crate and drives to the install zone
8. Player stands near the vehicle's front and confirms the target vehicle by plate
9. Three-stage progress bar/circle plays with mechanic animation
10. Engine audio hash is forced onto the vehicle; handling stats are adjusted
11. Engine is saved to the database by plate — persists across sessions
12. On failure at any stage, a full refund is automatically issued

---

## 🐛 Troubleshooting

**Shop not opening:**
- Confirm you are within interaction range of the configured `location` vector
- Check your job matches the shop's `jobs` whitelist
- Verify you have the required item (`Config.RequiredItem`)

**Payment not processing:**
- Ensure the target player is online and has sufficient bank funds
- Check server console for validation errors with `Config.Debug = true`

**Engine sound not applying:**
- Confirm the `sound` value matches a valid GTA V vehicle audio hash
- Make sure the vehicle engine is running and in a valid state before installation
- Check client console for `ForceVehicleEngineAudio` errors

**Engine not persisting after restart:**
- Verify `oxmysql` is started before `mnc-engineswap` in `server.cfg`
- Confirm the `vehicle_engines` table was created in your database

**Delivery prop not spawning:**
- Confirm the `delivery` vector in the shop config is on accessible ground
- Enable `Config.Debug` and watch for prop spawn logs in the client console

---

## 📝 Credits & License

**Author**: Stan Leigh  
**Version**: 1.9.3  
**Framework**: QBCore

This project is licensed under the [MIT License](https://opensource.org/licenses/MIT).

### Contributing
Contributions are welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Submit a pull request with a detailed description

---

## 📞 Support & Community

For support, bug reports, or feature requests:
- Open an issue on GitHub
- Join our Discord community
- Check existing documentation

---

## 🔄 Changelog

### Version 1.9.3 (Current Release)
**Improvements:**
- 🔧 Added `vehicleConfirmed` flag and plate-based vehicle tracking to prevent swapping the wrong vehicle
- 🔧 Introduced `targetPlayerId` support — mechanics can charge a different player's bank account
- 🔧 Automatic refund system now triggers on all failure paths including invalid vehicle state
- 🔧 Three-part progress sequence (remove stock → install kit → install engine) for both bar and circle styles
- 🔧 Hood now opens during installation and closes cleanly on completion or cancellation
- 🔧 Delivery crate and pallet props cleaned up on ESC, cancellation, and after install

**Bug Fixes:**
- 🐛 Fixed concurrent installation exploit with `isInstalling` guard flag
- 🐛 Resolved `isProcessingOrder` not resetting after a failed NUI fetch
- 🐛 Corrected shop state (`pendingShop`) not being preserved when UI is dismissed mid-order
- 🐛 Fixed pallet prop persisting after failed installation
- 🐛 Resolved `targetPlayerId` not being reset after installation completes

---

### Version 1.8.0
**New Features:**
- ✨ Added multi-shop support with per-shop job restrictions, themes, and blip settings
- ✨ Implemented configurable map blips per shop (sprite, color, scale, name)
- ✨ Added optional minigame (ox_lib skill check) before installation

**Improvements:**
- 🔧 Separated delivery point and install zone per shop
- 🔧 Added `shop.title` field for custom NUI shop header per location
- 🔧 Improved job label lookup with fallback to raw job name

**Bug Fixes:**
- 🐛 Fixed blip creation crashing when `shop.blip` was set to `false`
- 🐛 Resolved install zone check not scoping to the correct shop

---

### Version 1.7.0
**New Features:**
- ✨ Added engine category system with filter dropdown in shop UI
- ✨ Implemented live search bar filtering by name and description
- ✨ Added themed NUI with five accent color options
- ✨ Introduced per-engine image, description, and price fields

**Improvements:**
- 🔧 Replaced static engine list with dynamic card generation from config
- 🔧 Enhanced modal confirmation with engine image and formatted price

**Bug Fixes:**
- 🐛 Fixed category filter not resetting when shop is reopened
- 🐛 Resolved modal staying open after shop close via ESC

---

### Version 1.6.0
**New Features:**
- ✨ Added persistent engine storage via `vehicle_engines` MySQL table
- ✨ Engine sound reapplied automatically on vehicle spawn/entry
- ✨ Implemented `mnc-engineswap:saveEngine` and `mnc-engineswap:getEngine` server callbacks

**Improvements:**
- 🔧 Switched to `ON DUPLICATE KEY UPDATE` for safe upsert behaviour
- 🔧 Database table auto-created on resource start via `MySQL.ready`

**Bug Fixes:**
- 🐛 Fixed engine not being saved when installation succeeded without handling modifiers
- 🐛 Resolved database errors when plate contained special characters

---

### Version 1.5.0
**New Features:**
- ✨ Added handling modifier system — drive force, max speed, and traction adjusted to match source vehicle
- ✨ Implemented server-side price validation to prevent client-side tampering
- ✨ Added automatic refund event (`mnc-engineswap:refundPayment`) on installation failure

**Improvements:**
- 🔧 Wrapped `ForceVehicleEngineAudio` and handling calls in `pcall` for safe error handling
- 🔧 Added detailed debug logging throughout payment and installation flows

**Bug Fixes:**
- 🐛 Fixed refund not triggering when progress bar was cancelled mid-install
- 🐛 Resolved handling modifiers not applying when vehicle was freshly spawned

---

### Version 1.0.0
**New Features:**
- ✨ Initial release with basic engine sound swapping
- ✨ NUI shop interface with engine selection
- ✨ QBCore bank payment integration
- ✨ ox_lib progress bar for installation
- ✨ Delivery prop spawning at configured coordinates
- ✨ Required item check (`toolbox`) before shop access

---

## ⚠️ Important Notes

1. **Audio Hashes**: The `sound` field must be a valid GTA V vehicle audio hash — invalid hashes will silently fail to apply
2. **Handling Modifiers**: Not all audio hashes have a matching handling profile; the system falls back gracefully and issues a refund if none is found
3. **Database**: Requires oxmysql — MariaDB 10.3+ recommended
4. **Compatibility**: QBCore only — not compatible with ESX
5. **Legal**: For use on FiveM servers only, respect Rockstar's ToS

---

**Give your players the engine they deserve. 🔧**