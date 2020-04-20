Drugs.RegisterZoneLoaded('harvest', function(zone)
    local position = zone.position or {}
    local outputs = zone.outputs or {}

    if (position == {} or outputs == {}) then
        return false
    end

    local zoneName, zoneAction = Drugs.GenerateZoneNameAndAction('harvest', nil, outputs)
    local blip = false

    if (zone.blip ~= nil) then
        blip = {
            onMap = (zone.blip or {}).onMap or false,
            sprite = (zone.blip or {}).sprite or 1,
            colour = (zone.blip or {}).colour or 1
        }
    end

    if (string.lower(type(blip)) == 'table') then
        if (not blip.onMap) then
            blip = false
        end
    end

    return {
        position = position,
        name = zoneName,
        action = zoneAction,
        blacklistedFor = zone.blacklistedFor or {},
        whitelistedFor = zone.whitelistedFor or {},
        requiredCops = zone.requiredCops or 1,
        timeToExecute = zone.timeToHarvest or 3.5,
        type = 'harvest',
        inputs = {},
        outputs = outputs,
        blip = blip
    }
end)

Drugs.RegisterZoneProcessor('harvest', function(xPlayer, zoneInfo, cb)
    local outputItems = zoneInfo.outputs or {}
    local limitReached = false
    local addItems = {}
    local addAccounts = {}
    local itemLabels = {}

    for _, outputItem in pairs(outputItems) do
        local isAccount = outputItem.account ~= nil
        local isItem = outputItem.item ~= nil

        if (not isAccount and isItem) then
            local esxItem = Drugs.GetDrugsItem(outputItem.item) or {}
            local count = outputItem.count or 1
            local limitSystem = string.lower(ServerConfig.DetermineLimit or 'weight')

            if (limitSystem == 'weight') then
                if (not xPlayer.canCarryItem(outputItem.item, count)) then
                    limitReached = true
                else
                    table.insert(itemLabels, esxItem.label)
                    table.insert(addItems, { item = outputItem.item, count = count })
                end
            else
                print(outputItem.item)

                local playerItem = xPlayer.getInventoryItem(outputItem.item)

                if (not xPlayer.canCarryItem(outputItem.item, count)) then
                    limitReached = true
                else
                    table.insert(itemLabels, esxItem.label or playerItem.label or outputItem.item)
                    table.insert(addItems, { item = outputItem.item, count = count })
                end
            end
        elseif (isAccount and not isItem) then
            table.insert(itemLabels, _U(outputItem.account))
            table.insert(addAccounts, { account = outputItem.account, money = Drugs.CalculatePrice(outputItem.price or 1) })
        end
    end

    local outputItemString = ''

    for i = 1, #itemLabels, 1 do
        if (i == #itemLabels) then
            outputItemString = outputItemString .. itemLabels[i]
        elseif ((i + 1) == #itemLabels) then
            outputItemString = outputItemString .. itemLabels[i] .. ' ' .. _('and') .. ' '
        else
            outputItemString = outputItemString .. itemLabels[i] .. ', '
        end
    end

    if (limitReached) then
        xPlayer.showNotification(_U('limit_harvest', outputItemString))
        Drugs.UpdateLastTimeTriggerd(xPlayer.source)

        if (cb ~= nil) then
            cb()
        end
    else
        local itemsReceived = ''

        for _, addItem in pairs(addItems) do
            itemsReceived = itemsReceived .. '~n~ ~g~>~s~ ' .. Drugs.Formats.NumberToFormattedString(addItem.count) .. 'x ' .. itemLabels[_]

            xPlayer.addInventoryItem(addItem.item, addItem.count)
        end

        for _, addAccount in pairs(addAccounts) do
            itemsReceived = itemsReceived .. '~n~ ~g~>~s~ ' .. Drugs.Formats.NumberToCurrancy(addAccount.money) .. 'x ' .. _U(addAccount.account)

            xPlayer.addAccountMoney(addAccount.account, addAccount.money)
        end

        xPlayer.showNotification(_U('item_received', itemsReceived))
        Drugs.UpdateLastTimeTriggerd(xPlayer.source)

        if (cb ~= nil) then
            cb()
        end
    end
end)

Drugs.RegisterZoneLabelGenerator('harvest', function(zoneInfo)
    local outputItems = zoneInfo.outputs or {}
    local itemLabels = {}

    for _, outputItem in pairs(outputItems) do
        local isAccount = outputItem.account ~= nil
        local isItem = outputItem.item ~= nil

        if (not isAccount and isItem) then
            local esxItem = Drugs.GetDrugsItem(outputItem.item)

            if (esxItem ~= nil) then
                table.insert(itemLabels, esxItem.label or outputItem.item or 'Unknown')
            else
                table.insert(itemLabels, outputItem.item or 'Unknown')
            end
        elseif (isAccount and not isItem) then
            table.insert(itemLabels, _U(outputItem.account))
        end
    end

    local outputItemString = ''

    for i = 1, #itemLabels, 1 do
        if (i == #itemLabels) then
            outputItemString = outputItemString .. itemLabels[i]
        elseif ((i + 1) == #itemLabels) then
            outputItemString = outputItemString .. itemLabels[i] .. ' ' .. _('and') .. ' '
        else
            outputItemString = outputItemString .. itemLabels[i] .. ', '
        end
    end

    return outputItemString
end)