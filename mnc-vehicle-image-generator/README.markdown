# 📸 MNC Vehicle Image Generator

[![FiveM](https://img.shields.io/badge/FiveM-Ready-green.svg)](https://fivem.net/)
[![QBCore](https://img.shields.io/badge/Framework-QBCore-blue.svg)](https://github.com/qbcore-framework)
[![Version](https://img.shields.io/badge/Version-1.8.3-brightgreen.svg)]()

---

## 🌟 Overview

MNC Vehicle Image Generator is an admin/dev tool with an NUI menu that automatically spawns each vehicle model from a configurable list, poses it in front of a scripted camera, takes a screenshot with `screenshot-basic`, uploads it to a Discord webhook, and downloads/saves the resulting image locally to the resource's `vehicle-images/` folder. It's built for batch-generating vehicle catalog/showcase images (e.g. for `mnc-vehiclecatalog` or `mnc-vehiclespawner`).

---

## ✨ Key Features

**Capture pipeline**
- Iterates through `Config.VehicleSpawnCodes`, spawning each model at a configured coordinate/heading, applying a fade-in, positioning a scripted camera using configurable offset/rotation/FOV, and forcing extra-sunny weather + 8:00 AM lighting for consistent shots.
- Player is hidden, made invincible, and given no collision during capture; radar/HUD are hidden.
- Captures are taken in configurable "chunks" (`Config.ChunkSize`, default 25) with a pause between chunks to free the model/entity pool and avoid FiveM pool-size crashes; capture can be resumed from the UI after a chunk pause.
- Screenshots are uploaded via `exports['screenshot-basic']:requestScreenshotUpload` directly to a Discord webhook, then the server downloads the resulting Discord CDN image and saves it to `vehicle-images/<model>.png` via `SaveResourceFile`.
- Live progress, per-vehicle skip handling (on model/entity load timeout), and completion status are all pushed to the NUI via `SendNUIMessage`.

**NUI menu**
- Full HTML/CSS/JS UI (`html/index.html`) for entering a Discord webhook, previewing/adjusting the camera position live against a preview vehicle (`startPreview`/`updatePreview`/`stopPreview`), starting/stopping capture, and tracking which vehicles are already completed.

**Persistence & exports**
- Tracks completed captures in `vehicle-images.json` in the resource root (also cross-checks the `vehicle-images/` folder on disk) so re-runs skip already-captured vehicles.
- Exposes `GetVehicleImage(model)`, `GetAllVehicleImages()`, and `GetVehicleImageFile(model)` server exports for other resources to pull generated image URLs/file paths.

**Admin command**
- `/vehlist` (admin only) dumps every vehicle model defined in `qb-core/shared/vehicles.lua` into chunked `vehlist<N>.lua` files (250 vehicles per file, formatted as `Config.VehicleSpawnCodes` tables) for easy copy-paste into this script's config.

---

## 📋 Requirements

| Dependency | Required |
|---|---|
| qb-core | Yes |
| screenshot-basic | Yes |

---

## 🚀 Installation

```bash
# Place into your resources folder
[server-data]/resources/[custom]/mnc-vehicle-image-generator/
```

```lua
# server.cfg
ensure mnc-vehicle-image-generator
```

No database setup needed. The resource auto-creates/updates `vehicle-images.json` in its own folder and saves downloaded screenshots into a `vehicle-images/` subfolder at runtime — you'll need a Discord webhook URL (entered in the UI, or preset via `Config.DefaultWebhook`) for uploads to work.

---

## ⚙️ Configuration Guide

```lua
Config.CameraSettings = {
    coords = vector3(90.48, -2731.8, 6.0), -- Where vehicles spawn
    heading = 290.2,
    cameraOffset = vector3(6.8, -4, 0.6),
    cameraRotation = vector3(176.6, -181.1, -118.5),
    fov = 71.5
}

Config.CaptureDelay = 1000 -- ms between each vehicle capture
Config.ChunkSize = 25      -- vehicles captured before pausing to free memory
```

`CameraSettings` controls where vehicles spawn and how the screenshot camera is framed relative to them (adjustable live via the UI's preview mode). `CaptureDelay` throttles requests to avoid Discord webhook rate limits, and `ChunkSize` controls how many vehicles are captured before the script pauses to avoid entity/model pool crashes on large batches. `Config.VehicleSpawnCodes` is the list of vehicle spawn codes that will be captured.

---

## 🎮 Controls & Usage

- `/vehimage` — opens the capture UI (requests the completed-vehicles list from the server first, then loads the NUI).
- `/vehlist` — admin only, exports all `qb-core` vehicle models to chunked Lua files for populating `Config.VehicleSpawnCodes`.
- Inside the UI: enter/test a Discord webhook, preview and fine-tune the camera position against a live preview vehicle, then start/stop/resume batch capture.

---

## 🔧 Troubleshooting

- **Images aren't uploading** — verify the Discord webhook URL is valid and test it with the UI's webhook test button, or `Config.DefaultWebhook` if preset.
- **"Model failed to load, skipping"** — some spawn codes in `Config.VehicleSpawnCodes` may belong to add-on vehicles not installed on the server; remove or fix the invalid entries.
- **Server crashes/pool errors during long batches** — lower `Config.ChunkSize` so the pause-and-clear cycle happens more often.
- **Downloaded images look tiny/corrupt** — the server rejects downloads under 15KB as likely failed uploads; check that Discord's CDN returned the full-size image and that the webhook has correct permissions.

---

## 📝 Credits & License

**Author**: Stan Leigh
**Version**: 1.8.3
**Framework**: QBCore

Distributed as part of the MnCLosSantos mod-dump collection — open source, please credit the original author if you edit and re-release.
