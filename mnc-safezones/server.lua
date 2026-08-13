local QBCore = exports['qb-core']:GetCoreObject()
local SafeZones = {}

-- ─── Database init ─────────────────────────────────────────────────────────────
CreateThread(function()
    while GetResourceState('oxmysql') ~= 'started' do Wait(100) end
    Wait(2000)

    -- Create table (includes center_z and height columns)
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS mnc_safezones (
            id        INT AUTO_INCREMENT PRIMARY KEY,
            name      VARCHAR(100) NOT NULL,
            center_x  FLOAT        NOT NULL,
            center_y  FLOAT        NOT NULL,
            center_z  FLOAT        NOT NULL DEFAULT 0.0,
            radius    FLOAT        NOT NULL DEFAULT 50.0,
            height    FLOAT        NOT NULL DEFAULT 20.0,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])

    -- Add center_z / height columns if upgrading from v1
    MySQL.query("ALTER TABLE mnc_safezones ADD COLUMN IF NOT EXISTS center_z FLOAT NOT NULL DEFAULT 0.0")
    MySQL.query("ALTER TABLE mnc_safezones ADD COLUMN IF NOT EXISTS height   FLOAT NOT NULL DEFAULT 20.0")

    local count = MySQL.scalar.await('SELECT COUNT(*) FROM mnc_safezones')
    if count == 0 then
        MySQL.insert.await([[
            INSERT INTO mnc_safezones (name, center_x, center_y, center_z, radius, height) VALUES
            ('City Hall',  -264.51,  -964.19,   30.0, 80.0, 20.0),
            ('Hospital',   310.8,    -593.31,   30.0, 80.0, 20.0),
            ('MRPD',       448.5,    -988.4,    30.0, 80.0, 20.0),
            ('LSIA',       -1037.43, -2736.82,  30.0, 80.0, 20.0)
        ]])
        print("^2[mnc-safezones]^7 Default safe zones inserted")
    end

    LoadSafeZones()
end)

-- ─── Load & broadcast ──────────────────────────────────────────────────────────
function LoadSafeZones()
    local result = MySQL.query.await('SELECT * FROM mnc_safezones ORDER BY id ASC')
    SafeZones = {}
    for _, row in ipairs(result or {}) do
        table.insert(SafeZones, {
            id       = row.id,
            name     = row.name,
            center_x = row.center_x,
            center_y = row.center_y,
            center_z = row.center_z,
            radius   = row.radius,
            height   = row.height,
        })
    end
    TriggerClientEvent('mnc-safezones:receiveSafeZones', -1, SafeZones)
    print(("^2[mnc-safezones]^7 Loaded %d zones"):format(#SafeZones))
end

-- ─── Send zones to a player when they finish loading ──────────────────────────
-- This covers two cases:
--   1. QBCore:Server:PlayerLoaded  – fired by qb-core when the player's
--      character is fully spawned and client-side resources are ready.
--   2. playerSpawned (fallback)    – broader FiveM event, catches edge-cases
--      where the QBCore event fires before mnc-safezones has finished its own
--      DB init (unlikely but safe to have).
--
-- Both handlers simply push the current SafeZones table to that one player.
-- Because SafeZones is populated before any player can realistically join
-- (2 s startup delay + DB query), this will almost always have data.

AddEventHandler('QBCore:Server:PlayerLoaded', function(player)
    local src = player.PlayerData.source
    TriggerClientEvent('mnc-safezones:receiveSafeZones', src, SafeZones)
end)

-- Belt-and-suspenders: also hook the raw FiveM spawn event so late-joiners
-- or players who bypass the QBCore flow still receive the zone list.
AddEventHandler('playerSpawned', function()
    local src = source
    TriggerClientEvent('mnc-safezones:receiveSafeZones', src, SafeZones)
end)

-- ─── Open menu request ─────────────────────────────────────────────────────────
RegisterNetEvent('mnc-safezones:requestMenu')
AddEventHandler('mnc-safezones:requestMenu', function()
    local src = source
    if QBCore.Functions.HasPermission(src, 'admin') then
        -- Always send fresh zone list before opening
        TriggerClientEvent('mnc-safezones:receiveSafeZones', src, SafeZones)
        TriggerClientEvent('mnc-safezones:openMenu', src)
    else
        TriggerClientEvent('ox_lib:notify', src, { title = 'Access Denied', description = 'Admin only', type = 'error' })
    end
end)

-- ─── Add zone ──────────────────────────────────────────────────────────────────
RegisterNetEvent('mnc-safezones:addSafeZone')
AddEventHandler('mnc-safezones:addSafeZone', function(data)
    local src = source
    if not QBCore.Functions.HasPermission(src, 'admin') then return end

    local name     = tostring(data.name   or 'Unnamed')
    local cx       = tonumber(data.center_x) or 0.0
    local cy       = tonumber(data.center_y) or 0.0
    local cz       = tonumber(data.center_z) or 0.0
    local radius   = tonumber(data.radius)   or 50.0
    local height   = tonumber(data.height)   or 20.0

    MySQL.insert(
        'INSERT INTO mnc_safezones (name, center_x, center_y, center_z, radius, height) VALUES (?,?,?,?,?,?)',
        { name, cx, cy, cz, radius, height },
        function(insertId)
            if insertId then
                local zone = { id = insertId, name = name, center_x = cx, center_y = cy, center_z = cz, radius = radius, height = height }
                table.insert(SafeZones, zone)
                TriggerClientEvent('mnc-safezones:receiveSafeZones', -1, SafeZones)
                TriggerClientEvent('ox_lib:notify', src, { title = 'Safe Zone', description = 'Zone "' .. name .. '" created', type = 'success' })
            end
        end
    )
end)

-- ─── Remove zone ───────────────────────────────────────────────────────────────
RegisterNetEvent('mnc-safezones:removeSafeZone')
AddEventHandler('mnc-safezones:removeSafeZone', function(id)
    local src = source
    if not QBCore.Functions.HasPermission(src, 'admin') then return end

    id = tonumber(id)
    MySQL.update('DELETE FROM mnc_safezones WHERE id = ?', { id }, function(affected)
        if affected and affected > 0 then
            for i = #SafeZones, 1, -1 do
                if SafeZones[i].id == id then
                    local zoneName = SafeZones[i].name
                    table.remove(SafeZones, i)
                    TriggerClientEvent('mnc-safezones:receiveSafeZones', -1, SafeZones)
                    TriggerClientEvent('ox_lib:notify', src, { title = 'Safe Zone', description = 'Zone "' .. zoneName .. '" removed', type = 'success' })
                    break
                end
            end
        end
    end)
end)

print("^2[mnc-safezones]^7 Script loaded successfully!")