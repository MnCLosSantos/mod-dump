# 📦 MnC Item Spawner (Curated Catalog)

[![FiveM](https://img.shields.io/badge/FiveM-Ready-green.svg)](https://fivem.net/)
[![QBCore](https://img.shields.io/badge/Framework-QBCore-blue.svg)](https://github.com/qbcore-framework)
[![Version](https://img.shields.io/badge/Version-1.0.0-brightgreen.svg)]()

---

## 🌟 Overview

This is the curated-catalog variant of MnC Item Spawner. Instead of pulling every item from `QBCore.Shared.Items`, it presents a hand-picked `Config.Products` list organized into named categories (weapons, ammo, drugs, hardware, ambulance supplies, attachments, cards, electronics, crafting benches, and more), each with a display "stock" counter that depletes locally as items are added to a spawn cart.

---

## ✨ Key Features

**Access Control**
- Same job/grade gating as the base spawner: `Config.EnableJobLock` + `Config.AllowedJobs` (job name → minimum grade)

**Curated Catalog**
- `Config.Products` groups items into categories such as `normal`, `liquor`, `drugs`, `drug crafting`, `hardware`, `weapons`, `ammo`, `ambulance`, `attachment`, `weapon tints`, `cards`, `electronics`, and `crafting`
- Each product entry has a `name`, `price`, and starting `amount` (default `5000`) used purely as an on-screen stock counter
- Item labels/images are still resolved from `QBCore.Shared.Items` where the item exists, falling back to a title-cased version of the raw item name
- The local stock counter decrements client-side as items are added to the cart (UI refresh only — QBCore items are otherwise unlimited)

**UI**
- Command `Config.Command` (default `itemspawner`) opens the NUI grid
- Same 5 selectable visual themes as the auto-catalog version (`style1`–`style5`)
- Single-item spawn and multi-item cart submission

**Inventory-Aware Granting**
- Identical server-side logic to the auto-catalog version: auto-detects `ox_inventory`/`qb-inventory`, checks carry capacity, and notifies on a full inventory

---

## 📋 Requirements

| Dependency | Required |
|---|---|
| qb-core | ✅ Yes |
| ox_lib | ✅ Yes |
| ox_inventory or qb-inventory | Optional (auto-detected for carry-capacity checks) |

---

## 🚀 Installation

```bash
# Place into your resources folder
[server-data]/resources/[custom]/mnc-itemspawner/
```

```lua
# server.cfg
ensure mnc-itemspawner
```

No database setup required — items are granted directly into the player's inventory via `ox_inventory`/`qb-inventory`/QBCore's default item functions.

---

## ⚙️ Configuration Guide

```lua
Config.AllowedJobs = {
    ['admin'] = 4,
    ['staff'] = 4,
    ['police'] = 4,
}

Config.Products = {
    ['hardware'] = {
        { name = 'lockpick',       price = 0, amount = 5000 },
        { name = 'repairkit',      price = 0, amount = 5000 },
        { name = 'advancedrepairkit', price = 0, amount = 5000 },
    },
    -- ...weapons, ammo, drugs, cards, electronics, crafting, etc.
}
```

To add or remove what appears in the spawner, edit the relevant category array inside `Config.Products` — each entry just needs a valid QBCore item `name`.

---

## 🎮 Controls & Usage

```
/itemspawner
```
Opens the categorized NUI catalog. Add items to your cart and submit, or spawn a single item directly.

---

## 🔧 Troubleshooting

- **"Access Denied"** — the caller's job/grade doesn't meet the threshold in `Config.AllowedJobs`.
- **An item you need isn't in the list** — this build only shows items explicitly listed in `Config.Products`; add a new `{ name = '...', price = 0, amount = 5000 }` entry to the appropriate category.
- **Item shows a generic label** — the item name isn't found in your `QBCore.Shared.Items`; the label falls back to a title-cased version of the raw name.

---

## 📝 Credits & License

**Author**: Stan Leigh
**Version**: 1.0.0
**Framework**: QBCore

Distributed as part of the MnCLosSantos mod-dump collection — open source, please credit the original author if you edit and re-release.
