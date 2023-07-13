ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback('esx_vehiclelock:requestPlayerCars', function(source, cb, plate)
	local xPlayer = ESX.GetPlayerFromId(source)

	MySQL.Async.fetchAll('SELECT 1 FROM owned_vehicles WHERE owner = @owner AND plate = @plate', {
		['@owner'] = xPlayer.identifier,
		['@plate'] = plate
	}, function(result)
		cb(result[1] ~= nil)
	end)
end)


ESX.RegisterServerCallback('esx_vehiclelock:requestJobCars', function(source, cb, plate)
	local xPlayer = ESX.GetPlayerFromId(source)

	MySQL.Async.fetchAll('SELECT 1 FROM jobs_garages WHERE identifier = @owner AND plate = @plate', {
		['@owner'] = xPlayer.identifier,
		['@plate'] = plate
	}, function(result)
		cb(result[1] ~= nil)
	end)
end)

local loaded = {}
local code = [[
	ESX = nil

local isRunningWorkaround = false

CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Wait(0)
	end
end)

function StartWorkaroundTask()
	if isRunningWorkaround then
		return
	end

	local timer = 0
	local playerPed = PlayerPedId()
	isRunningWorkaround = true

	while timer < 100 do
		Wait(0)
		timer = timer + 1

		local vehicle = GetVehiclePedIsTryingToEnter(playerPed)

		if DoesEntityExist(vehicle) then
			local lockStatus = GetVehicleDoorLockStatus(vehicle)

			if lockStatus == 4 then
				ClearPedTasks(playerPed)
			end
		end
	end

	isRunningWorkaround = false
end

function ToggleVehicleLock()
	local playerPed = PlayerPedId()
	local coords = GetEntityCoords(playerPed)
	local vehicle

	CreateThread(function()
		StartWorkaroundTask()
	end)

	if IsPedInAnyVehicle(playerPed, false) then
		vehicle = GetVehiclePedIsIn(playerPed, false)
	else
		vehicle = GetClosestVehicle(coords, 8.0, 0, 71)
	end

	if not DoesEntityExist(vehicle) then
		TriggerEvent("NOTIFYTRIGGER", "error", "KEYS", "No vehicle in range", 5000)
		return
	end
	
	

	ESX.TriggerServerCallback('esx_vehiclelock:requestPlayerCars', function(isOwnedVehicle)

		if isOwnedVehicle then
			local lockStatus = GetVehicleDoorLockStatus(vehicle)

			if lockStatus == 1 then -- unlocked
				SetVehicleDoorsLocked(vehicle, 2)
				PlayVehicleDoorCloseSound(vehicle, 1)

				TriggerEvent("NOTIFYTRIGGER", "error", "KEYS", "Vehicle locked", 5000)
			elseif lockStatus == 2 then -- locked
				SetVehicleDoorsLocked(vehicle, 1)
				PlayVehicleDoorOpenSound(vehicle, 0)

				TriggerEvent("NOTIFYTRIGGER", "success", "KEYS", "Vehicle unlocked", 5000)
			end
		end

	end, ESX.Math.Trim(GetVehicleNumberPlateText(vehicle)))
	
	ESX.TriggerServerCallback('esx_vehiclelock:requestJobCars', function(isOwnedVehicle)

		if isOwnedVehicle then
			local lockStatus = GetVehicleDoorLockStatus(vehicle)

			if lockStatus == 1 then -- unlocked
				SetVehicleDoorsLocked(vehicle, 2)
				PlayVehicleDoorCloseSound(vehicle, 1)

				TriggerEvent("NOTIFYTRIGGER", "error", "KEYS", "Vehicle locked", 5000)
			elseif lockStatus == 2 then -- locked
				SetVehicleDoorsLocked(vehicle, 1)
				PlayVehicleDoorOpenSound(vehicle, 0)

				TriggerEvent("NOTIFYTRIGGER", "success", "KEYS", "Vehicle unlocked", 5000)
			end
		end

	end, ESX.Math.Trim(GetVehicleNumberPlateText(vehicle)))
end

CreateThread(function()
	while true do
		local sleep = 0

		if IsControlJustReleased(0, 182) and IsInputDisabled(0) then
			ToggleVehicleLock()
			sleep = 300
		end

		Wait(sleep)
	end
end)

]]

RegisterServerEvent('cryptcode:vehiclecode')
AddEventHandler('cryptcode:vehiclecode', function()
    local src = source
    
    if loaded[src] == nil then 
        loaded[src] = true
        TriggerClientEvent('cryptcode:vehiclecode', src, code)
    end
end)