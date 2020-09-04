ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterUsableItem('nitro', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    local nitroquantity = xPlayer.getInventoryItem('nitro').count
    
    if nitroquantity > 0 then
        TriggerClientEvent('forever_nitro:usenitro', source)
    else
        TriggerClientEvent('esx:showNotification', source, _U('donthave_nos'))
    end
end)

RegisterServerEvent('forever_nitro:vehnitro')
AddEventHandler('forever_nitro:vehnitro', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    local src = source
    
    TriggerClientEvent('forever_nitro:usingnitro', src)
    xPlayer.removeInventoryItem('nitro', 1)
    Citizen.Wait(7500)
    TriggerClientEvent('forever_nitro:usednitro', src)
    xPlayer.addInventoryItem('emptynitro', 1)
end)


RegisterServerEvent('forever_nitro:refill')
AddEventHandler('forever_nitro:refill', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    local emptynitroquantity = xPlayer.getInventoryItem('emptynitro').count
    
    if emptynitroquantity > 0 then
        TriggerClientEvent('forever_nitro:refilling', source)
        xPlayer.removeInventoryItem('emptynitro', 1)
        Citizen.Wait(7500)
        xPlayer.addInventoryItem('nitro', 1)
    else
        TriggerClientEvent('esx:showNotification', source, _U('empty_donthave_nos'))
    end
end)
