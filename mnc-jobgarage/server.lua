-- server.lua
local QBCore = exports['qb-core']:GetCoreObject()
local ActiveVehicles = {} -- Table to store active vehicle network IDs and their plates

-- Helper function to get player identifier
local function getPlayerIdentifier(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if Player and Player.PlayerData and Player.PlayerData.charinfo then
        local citizenid = Player.PlayerData.citizenid or "N/A"
        local playerName = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname
        return citizenid, playerName
    end
    return "N/A", "N/A"
end

-- Helper function to get current date in dd/mm/yyyy format
local function getCurrentDate()
    return os.date("%d/%m/%Y")
end

-- Helper function to get future date (30 days from now)
local function getFutureDate(days)
    return os.date("%d/%m/%Y", os.time() + (days * 24 * 60 * 60))
end

-- Helper function to save insured vehicle
local function saveInsuredVehicle(data)
    local color1 = data.color1 or ""
    local color2 = data.color2 or ""
    
    exports.oxmysql:insert([[
        INSERT INTO insured_vehicles (plate, citizenid, playerName, modTier, isBusiness, startDate, endDate, category, name, color1, color2, insuranceCompany)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ON DUPLICATE KEY UPDATE
            citizenid = ?, playerName = ?, modTier = ?, isBusiness = ?, startDate = ?, endDate = ?, category = ?, name = ?, color1 = ?, color2 = ?, insuranceCompany = ?
    ]], {
        data.plate, data.citizenid, data.playerName, data.modTier, data.isBusiness, data.startDate, data.endDate, data.category, data.name, color1, color2, data.insuranceCompany,
        data.citizenid, data.playerName, data.modTier, data.isBusiness, data.startDate, data.endDate, data.category, data.name, color1, color2, data.insuranceCompany
    })
end

-- Helper function to save registered vehicle
local function saveRegisteredVehicle(data)
    local color1 = data.color1 or ""
    local color2 = data.color2 or ""
    
    exports.oxmysql:insert([[
        INSERT INTO registered_vehicles (plate, citizenid, playerName, registrationDate, category, name, color1, color2)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        ON DUPLICATE KEY UPDATE
            citizenid = ?, playerName = ?, registrationDate = ?, category = ?, name = ?, color1 = ?, color2 = ?
    ]], {
        data.plate, data.citizenid, data.playerName, data.registrationDate, data.category, data.name, color1, color2,
        data.citizenid, data.playerName, data.registrationDate, data.category, data.name, color1, color2
    })
end

-- Helper function to save inspected vehicle
local function saveInspectedVehicle(data)
    local color1 = data.color1 or ""
    local color2 = data.color2 or ""
    
    exports.oxmysql:insert([[
        INSERT INTO inspected_vehicles (plate, citizenid, playerName, inspectionDate, category, name, color1, color2)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        ON DUPLICATE KEY UPDATE
            citizenid = ?, playerName = ?, inspectionDate = ?, category = ?, name = ?, color1 = ?, color2 = ?
    ]], {
        data.plate, data.citizenid, data.playerName, data.inspectionDate, data.category, data.name, color1, color2,
        data.citizenid, data.playerName, data.inspectionDate, data.category, data.name, color1, color2
    })
end

-- Helper function to delete vehicle documents
local function deleteVehicleDocuments(plate)
    exports.oxmysql:execute('DELETE FROM insured_vehicles WHERE plate = ?', { plate })
    exports.oxmysql:execute('DELETE FROM registered_vehicles WHERE plate = ?', { plate })
    exports.oxmysql:execute('DELETE FROM inspected_vehicles WHERE plate = ?', { plate })
    
    if Config.Debug then
        print("^5Debug^7: ^2Deleted all documents for plate: ^6" .. plate)
    end
end

-- Helper function to auto-insure job vehicle
local function autoInsureJobVehicle(src, plate, vehicleName, colors)
    local citizenid, playerName = getPlayerIdentifier(src)
    
    if citizenid == "N/A" then
        if Config.Debug then
            print("^5Debug^7: ^1Failed to get player identifier for source: ^6" .. src)
        end
        return
    end
    
    local color1 = ""
    local color2 = ""
    if type(colors) == "table" and #colors >= 2 then
        color1 = colors[1] or ""
        color2 = colors[2] or ""
    end
    
    local category = "compacts" -- Default category for job vehicles
    
    -- Save inspection record
    saveInspectedVehicle({
        plate = plate,
        citizenid = citizenid,
        playerName = playerName,
        inspectionDate = getCurrentDate(),
        category = category,
        name = vehicleName or "Job Vehicle",
        color1 = color1,
        color2 = color2
    })
    
    -- Save registration record
    saveRegisteredVehicle({
        plate = plate,
        citizenid = citizenid,
        playerName = playerName,
        registrationDate = getCurrentDate(),
        category = category,
        name = vehicleName or "Job Vehicle",
        color1 = color1,
        color2 = color2
    })
    
    -- Save insurance record
    saveInsuredVehicle({
        plate = plate,
        citizenid = citizenid,
        playerName = playerName,
        modTier = 1,
        isBusiness = false,
        startDate = getCurrentDate(),
        endDate = getFutureDate(30), -- 30 days from now
        category = category,
        name = vehicleName or "Job Vehicle",
        color1 = color1,
        color2 = color2,
        insuranceCompany = "MNC"
    })
    
    if Config.Debug then
        print("^5Debug^7: ^2Auto-insured job vehicle - Plate: ^6" .. plate .. "^7, Owner: ^6" .. playerName)
    end
end

-- 🔹 Sync Locations
RegisterNetEvent('mnc-jobgarage:server:syncLocations', function()
    if not Config then
        print("Error: Config not loaded, cannot sync locations")
        return
    end
    TriggerClientEvent('mnc-jobgarage:client:syncLocations', -1, Config.Locations)
end)

-- 🔹 Add New Locations
RegisterNetEvent('mnc-jobgarage:server:syncAddLocations', function(data)
    if not Config then
        print("Error: Config not loaded, cannot add locations")
        return
    end
    local dupe = false
    for _, v in pairs(Config.Locations or {}) do
        if v.garage and v.garage.out == data.garage.out then
            dupe = true
            break
        end
    end
    if not dupe then
        if type(data.garage.list[1]) == "string" then
            local list = {}
            for _, v in pairs(data.garage.list) do list[v] = {} end
            data.garage.list = list
        end
        Config.Locations[#Config.Locations + 1] = { zoneEnable = true, job = data.job, garage = data.garage }
        if Config.Debug then
            local coords = { string.format("%.2f", data.garage.out.x), string.format("%.2f", data.garage.out.y), string.format("%.2f", data.garage.out.z), string.format("%.2f", data.garage.out.w or 0.0) }
            print("^5Debug^7: ^2Adding new ^3JobGarage^2 location^7: ^5vec4^7(^6" .. coords[1] .. "^7, ^6" .. coords[2] .. "^7, ^6" .. coords[3] .. "^7, ^6" .. coords[4] .. "^7)")
        end
        TriggerClientEvent("mnc-jobgarage:client:syncLocations", -1, Config.Locations)
    end
end)

-- 🔹 Add Trunk Items
RegisterNetEvent("mnc-jobgarage:server:addTrunkItems", function(plate, items)
    local src = source
    if exports['qb-inventory'] then
        exports['qb-inventory']:OpenInventory(src, "trunk-" .. plate)
        Wait(100)
        TriggerClientEvent('qb-inventory:client:closeInv', src)
        for _, v in pairs(items) do
            exports['qb-inventory']:AddItem("trunk-" .. plate, v.name, v.amount or 1, nil, v.info)
        end
    else
        print("Error: No inventory system detected (ox_inventory or qb-inventory)")
    end
end)

-- 🔹 Track Spawned Vehicle and Auto-Insure
RegisterNetEvent("mnc-jobgarage:server:trackVehicle", function(netVeh, plate, vehicleName, colors)
    local src = source
    ActiveVehicles[netVeh] = {
        plate = plate,
        source = src
    }
    
    -- Auto-insure the job vehicle
    autoInsureJobVehicle(src, plate, vehicleName, colors)
    
    if Config.Debug then
        print("^5Debug^7: ^2Tracking and auto-insured vehicle with NetID: ^6" .. netVeh .. "^7, Plate: ^6" .. plate .. "^7 for player: ^6" .. src)
    end
end)

-- 🔹 Remove Tracked Vehicle and Delete Documents
RegisterNetEvent("mnc-jobgarage:server:removeVehicle", function(netVeh)
    local src = source
    if ActiveVehicles[netVeh] then
        local plate = ActiveVehicles[netVeh].plate
        
        -- Delete all documents for this vehicle
        deleteVehicleDocuments(plate)
        
        -- Remove from tracking
        ActiveVehicles[netVeh] = nil
        
        if Config.Debug then
            print("^5Debug^7: ^2Removed vehicle with NetID: ^6" .. netVeh .. "^7, Plate: ^6" .. plate .. "^7 and deleted documents for player: ^6" .. src)
        end
    end
end)

-- 🔹 Cleanup on Resource Stop
AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        if not Config then
            print("Error: Config not loaded, cannot clean up vehicles")
            return
        end
        for netVeh, data in pairs(ActiveVehicles) do
            local veh = NetworkGetEntityFromNetworkId(netVeh)
            if DoesEntityExist(veh) then
                DeleteEntity(veh)
            end
            
            -- Delete all documents for this vehicle
            if data.plate then
                deleteVehicleDocuments(data.plate)
            end
            
            if Config.Debug then
                print("^5Debug^7: ^2Deleted vehicle with NetID: ^6" .. netVeh .. "^7, Plate: ^6" .. (data.plate or "unknown") .. "^7 and removed documents on resource stop")
            end
        end
        ActiveVehicles = {}
        if Config.Debug then
            print("^5Debug^7: ^2Cleaned up all tracked vehicles and documents on resource stop")
        end
    end
end)

print("^2[mnc-jobgarage]^7 Script loaded successfully!")