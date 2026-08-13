-- mnc-seizecar/server.lua
local QBCore = exports['qb-core']:GetCoreObject()

Config = {
    DefaultFuel = 100,
    DefaultEngineHealth = 1000,
    DefaultBodyHealth = 1000,
    -- Jobs allowed to use /seizecar (e.g. police, mechanic, etc.)
    SeizeCarJob = { ['police'] = true, ['mechanic'] = false },
}

-- Detect installed garage system automatically
local function DetectGarageSystem()
    if GetResourceState('qb-garages') == 'started' then
        return 'qb-garages', 'pillboxgarage'
    elseif GetResourceState('cdn-garage') == 'started' then
        return 'cdn-garage', 'A'
    elseif GetResourceState('jg-advancedgarages') == 'started' then
        return 'jg-advancedgarages', 'pillboxgarage'
    else
        return 'unknown', 'pillboxgarage'
    end
end

local GarageSystem, DefaultGarage = DetectGarageSystem()
print(('[mnc-seizecar] Detected garage system: %s (default: %s)'):format(GarageSystem, DefaultGarage))

-- Helper: Generate random 8-char plate
local function GeneratePlate()
    local charset = {}
    for i = 48, 57 do table.insert(charset, string.char(i)) end -- 0-9
    for i = 65, 90 do table.insert(charset, string.char(i)) end -- A-Z
    math.randomseed(GetGameTimer())
    local plate = ''
    for i = 1, 8 do plate = plate .. charset[math.random(1, #charset)] end
    return plate:upper()
end

-- Helper: Notify players with ox_lib
local function Notify(src, msg, type)
    if src and src > 0 then
        TriggerClientEvent('ox_lib:notify', src, { description = msg, type = type or 'inform' })
    else
        print(('[mnc-seizecar] %s'):format(msg))
    end
end

-- Helper: Get citizenid by server ID (supports offline players)
local function GetCitizenIdByServerId(targetId)
    local Player = QBCore.Functions.GetPlayer(targetId)
    if Player then
        return Player.PlayerData.citizenid, Player.PlayerData.license
    end
    local result = exports.oxmysql:executeSync("SELECT citizenid, license FROM players WHERE id = ?", { targetId })
    if result and result[1] then
        return result[1].citizenid, result[1].license
    end
    return nil, nil
end

-- =========================
-- Remove Single Car Command
-- =========================
QBCore.Commands.Add('removecar', 'Remove a specific vehicle from a player (Admin)', {{name = 'id', help = 'Player ID'}, {name = 'plate', help = 'Vehicle plate'}}, true, function(source, args)
    local src = source
    local targetId = tonumber(args[1])
    local plate = args[2] and args[2]:upper()

    if not targetId or not plate then
        return Notify(src, 'Usage: /removecar [id] [plate]', 'error')
    end

    if src ~= 0 and not (QBCore.Functions.HasPermission(src, 'admin') or QBCore.Functions.HasPermission(src, 'god') or IsPlayerAceAllowed(src, 'command')) then
        return Notify(src, 'No permission.', 'error')
    end

    local cid, _ = GetCitizenIdByServerId(targetId)
    if not cid then
        return Notify(src, 'Player not found.', 'error')
    end

    local result = exports.oxmysql:executeSync("DELETE FROM player_vehicles WHERE citizenid = ? AND plate = ? LIMIT 1", { cid, plate })

    if result and result.affectedRows and result.affectedRows > 0 then
        Notify(src, ('Removed vehicle with plate %s from player %s'):format(plate, targetId), 'success')

        local Target = QBCore.Functions.GetPlayer(targetId)
        if Target then
            TriggerClientEvent('ox_lib:notify', targetId, {
                description = ('Your vehicle with plate %s has been removed by an admin.'):format(plate),
                type = 'error'
            })
        end
    else
        Notify(src, ('No vehicle found with plate %s for player %s'):format(plate, targetId), 'error')
    end
end, 'admin')

-- =========================
-- Remove All Cars Command
-- =========================
QBCore.Commands.Add('removeallcars', 'Remove ALL vehicles from a player (Admin)', {{name = 'id', help = 'Player ID'}}, true, function(source, args)
    local src = source
    local targetId = tonumber(args[1])

    if not targetId then
        return Notify(src, 'Usage: /removeallcars [id]', 'error')
    end

    if src ~= 0 and not (QBCore.Functions.HasPermission(src, 'admin') or QBCore.Functions.HasPermission(src, 'god') or IsPlayerAceAllowed(src, 'command')) then
        return Notify(src, 'No permission.', 'error')
    end

    local cid, _ = GetCitizenIdByServerId(targetId)
    if not cid then
        return Notify(src, 'Player not found.', 'error')
    end

    local result = exports.oxmysql:executeSync("DELETE FROM player_vehicles WHERE citizenid = ?", { cid })
    local count = (result and result.affectedRows) or 0

    if count > 0 then
        Notify(src, ('Removed %s vehicle(s) from player %s'):format(count, targetId), 'success')

        local Target = QBCore.Functions.GetPlayer(targetId)
        if Target then
            TriggerClientEvent('ox_lib:notify', targetId, {
                description = 'All your vehicles have been removed by an admin.',
                type = 'error'
            })
        end
    else
        Notify(src, ('Player %s has no vehicles to remove.'):format(targetId), 'inform')
    end
end, 'admin')

-- =========================
-- Seize Car Command (Job-restricted)
-- =========================
QBCore.Commands.Add('seizecar', 'Seize a player\'s vehicle (Job-restricted)', {{name = 'id', help = 'Player ID'}, {name = 'plate', help = 'Vehicle plate'}}, true, function(source, args)
    local src = source
    if src == 0 then return Notify(src, 'This command cannot be used from console.', 'error') end

    local targetId = tonumber(args[1])
    local plate = args[2] and args[2]:upper()

    if not targetId or not plate then
        return Notify(src, 'Usage: /seizecar [id] [plate]', 'error')
    end

    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local job = Player.PlayerData.job.name
    if not Config.SeizeCarJob[job] then
        return Notify(src, 'Your job cannot use this command.', 'error')
    end

    local cid, _ = GetCitizenIdByServerId(targetId)
    if not cid then
        return Notify(src, 'Player not found.', 'error')
    end

    local result = exports.oxmysql:executeSync("DELETE FROM player_vehicles WHERE citizenid = ? AND plate = ? LIMIT 1", { cid, plate })

    if result and result.affectedRows and result.affectedRows > 0 then
        Notify(src, ('Seized vehicle with plate %s from player %s'):format(plate, targetId), 'success')

        local Target = QBCore.Functions.GetPlayer(targetId)
        if Target then
            local officerName = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname
            TriggerClientEvent('ox_lib:notify', targetId, {
                description = ('Your vehicle with plate %s has been seized by %s (%s).'):format(plate, officerName, job),
                type = 'error'
            })
        end
    else
        Notify(src, ('No vehicle found with plate %s for player %s'):format(plate, targetId), 'error')
    end
end)

print("^2[mnc-seizecar]^7 Script loaded successfully!")