# 👕 MnC Job Clothing

[![FiveM](https://img.shields.io/badge/FiveM-Ready-green.svg)](https://fivem.net/)
[![QBCore](https://img.shields.io/badge/Framework-QBCore-blue.svg)](https://github.com/qbcore-framework)
[![Version](https://img.shields.io/badge/Version-1.3.0-brightgreen.svg)]()

---

## 🌟 Overview

MnC Job Clothing is a multi-location, persistent job locker room system. Each configured location is a `qb-target` zone tied to a specific job; employees can browse, wear, save, update, and delete grade-gated outfits, all stored per job/location/gender in the database and rendered through ox_lib context menus.

---

## ✨ Key Features

**Locker Room Locations**
- `Config.Locations` defines each locker room's coordinates, job restriction, whether the player must be on duty (`require_onduty`), the minimum grade to *use* the menu (`min_grade_to_use`), and the minimum grade to *save/manage* outfits (`min_grade_to_add`)
- Each location is a `qb-target` box zone (`Config.ZoneSize`) that opens the clothing menu on interaction

**Outfit Management (ox_lib context menu)**
- **Wear Outfit** — instantly applies a saved outfit (available to anyone meeting its `min_grade`)
- **Update Outfit** — overwrites a saved outfit with the player's current appearance (confirmation dialog), restricted to `min_grade_to_add`
- **Delete Outfit** — permanently removes an outfit (confirmation dialog)
- **Add New Outfit** — captures the player's current clothing and saves it under a new name, minimum grade, and icon via an ox_lib input dialog
- **Take Off** — reverts to the player's original clothes captured before changing into a uniform

**Persistence**
- Outfits are stored in an auto-created `job_outfits` table (job, location, name, gender, JSON clothing data, icon, min_grade), with automatic `ALTER TABLE` migrations to add the `icon`/`min_grade` columns if upgrading from an older version
- Captures all 12 clothing component slots and 5 prop slots per outfit, with fallback support for a legacy outfit data format

**Misc**
- `Config.Progress` selects `bar` or `circle` style for the ox_lib progress animation shown while changing
- `Config.Debug` toggle for verbose logging

---

## 📋 Requirements

| Dependency | Required |
|---|---|
| qb-core | ✅ Yes |
| ox_lib | ✅ Yes |
| oxmysql | ✅ Yes |
| qb-target | ✅ Yes (used for all locker room interaction zones) |

---

## 🚀 Installation

```bash
# Place into your resources folder
[server-data]/resources/[custom]/mnc-jobclothing/
```

```lua
# server.cfg
ensure mnc-jobclothing
```

No manual SQL import needed — the script automatically creates the `job_outfits` table (and migrates older versions of it) on first start.

---

## ⚙️ Configuration Guide

```lua
Config.Locations = {
    {
        name = "police_locker",
        label = "Police Locker Room",
        coords = vector4(461.74, -995.94, 30.69, 359.05),
        job = "police",
        require_onduty = true,
        min_grade_to_use = 0,
        min_grade_to_add = 4,
    },
}
```

Each location controls where the locker room zone is, which job it's for, whether the player must be on duty, and the grade thresholds for using vs. managing outfits.

---

## 🎮 Controls & Usage

Walk up to a configured locker room and interact through the `qb-target` prompt to open the clothing menu — no chat commands are used.

---

## 🔧 Troubleshooting

- **Zone doesn't appear / can't interact** — confirm `qb-target` is started before this resource, and that the location's `job` matches the exact job name in your `qb-core` shared jobs.
- **"No permission to save outfits"** — the player's job grade is below that location's `min_grade_to_add`.
- **Outfit looks wrong after a QBCore update** — very old outfits may be stored in the legacy format; the script auto-detects and falls back to the legacy component mapping, but re-saving the outfit will upgrade it.
- **Can't add new outfits after updating the script** — check the server console for the automatic `ALTER TABLE` migration messages confirming the `icon`/`min_grade` columns were added.

---

## 📝 Credits & License

**Author**: Adapted for ox_lib
**Version**: 1.3.0
**Framework**: QBCore

Distributed as part of the MnCLosSantos mod-dump collection — open source, please credit the original author if you edit and re-release.
