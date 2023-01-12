local QBCore = exports['qb-core']:GetCoreObject()
local ox_inventory = exports.ox_inventory

RegisterServerEvent('ar-picking:server:FinishedProcessing')
AddEventHandler('ar-picking:server:FinishedProcessing', function()
	local src = source
	local Player = QBCore.Functions.GetPlayer(src)

	ox_inventory:RemoveItem(src, 'raw_cannabis', 1)
	ox_inventory:AddItem(src, 'weed_skunk', 1)

    TriggerEvent("qb-log:server:CreateLog", "weedfarm", "Added", "black", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) added 1 bag(s) of weed to their inventory")
end)
