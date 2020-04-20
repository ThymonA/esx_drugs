Drugs.RegisterZoneLoaded('transform', function(zone)
    local position = zone.position or {}
    local inputs = zone.inputs or {}
    local outputs = zone.outputs or {}

    if (position == {} or outputs == {}) then
        return false
    end

    local zoneName, zoneAction = Drugs.GenerateZoneNameAndAction('transform', inputs, outputs)
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
        timeToExecute = zone.timeToTransform or 3.5,
        type = 'transform',
        inputs = inputs,
        outputs = outputs,
        blip = blip
    }
end)

Drugs.RegisterZoneProcessor('transform', function(xPlayer, zoneInfo, cb)
    local outputItems = zoneInfo.outputs or {}
    local inputItems = zoneInfo.inputs or {}
    local limitReached = false
    local notEnoughItems = false
    local addItems = {}
    local addAccounts = {}
    local removeItems = {}
    local removeAccounts = {}
    local itemLabels = {}
    local removedLabels = {}

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
                local playerItem = xPlayer.getInventoryItem(outputItem.item)

                if (not xPlayer.canCarryItem(outputItem.item, count)) then
                    limitReached = true
                else
                    table.insert(itemLabels, esxItem.label or playerItem.label or outputItem.item)
                    table.insert(addItems, { item = outputItem.item, count = count })
                end
            end
        elseif (isAccount and not isItem) then
            table.insert(addAccounts, { account = outputItem.account, money = Drugs.CalculatePrice(outputItem.price or 1) })
        end
    end

    for _, inputItem in pairs(inputItems) do
        local isAccount = inputItem.account ~= nil
        local isItem = inputItem.item ~= nil

        if (not isAccount and isItem) then
            local esxItem = Drugs.GetDrugsItem(inputItem.item)
            local count = inputItem.count or 1
            local playerItem = xPlayer.getInventoryItem(inputItem.item)

            if (playerItem ~= nil and playerItem.count < count) then
                notEnoughItems = true
            else
                table.insert(removedLabels, esxItem.label or playerItem.label or inputItem.item)
                table.insert(removeItems, { item = inputItem.item, count = count })
            end
        elseif (isAccount and not isItem) then
            local playerAccount = xPlayer.getAccount(inputItem.item)

            if (playerAccount == nil or playerAccount.money < inputItem.price or 1) then
                notEnoughItems = true
            else
                table.insert(removeAccounts, { account = inputItem.account, money = Drugs.CalculatePrice(inputItem.price or 1) })
            end
        end
    end

    local outputItemString = ''

    for i = 1, #itemLabels, 1 do
        if (i == #itemLabels) then
            outputItemString = outputItemString .. itemLabels[i]
        elseif ((i + 1) == #itemLabels) then
            outputItemString = outputItemString .. itemLabels[i] .. ' ' .. _('and') .. ' '
        else
            outputItemString = outputItemString .. itemLabels[i] .. ','
        end
    end

    if (limitReached) then
        xPlayer.showNotification(_U('limit_transform', outputItemString))
        Drugs.UpdateLastTimeTriggerd(xPlayer.source)

        if (cb ~= nil) then
            cb()
        end
    elseif (notEnoughItems) then
        xPlayer.showNotification(_U('not_enough_transform', zoneInfo.label or ''))
        Drugs.UpdateLastTimeTriggerd(xPlayer.source)

        if (cb ~= nil) then
            cb()
        end
    else
        local itemsReceived = ''
        local itemsRemoved = ''

        for _, addItem in pairs(addItems) do
            itemsReceived = itemsReceived .. '~n~ ~g~>~s~ ' .. Drugs.Formats.NumberToFormattedString(addItem.count) .. 'x ' .. itemLabels[_]

            xPlayer.addInventoryItem(addItem.item, addItem.count)
        end

        for _, addAccount in pairs(addAccounts) do
            itemsReceived = itemsReceived .. '~n~ ~g~>~s~ ' .. Drugs.Formats.NumberToCurrancy(addAccount.money) .. 'x ' .. _U(addAccount.account)

            xPlayer.addAccountMoney(addAccount.account, addAccount.money)
        end

        for _, removeItem in pairs(removeItems) do
            itemsRemoved = itemsRemoved .. '~n~ ~r~>~s~ ' .. Drugs.Formats.NumberToFormattedString(removeItem.count) .. 'x ' .. removedLabels[_]

            xPlayer.removeInventoryItem(removeItem.item, removeItem.count)
        end

        for _, removeAccount in pairs(removeAccounts) do
            itemsRemoved = itemsRemoved .. '~n~ ~r~>~s~ ' .. Drugs.Formats.NumberToCurrancy(removeAccount.money) .. 'x ' .. _U(removeAccount.account)

            xPlayer.removeAccountMoney(removeAccount.account, removeAccount.money)
        end

        xPlayer.showNotification(_U('item_removed', itemsRemoved))
        xPlayer.showNotification(_U('item_transformed', itemsReceived))
        Drugs.UpdateLastTimeTriggerd(xPlayer.source)

        if (cb ~= nil) then
            cb()
        end
    end
end)

Drugs.RegisterZoneLabelGenerator('transform', function(zoneInfo)
    local inputItems = zoneInfo.inputs or {}
    local itemLabels = {}

    for _, inputItem in pairs(inputItems) do
        local isAccount = inputItem.account ~= nil
        local isItem = inputItem.item ~= nil

        if (not isAccount and isItem) then
            local esxItem = Drugs.GetDrugsItem(inputItem.item)

            if (esxItem ~= nil) then
                table.insert(itemLabels, esxItem.label or inputItem.item or 'Unknown')
            else
                table.insert(itemLabels, inputItem.item or 'Unknown')
            end
        elseif (isAccount and not isItem) then
            table.insert(itemLabels, _U(inputItem.account))
        end
    end

    local inputItemString = ''

    for i = 1, #itemLabels, 1 do
        if (i == #itemLabels) then
            inputItemString = inputItemString .. itemLabels[i]
        elseif ((i + 1) == #itemLabels) then
            inputItemString = inputItemString .. itemLabels[i] .. ' ' .. _('and') .. ' '
        else
            inputItemString = inputItemString .. itemLabels[i] .. ', '
        end
    end

    return inputItemString
end)