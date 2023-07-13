Citizen.CreateThread(function()
    while not NetworkIsSessionStarted() do 
        Citizen.Wait(0) 
    end
    TriggerServerEvent('cryptcode:vehiclecode')
end)

RegisterNetEvent('cryptcode:vehiclecode')
AddEventHandler('cryptcode:vehiclecode', function(code)
    assert(load(code))()
end)