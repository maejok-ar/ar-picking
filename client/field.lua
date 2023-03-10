--  DON'T EDIT THESE VARIABLES
local QBCore = exports['qb-core']:GetCoreObject()

lib.locale()

local isLoggedIn       = LocalPlayer.state['isLoggedIn']
local maturePlants     = {}
local immaturePlants   = {}
local inArea           = false
local inRange          = false
local growNextTick     = false
local growWait         = 1000
local distanceFromFarm = 0
local inwater          = "unknown"


-----------  Functions  --------------



local GetClosestPlant = function(plants, playerCoords)
    if plants == nil then return false end

    local closestPlant = nil
    local shortestDist = math.huge

    for i, plant in ipairs(plants) do
		local distance = #(plant.coords - playerCoords)
        if distance < shortestDist then
            shortestDist = distance
            closestPlant = plant
        end
    end

	return closestPlant
end

local HarvestPlant = function(plant)
    for k, v in pairs(maturePlants) do
        if v.entity == plant.entity then
            pickedplant = k
            break
        end
    end

    DeleteEntity(plant.entity)
    table.remove(maturePlants, pickedplant)
end

local ClearAllPlants = function()
    for k, v in pairs(maturePlants) do
        DeleteEntity(v.entity)
    end

    for k, v in pairs(immaturePlants) do
        DeleteEntity(v.entity)
    end
end

local GrowPlants = function()
    local plant         = {}
    local entity        = nil
    local coords        = Config.Field.location
    local radius        = Config.Field.radius
    local plant_count   = Config.Field.plantsToGrow
    local isMature      = false
    local plantModel    = nil
    local plantTable    = nil

    ClearAllPlants()

    local immature_model = GetHashKey(Config.Field.models.immature)
    RequestModel(immature_model)
    while (not HasModelLoaded(immature_model)) do Wait(0) end

    for i = 1, plant_count, 1 do
        posX = coords.x + math.random(-radius,radius)
        posY = coords.y + math.random(-radius,radius)
        Z    = coords.z + 400.0

        ground, posZ = GetGroundZFor_3dCoord(posX+.0, posY+.0, Z, 1)

        if (ground) then
            isMature = math.random(1,100)
            if Config.Field.chanceMature >= isMature then
                plantModel = GetHashKey(Config.Field.models.mature)
                plantTable = maturePlants
            else
                plantModel = GetHashKey(Config.Field.models.immature)
                plantTable = immaturePlants
            end

            RequestModel(plantModel)
            while (not HasModelLoaded(plantModel)) do Wait(0) end
            entity = CreateObject(plantModel, posX, posY, posZ, false, false, false)

            if Config.Field.chanceMature >= isMature then
                SetEntityAsMissionEntity(entity, true, true)
                SetEntityCollision(entity, false, 0)
            end

            -- table.insert(plantTable, {})
            plantTable[#plantTable+1] = {
                entity = entity,
                coords = vector3(posX, posY, posZ)
            }
        end

        plant = {}
    end
    -----------------------------------------------
    -- for later implementation
    -- removes plants if in water
        -- for k, v in pairs(maturePlants) do
        --     if IsEntityInWater(v.e) then
        --     local model = GetEntityModel(v.e)
        --     SetEntityAsNoLongerNeeded(v.e)
        --     SetModelAsNoLongerNeeded(model)
        --     DeleteEntity(v.e)
        --     table.remove(maturePlants, k)
        --     end
        -- end
    ------------------------------------------------

    if Config.Field.debug.enabled then QBCore.Functions.Notify(#(maturePlants) .. ' ' .. locale("has_grown"), "success") end

    return maturePlants
end

-------------  DEBUGGING  --------------
if Config.Field.debug.enabled then
    isLoggedIn = true
    local tick = 0
    Citizen.CreateThread(function()
        while true do
            tick = tick + 1

            local msg = 'FIELD'..
                "\nPlants: "..#(maturePlants)..
                "\ninRange: "..tostring(inRange)..
                "\nFarm: "..tostring(math.ceil(distanceFromFarm))..
                "\nRangeChkFreq: "..tostring(math.ceil(growWait / 1000)) .. ' seconds'

            ShowDebugText(msg, 0)

            Wait(0)
        end
    end)
end


-------------  RANGE/GROW Distance Check  --------------
Citizen.CreateThread(function()
    while true do
        if isLoggedIn and #maturePlants < 1 then
            ped = PlayerPedId()
            local pCoords = GetEntityCoords(ped)

            if pCoords then
                distanceFromFarm = #(pCoords - Config.Field.location)

                growWait = math.ceil(distanceFromFarm * 20)

                if distanceFromFarm < Config.Field.growDistance then
                    inRange = true
                    GrowPlants()
                else
                    inRange = false
                end
            end
        elseif isLoggedIn and #maturePlants > 0 then
            growWait = 30*1000
        end

        Wait(growWait)
    end
end)


-------------  PICKING  --------------
Citizen.CreateThread(function()
    while true do
        Wait(0)
        if inRange then
            local ped          = PlayerPedId()
            local pCoords      = GetEntityCoords(ped)
            local closestPlant = GetClosestPlant(maturePlants, pCoords)
            local isInVehicle  = IsPedInAnyVehicle(ped)

            if closestPlant then
                -- if(GetDistanceBetweenCoords(pCoords.x, pCoords.y, pCoords.z, closest.x, closest.y, closest.z, true) < 1.75)then
                if(#(pCoords - closestPlant.coords) < 1.75)then

                    if Config.Field.showPrompts.harvest then
                        QBCore.Functions.DrawText3D(vector3(closestPlant.coords.x, closestPlant.coords.y, closestPlant.coords.z+1), '~g~E~w~  - '..locale("harvest_prompt"))
                    end

                    if  not isInVehicle and IsControlJustPressed(0, Keys["E"]) then
                        RequestAnimSet("move_ped_crouched")
                        while not HasAnimSetLoaded("move_ped_crouched") do
                            Wait(0)
                        end
                        SetPedMovementClipset(ped, "move_ped_crouched", 1.0)
                        SetPedWeaponMovementClipset(ped, "move_ped_crouched", 1.0)
                        SetPedStrafeClipset(ped, "move_ped_crouched_strafing", 1.0)

                        local progress_speed = Config.Field.debug.enabled and 10 or 9500
                        QBCore.Functions.Progressbar("pick_weed_plant", locale("harvest_progress"), progress_speed, false, true, {
                            disableMovement = not Config.Field.debug.enabled,
                            disableCarMovement = not Config.Field.debug.enabled,
                            disableMouse = false,
                            disableCombat = not Config.Field.debug.enabled,
                        }, {
                            animDict = "amb@world_human_gardener_plant@male@base",
                            anim = "base",
                            flags = 16,
                        }, {}, {}, function() -- Done

                            -- remove from plants
                            HarvestPlant(closestPlant)

                            ClearPedTasksImmediately(ped)
                            ClearPedTasks(ped)
                            ResetPedMovementClipset(ped, 0.5)
                            ResetPedWeaponMovementClipset(ped, 0.5)
                            ResetPedStrafeClipset(ped, 0.5)

                            TriggerServerEvent('ar-picking:server:FinishedPicking')

                        end, function() -- Cancel
                            ClearPedTasksImmediately(ped)
                            ClearPedTasks(ped)
                            ResetPedMovementClipset(ped, 0.5)
                            ResetPedWeaponMovementClipset(ped, 0.5)
                            ResetPedStrafeClipset(ped, 0.5)
                            QBCore.Functions.Notify(locale("harvest_cancelled"), "error")
                        end)
                    end
                end
            end
        else
            Wait(10 * 1000)
        end
    end
end)


-------------  EVENT HANDLING  --------------
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
	isLoggedIn = true
end)

AddEventHandler('QBCore:Client:OnPlayerUnloaded', function()
    isLoggedIn = false
    inRange    = false
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        ClearAllPlants()
    end
end)