-- Store marker information in Draw Markers
Citizen.CreateThread(function()
    while true do
        if (#Drugs.Locations > 0) then
            local playerPed = GetPlayerPed(-1)
            local playerCoords = GetEntityCoords(playerPed)

            Drugs.DrawMarkers = {}

            for _, location in pairs(Drugs.Locations or {}) do
                local position = location.position or nil

                if (position ~= nil) then
                    local distance = #(position - playerCoords)

                    if (distance < Config.DrawDistance) then
                        local marker = (Config.Marker or {})[string.lower(location.type or 'unknown')] or {}

                        table.insert(Drugs.DrawMarkers, {
                            position = position,
                            action = location.action or 'unknown',
                            name = location.name or 'unknown',
                            type = location.type or 'unknown',
                            label = location.label or 'Unknown',
                            marker = {
                                x = marker.x or 5.0,
                                y = marker.y or 5.0,
                                z = marker.z or 1.5,
                                r = marker.r or 255,
                                g = marker.g or 0,
                                b = marker.b or 0,
                                type = marker.type or 1
                            }
                        })
                    end
                end
            end
        end

        Citizen.Wait(1500)
    end
end)

-- Every mil sec events
Citizen.CreateThread(function()
    while true do
        Drugs.IsInMarker = false

        local playerPed = GetPlayerPed(-1)
        local playerCoords = GetEntityCoords(playerPed)

        Drugs.IsInVehicle = IsPedInAnyVehicle(playerPed, false)

        for _, drawMarker in pairs(Drugs.DrawMarkers or {}) do
            local x, y, z = table.unpack(drawMarker.position)
            local distance = #(drawMarker.position - playerCoords)
            local marker = drawMarker.marker

            DrawMarker(marker.type, x, y, z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, marker.x, marker.y, marker.z, marker.r, marker.g, marker.b, 100, false, true, 2, false, false, false, false)

            if (distance < (marker.x * 0.55)) then
                Drugs.IsInMarker = true
                Drugs.CurrentAction = drawMarker.name
                Drugs.CurrentMarker = drawMarker
            end
        end

        if (Drugs.IsInMarker and Drugs.LastAction == nil) then
            Drugs.HasEnteredMarker()
        elseif (not Drugs.IsInMarker and Drugs.LastAction ~= nil) then
            Drugs.HasExitedMarker()
        end

        if (not Config.CanProcessInVehicle and Drugs.LastAction ~= nil and Drugs.IsInVehicle) then
            Drugs.HasExitedMarker()
            Drugs.ESX.ShowNotification(_U('process_in_vehicle'))
        end

        Citizen.Wait(0)
    end
end)

-- Keep alive when player is in marker
Citizen.CreateThread(function()
    while true do
        if (Drugs.IsInMarker) then
            TriggerServerEvent('esx_drugs:keepAlive')
        end

        Citizen.Wait(30000)
    end
end)

-- Trigger when player enters the marker
Drugs.HasEnteredMarker = function()
    local currentType = Drugs.GetCurrentType()

    local showNotification = true

    if (not Config.CanProcessInVehicle) then
        showNotification = not Drugs.IsInVehicle
    end

    if (currentType ~= nil and currentType ~= '' and showNotification) then
        local itemName = Drugs.GetCurrentLabel()

        Drugs.ESX.ShowHelpNotification(_U('press_' .. currentType, itemName))

        if (IsControlJustPressed(0, 38)) then
            Drugs.LastAction = Drugs.CurrentAction
            Drugs.CurrentAction = nil

            local currentAction = Drugs.LoadAnyAction()

            TriggerServerEvent('esx_drugs:startAction', currentAction)
        end
    end
end

-- Trigger when player exit the marker
Drugs.HasExitedMarker = function()
    Drugs.ESX.UI.Menu.CloseAll()

    Drugs.IsInMarker = false
    Drugs.CurrentAction = nil
    Drugs.CurrentMarker = nil
    Drugs.LastAction = nil

    TriggerServerEvent('esx_drugs:stopAction')
end