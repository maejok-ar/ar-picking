local QBCore = exports['qb-core']:GetCoreObject()

RegisterServerEvent('ar-weed:server:FinishedProcessing')
AddEventHandler('ar-weed:server:FinishedProcessing', function()
	local src = source
	local Player = QBCore.Functions.GetPlayer(src)
    Player.Functions.RemoveItem("raw_cannabis", 1)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['raw_cannabis'], "remove")
    Player.Functions.AddItem("weed_skunk", 1)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['weed_skunk'], "add")

    TriggerEvent("qb-log:server:CreateLog", "weedfarm", "Added", "black", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) added 1 bag(s) of weed to their inventory")
end)
