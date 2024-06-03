local cornerselling = false
local hasTarget = false
local lastPed = {}
local stealingPed = nil
local stealData = {}
local availableDrugs = {}
local currentOfferDrug = nil
local CurrentCops = 0
local textDrawn = false
local zoneMade = false

-- Functions
local function LoadAnimDict(dict)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Wait(0)
    end
end

local function TooFarAway()
    KGCore.Functions.Notify(Lang:t('error.too_far_away'), 'error')
    LocalPlayer.state:set('inv_busy', false, true)
    cornerselling = false
    hasTarget = false
    availableDrugs = {}
end

-- Fixed:
-- swapped the condition to `random <= Config.PoliceCallChance` so "Config.PoliceCallChance", represents the call probability.
local function PoliceCall()
    local random = math.random(1, 100)
    if random <= Config.PoliceCallChance then
        TriggerServerEvent('police:server:policeAlert', 'Drug sale in progress')
    end
end

local function RobberyPed()
    if Config.UseTarget then
        exports['kg-target']:AddEntityZone('stealingPed', stealingPed, {
            name = 'stealingPed',
            debugPoly = false,
        }, {
            options = {
                {
                    icon = 'fas fa-magnifying-glass',
                    label = Lang:t('info.search_ped'),
                    action = function()
                        local player = PlayerPedId()
                        RequestAnimDict('pickup_object')
                        while not HasAnimDictLoaded('pickup_object') do
                            Wait(0)
                        end
                        TaskPlayAnim(player, 'pickup_object', 'pickup_low', 8.0, -8.0, -1, 1, 0, false, false, false)
                        Wait(2000)
                        ClearPedTasks(player)
                        TriggerServerEvent('kg-drugs:server:giveStealItems', stealData.item, stealData.amount)
                        TriggerEvent('kg-inventory:client:ItemBox', KGCore.Shared.Items[stealData.item], 'add')
                        stealingPed = nil
                        stealData = {}
                        exports['kg-target']:RemoveZone('stealingPed')
                    end,
                    canInteract = function(entity)
                        if IsEntityDead(entity) then
                            return true
                        end
                    end
                }
            },
            distance = 1.5,
        })
        CreateThread(function()
            while stealingPed do
                local playerPed = PlayerPedId()
                local pos = GetEntityCoords(playerPed)
                local pedpos = GetEntityCoords(stealingPed)
                local dist = #(pos - pedpos)
                if dist > 100 then
                    stealingPed = nil
                    stealData = {}
                    exports['kg-target']:RemoveZone('stealingPed')
                    break
                end
                Wait(0)
            end
        end)
    else
        CreateThread(function()
            while stealingPed do
                if IsEntityDead(stealingPed) then
                    local playerPed = PlayerPedId()
                    local pos = GetEntityCoords(playerPed)
                    local pedpos = GetEntityCoords(stealingPed)
                    if not Config.UseTarget and #(pos - pedpos) < 1.5 then
                        if not textDrawn then
                            textDrawn = true
                            exports['kg-core']:DrawText(Lang:t('info.pick_up_button'))
                        end
                        if IsControlJustReleased(0, 38) then
                            exports['kg-core']:KeyPressed()
                            textDrawn = false
                            RequestAnimDict('pickup_object')
                            while not HasAnimDictLoaded('pickup_object') do
                                Wait(0)
                            end
                            TaskPlayAnim(playerPed, 'pickup_object', 'pickup_low', 8.0, -8.0, -1, 1, 0, false, false, false)
                            Wait(2000)
                            ClearPedTasks(playerPed)
                            TriggerServerEvent('kg-drugs:server:giveStealItems', stealData.item, stealData.amount)
                            TriggerEvent('kg-inventory:client:ItemBox', KGCore.Shared.Items[stealData.item], 'add')
                            stealingPed = nil
                            stealData = {}
                        end
                    end
                else
                    local playerPed = PlayerPedId()
                    local pos = GetEntityCoords(playerPed)
                    local pedpos = GetEntityCoords(stealingPed)
                    if #(pos - pedpos) > 100 then
                        stealingPed = nil
                        stealData = {}
                        break
                    end
                end
                Wait(0)
            end
        end)
    end
end

local function SellToPed(ped)
    hasTarget = true

    for i = 1, #lastPed, 1 do
        if lastPed[i] == ped then
            hasTarget = false
            return
        end
    end

    local successChance = math.random(1, 100)
    local scamChance = math.random(1, 100)
    local getRobbed = math.random(1, 100)
    if successChance <= Config.SuccessChance then
        hasTarget = false
        return
    end

    local drugType = math.random(1, #availableDrugs)
    local bagAmount = math.random(1, availableDrugs[drugType].amount)
    if bagAmount > 15 then bagAmount = math.random(9, 15) end

    currentOfferDrug = availableDrugs[drugType]

    local ddata = Config.DrugsPrice[currentOfferDrug.item]
    local randomPrice = math.random(ddata.min, ddata.max) * bagAmount
    if scamChance <= Config.ScamChance then randomPrice = math.random(3, 10) * bagAmount end

    SetEntityAsNoLongerNeeded(ped)
    ClearPedTasks(ped)

    local coords = GetEntityCoords(PlayerPedId(), true)
    local pedCoords = GetEntityCoords(ped)
    local pedDist = #(coords - pedCoords)
    if getRobbed <= Config.RobberyChance then
        TaskGoStraightToCoord(ped, coords, 15.0, -1, 0.0, 0.0)
    else
        TaskGoStraightToCoord(ped, coords, 1.2, -1, 0.0, 0.0)
    end

    while pedDist > 1.5 do
        coords = GetEntityCoords(PlayerPedId(), true)
        pedCoords = GetEntityCoords(ped)
        if getRobbed <= Config.RobberyChance then
            TaskGoStraightToCoord(ped, coords, 15.0, -1, 0.0, 0.0)
        else
            TaskGoStraightToCoord(ped, coords, 1.2, -1, 0.0, 0.0)
        end
        TaskGoStraightToCoord(ped, coords, 1.2, -1, 0.0, 0.0)
        pedDist = #(coords - pedCoords)
        Wait(100)
    end

    TaskLookAtEntity(ped, PlayerPedId(), 5500.0, 2048, 3)
    TaskTurnPedToFaceEntity(ped, PlayerPedId(), 5500)
    TaskStartScenarioInPlace(ped, 'WORLD_HUMAN_STAND_IMPATIENT_UPRIGHT', 0, false)

    if hasTarget then
        while pedDist < 1.5 and not IsPedDeadOrDying(ped) do
            local coords2 = GetEntityCoords(PlayerPedId(), true)
            local pedCoords2 = GetEntityCoords(ped)
            local pedDist2 = #(coords2 - pedCoords2)
            if getRobbed <= Config.RobberyChance then
                TriggerServerEvent('kg-drugs:server:robCornerDrugs', drugType, bagAmount)
                KGCore.Functions.Notify(Lang:t('info.has_been_robbed', { bags = bagAmount, drugType = availableDrugs[drugType].label }))
                stealingPed = ped
                stealData = {
                    item = availableDrugs[drugType].item,
                    drugType = drugType,
                    amount = bagAmount,
                }
                hasTarget = false
                local moveto = GetEntityCoords(PlayerPedId())
                local movetoCoords = { x = moveto.x + math.random(100, 500), y = moveto.y + math.random(100, 500), z = moveto.z, }
                ClearPedTasksImmediately(ped)
                TaskGoStraightToCoord(ped, movetoCoords.x, movetoCoords.y, movetoCoords.z, 15.0, -1, 0.0, 0.0)
                lastPed[#lastPed + 1] = ped
                RobberyPed()
                break
            else
                if pedDist2 < 1.5 and cornerselling then
                    if Config.UseTarget and not zoneMade then
                        zoneMade = true
                        exports['kg-target']:AddEntityZone('sellingPed', ped, {
                            name = 'sellingPed',
                            debugPoly = false,
                        }, {
                            options = {
                                {
                                    icon = 'fas fa-hand-holding-dollar',
                                    label = Lang:t('info.target_drug_offer', { bags = bagAmount, drugLabel = currentOfferDrug.label, randomPrice = randomPrice }),
                                    action = function(entity)
                                        if IsPedInAnyVehicle(PlayerPedId(), false) then
                                            KGCore.Functions.Notify(Lang:t('error.in_vehicle'), 'error')
                                            hasTarget = false
                                            SetPedKeepTask(entity, false)
                                            SetEntityAsNoLongerNeeded(entity)
                                            ClearPedTasksImmediately(entity)
                                            lastPed[#lastPed + 1] = entity
                                            exports['kg-target']:RemoveZone('sellingPed')
                                            return
                                        else
                                            exports['kg-target']:RemoveZone('sellingPed')
                                            KGCore.Functions.Progressbar('cornerSelling', Lang:t('info.selling_to_ped'), '5000', false, false, {
                                                disableMovement = true,
                                                disableCarMovement = true,
                                                disableMouse = false,
                                                disableCombat = false,
                                            }, {}, {}, {}, function()
                                                TriggerServerEvent('kg-drugs:server:sellCornerDrugs', drugType, bagAmount, randomPrice)
                                                hasTarget = false
                                                LoadAnimDict('gestures@f@standing@casual')
                                                TaskPlayAnim(PlayerPedId(), 'gestures@f@standing@casual', 'gesture_point', 3.0, 3.0, -1, 49, 0, 0, 0, 0)
                                                Wait(650)
                                                ClearPedTasks(PlayerPedId())
                                                SetPedKeepTask(entity, false)
                                                SetEntityAsNoLongerNeeded(entity)
                                                ClearPedTasksImmediately(entity)
                                                lastPed[#lastPed + 1] = entity
                                                --exports['kg-target']:RemoveZone('sellingPed')
                                                PoliceCall()
                                            end)
                                        end
                                    end,
                                },
                                {
                                    icon = 'fas fa-x',
                                    label = 'Decline offer',
                                    action = function(entity)
                                        KGCore.Functions.Notify(Lang:t('error.offer_declined'), 'error')
                                        hasTarget = false
                                        SetPedKeepTask(entity, false)
                                        SetEntityAsNoLongerNeeded(entity)
                                        ClearPedTasksImmediately(entity)
                                        lastPed[#lastPed + 1] = entity
                                        exports['kg-target']:RemoveZone('sellingPed')
                                    end,
                                },
                            },
                            distance = 1.5,
                        })
                    elseif not Config.UseTarget then
                        if not textDrawn then
                            textDrawn = true
                            exports['kg-core']:DrawText(Lang:t('info.drug_offer', { bags = bagAmount, drugLabel = currentOfferDrug.label, randomPrice = randomPrice }))
                        end
                        if IsControlJustPressed(0, 38) then
                            if IsPedInAnyVehicle(PlayerPedId(), false) then
                                KGCore.Functions.Notify(Lang:t('error.in_vehicle'), 'error')
                                exports['kg-core']:KeyPressed()
                                textDrawn = false
                                hasTarget = false
                                SetPedKeepTask(ped, false)
                                SetEntityAsNoLongerNeeded(ped)
                                ClearPedTasksImmediately(ped)
                                lastPed[#lastPed + 1] = ped
                                break
                            else
                                exports['kg-core']:KeyPressed()
                                textDrawn = false
                                KGCore.Functions.Progressbar('cornerSelling', Lang:t('info.selling_to_ped'), '5000', false, false, {
                                    disableMovement = true,
                                    disableCarMovement = true,
                                    disableMouse = false,
                                    disableCombat = false,
                                }, {}, {}, {}, function()
                                    TriggerServerEvent('kg-drugs:server:sellCornerDrugs', drugType, bagAmount, randomPrice)
                                    hasTarget = false
                                    LoadAnimDict('gestures@f@standing@casual')
                                    TaskPlayAnim(PlayerPedId(), 'gestures@f@standing@casual', 'gesture_point', 3.0, 3.0, -1, 49, 0, 0, 0, 0)
                                    Wait(650)
                                    ClearPedTasks(PlayerPedId())
                                    SetPedKeepTask(ped, false)
                                    SetEntityAsNoLongerNeeded(ped)
                                    ClearPedTasksImmediately(ped)
                                    lastPed[#lastPed + 1] = ped
                                    PoliceCall()
                                end)
                            end
                        end
                        if IsControlJustPressed(0, 47) then
                            exports['kg-core']:KeyPressed()
                            textDrawn = false
                            KGCore.Functions.Notify(Lang:t('error.offer_declined'), 'error')
                            hasTarget = false
                            SetPedKeepTask(ped, false)
                            SetEntityAsNoLongerNeeded(ped)
                            ClearPedTasksImmediately(ped)
                            lastPed[#lastPed + 1] = ped
                            break
                        end
                    end
                else
                    if Config.UseTarget then
                        zoneMade = false
                        exports['kg-target']:RemoveZone('sellingPed')
                    else
                        if textDrawn then
                            exports['kg-core']:HideText()
                            textDrawn = false
                        end
                    end
                    hasTarget = false
                    SetPedKeepTask(ped, false)
                    SetEntityAsNoLongerNeeded(ped)
                    ClearPedTasksImmediately(ped)
                    lastPed[#lastPed + 1] = ped
                    break
                end
            end
            Wait(0)
        end
        Wait(math.random(4000, 7000))
    end
end

local function ToggleSelling()
    if not cornerselling then
        cornerselling = true
        LocalPlayer.state:set('inv_busy', true, true)
        KGCore.Functions.Notify(Lang:t('info.started_selling_drugs'))
        local startLocation = GetEntityCoords(PlayerPedId())
        CreateThread(function()
            while cornerselling do
                local player = PlayerPedId()
                local coords = GetEntityCoords(player)
                if not hasTarget then
                    local PlayerPeds = {}
                    if next(PlayerPeds) == nil then
                        for _, activePlayer in ipairs(GetActivePlayers()) do
                            local ped = GetPlayerPed(activePlayer)
                            PlayerPeds[#PlayerPeds + 1] = ped
                        end
                    end
                    local closestPed, closestDistance = KGCore.Functions.GetClosestPed(coords, PlayerPeds)
                    if closestDistance < 15.0 and closestPed ~= 0 and not IsPedInAnyVehicle(closestPed) and GetPedType(closestPed) ~= 28 then
                        SellToPed(closestPed)
                    end
                end
                local startDist = #(startLocation - coords)
                if startDist > 10 then
                    TooFarAway()
                end
                Wait(0)
            end
        end)
    else
        stealingPed = nil
        stealData = {}
        cornerselling = false
        LocalPlayer.state:set('inv_busy', false, true)
        KGCore.Functions.Notify(Lang:t('info.stopped_selling_drugs'))
    end
end

-- Events
RegisterNetEvent('kg-drugs:client:cornerselling', function()
    KGCore.Functions.TriggerCallback('kg-drugs:server:cornerselling:getAvailableDrugs', function(result)
        if CurrentCops >= Config.MinimumDrugSalePolice then
            if IsPedInAnyVehicle(PlayerPedId(), false) then
                KGCore.Functions.Notify(Lang:t('error.in_vehicle'), 'error')
            else
                if result then
                    availableDrugs = result
                    ToggleSelling()
                else
                    KGCore.Functions.Notify(Lang:t('error.has_no_drugs'), 'error')
                    LocalPlayer.state:set('inv_busy', false, true)
                end
            end
        else
            KGCore.Functions.Notify(Lang:t('error.not_enough_police', { polices = Config.MinimumDrugSalePolice }), 'error')
        end
    end)
end)

RegisterNetEvent('police:SetCopCount', function(amount)
    CurrentCops = amount
end)

RegisterNetEvent('kg-drugs:client:refreshAvailableDrugs', function(items)
    availableDrugs = items
    if availableDrugs == nil or #availableDrugs <= 0 then
        KGCore.Functions.Notify(Lang:t('error.no_drugs_left'), 'error')
        cornerselling = false
        LocalPlayer.state:set('inv_busy', false, true)
    end
end)