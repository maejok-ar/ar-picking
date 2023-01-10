local QBCore = exports['qb-core']:GetCoreObject()
local maturePlants     = {}
local immaturePlants   = {}
local isLoggedIn       = false
local inArea           = false
local inRange          = false
local growNextTick     = false
local growWait         = 1000
local distanceFromFarm = 0
local inwater          = "unknown"


-----------  Functions  --------------
local ClearAllPlants = function()
    for k, v in pairs(maturePlants) do
        local entitymodel = GetEntityModel(v.entity)
        SetEntityAsNoLongerNeeded(entitymodel)
        SetModelAsNoLongerNeeded(entitymodel)
        DeleteEntity(v.entity)
    end

    for k, v in pairs(immaturePlants) do
        local entitymodel = GetEntityModel(v.entity)
        SetEntityAsNoLongerNeeded(entitymodel)
        SetModelAsNoLongerNeeded(entitymodel)
        DeleteEntity(v.entity)
    end
end

local GrowPlants = function()
    if Config.Field.debug.enabled then QBCore.Functions.Notify("Weed Grown", "success") end
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
    while (not HasModelLoaded(immature_model)) do Citizen.Wait(1) end

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
            while (not HasModelLoaded(plantModel)) do Citizen.Wait(1) end
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

    return maturePlants
end

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

            Citizen.Wait(10)
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
        Citizen.Wait(7)
        if inRange then
            local ped          = PlayerPedId()
            local pCoords      = GetEntityCoords(ped)
            local closestPlant = GetClosestPlant(maturePlants, pCoords)
            local isInVehicle  = IsPedInAnyVehicle(ped)

            if closestPlant then
                -- if(GetDistanceBetweenCoords(pCoords.x, pCoords.y, pCoords.z, closest.x, closest.y, closest.z, true) < 1.75)then
                if(#(pCoords - closestPlant.coords) < 1.75)then

                    if Config.Field.showPrompts.harvest then
                        QBCore.Functions.DrawText3D(closestPlant.x, closestPlant.y, closestPlant.z+1, '~g~E~w~  -  Harvest')
                    end

                    if  not isInVehicle and IsControlJustPressed(0, Keys["E"]) then
                        RequestAnimSet("move_ped_crouched")
                        while not HasAnimSetLoaded("move_ped_crouched") do
                            Citizen.Wait(0)
                        end
                        SetPedMovementClipset(ped, "move_ped_crouched", 1.0)
                        SetPedWeaponMovementClipset(ped, "move_ped_crouched", 1.0)
                        SetPedStrafeClipset(ped, "move_ped_crouched_strafing", 1.0)

                        QBCore.Functions.Progressbar("pick_weed_plant", "Harvesting...", 9500, false, true, {
                            disableMovement = true,
                            disableCarMovement = true,
                            disableMouse = false,
                            disableCombat = true,
                        }, {
                            animDict = "amb@world_human_gardener_plant@male@base",
                            anim = "base",
                            flags = 16,
                        }, {}, {}, function() -- Done

                            -- remove from plants
                            local pickedplant = {}
                            for k, v in pairs(maturePlants) do
                                if v.entity == closestPlant.entity then
                                    pickedplant = k
                                    break
                                end
                            end

                            local entitymodel = GetEntityModel(closestPlant.entity)
                            SetEntityAsNoLongerNeeded(entitymodel)
                            SetModelAsNoLongerNeeded(entitymodel)
                            DeleteEntity(closestPlant.entity)

                            ResetPedMovementClipset(ped, 0.5)
                            ResetPedWeaponMovementClipset(ped, 0.5)
                            ResetPedStrafeClipset(ped, 0.5)

                            table.remove(maturePlants, pickedplant)

                            TriggerServerEvent('ar-weed:server:FinishedPicking')

                        end, function() -- Cancel
                            ClearPedTasksImmediately(ped)
                            ClearPedTasks(ped)
                            ResetPedMovementClipset(ped, 0.5)
                            ResetPedWeaponMovementClipset(ped, 0.5)
                            ResetPedStrafeClipset(ped, 0.5)
                            QBCore.Functions.Notify("Canceled..", "error")
                        end)
                    end
                end
            end
        else
            Citizen.Wait(10 * 1000)
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