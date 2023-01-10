
local QBCore = exports['qb-core']:GetCoreObject()

RegisterServerEvent('ar-weed:server:FinishedPicking')
AddEventHandler('ar-weed:server:FinishedPicking', function()
	local src = source
	local Player = QBCore.Functions.GetPlayer(src)

	local Reward = math.random(Config.Field.reward.min, Config.Field.reward.max)

	Player.Functions.AddItem("raw_cannabis", Reward)
	for i = Reward, 1, -1 do
		TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['raw_cannabis'], "add")
	end

	-- if (Reward > Config.Field.reward.max) then
		TriggerEvent("qb-log:server:CreateLog", "weedfarm", "Added", "black", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) added "..Reward.." raw cannabis to their inventory")
	-- end
end)
