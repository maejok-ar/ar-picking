
local QBCore = exports['qb-core']:GetCoreObject()
local isLoggedIn             = false
local playerCoords           = nil
local distanceFromTable = 0
local distanceFromEntrance   = 0
local distanceFromExit       = 0


-------------  FUNCTIONS  --------------
local TeleportToInterior = function (x, y, z, h)
    Citizen.CreateThread(function()
        SetEntityCoords(PlayerPedId(), x, y, z, 0, 0, 0, false)
        SetEntityHeading(PlayerPedId(), h)

        Citizen.Wait(100)

        DoScreenFadeIn(1000)
    end)
end


-------------  DEBUGGING  --------------
if Config.Processing.debug.enabled then
    isLoggedIn = true
    local tick = 0
    Citizen.CreateThread(function()
        while true do
            tick = tick + 1
            local player = PlayerPedId()
            local coords = GetEntityCoords(player)
            msg = 'PROCESSING'..
                "\nEntrance: "..tostring(math.ceil(distanceFromEntrance))..
                "\nExit: "..tostring(math.ceil(distanceFromExit))..
                "\nTable: "..tostring(math.ceil(distanceFromTable))

            ShowDebugText(msg, 1)

            Citizen.Wait(5)
        end
    end)
end


-------------  PROCESSING TABLE  --------------
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(3)

        if isLoggedIn then
            ped = PlayerPedId()
            playerCoords = GetEntityCoords(ped)

            distanceFromTable = #(playerCoords - Config.Processing.locations.table)

            if distanceFromTable < 1.8 then
                if Config.Processing.showPrompts.process then
                    QBCore.Functions.DrawText3D(Config.Processing.locations.table.x, Config.Processing.locations.table.y, Config.Processing.locations.table.z+0.5, '~g~E~w~  -   Process Cannabis')
                end
                if IsControlJustPressed(0, Keys["E"]) then
                    QBCore.Functions.TriggerCallback('QBCore:Functions:HasItem', function(hasItem)
                        if hasItem then
                            QBCore.Functions.Progressbar("pick_weed_plant", "Breaking cannabis up into bags", Config.Processing.taskLength*1000, false, true, {
                                disableMovement = true,
                                disableCarMovement = true,
                                disableMouse = false,
                                disableCombat = true,
                            }, {
                                animDict = "anim@amb@business@weed@weed_sorting_seated@",
                                anim = "sorter_right_sort_v3_sorter02",
                                flags = 16,
                            }, {}, {}, function() -- Done

                                TriggerServerEvent('ar-weed:server:FinishedProcessing')
                                ClearPedTasksImmediately(ped)
                                ClearPedTasks(ped)

                            end, function() -- Cancel
                                ClearPedTasksImmediately(ped)
                                ClearPedTasks(ped)
                                ResetPedMovementClipset(ped, 0.5)
                                ResetPedWeaponMovementClipset(ped, 0.5)
                                ResetPedStrafeClipset(ped, 0.5)
                                QBCore.Functions.Notify("Canceled..", "error")
                            end)
                        else
                            QBCore.Functions.Notify("You don't have the necessary items!", "error")
                        end
                    end, "raw_cannabis")
                end
            end
        end

    end
end)

-------------  PROCESSING TABLE  --------------
Citizen.CreateThread(function()
    local sleep = 1000
    while true do
        if isLoggedIn then

            ped = PlayerPedId()
            playerCoords = GetEntityCoords(ped)

            inCoords = Config.Processing.locations.inside
            outCoords = Config.Processing.locations.outside

            distanceFromEntrance = #(playerCoords - vector3(inCoords.x, inCoords.y, inCoords.z))
            distanceFromExit = #(playerCoords - vector3(outCoords.x, outCoords.y, outCoords.z))

            if (distanceFromEntrance <= 5) or (distanceFromExit <= 5) then
                sleep = 3
            else
                if distanceFromEntrance > distanceFromExit then
                    sleep = math.ceil(distanceFromExit * 60)
                else
                    sleep = math.ceil(distanceFromEntrance * 60)
                end
            end

            if distanceFromExit < 1.2 then
                if Config.Processing.showPrompts.enter then
                    QBCore.Functions.DrawText3D(outCoords.x, outCoords.y, outCoords.z+0.5, '~g~E~w~  -  Enter')
                end
                if IsControlJustReleased(0, Keys["E"]) then
                    SetEntityCoords(ped, inCoords.x, inCoords.y, inCoords.z, true)
                    SetEntityHeading(ped, inCoords.w)
                    Wait(1000)
                    DoScreenFadeIn(1000)
                end


            elseif distanceFromEntrance < 1.2 then

                if Config.Processing.showPrompts.exit then
                    QBCore.Functions.DrawText3D(inCoords.x, inCoords.y, inCoords.z+0.5, '~g~E~w~  -  Exit')
                end
                if IsControlJustReleased(0, Keys["E"]) then
                    SetEntityCoords(ped, outCoords.x, outCoords.y, outCoords.z, true)
                    SetEntityHeading(ped, outCoords.w)
                    Wait(1000)
                    DoScreenFadeIn(1000)
                end
            end


        end
        Citizen.Wait(sleep)
    end
end)


-------------  EVENT HANDLING  --------------
RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
	isLoggedIn = true
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnloaded')
AddEventHandler('QBCore:Client:OnPlayerUnloaded', function()
    isLoggedIn = false
end)



