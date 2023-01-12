
local QBCore = exports['qb-core']:GetCoreObject()
local ox_inventory = exports.ox_inventory

RegisterServerEvent('ar-picking:server:FinishedPicking')
AddEventHandler('ar-picking:server:FinishedPicking', function()
	local src = source
	local Player = QBCore.Functions.GetPlayer(src)

	local Reward = math.random(Config.Field.reward.min, Config.Field.reward.max)

	ox_inventory:AddItem(src, 'raw_cannabis', Reward)

	-- if (Reward > Config.Field.reward.max) then
	TriggerEvent("qb-log:server:CreateLog", "weedfarm", "Added", "black", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) added "..Reward.." raw cannabis to their inventory")
	-- end
end)
