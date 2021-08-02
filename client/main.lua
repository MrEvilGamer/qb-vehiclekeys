local Keys = {
    ["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
    ["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
    ["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
    ["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
    ["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
    ["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
    ["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
    ["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
}

local HasKey = false
local LastVehicle = nil
local IsHotwiring = false
local IsRobbing = false
local isLoggedIn = true
local requiredItemsShowed = false

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5)
        if IsPedInAnyVehicle(GetPlayerPed(-1), false) and GetPedInVehicleSeat(GetVehiclePedIsIn(GetPlayerPed(-1), true), -1) == GetPlayerPed(-1) and QBCore ~= nil then
            local plate = GetVehicleNumberPlateText(GetVehiclePedIsIn(GetPlayerPed(-1), true))
            if LastVehicle ~= GetVehiclePedIsIn(GetPlayerPed(-1), false) then
                QBCore.Functions.TriggerCallback('vehiclekeys:CheckHasKey', function(result)
                    if result then
                        HasKey = true
                        SetVehicleEngineOn(veh, true, false, true)
                    else
                        HasKey = false
                        SetVehicleEngineOn(veh, false, false, true)
                    end
                    LastVehicle = GetVehiclePedIsIn(GetPlayerPed(-1), false)
                end, plate)
            end
        end

        if not HasKey and IsPedInAnyVehicle(GetPlayerPed(-1), false) and GetPedInVehicleSeat(GetVehiclePedIsIn(GetPlayerPed(-1), false), -1) == GetPlayerPed(-1) and QBCore ~= nil and not IsHotwiring then
            local veh = GetVehiclePedIsIn(GetPlayerPed(-1), false)
            SetVehicleEngineOn(veh, false, false, true)
            local requiredItems = {
                [1] = {name = QBCore.Shared.Items["lockpick"]["name"], image = QBCore.Shared.Items["lockpick"]["image"]},
                [2] = {name = QBCore.Shared.Items["advancedlockpick"]["name"], image = QBCore.Shared.Items["advancedlockpick"]["image"]},
            }

            local veh = GetVehiclePedIsIn(GetPlayerPed(-1), false)
            local vehpos = GetOffsetFromEntityInWorldCoords(veh, 0, 1.5, 0.5)
            QBCore.Functions.DrawText3D(vehpos.x, vehpos.y, vehpos.z, "~g~H~w~ - Hotwire")
            SetVehicleEngineOn(veh, false, false, true)

            if IsControlJustPressed(0, Keys["H"]) then
                Hotwire()
            end
            if not requiredItemsShowed then
                requiredItemsShowed = true
                TriggerEvent('inventory:client:requiredItems', requiredItems, true)
            end
        else
            Citizen.Wait(10)
            if requiredItemsShowed then
                requiredItemsShowed = false
                TriggerEvent('inventory:client:requiredItems', requiredItems, false)
            end
        end

        if IsControlJustPressed(1, Keys["L"]) then
            LockVehicle()
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(7)
        if not IsRobbing and isLoggedIn and QBCore ~= nil then
            if GetVehiclePedIsTryingToEnter(GetPlayerPed(-1)) ~= nil and GetVehiclePedIsTryingToEnter(GetPlayerPed(-1)) ~= 0 then
                local vehicle = GetVehiclePedIsTryingToEnter(GetPlayerPed(-1))
                local driver = GetPedInVehicleSeat(vehicle, -1)
                if driver ~= 0 and not IsPedAPlayer(driver) then
                    if IsEntityDead(driver) then
                        IsRobbing = true
                        QBCore.Functions.Progressbar("rob_keys", "Taking keys.", 3000, false, true, {}, {}, {}, {}, function() -- Done
                            TriggerEvent("vehiclekeys:client:SetOwner", GetVehicleNumberPlateText(vehicle))
                            HasKey = true
                            IsRobbing = false
                        end)
                    end
                end
            end

            --[[if QBCore.Functions.GetPlayerData().job.name ~= "police" then
                local aiming, target = GetEntityPlayerIsFreeAimingAt(PlayerId())
                if aiming and (target ~= nil and target ~= 0) then
                    if DoesEntityExist(target) and not IsPedAPlayer(target) then
                        if IsPedInAnyVehicle(target, false) and not IsPedInAnyVehicle(GetPlayerPed(-1), false ) then
                            if not IsBlacklistedWeapon() then
                                local pos = GetEntityCoords(GetPlayerPed(-1), true)
                                local targetpos = GetEntityCoords(target, true)
                                local vehicle = GetVehiclePedIsIn(target, true)
                                if GetDistanceBetweenCoords(pos.x, pos.y, pos.z, targetpos.x, targetpos.y, targetpos.z, true) < 13.0 then
                                    RobVehicle(target)
                                end
                            end
                        end
                    end
                end
            end]]--
        end
    end
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    isLoggedIn = true
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload')
AddEventHandler('QBCore:Client:OnPlayerUnload', function()
    isLoggedIn = false
end)

RegisterNetEvent('vehiclekeys:client:SetOwner')
AddEventHandler('vehiclekeys:client:SetOwner', function(plate)
    local VehPlate = plate
    if VehPlate == nil then
        VehPlate = GetVehicleNumberPlateText(GetVehiclePedIsIn(GetPlayerPed(-1), true))
    end
    TriggerServerEvent('vehiclekeys:server:SetVehicleOwner', VehPlate)
    if IsPedInAnyVehicle(GetPlayerPed(-1)) and plate == GetVehicleNumberPlateText(GetVehiclePedIsIn(GetPlayerPed(-1), true)) then
        SetVehicleEngineOn(GetVehiclePedIsIn(GetPlayerPed(-1), true), true, false, true)
    end
    HasKey = true
    --QBCore.Functions.Notify('You picked the keys of the vehicle', 'success', 3500)
end)

RegisterNetEvent('vehiclekeys:client:GiveKeys')
AddEventHandler('vehiclekeys:client:GiveKeys', function(target)
    local plate = GetVehicleNumberPlateText(GetVehiclePedIsIn(GetPlayerPed(-1), true))
    TriggerServerEvent('vehiclekeys:server:GiveVehicleKeys', plate, target)
end)

RegisterNetEvent('vehiclekeys:client:ToggleEngine')
AddEventHandler('vehiclekeys:client:ToggleEngine', function()
    local EngineOn = IsVehicleEngineOn(GetVehiclePedIsIn(GetPlayerPed(-1)))
    local veh = GetVehiclePedIsIn(GetPlayerPed(-1), true)
    if HasKey then
        if EngineOn then
            SetVehicleEngineOn(veh, false, false, true)
        else
            SetVehicleEngineOn(veh, true, false, true)
        end
    end
end)

RegisterNetEvent('lockpicks:UseLockpick')
AddEventHandler('lockpicks:UseLockpick', function(isAdvanced)
    if (IsPedInAnyVehicle(GetPlayerPed(-1))) then
        if not HasKey then
            LockpickIgnition(isAdvanced)
        end
    else
        LockpickDoor(isAdvanced)
    end
end)

function RobVehicle(target)
    IsRobbing = true
    Citizen.CreateThread(function()
        while IsRobbing do
            local RandWait = math.random(10000, 15000)
            loadAnimDict("random@mugging3")

            TaskLeaveVehicle(target, GetVehiclePedIsIn(target, true), 256)
            Citizen.Wait(1000)
            ClearPedTasksImmediately(target)

            TaskStandStill(target, RandWait)
            TaskHandsUp(target, RandWait, GetPlayerPed(-1), 0, false)

            Citizen.Wait(RandWait)

            --TaskReactAndFleePed(target, GetPlayerPed(-1))
            IsRobbing = false
        end
    end)
end

function LockVehicle()
    local veh = QBCore.Functions.GetClosestVehicle()
    local coordA = GetEntityCoords(GetPlayerPed(-1), true)
    local coordB = GetOffsetFromEntityInWorldCoords(GetPlayerPed(-1), 0.0, 255.0, 0.0)
    local veh = GetClosestVehicleInDirection(coordA, coordB)
    local pos = GetEntityCoords(GetPlayerPed(-1), true)
    if IsPedInAnyVehicle(GetPlayerPed(-1)) then
        veh = GetVehiclePedIsIn(GetPlayerPed(-1))
    end
    local plate = GetVehicleNumberPlateText(veh)
    local vehpos = GetEntityCoords(veh, false)
    if veh ~= nil and GetDistanceBetweenCoords(pos.x, pos.y, pos.z, vehpos.x, vehpos.y, vehpos.z, true) < 7.5 then
        QBCore.Functions.TriggerCallback('vehiclekeys:CheckHasKey', function(result)
            if result then
                if HasKey then
                    local vehLockStatus = GetVehicleDoorLockStatus(veh)
                    loadAnimDict("anim@mp_player_intmenu@key_fob@")
                    TaskPlayAnim(GetPlayerPed(-1), 'anim@mp_player_intmenu@key_fob@', 'fob_click' ,3.0, 3.0, -1, 49, 0, false, false, false)
        
                    if vehLockStatus == 1 then
                        Citizen.Wait(750)
                        ClearPedTasks(GetPlayerPed(-1))
                        TriggerServerEvent("InteractSound_SV:PlayWithinDistance", 8, "lock", 0.3)
                        SetVehicleDoorsLocked(veh, 2)
                        if(GetVehicleDoorLockStatus(veh) == 2)then
                            QBCore.Functions.Notify("Vehicle locked!")
                        else
                            QBCore.Functions.Notify("Something went wrong whit the locking system!")
                        end
                    else
                        Citizen.Wait(750)
                        ClearPedTasks(GetPlayerPed(-1))
                        TriggerServerEvent("InteractSound_SV:PlayWithinDistance", 8, "unlock", 0.3)
                        SetVehicleDoorsLocked(veh, 1)
                        if(GetVehicleDoorLockStatus(veh) == 1)then
                            QBCore.Functions.Notify("Vehicle unlocked!")
                        else
                            QBCore.Functions.Notify("Something went wrong whit the locking system!")
                        end
                    end
        
                    if not IsPedInAnyVehicle(GetPlayerPed(-1)) then
                        SetVehicleInteriorlight(veh, true)
                        SetVehicleIndicatorLights(veh, 0, true)
                        SetVehicleIndicatorLights(veh, 1, true)
                        Citizen.Wait(450)
                        SetVehicleIndicatorLights(veh, 0, false)
                        SetVehicleIndicatorLights(veh, 1, false)
                        Citizen.Wait(450)
                        SetVehicleInteriorlight(veh, true)
                        SetVehicleIndicatorLights(veh, 0, true)
                        SetVehicleIndicatorLights(veh, 1, true)
                        Citizen.Wait(450)
                        SetVehicleInteriorlight(veh, false)
                        SetVehicleIndicatorLights(veh, 0, false)
                        SetVehicleIndicatorLights(veh, 1, false)
                    end
                end
            else
                QBCore.Functions.Notify('You dont have the keys of the vehicle..', 'error')
            end
        end, plate)
    end
end

local openingDoor = false
function LockpickDoor(isAdvanced)
    local vehicle = QBCore.Functions.GetClosestVehicle()
    if vehicle ~= nil and vehicle ~= 0 then
        local vehpos = GetEntityCoords(vehicle)
        local pos = GetEntityCoords(GetPlayerPed(-1))
        if GetDistanceBetweenCoords(pos.x, pos.y, pos.z, vehpos.x, vehpos.y, vehpos.z, true) < 1.5 then
            local vehLockStatus = GetVehicleDoorLockStatus(vehicle)
            if (vehLockStatus > 1) then
                local lockpickTime = math.random(15000, 30000)
                if isAdvanced then
                    lockpickTime = math.ceil(lockpickTime*0.5)
                end
                LockpickDoorAnim(lockpickTime)
                PoliceCall()
                IsHotwiring = true
                SetVehicleAlarm(vehicle, true)
                SetVehicleAlarmTimeLeft(vehicle, lockpickTime)
                QBCore.Functions.Progressbar("lockpick_vehicledoor", "breaking the door open.", lockpickTime, false, true, {
                    disableMovement = true,
                    disableCarMovement = true,
                    disableMouse = false,
                    disableCombat = true,
                }, {}, {}, {}, function() -- Done
                    openingDoor = false
                    StopAnimTask(GetPlayerPed(-1), "veh@break_in@0h@p_m_one@", "low_force_entry_ds", 1.0)
                    IsHotwiring = false
                    if math.random(1, 100) <= 90 then
                        QBCore.Functions.Notify("Door open!")
                        TriggerServerEvent("InteractSound_SV:PlayWithinDistance", 5, "unlock", 0.3)
                        SetVehicleDoorsLocked(vehicle, 0)
                        SetVehicleDoorsLockedForAllPlayers(vehicle, false)
                    else
                        QBCore.Functions.Notify("Failed!", "error")
                    end
                end, function() -- Cancel
                    openingDoor = false
                    StopAnimTask(GetPlayerPed(-1), "veh@break_in@0h@p_m_one@", "low_force_entry_ds", 1.0)
                    QBCore.Functions.Notify("Failed!", "error")
                    IsHotwiring = false
                end)
            end
        end
    end
end

function LockpickDoorAnim(time)
    time = time / 1000
    loadAnimDict("veh@break_in@0h@p_m_one@")
    TaskPlayAnim(GetPlayerPed(-1), "veh@break_in@0h@p_m_one@", "low_force_entry_ds" ,3.0, 3.0, -1, 16, 0, false, false, false)
    openingDoor = true
    Citizen.CreateThread(function()
        while openingDoor do
            TaskPlayAnim(PlayerPedId(), "veh@break_in@0h@p_m_one@", "low_force_entry_ds", 3.0, 3.0, -1, 16, 0, 0, 0, 0)
            Citizen.Wait(1000)
            time = time - 1
            if time <= 0 then
                openingDoor = false
                StopAnimTask(GetPlayerPed(-1), "veh@break_in@0h@p_m_one@", "low_force_entry_ds", 1.0)
            end
        end
    end)
end

function LockpickIgnition(isAdvanced)
    if not HasKey then 
        local vehicle = GetVehiclePedIsIn(GetPlayerPed(-1), true)
        IsHotwiring = true
        PoliceCall()
        local lockpickTime = math.random(30000, 40000)
        if isAdvanced then
            lockpickTime = math.ceil(lockpickTime*0.5)
        end
        QBCore.Functions.Progressbar("lockpick_ignition", "Lockicking..", lockpickTime, false, true, {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        }, {
            animDict = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@",
            anim = "machinic_loop_mechandplayer",
            flags = 16,
        }, {}, {}, function() -- Done
            StopAnimTask(GetPlayerPed(-1), "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", "machinic_loop_mechandplayer", 1.0)
            IsHotwiring = false
            if math.random(1, 100) <= 65 then
                QBCore.Functions.Notify("Lockpick successful!")
                HasKey = true
                TriggerEvent("vehiclekeys:client:SetOwner", GetVehicleNumberPlateText(vehicle))
            else
                QBCore.Functions.Notify("Canceled!", "error")
            end
        end, function() -- Cancel
            StopAnimTask(GetPlayerPed(-1), "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", "machinic_loop_mechandplayer", 1.0)
            HasKey = false
            SetVehicleEngineOn(veh, false, false, true)
            QBCore.Functions.Notify("Lockpick Canceled!", "error")
            IsHotwiring = false
        end)
    end
end

function Hotwire()
    if not HasKey then 
        local vehicle = GetVehiclePedIsIn(GetPlayerPed(-1), true)
        IsHotwiring = true
        local hotwireTime = math.random(20000, 40000)
        SetVehicleAlarm(vehicle, true)
        SetVehicleAlarmTimeLeft(vehicle, hotwireTime)
        PoliceCall()
        QBCore.Functions.Progressbar("hotwire_vehicle", "Engaging the ignition switch", hotwireTime, false, true, {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        }, {
            animDict = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@",
            anim = "machinic_loop_mechandplayer",
            flags = 16,
        }, {}, {}, function() -- Done
            StopAnimTask(GetPlayerPed(-1), "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", "machinic_loop_mechandplayer", 1.0)
            if (math.random(0, 100) < 80) then
                HasKey = true
                QBCore.Functions.Notify("Hotwire succeeded!")
            else
                HasKey = false
                SetVehicleEngineOn(veh, false, false, true)
                QBCore.Functions.Notify("Hotwire Canceled!", "error")
            end
            IsHotwiring = false
        end, function() -- Cancel
            StopAnimTask(GetPlayerPed(-1), "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", "machinic_loop_mechandplayer", 1.0)
            HasKey = false
            SetVehicleEngineOn(veh, false, false, true)
            QBCore.Functions.Notify("Hotwire Canceled!", "error")
            IsHotwiring = false
        end)
    end
end

function PoliceCall()
    local pos = GetEntityCoords(GetPlayerPed(-1))
    local chance = 25
    if GetClockHours() >= 1 and GetClockHours() <= 6 then
        chance = 3
    end
    if math.random(1, 100) <= chance then
        local closestPed = GetNearbyPed()
        if closestPed ~= nil then
            local msg = ""
            local s1, s2 = Citizen.InvokeNative(0x2EB41072B4C1E4C0, pos.x, pos.y, pos.z, Citizen.PointerValueInt(), Citizen.PointerValueInt())
            local streetLabel = GetStreetNameFromHashKey(s1)
            local street2 = GetStreetNameFromHashKey(s2)
            if street2 ~= nil and street2 ~= "" then 
                streetLabel = streetLabel .. " " .. street2
            end
            if IsPedInAnyVehicle(GetPlayerPed(-1)) then
                local vehicle = GetVehiclePedIsIn(GetPlayerPed(-1), false)
                local modelName = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))
                local modelPlate = GetVehicleNumberPlateText(vehicle)
                msg = "Vehicle theft attempt at " ..streetLabel.. ". Vehicle: " .. modelName .. ", Plate: " .. modelPlate
            else
                local vehicle = QBCore.Functions.GetClosestVehicle()
                local modelName = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))
                local modelPlate = GetVehicleNumberPlateText(vehicle)
                msg = "Vehicle theft attempt at " ..streetLabel.. ". Vehicle: " .. modelName .. ", Plate: " .. modelPlate
            end
            TriggerServerEvent("police:server:VehicleCall", pos, msg)
        end
    end
end

function GetClosestVehicleInDirection(coordFrom, coordTo)
	local offset = 0
	local rayHandle
	local vehicle

	for i = 0, 100 do
		rayHandle = CastRayPointToPoint(coordFrom.x, coordFrom.y, coordFrom.z, coordTo.x, coordTo.y, coordTo.z + offset, 10, GetPlayerPed(-1), 0)	
		a, b, c, d, vehicle = GetRaycastResult(rayHandle)
		
		offset = offset - 1

		if vehicle ~= 0 then break end
	end
	
	local distance = Vdist2(coordFrom, GetEntityCoords(vehicle))
	
	if distance > 250 then vehicle = nil end

    return vehicle ~= nil and vehicle or 0
end

function GetNearbyPed()
	local retval = nil
	local PlayerPeds = {}
    for _, player in ipairs(GetActivePlayers()) do
        local ped = GetPlayerPed(player)
        table.insert(PlayerPeds, ped)
    end
    local player = GetPlayerPed(-1)
    local coords = GetEntityCoords(player)
	local closestPed, closestDistance = QBCore.Functions.GetClosestPed(coords, PlayerPeds)
	if not IsEntityDead(closestPed) and closestDistance < 30.0 then
		retval = closestPed
	end
	return retval
end

function IsBlacklistedWeapon()
    local weapon = GetSelectedPedWeapon(GetPlayerPed(-1))
    if weapon ~= nil then
        for _, v in pairs(Config.NoRobWeapons) do
            if weapon == GetHashKey(v) then
                return true
            end
        end
    end
    return false
end

function loadAnimDict( dict )
    while ( not HasAnimDictLoaded( dict ) ) do
        RequestAnimDict( dict )
        Citizen.Wait( 0 )
    end
end


local recentRobs = {}
local LastGive = {}
local LastGiveCash = {}

Citizen.CreateThread(function()
    while true do
        Wait(1)
        aiming, ent = GetEntityPlayerIsFreeAimingAt(PlayerId())
        if aiming then
            local pedCrds = GetEntityCoords(PlayerPedId())
            local entCrds = GetEntityCoords(ent)

            local pedType = GetPedType(ent)
            local animalped = false
            if pedType == 6 or pedType == 27 or pedType == 29 or pedType == 28 then
                animalped = true
            end

            if not animalped and #(pedCrds - entCrds) < 5.0 and not recentRobs["rob"..ent] and not IsPedAPlayer(ent) and not IsEntityDead(ent) and not IsPedDeadOrDying(ent, 1) and IsPedArmed(PlayerPedId(), 6) and not IsPedArmed(ent, 7) and not IsEntityPlayingAnim(ent, "missfbi5ig_22", "hands_up_anxious_scientist", 3) then
                local veh = 0
                if IsPedInAnyVehicle(ent, false) and GetEntitySpeed(veh) < 1.5 then
                    ClearPedTasks(ent)
                    Citizen.Wait(100)
                    veh = GetVehiclePedIsIn(ent,false)
                    TaskLeaveVehicle(ent, veh, 0)
                    Citizen.Wait(1500)
                    TriggerEvent("robEntity", ent, veh)
                    recentRobs["rob"..ent] = true
                    Citizen.Wait(10000)
                end

                if not IsPedInAnyVehicle(ent, false) then
                    TriggerEvent("robEntity",ent,veh)
                    recentRobs["rob"..ent] = true
                    Citizen.Wait(1000)
                end

            end

        else
            Wait(1000)
        end
    end
end)


-- 303280717 safe hash
local RobbedRegisters = {}
RegisterNetEvent("robEntity")
AddEventHandler("robEntity", function(entityRobbed,veh)

    local robbingEntity = true
    local startCrds = GetEntityCoords(PlayerPedId())
    local entCrds = GetEntityCoords(PlayerPedId())
    local pedCrds = GetEntityCoords(PlayerPedId())

    TaskLeaveVehicle(entityRobbed, veh, 0)
    SetPedFleeAttributes(entityRobbed, 0, 0)
    SetPedDropsWeaponsWhenDead(entityRobbed,false)
    ClearPedTasks(entityRobbed)
    ClearPedSecondaryTask(entityRobbed)
    TaskTurnPedToFaceEntity(entityRobbed, PlayerPedId(), 3.0)
    TaskSetBlockingOfNonTemporaryEvents(entityRobbed, true)
    SetPedCombatAttributes(entityRobbed, 17, 1)
    SetPedSeeingRange(entityRobbed, 0.0)
    SetPedHearingRange(entityRobbed, 0.0)
    SetPedAlertness(entityRobbed, 0)
    SetPedKeepTask(entityRobbed, true)
    SetVehicleCanBeUsedByFleeingPeds(veh, false)
    ResetPedLastVehicle(entityRobbed)
    Citizen.Wait(10)

    RequestAnimDict("missfbi5ig_22")
    while not HasAnimDictLoaded("missfbi5ig_22") do
        Citizen.Wait(0)
    end

    local storeRobbery = false
    local alerted = false
    local robberySuccessful = true

    while robbingEntity do
        Citizen.Wait(10)
        if not IsEntityPlayingAnim(entityRobbed, "missfbi5ig_22", "hands_up_anxious_scientist", 3) then
            TaskPlayAnim(entityRobbed, "missfbi5ig_22", "hands_up_anxious_scientist", 5.0, 1.0, -1, 1, 0, 0, 0, 0)
            Citizen.Wait(1000)
        end

        pedCrds = GetEntityCoords(PlayerPedId())
        entCrds = GetEntityCoords(entityRobbed)

        if #(pedCrds - entCrds) > 15.0 then
            robbingEntity = false
            robberySuccessful = false
        end
        
        if math.random(1000) < 15 and #(pedCrds - entCrds) < 7.0 then
            --TriggerEvent("traps:luck:ai")

            if veh ~= 0 and LastGive[veh] ~= true then
                --TriggerEvent("notification","They handed you the keys!")
                local plate = GetVehicleNumberPlateText(veh, false)
                local ped = PlayerPedId()
                local pos = GetEntityCoords(ped)
                --TriggerServerEvent("esx_addons_gcphone:startCall", "police", "Person robbery in progress. ", pos)
                --TriggerServerEvent("cl-keys:giveKey",plate)
                Citizen.Wait(7000)
                QBCore.Functions.Notify( "Person gave you his keys!","success")
                HasKey = true
                TriggerEvent("vehiclekeys:client:SetOwner", plate)
                robbingEntity = false
                LastGive[veh] = true
            end

            if veh ~= 0 and LastGiveCash[veh] ~= true then
            if(robberySuccessful) then

            end
        end
            robbingEntity = false
            RequestAnimDict("mp_common")
            while not HasAnimDictLoaded("mp_common") do
                Citizen.Wait(0)
            end			
            TaskPlayAnim( entityRobbed, "mp_common", "givetake1_a", 1.0, 1.0, -1, 1, 0, 0, 0, 0 )
            Citizen.Wait(2200)
        end
    end
    ClearPedTasks(entityRobbed)
    Citizen.Wait(10)
    TaskReactAndFleePed(entityRobbed, GetPlayerPed(-1))
    --TaskWanderStandard(entityRobbed, 10.0, 10)

    Citizen.Wait(math.random(1000,30000))	
    if veh ~= 0 then
        PoliceCall()
    else
        PoliceCall()
    end
    if #recentRobs > 20 then
        recentRobs = {}
    end
end)
