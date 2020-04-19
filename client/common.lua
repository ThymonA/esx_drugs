-- Core
Drugs                   = {}
Drugs.ESX               = nil
Drugs.Blips             = {}

-- Locations
Drugs.Locations         = {}
Drugs.LocationsLoaded   = false

-- Marker
Drugs.IsInMarker        = false
Drugs.DrawMarkers       = {}
Drugs.CurrentAction     = nil
Drugs.CurrentMarker     = nil
Drugs.LastAction        = nil

-- Extras
Drugs.IsInVehicle       = false

-- Initialize ESX
Citizen.CreateThread(function()
    while Drugs.ESX == nil do
        TriggerEvent('esx:getSharedObject', function(object)
            Drugs.ESX = object
        end)

        Citizen.Wait(0)
    end

    while Drugs.ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end

    while not Drugs.LocationsLoaded do
        Drugs.LoadAllDrugsLocation()

        Citizen.Wait(500)
    end
end)

-- Load All Drugs Locations
Drugs.LoadAllDrugsLocation = function()
    Drugs.ESX.TriggerServerCallback('esx_drugs:getLocations', function(locations)
        Drugs.Locations = locations

        for _, blip in pairs(Drugs.Blips or {}) do
            if (DoesBlipExist(blip)) then
                RemoveBlip(blip)
            end
        end

        for _, location in pairs(locations or {}) do
            if ((not (not location.blip)) and location.blip.onMap) then
                local position = location.position or nil

                if (position ~= nil) then
                    local x,y,z = table.unpack(position)
                    local blip = AddBlipForCoord(x, y, z)

                    SetBlipSprite(blip, location.blip.sprite or 1)
                    SetBlipDisplay(blip, Config.Blip.Display)
                    SetBlipScale(blip, Config.Blip.Scale or 4)
                    SetBlipColour(blip, location.blip.colour or 1)
                    SetBlipAsShortRange(blip, Config.Blip.AsShortRange or false)
                    BeginTextCommandSetBlipName('STRING')
                    AddTextComponentString(_U('blip_' .. location.type, location.label))
                    EndTextCommandSetBlipName(blip)

                    table.insert(Drugs.Blips, blip)
                end
            end
        end

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

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    Drugs.DrawMarkers = {}
    Drugs.Locations = {}
    Drugs.LocationsLoaded = false

    Drugs.LoadAllDrugsLocation()
end)

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() == resourceName) then
        for _, blip in pairs(Drugs.Blips or {}) do
            if (DoesBlipExist(blip)) then
                RemoveBlip(blip)
            end
        end
    end
end)