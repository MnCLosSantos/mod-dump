-- client.lua
local QBCore = exports['qb-core']:GetCoreObject()
local Targets, Parking, Locations, currentVeh = {}, {}, {}, { out = false, current = nil, name = nil }

-- 🔹 Apply Performance Upgrades (Client-side, Excluding Armor)
local function applyPerformance(veh, perf)
    if not DoesEntityExist(veh) then
        if Config.Debug then print("Error: applyPerformance - Vehicle does not exist") end
        return
    end
    SetVehicleModKit(veh, 0)
    if perf == "max" then
        for _, i in ipairs({11, 12, 13, 15}) do
            SetVehicleMod(veh, i, GetNumVehicleMods(veh, i) - 1 or 0, false)
        end
        ToggleVehicleMod(veh, 18, true)
    elseif type(perf) == "table" then
        SetVehicleMod(veh, 11, perf[1] - 1 or 0, false)
        SetVehicleMod(veh, 12, perf[2] - 1 or 0, false)
        SetVehicleMod(veh, 13, perf[3] - 1 or 0, false)
        SetVehicleMod(veh, 15, perf[4] - 1 or 0, false)
        ToggleVehicleMod(veh, 18, perf[5] or false)
    end
end

-- 🔹 Apply Visual Upgrades (Client-side)
local function applyVisualUpgrades(veh, visualUpgrades)
    if not DoesEntityExist(veh) then
        if Config.Debug then print("Error: applyVisualUpgrades - Vehicle does not exist") end
        return
    end
    if not visualUpgrades or type(visualUpgrades) ~= "table" then
        if Config.Debug then print("Error: applyVisualUpgrades - Invalid visualUpgrades table") end
        return
    end
    SetVehicleModKit(veh, 0)
    local modMapping = {
        spoiler = 0, frontBumper = 1, rearBumper = 2, sideSkirt = 3, exhaust = 4, frame = 5,
        grille = 6, hood = 7, fender = 8, rightFender = 9, roof = 10, brakes = 12, horn = 14,
        wheels = 23, wheelType = 24, rearWheels = 25, plateHolder = 26, vanityPlates = 27,
        trimDesign = 28, ornaments = 29, dashboard = 30, dialDesign = 31, seats = 32,
        steeringWheel = 33, shifterLeavers = 34, plaques = 35, speakers = 36, trunk = 37,
        hydraulics = 38, engineBlock = 39, airFilter = 40, struts = 41, archCover = 42,
        aerials = 43, trim = 44, tank = 45, doorSpeaker = 46, livery = 48, xenon = 22
    }
    for modType, modIndex in pairs(visualUpgrades) do
        if modType == "neon" then
            if type(modIndex) == "table" and modIndex.enabled then
                ToggleVehicleMod(veh, 17, true)
                if modIndex.color and type(modIndex.color) == "table" and #modIndex.color == 3 then
                    SetVehicleNeonLightsColour(veh, modIndex.color[1], modIndex.color[2], modIndex.color[3])
                end
                SetVehicleNeonLightEnabled(veh, 0, modIndex.layout ~= 1 and modIndex.layout ~= 0)
                SetVehicleNeonLightEnabled(veh, 1, modIndex.layout ~= 0 and modIndex.layout ~= 2)
                SetVehicleNeonLightEnabled(veh, 2, true)
                SetVehicleNeonLightEnabled(veh, 3, true)
                if Config.Debug then
                    print("Debug: Applied neon lights (Color: " .. (modIndex.color and table.concat(modIndex.color, ", ") or "default") .. ", Layout: " .. (modIndex.layout or 0) .. ")")
                end
            else
                ToggleVehicleMod(veh, 17, false)
                if Config.Debug then print("Debug: Disabled neon lights") end
            end
        elseif modType == "wheelType" then
            SetVehicleWheelType(veh, modIndex)
            if Config.Debug then print("Debug: Set wheel type to " .. modIndex) end
        else
            local modId = modMapping[modType]
            if modId then
                if modIndex >= 0 and GetNumVehicleMods(veh, modId) > modIndex then
                    SetVehicleMod(veh, modId, modIndex, false)
                    if Config.Debug then print("Debug: Applied visual mod " .. modType .. " (ID: " .. modId .. ", Index: " .. modIndex .. ")") end
                else
                    if Config.Debug then print("Warning: Invalid mod index " .. modIndex .. " for mod " .. modType .. " (ID: " .. modId .. ") - Max: " .. GetNumVehicleMods(veh, modId)) end
                end
            else
                if Config.Debug then print("Warning: Unknown mod type " .. modType) end
            end
        end
    end
end

-- 🔹 Helper Functions
local function makeProp(data, freeze, ground)
    local propModel = GetHashKey(data.prop or "prop_parkingpay")
    local prop = CreateObject(propModel, data.coords.x, data.coords.y, data.coords.z - 1.0, false, false, false)
    SetEntityHeading(prop, data.coords.w or 0.0)
    if freeze then FreezeEntityPosition(prop, true) end
    if ground then PlaceObjectOnGroundProperly(prop) end
    return prop
end

local function removeTargets()
    for k, target in pairs(Targets) do
        if Config.Target == "qb" then
            exports['qb-target']:RemoveTargetEntity(target.entity, k)
        elseif Config.Target == "ox" then
            exports.ox_target:removeTargetEntity(target.entity, k)
        end
        Targets[k] = nil
    end
    for i = 1, #Parking do
        if DoesEntityExist(Parking[i]) then
            DeleteEntity(Parking[i])
        end
    end
    Parking = {}
end

local function makeTargets()
    removeTargets()
    for i, loc in pairs(Config.Locations or {}) do
        if loc.zoneEnable and loc.garage then
            local out = loc.garage.out
            local prop = makeProp({ prop = "prop_parkingpay", coords = vec4(out.x, out.y, out.z, out.w) }, true, false)
            Parking[#Parking + 1] = prop
            local targetName = "JobGarage: " .. i
            Targets[targetName] = { entity = prop }
            local jobLabel = loc.job or "Unknown Job"
            if Config.Target == "ox" then
                exports.ox_target:addTargetEntity(prop, {
                    options = {
                        {
                            name = targetName,
                            icon = "fas fa-clipboard",
                            label = "Access " .. jobLabel .. " Garage",
                            job = loc.job,
                            onSelect = function()
                                TriggerEvent("mnc-jobgarage:client:Garage:Menu", {
                                    job = loc.job,
                                    spawncoords = loc.garage.spawn,
                                    list = loc.garage.list,
                                    prop = prop,
                                    returncoords = loc.garage.out
                                })
                            end,
                            distance = 2.0
                        }
                    }
                })
            elseif Config.Target == "qb" then
                exports['qb-target']:AddTargetEntity(prop, {
                    options = {
                        {
                            type = "client",
                            event = "mnc-jobgarage:client:Garage:Menu",
                            icon = "fas fa-clipboard",
                            label = "Access " .. jobLabel .. " Garage",
                            job = loc.job,
                            action = function()
                                TriggerEvent("mnc-jobgarage:client:Garage:Menu", {
                                    job = loc.job,
                                    spawncoords = loc.garage.spawn,
                                    list = loc.garage.list,
                                    prop = prop,
                                    returncoords = loc.garage.out
                                })
                            end
                        }
                    },
                    distance = 2.0
                })
            end
        end
    end
end

-- 🔹 Initialize Targets
CreateThread(function()
    if not Config then
        print("Error: Config not loaded, cannot initialize targets")
        return
    end
    makeTargets()
end)

-- 🔹 Sync Locations
RegisterNetEvent('mnc-jobgarage:client:syncLocations', function(locations)
    Locations = locations
    makeTargets()
end)

-- 🔹 Garage Menu
RegisterNetEvent("mnc-jobgarage:client:Garage:Menu", function(data)
    local playerJob = QBCore.Functions.GetPlayerData().job
    local menuTitle = (playerJob and playerJob.label or "Job") .. " Garage"
    local vehicleMenu = {}

    if currentVeh.out and DoesEntityExist(currentVeh.current) then
        local returnItem = {
            header = "Return Vehicle",
            txt = "Return your current vehicle to the garage",
            title = "Return Vehicle",
            description = "Return your current vehicle to the garage",
            icon = "fas fa-car-burst"
        }
        if Config.Menu == "qb" then
            returnItem.params = {
                event = "mnc-jobgarage:client:RemSpawn",
                args = { returncoords = data.returncoords }
            }
        else
            returnItem.onSelect = function()
                TriggerEvent("mnc-jobgarage:client:RemSpawn", { returncoords = data.returncoords })
            end
        end
        vehicleMenu[#vehicleMenu + 1] = returnItem

        local blipItem = {
            header = "Mark Vehicle with Blip",
            txt = "Toggle a blip on your current vehicle",
            title = "Mark Vehicle with Blip",
            description = "Toggle a blip on your current vehicle",
            icon = "fas fa-map-marker-alt"
        }
        if Config.Menu == "qb" then
            blipItem.params = {
                event = "mnc-jobgarage:client:Garage:Blip",
                args = {}
            }
        else
            blipItem.onSelect = function()
                TriggerEvent("mnc-jobgarage:client:Garage:Blip")
            end
        end
        vehicleMenu[#vehicleMenu + 1] = blipItem
    else
        -- Build sorted list of available vehicles
        local sorted = {}

        for spawnName, v in pairs(data.list or {}) do
            local showButton = false
            if not v.grade and not v.rank then
                showButton = true
            elseif v.grade and playerJob.grade and playerJob.grade.level >= v.grade then
                showButton = true
            elseif v.rank then
                for _, rank in pairs(v.rank) do
                    if rank == (playerJob.grade and playerJob.grade.level or -1) then
                        showButton = true
                        break
                    end
                end
            end

            if showButton then
                table.insert(sorted, {
                    spawnName = spawnName,
                    data = v,
                    order = v.order or 9999   -- fallback so un-ordered items appear last
                })
            end
        end

        table.sort(sorted, function(a, b)
            return a.order < b.order
        end)

        for _, entry in ipairs(sorted) do
            local spawnName = entry.spawnName
            local v = entry.data

            local spawnHash = GetHashKey(spawnName)
            local vehicleName = v.CustomName or GetDisplayNameFromVehicleModel(spawnHash) or ("Unknown (" .. spawnName .. ")")
            
            local classIcons = {
                [8] = "fas fa-motorcycle",
                [9] = "fas fa-truck-monster",
                [10] = "fas fa-truck-front",
                [11] = "fas fa-truck-front",
                [12] = "fas fa-truck-front",
                [13] = "fas fa-bicycle",
                [14] = "fas fa-ship",
                [15] = "fas fa-helicopter",
                [16] = "fas fa-plane",
                [18] = "fas fa-kit-medical"
            }
            local vehicleIcon = classIcons[GetVehicleClassFromName(spawnHash)] or "fas fa-car"

            local menuItem = {
                header = vehicleName,
                txt = "Spawn " .. vehicleName,
                title = vehicleName,
                description = "Spawn " .. vehicleName,
                icon = vehicleIcon
            }

            if Config.Menu == "qb" then
                menuItem.params = {
                    event = "mnc-jobgarage:client:SpawnList",
                    args = { spawnName = spawnName, spawncoords = data.spawncoords, list = v }
                }
            else
                menuItem.onSelect = function()
                    TriggerEvent("mnc-jobgarage:client:SpawnList", { spawnName = spawnName, spawncoords = data.spawncoords, list = v })
                end
            end

            vehicleMenu[#vehicleMenu + 1] = menuItem
        end
    end

    if #vehicleMenu == 0 then
        if Config.Notify == "qb" then
            QBCore.Functions.Notify("No vehicles available for your rank", "error")
        elseif Config.Notify == "ox" then
            lib.notify({ title = 'Garage', description = 'No vehicles available for your rank', type = 'error' })
        end
        return
    end

    -- qb-menu
    if Config.Menu == "qb" then
        exports['qb-menu']:openMenu(vehicleMenu)
    -- ox_lib context menu
    elseif Config.Menu == "ox" then
        lib.showContext({
            id = 'job_garage_menu',
            title = menuTitle,
            options = vehicleMenu
        })
    end
end)

-- 🔹 Spawn Vehicle
RegisterNetEvent("mnc-jobgarage:client:SpawnList", function(data)
    local spawnName = data.spawnName
    local spawncoords = data.spawncoords
    local list = data.list or {}

    QBCore.Functions.SpawnVehicle(spawnName, function(veh)
        currentVeh.current = veh

        local desiredPlate

        -- Use custom plate from config if exists, otherwise generate fallback
        if list.plate then
            desiredPlate = list.plate
        else
            desiredPlate = "JOB" .. math.random(1000, 9999)  -- e.g. JOB1234
        end

        -- Clean input: uppercase, remove invalid characters, limit to 8 chars
        desiredPlate = desiredPlate:upper():gsub("[^%w]", ""):sub(1, 8)

        -- Pad with spaces on the RIGHT to make EXACTLY 8 characters
        local fullPlate = desiredPlate
        while #fullPlate < 8 do
            fullPlate = fullPlate .. " "
        end

        -- Apply the formatted plate to the vehicle
        SetVehicleNumberPlateText(veh, fullPlate)

        -- Clean version without spaces (most key systems prefer this)
        local cleanPlate = fullPlate:gsub("%s+", "")

        -- Give network control to server + small delay for sync
        NetworkRequestControlOfEntity(veh)
        while not NetworkHasControlOfEntity(veh) do Wait(10) end
        Wait(400)  -- Important delay for plate registration in qb/qbx keys

        SetVehicleDoorsLocked(veh, 1)                    -- Make sure unlocked initially
        SetVehicleDoorsLockedForAllPlayers(veh, false)

        TriggerEvent("vehiclekeys:client:SetOwner", cleanPlate)

        SetEntityHeading(veh, spawncoords.w)

        -- Colors
        local colors = list.colors or {0, 0}
        if type(colors) ~= "table" then colors = {0, 0} end
        local primary, secondary = colors[1] or 0, colors[2] or 0
        SetVehicleColours(veh, primary, secondary)

        -- Livery
        if list.livery then
            SetVehicleLivery(veh, list.livery)
        end

        -- Extras
        if list.extras then
            for extra, enabled in pairs(list.extras) do
                SetVehicleExtra(veh, tonumber(extra), enabled == false)
            end
        end

        -- Bulletproof Tires
        if list.bulletproof then
            SetVehicleTyresCanBurst(veh, false)
        end

        -- Performance Upgrades
        if list.performance then
            applyPerformance(veh, list.performance)
        end

        -- Visual Upgrades
        if list.visualUpgrades then
            applyVisualUpgrades(veh, list.visualUpgrades)
        end

        -- Window Tint (with retry logic)
        if list.windowTint then
            local maxRetries = 3
            local retryCount = 0
            local appliedTint = false
            while retryCount < maxRetries and not appliedTint do
                if DoesEntityExist(veh) then
                    SetVehicleWindowTint(veh, list.windowTint)
                    Wait(200)
                    local currentTint = GetVehicleWindowTint(veh)
                    if currentTint == list.windowTint then
                        appliedTint = true
                    else
                        retryCount = retryCount + 1
                    end
                else
                    break
                end
            end
            if not appliedTint then
                if Config.Notify == "qb" then
                    QBCore.Functions.Notify("Error: Failed to apply window tint", "error")
                elseif Config.Notify == "ox" then
                    lib.notify({ title = 'Error', description = 'Failed to apply window tint', type = 'error' })
                end
            end
        end

        -- Trunk Items
        if list.trunkItems then
            Wait(500)
            TriggerServerEvent("mnc-jobgarage:server:addTrunkItems", cleanPlate, list.trunkItems)
        end

        SetPedIntoVehicle(PlayerPedId(), veh, -1)

        -- Fuel
        if Config.Fuel and exports[Config.Fuel] then
            exports[Config.Fuel]:SetFuel(veh, 100.0)
        else
            SetVehicleFuelLevel(veh, 90.0)
        end

        SetVehicleEngineOn(veh, true, true)

        currentVeh.out = true
        currentVeh.name = list.CustomName or GetDisplayNameFromVehicleModel(GetHashKey(spawnName))

        -- Updated notification with clean plate
        if Config.Notify == "qb" then
            QBCore.Functions.Notify("Vehicle Spawned: " .. currentVeh.name .. " [" .. cleanPlate .. "]", "success")
        elseif Config.Notify == "ox" then
            lib.notify({ title = 'Vehicle Spawned', description = currentVeh.name .. ' [' .. cleanPlate .. ']', type = 'success' })
        end

        local netVeh = NetworkGetNetworkIdFromEntity(veh)
        local colorsTable = { primary, secondary }
        TriggerServerEvent("mnc-jobgarage:server:trackVehicle", netVeh, cleanPlate, currentVeh.name, colorsTable)

        -- Final tint reapplication & window check (unchanged)
        CreateThread(function()
            for i = 1, 5 do
                Wait(2000)
                if DoesEntityExist(veh) and list.windowTint then
                    SetVehicleWindowTint(veh, list.windowTint)
                else
                    break
                end
            end

            Wait(1000)
            if DoesEntityExist(veh) and list.windowTint then
                local currentTint = GetVehicleWindowTint(veh)
                if currentTint ~= list.windowTint then
                    if Config.Notify == "qb" then
                        QBCore.Functions.Notify("Error: Window tint not applied correctly", "error")
                    elseif Config.Notify == "ox" then
                        lib.notify({ title = 'Error', description = 'Window tint not applied correctly', type = 'error' })
                    end
                end

                local anyWindowIntact = false
                for i = 0, 7 do
                    if IsVehicleWindowIntact(veh, i) then anyWindowIntact = true end
                end
                if not anyWindowIntact then
                    if Config.Notify == "qb" then
                        QBCore.Functions.Notify("Warning: Vehicle has no intact windows, tint may not be visible", "warning")
                    elseif Config.Notify == "ox" then
                        lib.notify({ title = 'Warning', description = 'Vehicle has no intact windows, tint may not be visible', type = 'warning' })
                    end
                end
            end
        end)
    end, spawncoords, true)
end)

-- 🔹 Remove Vehicle
RegisterNetEvent("mnc-jobgarage:client:RemSpawn", function(data)
    if not currentVeh.current or not DoesEntityExist(currentVeh.current) then
        if Config.Notify == "qb" then
            QBCore.Functions.Notify("Error: No vehicle to return", "error")
        elseif Config.Notify == "ox" then
            lib.notify({ title = 'Error', description = 'No vehicle to return', type = 'error' })
        end
        return
    end

    if Config.ReturnDistanceCheck then
        local returnRadius = Config.ReturnRadius or 15.0
        local vehPos = GetEntityCoords(currentVeh.current)
        local returnPos = vector3(data.returncoords.x, data.returncoords.y, data.returncoords.z)
        local distance = #(vehPos - returnPos)
        if distance > returnRadius then
            if Config.Notify == "qb" then
                QBCore.Functions.Notify("Error: Vehicle must be within " .. returnRadius .. " meters of the garage", "error")
            elseif Config.Notify == "ox" then
                lib.notify({ title = 'Error', description = 'Vehicle must be within ' .. returnRadius .. ' meters of the garage', type = 'error' })
            end
            return
        end
    end

    local netVeh = NetworkGetNetworkIdFromEntity(currentVeh.current)
    TriggerServerEvent("mnc-jobgarage:server:removeVehicle", netVeh)

    if Config.CarDespawn then
        SetVehicleEngineHealth(currentVeh.current, 200.0)
        SetVehicleBodyHealth(currentVeh.current, 200.0)
        for i = 0, 7 do SmashVehicleWindow(currentVeh.current, i) Wait(150) end
        PopOutVehicleWindscreen(currentVeh.current)
        for i = 0, 5 do SetVehicleTyreBurst(currentVeh.current, i, true, 0) Wait(150) end
        for i = 0, 5 do SetVehicleDoorBroken(currentVeh.current, i, false) Wait(150) end
        Wait(800)
    end
    DeleteVehicle(currentVeh.current)
    currentVeh = { out = false, current = nil, name = nil }

    if Config.Notify == "qb" then
        QBCore.Functions.Notify("Vehicle Returned", "success")
    elseif Config.Notify == "ox" then
        lib.notify({ title = 'Vehicle Returned', type = 'success' })
    end
end)

-- 🔹 Vehicle Blip
local markerOn = false
local garageBlip = nil

RegisterNetEvent("mnc-jobgarage:client:Garage:Blip", function()
    if not currentVeh.current or not DoesEntityExist(currentVeh.current) then
        if Config.Notify == "qb" then
            QBCore.Functions.Notify("Error: No vehicle to mark", "error")
        elseif Config.Notify == "ox" then
            lib.notify({ title = 'Error', description = 'No vehicle to mark', type = 'error' })
        end
        return
    end

    if markerOn then
        markerOn = false
        if DoesBlipExist(garageBlip) then
            RemoveBlip(garageBlip)
            garageBlip = nil
            if Config.Notify == "qb" then
                QBCore.Functions.Notify("Blip Removed", "success")
            elseif Config.Notify == "ox" then
                lib.notify({ title = 'Blip Removed', type = 'success' })
            end
        end
    else
        markerOn = true
        garageBlip = AddBlipForEntity(currentVeh.current)
        SetBlipSprite(garageBlip, 85)
        SetBlipColour(garageBlip, 8)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Job Vehicle")
        EndTextCommandSetBlipName(garageBlip)
        SetBlipRoute(garageBlip, true)
        SetBlipRouteColour(garageBlip, 3)

        if Config.Notify == "qb" then
            QBCore.Functions.Notify("Blip Created: Vehicle location marked on map", "success")
        elseif Config.Notify == "ox" then
            lib.notify({ title = 'Blip Created', description = 'Vehicle location marked on map', type = 'success' })
        end

        CreateThread(function()
            while markerOn do
                local time = 5000
                if DoesEntityExist(currentVeh.current) then
                    local carLoc = GetEntityCoords(currentVeh.current)
                    local playerLoc = GetEntityCoords(PlayerPedId())
                    local dist = #(carLoc - playerLoc)
                    if dist <= 30.0 and dist > 1.5 then time = 1000
                    elseif dist <= 1.5 then
                        RemoveBlip(garageBlip)
                        garageBlip = nil
                        markerOn = false
                        if Config.Notify == "qb" then
                            QBCore.Functions.Notify("Blip Removed: Vehicle is nearby", "success")
                        elseif Config.Notify == "ox" then
                            lib.notify({ title = 'Blip Removed', description = 'Vehicle is nearby', type = 'success' })
                        end
                    end
                else
                    RemoveBlip(garageBlip)
                    garageBlip = nil
                    markerOn = false
                    if Config.Notify == "qb" then
                        QBCore.Functions.Notify("Blip Removed: Vehicle no longer exists", "error")
                    elseif Config.Notify == "ox" then
                        lib.notify({ title = 'Blip Removed', description = 'Vehicle no longer exists', type = 'error' })
                    end
                end
                Wait(time)
            end
        end)
    end
end)

-- Command: /printmyveh
-- Prints current vehicle config in F8 console, ready to copy-paste into config.lua
RegisterCommand('printmyveh', function()
    local ped = PlayerPedId()
    if not ped or not DoesEntityExist(ped) then return end

    if not IsPedInAnyVehicle(ped, false) then
        local msg = "You must be in a vehicle to use this command!"
        if Config.Notify == "qb" then
            QBCore.Functions.Notify(msg, "error")
        elseif Config.Notify == "ox" then
            lib.notify({ title = 'Error', description = msg, type = 'error' })
        else
            print("[printmyveh] " .. msg)
        end
        return
    end

    local veh = GetVehiclePedIsIn(ped, false)
    if not DoesEntityExist(veh) or not IsVehicleDriveable(veh, false) then
        print("[printmyveh] ERROR: Vehicle entity not valid")
        return
    end

    -- Get basic info safely
    local model = GetEntityModel(veh)
    local modelName = GetDisplayNameFromVehicleModel(model) or "Unknown"
    if modelName == "CARNOTFOUND" or modelName == "" then
        modelName = "Custom_" .. string.format("%x", model):upper()
    end

    local plate = GetVehicleNumberPlateText(veh) or "UNKNOWN"
    plate = plate:gsub("^%s*(.-)%s*$", "%1")  -- trim spaces

    -- Colors (fallback to 0,0 if failed)
    local primary, secondary = GetVehicleColours(veh)
    primary = primary or 0
    secondary = secondary or 0

    -- Window tint
    local windowTint = GetVehicleWindowTint(veh)
    if windowTint == -1 or windowTint == 0 then windowTint = nil end

    -- Livery
    local livery = GetVehicleLivery(veh)
    if livery == 0 then livery = nil end

    -- Extras
    local extras = {}
    local hasExtras = false
    for i = 1, 14 do
        if DoesExtraExist(veh, i) then
            local state = not IsVehicleExtraTurnedOn(veh, i)
            extras[tostring(i)] = state
            hasExtras = true
        end
    end
    if not hasExtras then extras = nil end

    -- Performance
    local perf = {}
    perf.engine       = GetVehicleMod(veh, 11) + 1
    perf.brakes       = GetVehicleMod(veh, 12) + 1
    perf.transmission = GetVehicleMod(veh, 13) + 1
    perf.suspension   = GetVehicleMod(veh, 15) + 1
    perf.turbo        = IsToggleModOn(veh, 18)

    local maxPerf = true
    for _, modType in ipairs({11,12,13,15}) do
        local current = GetVehicleMod(veh, modType) + 1
        local maxMods = GetNumVehicleMods(veh, modType)
        if current < maxMods then
            maxPerf = false
            break
        end
    end
    if maxPerf and perf.turbo then
        perf = "max"
    else
        perf = {perf.engine, perf.brakes, perf.transmission, perf.suspension, perf.turbo}
    end

    -- Visual mods
    local visual = {}
    local interestingMods = {
        spoiler = 0, frontBumper = 1, rearBumper = 2, sideSkirt = 3,
        exhaust = 4, hood = 7, fender = 8, rightFender = 9, roof = 10,
        wheels = 23, wheelType = 24, xenon = 22
    }

    for name, modType in pairs(interestingMods) do
        local index = GetVehicleMod(veh, modType)
        if index >= 0 then
            visual[name] = index
        end
    end

    -- Neon
    if IsToggleModOn(veh, 17) then
        local r, g, b = GetVehicleNeonLightsColour(veh)
        local layout = 0
        for i = 0, 3 do
            if IsVehicleNeonLightEnabled(veh, i) then
                layout = layout + (2 ^ i)
            end
        end
        if layout > 0 then
            visual.neon = {
                enabled = true,
                color = {r, g, b},
                layout = layout
            }
        end
    end

    -- Build config
    local config = {
        CustomName = modelName .. " (Generated)",
        colors = (primary ~= 0 or secondary ~= 0) and {primary, secondary} or nil,
        windowTint = windowTint,
        livery = livery,
        extras = extras,
        performance = perf,
        visualUpgrades = next(visual) ~= nil and visual or nil,
    }

    -- Print
    print(string.rep("=", 60))
    print(" Ready-to-paste vehicle configuration")
    print(string.rep("-", 60))
    print(("Model: %-20s | Plate: %s"):format(modelName, plate))
    print(" ")

    local modelKey = modelName:lower():gsub("[^%w]", "_")  -- safe key

    print("[\"" .. modelKey .. "\"] = {")

    if config.CustomName then
        print("    CustomName = \"" .. config.CustomName:gsub("\"", "\\\"") .. "\",")
    end
    if config.colors then
        print("    colors = {" .. config.colors[1] .. ", " .. config.colors[2] .. "},")
    end
    if config.windowTint then
        print("    windowTint = " .. config.windowTint .. ",")
    end
    if config.livery then
        print("    livery = " .. config.livery .. ",")
    end
    if config.extras then
        print("    extras = {")
        for k, v in pairs(config.extras) do
            print("        [" .. k .. "] = " .. tostring(v) .. ",")
        end
        print("    },")
    end
    if type(config.performance) == "string" then
        print("    performance = \"max\",")
    elseif type(config.performance) == "table" then
        print("    performance = { " .. table.concat(config.performance, ", ") .. " },")
    end
    if config.visualUpgrades then
        print("    visualUpgrades = {")
        for k, v in pairs(config.visualUpgrades) do
            if type(v) == "table" then
                local colorStr = table.concat(v.color, ", ")
                print("        " .. k .. " = { enabled = true, color = {" .. colorStr .. "}, layout = " .. (v.layout or 0) .. " },")
            else
                print("        " .. k .. " = " .. v .. ",")
            end
        end
        print("    },")
    end

    print("},")
    print(" ")
    print("Tip: You can change the model key and CustomName as needed.")
    print(string.rep("=", 60))

    -- Notification
    local successMsg = "Vehicle config printed to F8 console!"
    if Config.Notify == "qb" then
        QBCore.Functions.Notify(successMsg, "success")
    elseif Config.Notify == "ox" then
        lib.notify({ title = 'Success', description = successMsg, type = 'success' })
    end
end, false)

-- 🔹 Cleanup on Resource Stop
AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        removeTargets()
        if currentVeh.out and DoesEntityExist(currentVeh.current) then
            local netVeh = NetworkGetNetworkIdFromEntity(currentVeh.current)
            TriggerServerEvent("mnc-jobgarage:server:removeVehicle", netVeh)
            DeleteVehicle(currentVeh.current)
            currentVeh = { out = false, current = nil, name = nil }
        end
        if DoesBlipExist(garageBlip) then
            RemoveBlip(garageBlip)
            garageBlip = nil
            markerOn = false
        end
    end
end)