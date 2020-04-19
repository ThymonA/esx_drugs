Citizen.CreateThread(function()
    while not Drugs.LocationsLoaded do
        Drugs.LoadDrugsLocations()
        Citizen.Wait(0)
    end

    while not Drugs.DrugsItemsLoaded do
        Drugs.LoadDrugsItems()
        Citizen.Wait(0)
    end
end)

Drugs.ESX.RegisterServerCallback('esx_drugs:getLocations', function(source, cb)
    while not Drugs.LocationsLoaded do
        Citizen.Wait(0)
    end

    local playerId = source or 0

    if (playerId <= 0) then
        cb({})
    end

    local locations = {}

    for locationName, location in pairs(Drugs.Locations or {}) do
        if (Drugs.PlayerIsAllowed(playerId, locationName)) then
            table.insert(locations, {
                position = location.position or {},
                name = locationName,
                action = location.action or 'unknown',
                type = location.type or 'unknown',
                label = location.label or 'Unknown'
            })
        end
    end

    cb(locations)
end)

RegisterNetEvent('esx_drugs:startAction')
AddEventHandler('esx_drugs:startAction', function(locationName)
    local playerId = source or 0

    if (playerId <= 0) then
        return
    end

    if (Drugs.OpenRequest == nil) then
        Drugs.OpenRequest = {}
    end

    if (Drugs.OpenRequest[tostring(playerId)] ~= nil) then
        return
    end

    Drugs.OpenRequest[tostring(playerId)] = true

    if (Drugs.ProcessActions == nil) then
        Drugs.ProcessActions = {}
    end

    if (Drugs.ProcessActions[tostring(playerId)] ~= nil) then
        Drugs.ProcessActions[tostring(playerId)] = nil
    end

    if (Drugs.LocationExists(locationName)) then
        Drugs.ProcessActions[tostring(playerId)] = {
            name = locationName,
            lastTimeTriggerd = os.time(),
            keepAlive = os.time()
        }
    else
        Drugs.OpenRequest[tostring(playerId)] = nil
    end
end)

Drugs.SyncNumberOfPolice()
Drugs.StartProcessActions()