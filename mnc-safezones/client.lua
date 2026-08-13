local QBCore = exports['qb-core']:GetCoreObject()

local SafeZones      = {}
local ActiveZones    = {}
local ActiveBlips    = {}
local InSafeZone     = false
local CurrentZoneName = nil

-- ─── Always read live from QBCore – never cache job data ──────────────────────
-- Caching PlayerData.job leads to stale data after job changes.
-- QBCore.Functions.GetPlayerData() is cheap and always accurate.
local function GetJob()
    local pd = QBCore.Functions.GetPlayerData()
    return pd and pd.job
end

local function IsExempt()
    local job = GetJob()
    if not job then return false end
    for _, exemptJob in ipairs(Config.ExemptJobs) do
        if job.name == exemptJob then return true end
    end
    return false
end

-- ─── NUI HUD: show/hide zone indicator ────────────────────────────────────────
local function ShowZoneHUD(zoneName, exempt)
    SendNUIMessage({
        action  = 'showZoneHUD',
        name    = zoneName,
        exempt  = exempt,
    })
end

local function HideZoneHUD()
    SendNUIMessage({ action = 'hideZoneHUD' })
end

-- ─── Zone management ──────────────────────────────────────────────────────────
local function DestroyAllZones()
    for _, handle in pairs(ActiveZones) do
        if handle and handle.remove then handle:remove() end
    end
    for _, blip in pairs(ActiveBlips) do
        if DoesBlipExist(blip) then RemoveBlip(blip) end
    end
    ActiveZones   = {}
    ActiveBlips   = {}
    InSafeZone    = false
    CurrentZoneName = nil
    HideZoneHUD()
end

local function BuildZones(zones)
    DestroyAllZones()

    for _, zone in ipairs(zones) do
        local handle = lib.zones.sphere({
            coords  = vector3(zone.center_x, zone.center_y, zone.center_z),
            radius  = zone.radius,
            debug   = Config.Debug,
            onEnter = function()
                InSafeZone      = true
                CurrentZoneName = zone.name
                ShowZoneHUD(zone.name, IsExempt())
            end,
            onExit = function()
                InSafeZone      = false
                CurrentZoneName = nil
                HideZoneHUD()
                -- Always restore on exit regardless of exempt status
                local ped = PlayerPedId()
                SetPedCanSwitchWeapon(ped, true)
                SetPlayerCanDoDriveBy(PlayerId(), true)
            end,
        })
        ActiveZones[zone.id] = handle

        -- ─── Map blip: fixed size on zoom (sprite 10 = circle, green) ─────────────────
        -- local blip = AddBlipForCoord(zone.center_x, zone.center_y, zone.center_z)

        -- SetBlipSprite(blip, 10)       
        -- SetBlipColour(blip, 2)          
        -- SetBlipScale(blip, 1.0)          
        -- SetBlipAsShortRange(blip, true)  
        -- SetBlipDisplay(blip, 5)         
        -- SetBlipCategory(blip, 7)          

        -- BeginTextCommandSetBlipName('STRING')
        -- AddTextComponentSubstringPlayerName(zone.name)
        -- EndTextCommandSetBlipName(blip)

        ActiveBlips[zone.id] = blip
    end
end

-- ─── Keep HUD in sync if job changes while inside a zone ─────────────────────
AddEventHandler('QBCore:Client:OnJobUpdate', function()
    if InSafeZone and CurrentZoneName then
        ShowZoneHUD(CurrentZoneName, IsExempt())
    end
end)

AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    if InSafeZone and CurrentZoneName then
        ShowZoneHUD(CurrentZoneName, IsExempt())
    end
end)

-- ─── Receive zones from server ────────────────────────────────────────────────
RegisterNetEvent('mnc-safezones:receiveSafeZones', function(zones)
    SafeZones = zones or {}
    BuildZones(SafeZones)
end)

-- ─── Open NUI menu ────────────────────────────────────────────────────────────
RegisterNetEvent('mnc-safezones:openMenu', function()
    SendNUIMessage({ action = 'openMenu', zones = SafeZones })
    SetNuiFocus(true, true)
end)

-- ─── Disable combat thread ────────────────────────────────────────────────────
-- Wait(0) MUST be first so DisableControlAction runs every single frame.
-- Checking the condition after the wait means we always yield first,
-- then immediately apply disables before the game processes input.
CreateThread(function()
    while true do
        Wait(0)
        if InSafeZone and not IsExempt() then
            local ped = PlayerPedId()

            -- Shoot / attack (foot)
            DisableControlAction(0, 24,  true) -- Attack
            DisableControlAction(0, 25,  true) -- Aim
            DisableControlAction(0, 47,  true) -- Attack 2
            DisableControlAction(0, 58,  true) -- Sniper zoom / attack
            DisableControlAction(0, 22,  true) -- Jump (prevents throw-grenade)
            DisableControlAction(0, 26,  true) -- Look behind (prevents aim lock)

            -- Melee
            DisableControlAction(0, 263, true) -- Melee attack 1
            DisableControlAction(0, 264, true) -- Melee attack 2
            DisableControlAction(0, 140, true) -- Melee attack light
            DisableControlAction(0, 141, true) -- Melee attack heavy
            DisableControlAction(0, 142, true) -- Melee attack alternate

            -- Vehicle shoot / drive-by
            DisableControlAction(0, 68,  true) -- Vehicle attack (aim)
            DisableControlAction(0, 69,  true) -- Vehicle attack 2
            DisableControlAction(0, 70,  true) -- Vehicle attack alternate
            DisableControlAction(0, 91,  true) -- Vehicle passenger attack
            DisableControlAction(0, 92,  true) -- Vehicle passenger aim
            DisableControlAction(0, 114, true) -- Vehicle fly attack

            -- Weapon selection / throwing
            DisableControlAction(0, 37,  true) -- Select weapon (stops switching to throwables)

            SetPedCanSwitchWeapon(ped, false)
            SetPlayerCanDoDriveBy(PlayerId(), false)

            -- Hard-remove any current weapon aim state each frame
            local weapon = GetSelectedPedWeapon(ped)
            if weapon ~= GetHashKey('WEAPON_UNARMED') then
                SetPedCurrentWeaponVisible(ped, false, true, true, true)
            end
        end
    end
end)

-- ─── NUI Callbacks ────────────────────────────────────────────────────────────
RegisterNUICallback('addZone', function(data, cb)
    TriggerServerEvent('mnc-safezones:addSafeZone', {
        name     = data.name,
        center_x = data.center_x,
        center_y = data.center_y,
        center_z = data.center_z,
        radius   = data.radius,
        height   = data.height,
    })
    cb('ok')
end)

RegisterNUICallback('removeZone', function(data, cb)
    TriggerServerEvent('mnc-safezones:removeSafeZone', data.id)
    cb('ok')
end)

RegisterNUICallback('closeMenu', function(_, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

-- ─── Commands ─────────────────────────────────────────────────────────────────
RegisterCommand('safemenu', function()
    TriggerServerEvent('mnc-safezones:requestMenu')
end, false)

RegisterCommand('addsafepoint', function()
    local coords = GetEntityCoords(PlayerPedId())
    SendNUIMessage({
        action   = 'setPoint',
        center_x = math.floor(coords.x * 100) / 100,
        center_y = math.floor(coords.y * 100) / 100,
        center_z = math.floor(coords.z * 100) / 100,
    })
    lib.notify({
        title       = 'Safe Zone',
        description = ('Point captured: %.1f, %.1f, %.1f'):format(coords.x, coords.y, coords.z),
        type        = 'success'
    })
end, false)