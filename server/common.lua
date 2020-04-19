-- Core
Drugs                       = {}
Drugs.ESX                   = nil
Drugs.NumberOfCops          = 0

-- Locations
Drugs.Locations             = {}
Drugs.LocationsLoaded       = false
Drugs.ProcessActions        = {}

-- Items
Drugs.DrugsItems            = {}
Drugs.DrugsItemsLoaded      = false

-- Requests
Drugs.OpenRequest           = {}

-- Handlers
Drugs.ZoneLoader            = {}
Drugs.ZoneProcessor         = {}
Drugs.ZoneLabelGenerator    = {}

-- Initialize ESX
TriggerEvent('esx:getSharedObject', function(object)
    Drugs.ESX = object
end)

-- Register Zone Loader
Drugs.RegisterZoneLoaded = function(zone, cb)
    zone = string.lower(zone or 'unknown')

    Drugs.ZoneLoader[zone] = cb
end

-- Register Zone Processor
Drugs.RegisterZoneProcessor = function(zone, cb)
    zone = string.lower(zone or 'unknown')

    Drugs.ZoneProcessor[zone] = cb
end

-- Register Zone Label Generator
Drugs.RegisterZoneLabelGenerator = function(zone, cb)
    zone = string.lower(zone or 'unknown')

    Drugs.ZoneLabelGenerator[zone] = cb
end

-- Trigger Zone Processor
Drugs.TriggerZoneProcessor = function(playerId, locationName, cb)
    locationName = string.lower(locationName or 'unknown')
    playerId = playerId or 0

    if (playerId <= 0 or Drugs.Locations == nil or Drugs.Locations[locationName] == nil) then
        if (cb ~= nil) then
            cb()
        end

        return
    end

    local location = Drugs.Locations[locationName] or {}
    local zoneType = string.lower(location.type or 'unknown')
    local xPlayer = Drugs.ESX.GetPlayerFromId(playerId)

    if (xPlayer == nil or Drugs.ZoneProcessor == nil or Drugs.ZoneProcessor[zoneType] == nil or
        Drugs.ProcessActions == nil or Drugs.ProcessActions[tostring(xPlayer.source)] == nil) then
        if (cb ~= nil) then
            cb()
        end
        return
    end

    local lastTimeTriggerd = ((Drugs.ProcessActions or {})[tostring(xPlayer.source)] or {}).lastTimeTriggerd or os.time()
    local timeToWait = location.timeToExecute or 3.5
    local lastTimeAlive = ((Drugs.ProcessActions or {})[tostring(xPlayer.source)] or {}).lastTimeAlive or os.time()

    if (((lastTimeTriggerd + timeToWait) <= os.time()) and ((lastTimeAlive) >= (os.time() - 45))) then
        local requiredCops = location.requiredCops or 1

        if (Drugs.NumberOfCops < requiredCops) then
            xPlayer.showNotification(_U('required_cops', Drugs.NumberOfCops, requiredCops))

            Drugs.UpdateLastTimeTriggerd(playerId)

            if (cb ~= nil) then
                cb()
            end

            return
        end

        Drugs.ZoneProcessor[zoneType](xPlayer, location, cb)

        return
    end

    if (cb ~= nil) then
        cb()
    end
end

-- Generate Text Label For Zone
Drugs.TriggerZoneLabelGenerator = function(zoneInfo)
    local zoneType = string.lower(zoneInfo.type or 'unknown')

    if (Drugs.ZoneLabelGenerator ~= nil and Drugs.ZoneLabelGenerator[zoneType] ~= nil) then
        return Drugs.ZoneLabelGenerator[zoneType](zoneInfo)
    end

    return ''
end

-- Update Player Process Time
Drugs.UpdateLastTimeTriggerd = function(playerId)
    if (Drugs.ProcessActions == nil or Drugs.ProcessActions[tostring(playerId)] == nil) then
        return
    end

    Drugs.ProcessActions[tostring(playerId)].lastTimeTriggerd = os.time()
end

-- Load Marker By Zone
Drugs.LoadZoneDataByZone = function(zoneName, zone)
    zoneName = string.lower(zoneName or 'unknown')

    if (Drugs.ZoneLoader ~= nil and Drugs.ZoneLoader[zoneName] ~= nil) then
        return Drugs.ZoneLoader[zoneName](zone)
    end

    return false
end

-- Checks If Zone Exists
Drugs.ZoneTypeExists = function(name)
    name = string.lower(name or 'unknown')

    return (Drugs.ZoneLoader ~= nil and Drugs.ZoneLoader[name] ~= nil)
end

-- Load All Drugs Locations
Drugs.LoadDrugsLocations = function()
    if (Drugs.LocationsLoaded) then
        return
    end

    for name, zoneInfo in pairs(ServerConfig.Zones or {}) do
        local zoneType = string.lower(zoneInfo.type or 'unknown')

        if (Drugs.ZoneTypeExists(zoneType)) then
            local newZoneInfo = Drugs.LoadZoneDataByZone(zoneType, zoneInfo)

            if (not (not newZoneInfo)) then
                local zoneName = string.lower(newZoneInfo.name or 'unknown')

                if (Drugs.Locations ~= nil and Drugs.Locations[zoneName] == nil) then
                    Drugs.Locations[zoneName] = newZoneInfo
                end
            end
        end
    end

    Drugs.LocationsLoaded = true
end

-- Returns if given location exists
Drugs.LocationExists = function(locationName)
    locationName = string.lower(locationName or 'unknown')

    return (Drugs.Locations ~= nil and Drugs.Locations[locationName] ~= nil)
end

-- Load All Drugs Items
Drugs.LoadDrugsItems = function()
    if (Drugs.DrugsItemsLoaded) then
        return
    end

    while not Drugs.LocationsLoaded do
        Citizen.Wait(0)
    end

    for zoneName, zoneInfo in pairs(Drugs.Locations or {}) do
        local inputs = zoneInfo.inputs or {}
        local outputs = zoneInfo.outputs or {}

        for _, input in pairs(inputs) do
            local isItem = input.item ~= nil

            if (isItem) then
                local itemName = string.lower(input.item or 'unknown')

                if (Drugs.DrugsItems ~= nil and Drugs.DrugsItems[itemName] == nil) then
                    local drugsItem = Drugs.GetESXItemInfo(itemName)

                    if (not (not drugsItem)) then
                        Drugs.DrugsItems[string.lower(drugsItem.name)] = drugsItem
                    end
                end
            end
        end

        for _, output in pairs(outputs) do
            local isItem = output.item ~= nil

            if (isItem) then
                local itemName = string.lower(output.item or 'unknown')

                if (Drugs.DrugsItems ~= nil and Drugs.DrugsItems[itemName] == nil) then
                    local drugsItem = Drugs.GetESXItemInfo(itemName)

                    if (not (not drugsItem)) then
                        Drugs.DrugsItems[string.lower(drugsItem.name)] = drugsItem
                    end
                end
            end
        end

        Drugs.Locations[zoneName].label = Drugs.TriggerZoneLabelGenerator(zoneInfo)
    end

    Drugs.DrugsItemsLoaded = true
end

-- Returns ESX Drugs Item From Drugs Cache
Drugs.GetDrugsItem = function(item)
    item = string.lower(item or 'unknown')

    if (Drugs.DrugsItems == nil or Drugs.DrugsItems[item] == nil) then
        return nil
    end

    return Drugs.DrugsItems[item]
end

-- Get Item From ESX
Drugs.GetESXItemInfo = function(item)
    item = string.lower(item or 'unknown')

    while Drugs.ESX == nil do
        Citizen.Wait(0)
    end

    if (Drugs.ESX ~= nil and Drugs.ESX.Items ~= nil) then
        for itemName, itemValue in pairs(Drugs.ESX.Items or {}) do
            if (string.lower(itemName) == item) then
                local limit, weight = Drugs.CalculateWeightAndLimit(itemValue)

                return {
                    name = itemName,
                    label = itemValue.label or item,
                    limit = limit,
                    weight = weight,
                }
            end
        end
    end

    return false
end

-- Returns Limit and Weight of Item
Drugs.CalculateWeightAndLimit = function(item)
    item = item or {}

    local limit, weight
    local hasWeight = item.weight ~= nil
    local hasLimit = item.limit ~= nil

    if (hasWeight and not hasLimit) then
        weight = item.weight or 1
        limit = Drugs.Formats.Round(1.5 * weight, 0)
    elseif (hasLimit and not hasWeight) then
        limit = item.limit or 50
        weight = Drugs.Formats.Round(1.5 / limit, 2)
    elseif (hasLimit and hasWeight) then
        limit = item.limit or 50
        weight = item.weight or 1
    else
        limit = 50
        weight = Drugs.Formats.Round(1.5 / limit, 2)
    end

    return limit, weight
end

-- Returns name and action
Drugs.GenerateZoneNameAndAction = function(zoneName, inputs, outputs)
    zoneName = string.lower(zoneName or 'unknown')
    inputs = inputs or {}
    outputs = outputs or {}

    local name = zoneName
    local action = zoneName

    for _, input in pairs(inputs) do
        local isAccount = input.account ~= nil
        local isItem = input.item ~= nil

        if (isAccount) then
            name = name .. '_' .. input.account
            action = action .. '.' .. input.account
        elseif (isItem) then
            name = name .. '_' .. input.item
            action = action .. '.' .. input.item
        end
    end

    for _, output in pairs(outputs) do
        local isAccount = output.account ~= nil
        local isItem = output.item ~= nil

        if (isAccount) then
            name = name .. '_' .. output.account
            action = action .. '.' .. output.account
        elseif (isItem) then
            name = name .. '_' .. output.item
            action = action .. '.' .. output.item
        end
    end

    return string.lower(name), string.lower(action)
end

-- Returns If Player Is Allowed To Process On Location
Drugs.PlayerIsAllowed = function(playerId, locationName)
    locationName = string.lower(locationName or 'unknown')
    playerId = playerId or 0

    local xPlayer = Drugs.ESX.GetPlayerFromId(playerId)

    if (Drugs.Locations == nil or Drugs.Locations[locationName] == nil or xPlayer == nil) then
        return false
    end

    local allowed = true
    local location = Drugs.Locations[locationName]
    local whitelistedFor = location.whitelistedFor or {}
    local blacklistedFor = location.blacklistedFor or {}
    local playerJobName = string.lower((xPlayer.job or {}).name or 'unknown')

    if (#whitelistedFor > 0) then
        allowed = false
    end

    for _, whitelistedJob in pairs(whitelistedFor) do
        if (string.lower(whitelistedJob) == playerJobName) then
            allowed = true
        end
    end

    for _, blacklistedJob in pairs(blacklistedFor) do
        if (string.lower(blacklistedJob) == playerJobName) then
            allowed = false
        end
    end

    return allowed
end

-- Returns object as price (table or number)
Drugs.CalculatePrice = function(object)
    if (string.lower(type(object)) == 'number') then
        return object or 0
    elseif(string.lower(type(object)) == 'table') then
        local minPrice = object.min or 500
        local maxPrice = object.max or 1000
        local requiredCops = object.requiredCops or 5
        local priceDifference = maxPrice - minPrice

        if (priceDifference < 0) then
            priceDifference = minPrice - maxPrice

            local pricePerCop = Drugs.Formats.Round(priceDifference / requiredCops, 0)
            local currentPrice = maxPrice - (pricePerCop * Drugs.NumberOfCops)

            if (currentPrice < minPrice) then
                return minPrice
            end

            return currentPrice
        else
            local pricePerCop = Drugs.Formats.Round(priceDifference / requiredCops, 0)
            local currentPrice = minPrice + (pricePerCop * Drugs.NumberOfCops)

            if (currentPrice > maxPrice) then
                return maxPrice
            end

            return currentPrice
        end
    else
        return tonumber(object or '0') or 0
    end
end

AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() == resourceName) then
        Drugs.UpdatePolice()
    end
end)

AddEventHandler('playerDropped', function()
    local playerId = source

    playerId = playerId or 0

    if (Drugs.ProcessActions == nil) then
        return
    end

    if (Drugs.ProcessActions[tostring(playerId)] ~= nil) then
        Drugs.ProcessActions[tostring(playerId)] = nil
    end
end)

AddEventHandler('esx:playerLoaded', function(playerId, xPlayer)
    if (string.lower((xPlayer.job or {}).name or 'unknown') == 'police') then
        Drugs.NumberOfCops = Drugs.NumberOfCops + 1
    end
end)

AddEventHandler('esx:playerDropped', function(playerId)
    local xPlayer = Drugs.ESX.GetPlayerFromId(playerId)

    if (xPlayer ~= nil) then
        if (string.lower((xPlayer.job or {}).name or 'unknown') == 'police') then
            Drugs.NumberOfCops = Drugs.NumberOfCops - 1
        end
    end
end)

AddEventHandler('esx:setJob', function(playerId, newJob, oldJob)
    if (newJob ~= nil and oldJob ~= nil) then
        local newJobIsPolice = string.lower((newJob or {}).name or 'unknown') == 'police'
        local oldJobIsPolice = string.lower((oldJob or {}).name or 'unknown') == 'police'

        if (newJobIsPolice and not oldJobIsPolice) then
            Drugs.NumberOfCops = Drugs.NumberOfCops + 1

            if (Drugs.ProcessActions ~= nil and Drugs.ProcessActions[tostring(playerId)] ~= nil) then
                Drugs.ProcessActions[tostring(playerId)] = nil
            end
        elseif (not newJobIsPolice and oldJobIsPolice) then
            Drugs.NumberOfCops = Drugs.NumberOfCops - 1
        end

        if (Drugs.NumberOfCops < 0) then
            Drugs.NumberOfCops = 0
        end
    end
end)