Drugs.StartProcessActions = function()
    function processActions()
        local tasks = {}

        for rawPlayerId, actions in pairs(Drugs.ProcessActions or {}) do
            local playerId = tonumber(rawPlayerId or '0') or 0

            if (playerId > 0) then
                table.insert(tasks, function(cb)
                    if (not Drugs.PlayerIsAllowed(playerId, actions.name or 'unknown')) then
                        cb()
                    else
                        local locationName = string.lower(((Drugs.ProcessActions or {})[tostring(playerId)] or {}).name or 'unknown')

                        if (locationName == 'unknown') then
                            cb()
                        else
                            Drugs.TriggerZoneProcessor(playerId, locationName, cb)
                        end
                    end
                end)
            end
        end

        Async.parallel(tasks, function(results)
            SetTimeout(1000, processActions)
        end)
    end

    SetTimeout(1000, processActions)
end

Drugs.SyncNumberOfPolice = function()
    function syncNumberOfPolice()
        Drugs.UpdatePolice()

        SetTimeout(ServerConfig.SyncPoliceInterval, syncNumberOfPolice)
    end

    SetTimeout(ServerConfig.SyncPoliceInterval, syncNumberOfPolice)
end

Drugs.UpdatePolice = function()
    local xPlayers = Drugs.ESX.GetPlayers()
    local newNumberOfCops = 0

    for _, playerId in pairs(xPlayers or {}) do
        local xPlayer = Drugs.ESX.GetPlayerFromId(playerId)

        if (xPlayer ~= nil and xPlayer.job ~= nil and string.lower(xPlayer.job.name) == 'police') then
            newNumberOfCops = newNumberOfCops + 1
        end
    end

    Drugs.NumberOfCops = newNumberOfCops
end