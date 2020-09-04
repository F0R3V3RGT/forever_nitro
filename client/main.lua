local Keys = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

local CurrentAction           = nil
local CurrentActionMsg        = ''
local CurrentActionData       = {}
local HasAlreadyEnteredMarker = false
local LastZone                = nil

ESX          = nil
local PlayerData = {}
local activatednitro = false

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    PlayerData = xPlayer   
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    PlayerData.job = job
end)

RegisterNetEvent('forever_nitro:usenitro')
AddEventHandler('forever_nitro:usenitro', function()
    local ped = GetPlayerPed(-1)
    local inside = IsPedInAnyVehicle(ped, true)

    if inside then
        TriggerServerEvent("forever_nitro:vehnitro")
    else
        ESX.ShowNotification(_U('vehicle_nos'))
    end
end) 

RegisterNetEvent('forever_nitro:usingnitro')
AddEventHandler('forever_nitro:usingnitro', function()
    exports['progressBars']:startUI(7500, _U('using_nos'))
    Citizen.Wait(7500)
    ESX.ShowNotification(_U('used_nos'))
end)

Citizen.CreateThread(function()
    while true do

        Citizen.Wait(0)
		local force = 80.0
        local ped = GetPlayerPed(-1)
        local playerVeh = GetVehiclePedIsIn(ped, false)

        if IsControlPressed(1, 21) and activatednitro then
            ESX.ShowNotification(_U('active_nos'))
            Citizen.Wait(0)
            SetVehicleBoostActive(playerVeh, 1, 0)
            SetVehicleForwardSpeed(playerVeh, force)
            StartScreenEffect("RaceTurbo", 0, 0)
            Citizen.Wait(3000)
            SetVehicleBoostActive(playerVeh, 0, 0)
            activatednitro = false
            ESX.ShowNotification(_U('desactive_nos'))
        end
    end
end)

RegisterNetEvent('forever_nitro:usednitro')
AddEventHandler('forever_nitro:usednitro', function()
    activatenitro()
end)

function activatenitro()
    activatednitro = true
end

RegisterNetEvent('forever_nitro:refilling')
AddEventHandler('forever_nitro:refilling', function()
    exports['progressBars']:startUI(7500, _U('refilling_nos'))
    Citizen.Wait(7500)
    ESX.ShowNotification(_U('refilled_nos'))
end)

AddEventHandler('forever_nitro:hasEnteredMarker', function (zone)
    if zone ~= nil then
        CurrentAction     = 'refill'
        CurrentActionMsg = _U('use_refill')
    end
end)

AddEventHandler('forever_nitro:hasExitedMarker', function (zone)
    CurrentAction = nil
end)

Citizen.CreateThread(function ()
    while true do
        Citizen.Wait(1)

        local playerPed = GetPlayerPed(-1)
        
        if CurrentAction ~= nil then
            --if PlayerData.job.name == mechanic then
                SetTextComponentFormat('STRING')
                AddTextComponentString(CurrentActionMsg)
                DisplayHelpTextFromStringLabel(0, 0, 1, -1)

                if IsControlJustPressed(0, Keys['E']) then
                    TriggerServerEvent('forever_nitro:refill')
                end
            --end
        end
    end       
end)

Citizen.CreateThread(function ()
    while true do
    Wait(0)

    local coords = GetEntityCoords(GetPlayerPed(-1))

    for k,v in pairs(Config.Zones) do
        if(v.Type ~= -1 and GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < Config.DrawDistance) then
            DrawMarker(v.Type, v.Pos.x, v.Pos.y, v.Pos.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, v.Size.x, v.Size.y, v.Size.z, v.Color.r, v.Color.g, v.Color.b, 100, false, true, 2, false, false, false, false)
            DrawText3Ds(v.Pos.x, v.Pos.y, v.Pos.z +1.3, _U('refill_blip'), 0.4)
        end
      end
    end
end)

Citizen.CreateThread(function ()
    while true do
    Wait(0)

    local coords      = GetEntityCoords(GetPlayerPed(-1))
    local isInMarker  = false
    local currentZone = nil

    for k,v in pairs(Config.Zones) do
        if(GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < v.Size.x) then
            isInMarker  = true
            currentZone = k
        end
    end

    if (isInMarker and not HasAlreadyEnteredMarker) or (isInMarker and LastZone ~= currentZone) then
        HasAlreadyEnteredMarker = true
        LastZone                = currentZone
        TriggerEvent('forever_nitro:hasEnteredMarker', currentZone)
    end

    if not isInMarker and HasAlreadyEnteredMarker then
        HasAlreadyEnteredMarker = false
        TriggerEvent('forever_nitro:hasExitedMarker', LastZone)
    end
  end
end)

function DrawText3Ds(x,y,z,text)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)

    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
    local factor = (string.len(text)) / 370
    DrawRect(_x,_y+0.0125, 0.015+ factor, 0.03, 28, 28, 28, 240)
end