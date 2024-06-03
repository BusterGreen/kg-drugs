local StolenDrugs = {}

local function getAvailableDrugs(source)
    local AvailableDrugs = {}
    local Player = KGCore.Functions.GetPlayer(source)

    if not Player then return nil end

    for k in pairs(Config.DrugsPrice) do
        local item = Player.Functions.GetItemByName(k)

        if item then
            AvailableDrugs[#AvailableDrugs + 1] = {
                item = item.name,
                amount = item.amount,
                label = KGCore.Shared.Items[item.name]['label']
            }
        end
    end
    return table.type(AvailableDrugs) ~= 'empty' and AvailableDrugs or nil
end

KGCore.Functions.CreateCallback('kg-drugs:server:cornerselling:getAvailableDrugs', function(source, cb)
    cb(getAvailableDrugs(source))
end)

RegisterNetEvent('kg-drugs:server:giveStealItems', function(drugType, amount)
    local src = source
    local Player = KGCore.Functions.GetPlayer(src)
    if not Player or StolenDrugs == {} then return end
    for k, v in pairs(StolenDrugs) do
        if drugType == v.item and amount == v.amount then
            exports['kg-inventory']:AddItem(src, drugType, amount, false, false, 'kg-drugs:server:giveStealItems')
            table.remove(StolenDrugs, k)
        end
    end
end)

RegisterNetEvent('kg-drugs:server:sellCornerDrugs', function(drugType, amount, price)
    local src = source
    local Player = KGCore.Functions.GetPlayer(src)
    local availableDrugs = getAvailableDrugs(src)
    if not availableDrugs or not Player then return end
    local item = availableDrugs[drugType].item
    local hasItem = Player.Functions.GetItemByName(item)
    if hasItem.amount >= amount then
        TriggerClientEvent('KGCore:Notify', src, Lang:t('success.offer_accepted'), 'success')
        exports['kg-inventory']:RemoveItem(src, item, amount, false, 'kg-drugs:server:sellCornerDrugs')
        Player.Functions.AddMoney('cash', price, 'kg-drugs:server:sellCornerDrugs')
        TriggerClientEvent('kg-inventory:client:ItemBox', src, KGCore.Shared.Items[item], 'remove')
        TriggerClientEvent('kg-drugs:client:refreshAvailableDrugs', src, getAvailableDrugs(src))
    else
        TriggerClientEvent('kg-drugs:client:cornerselling', src)
    end
end)

RegisterNetEvent('kg-drugs:server:robCornerDrugs', function(drugType, amount)
    local src = source
    local Player = KGCore.Functions.GetPlayer(src)
    local availableDrugs = getAvailableDrugs(src)
    if not availableDrugs or not Player then return end
    local item = availableDrugs[drugType].item
    exports['kg-inventory']:RemoveItem(src, item, amount, false, 'kg-drugs:server:robCornerDrugs')
    table.insert(StolenDrugs, { item = item, amount = amount })
    TriggerClientEvent('kg-inventory:client:ItemBox', src, KGCore.Shared.Items[item], 'remove')
    TriggerClientEvent('kg-drugs:client:refreshAvailableDrugs', src, getAvailableDrugs(src))
end)
