local QBCore = exports['qb-core']:GetCoreObject()

ox_inventory = exports.ox_inventory
lib.locale()

local isLoggedIn           = LocalPlayer.state['isLoggedIn']
local playerCoords         = nil
local distanceFromTable    = 0
local distanceFromEntrance = 0
local distanceFromExit     = 0


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
    Citizen.CreateThread(function()
        while true do
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
                    QBCore.Functions.DrawText3D(vector3(Config.Processing.locations.table.x, Config.Processing.locations.table.y, Config.Processing.locations.table.z+0.5), '~g~E~w~  -  ' .. locale('do_process'))
                end
                if IsControlJustPressed(0, Keys["E"]) then

                    has_item = ox_inventory:Search('count', 'raw_cannabis')
                    if has_item then
                        local progress_speed = Config.Processing.debug.enabled and 10 or Config.Processing.taskLength*1000
                        QBCore.Functions.Progressbar("pick_weed_plant", locale('packaging_weed'), progress_speed, false, true, {
                            disableMovement = not Config.Processing.debug.enabled,
                            disableCarMovement = not Config.Processing.debug.enabled,
                            disableMouse = false,
                            disableCombat = not Config.Processing.debug.enabled,
                        }, {
                            animDict = "anim@amb@business@weed@weed_sorting_seated@",
                            anim = "sorter_right_sort_v3_sorter02",
                            flags = 16,
                        }, {}, {}, function() -- Done

                            TriggerServerEvent('ar-picking:server:FinishedProcessing')
                            ClearPedTasksImmediately(ped)
                            ClearPedTasks(ped)
                            ResetPedMovementClipset(ped, 0.5)
                            ResetPedWeaponMovementClipset(ped, 0.5)
                            ResetPedStrafeClipset(ped, 0.5)

                        end, function() -- Cancel
                            ClearPedTasksImmediately(ped)
                            ClearPedTasks(ped)
                            ResetPedMovementClipset(ped, 0.5)
                            ResetPedWeaponMovementClipset(ped, 0.5)
                            ResetPedStrafeClipset(ped, 0.5)
                            QBCore.Functions.Notify(locale('cancelled'), "error")
                        end)
                    else
                        QBCore.Functions.Notify(locale('no_item'), "error")
                    end
                end
            end
        end

    end
end)

-------------  Enter / Exit  --------------
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
                    QBCore.Functions.DrawText3D(vector3(outCoords.x, outCoords.y, outCoords.z+0.5), '~g~E~w~  -  ' .. locale('enter'))
                end
                if IsControlJustReleased(0, Keys["E"]) then
                    SetEntityCoords(ped, inCoords.x, inCoords.y, inCoords.z, true)
                    SetEntityHeading(ped, inCoords.w)
                    Wait(1000)
                    DoScreenFadeIn(1000)
                end


            elseif distanceFromEntrance < 1.2 then

                if Config.Processing.showPrompts.exit then
                    QBCore.Functions.DrawText3D(vector3(inCoords.x, inCoords.y, inCoords.z+0.5), '~g~E~w~  - ' .. locale('exit'))
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



