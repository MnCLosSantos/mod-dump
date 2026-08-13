local QBCore = exports['qb-core']:GetCoreObject()

-- Check if player has staff access
local function hasStaffAccess()
    local PlayerData = QBCore.Functions.GetPlayerData()
    if not PlayerData or not PlayerData.job then 
        return false 
    end
    if not Config.EnableJobLock then 
        return true 
    end
    local job = PlayerData.job.name
    local grade = PlayerData.job.grade.level
    if Config.AllowedJobs[job] and grade >= Config.AllowedJobs[job] then
        return true
    end
    return false
end

-- Fetch item models for all items
local function fetchItemModels()
    local itemModels = {}
    local categorizedItems = {}

    for category, items in pairs(Config.Products) do
        if not categorizedItems[category] then
            categorizedItems[category] = {}
        end
        for _, item in ipairs(items) do
            local qbItem = QBCore.Shared.Items[item.name]
            local itemLabel = qbItem and qbItem.label or item.name:gsub("_", " "):gsub("(%l)(%w*)", function(a, b) return a:upper() .. b end)
            -- Resolve image: prefer QBCore item image field, fall back to item name
            local itemImage = item.name
            if qbItem then
                if qbItem.client and qbItem.client.image then
                    itemImage = qbItem.client.image:gsub("%.png$", ""):gsub("%.jpg$", ""):gsub("%.jpeg$", "")
                elseif qbItem.image then
                    itemImage = qbItem.image:gsub("%.png$", ""):gsub("%.jpg$", ""):gsub("%.jpeg$", "")
                end
            end
            table.insert(categorizedItems[category], {
                name = item.name,
                image = itemImage,
                label = itemLabel,
                amount = item.amount,
                category = category,
            })
        end
    end

    SendNUIMessage({
        type = 'setItemModels',
        models = categorizedItems,
        uiStyle = Config.UIStyles[Config.UIStyle],
        title = "Item Spawner",
        hasStaffAccess = hasStaffAccess()
    })
end

-- Handle spawn submission
RegisterNUICallback('submitSpawn', function(data, cb)
    TriggerServerEvent('mnc-itemspawner:submitSpawn', data.item, data.quantity)
    cb({ status = 'ok' })
end)

-- Handle cart submission
RegisterNUICallback('submitCart', function(data, cb)
    TriggerServerEvent('mnc-itemspawner:submitCart', data.cart)
    cb({ status = 'ok' })
end)

-- Handle stock update when adding to cart
RegisterNUICallback('updateStock', function(data, cb)
    for category, items in pairs(Config.Products) do
        for _, item in ipairs(items) do
            if item.name == data.item then
                item.amount = math.max(0, item.amount - data.quantity)
                break
            end
        end
    end
    fetchItemModels()
    cb({ status = 'ok' })
end)

-- Handle UI opening via command
RegisterCommand(Config.Command, function()
    if not hasStaffAccess() then
        lib.notify({
            title = 'Access Denied',
            description = 'You do not have permission to use this command.',
            type = 'error',
            duration = 5000
        })
        return
    end
    SetNuiFocus(true, true)
    fetchItemModels()
    SendNUIMessage({
        action = "openUI",
        uiStyle = Config.UIStyles[Config.UIStyle],
        title = "Item Spawner",
        hasStaffAccess = hasStaffAccess()
    })
end, false)

-- Close UI
RegisterNUICallback('closeUI', function(_, cb)
    SetNuiFocus(false, false)
    cb({ status = 'closed' })
end)

-- Handle inventory full notification
RegisterNetEvent('mnc-itemspawner:notifyInventoryFull')
AddEventHandler('mnc-itemspawner:notifyInventoryFull', function(itemLabel)
    lib.notify({
        title = 'Inventory Full',
        description = 'You cannot carry any more ' .. itemLabel .. '.',
        type = 'error',
        duration = 5000
    })
end)