-- Core
Drugs                   = {}
Drugs.ESX               = nil

-- Locations
Drugs.Locations         = {}
Drugs.LocationsLoaded   = false

-- Marker
Drugs.IsInMarker        = false
Drugs.DrawMarkers       = {}
Drugs.CurrentAction     = nil
Drugs.CurrentMarker     = nil
Drugs.LastAction        = nil

-- Initialize ESX
Citizen.CreateThread(function()
    while Drugs.ESX == nil do
        TriggerEvent('esx:getSharedObject', function(object)
            Drugs.ESX = object
        end)

        Citizen.Wait(0)
    end

    Drugs.LoadAllDrugsLocation()
end)

-- Load All Drugs Locations
Drugs.LoadAllDrugsLocation = function()
    Drugs.ESX.TriggerServerCallback('esx_drugs:getLocations', function(locations)
        Drugs.Locations = locations
        Drugs.LocationsLoaded = true
    end)
end

-- Load Current Action
Drugs.LoadCurrentAction = function()
    if (Drugs.CurrentAction ~= nil) then
        return string.lower(Drugs.CurrentAction)
    end

    return nil
end

-- Load Last Action
Drugs.LoadLastAction = function()
    if (Drugs.LastAction ~= nil) then
        return string.lower(Drugs.LastAction)
    end

    return nil
end

-- Returns Current Marker Type
Drugs.GetCurrentType = function()
    if (Drugs.CurrentMarker ~= nil) then
        return string.lower((Drugs.CurrentMarker or {}).type or 'unknown')
    end

    return 'unknown'
end

-- Returns Current Marker Type
Drugs.GetCurrentLabel = function()
    if (Drugs.CurrentMarker ~= nil) then
        return string.lower((Drugs.CurrentMarker or {}).label or 'Unknown')
    end

    return 'Unknown'
end

-- Load Any Exsisting Action
Drugs.LoadAnyAction = function()
    return Drugs.LoadCurrentAction() or Drugs.LoadLastAction() or 'unknown'
end

RegisterNetEvent('mlx:setJob')
AddEventHandler('mlx:setJob', function(job)
    Drugs.DrawMarkers = {}
    Drugs.Locations = {}
    Drugs.LocationsLoaded = false

    Drugs.LoadAllDrugsLocation()
end)