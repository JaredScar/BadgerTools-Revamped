-------------------
--- BadgerTools ---
------------------- 

--- CODE ---

-- START BadgerTools

-- END BadgerTools

function spectatePlayer(targetPed)
	local playerPed = PlayerPedId() -- yourself
	enable = true
	
	if targetPed == playerPed then enable = false end

	if(enable)then
		--local targetx,targety,targetz = table.unpack(GetEntityCoords(targetPed, false))
		NetworkSetInSpectatorMode(true, targetPed)	
		SetEntityInvincible(GetPlayerPed(-1), true) 
		SetEntityVisible(GetPlayerPed(-1), false, 0)
		SetEveryoneIgnorePlayer(GetPlayerPed(-1), true)
		SetEntityCollision(GetPlayerPed(-1), false, false)
	else
		--local targetx,targety,targetz = table.unpack(GetEntityCoords(targetPed, false))
		NetworkSetInSpectatorMode(false, targetPed)
		SetEntityInvincible(GetPlayerPed(-1), false)
		SetEntityVisible(GetPlayerPed(-1), true, 0)
		SetEveryoneIgnorePlayer(GetPlayerPed(-1), false)
		SetEntityCollision(GetPlayerPed(-1), true, true)
	end
end
isSpectating = false;

frozen = false 
RegisterNetEvent('BT:Client:FreezePlayer')
AddEventHandler('BT:Client:FreezePlayer', function()
	FreezeEntityPosition(GetPlayerPed(-1), not frozen)
	frozen = not frozen
	if frozen then 
		ClearPedTasksImmediately(GetPlayerPed(-1))
	end
end)

Citizen.CreateThread(function()
	Wait(1000); 
	TriggerServerEvent('BT:Server:PlayerSpawned')
	NetworkSetTalkerProximity(proximity)
end)

RegisterNetEvent('BT:Client:TeleportPlayerToPlayer')
AddEventHandler('BT:Client:TeleportPlayerToPlayer', function(to)
	-- Teleport player to:
	local coords = GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(tonumber(to))), true)
	SetEntityCoords(GetPlayerPed(-1), coords.x, coords.y, coords.z, 1, 0, 0, 1)
end)

RegisterNetEvent('BT:Client:Update')
AddEventHandler('BT:Client:Update', function(tagHandler) 
	activeTagsHandler = tagHandler
	print("[BadgerTools] I got updated") -- DEBUG - Get rid of 
end)

RegisterNetEvent('BT:Client:UpdateColors')
AddEventHandler('BT:Client:UpdateColors', function(colorHandle) 
	colorPerms = colorHandle 
end)

RegisterNetEvent('BT:Client:SetTalkerProximity')
AddEventHandler('BT:Client:SetTalkerProximity', function(val)
	NetworkSetTalkerProximity(val + .0)
	proximity = val + .0
	print("[BadgerTools] Proximity was set to " .. tostring(val + .0)) 
end)

proximity = 15.0

activeTagsHandler = {}
colorPerms = {}

prefix = Config.Prefix;
function sendMsg(msg) 
	TriggerEvent('chatMessage', '', {255, 255, 255}, prefix .. '' .. msg)
end

RegisterCommand('proximity', function(source, args, rawCommand)
	-- It's /proximity <distance>
	if #args == 0 then 
		-- They don't know how to use the command, tell them how 
		sendMsg('^1ERROR: You must specify a distance. /proximity <distance>')
	else 
		local val = tonumber(args[1])
		NetworkSetTalkerProximity(val + .0)
		sendMsg('Your voice proximity has been set to ^5' .. args[1])
	end  
end)

-- Spectate Cycle Controls --
Citizen.CreateThread(function() 
	while true do 
		Citizen.Wait(0)
		-- Runs every millisecond
		-- LEFT ARROW = 174 RIGHT ARROW = 175
		if isSpectating then 
			-- They are spectating, check their controls and teleport them above the player 
			local playerIndex = getPlayerIndex(spectatedUserClientID)
			if playerIndex == nil then 
				-- Set them to another player to spectate 
				if GetPlayersCountButSkipMe() >= 1 then 
					local players = GetPlayersButSkipMyself()
					local player = GetPlayerPed(players[1]) 
					spectatedUserClientID = players[1]
					spectatedUserServerID = GetPlayerServerId(spectatedUserClientID)
					spectatePlayer(GetPlayerPed(spectatedUserClientID))
					ShowNotification('~b~Spectating ~f~' .. GetPlayerName(spectatedUserClientID))
					sendMsg('^5Spectating ^0' .. GetPlayerName(spectatedUserClientID))
				else
					-- Not enough players, spectate themselves 
					ShowNotification("~r~Error: Not enough players to spectate")
					spectatePlayer(GetPlayerPed(-1))
					sendMsg('^1Error: Not enough players to spectate')
					spectatedUserServerID = nil 
					spectatedUserClientID = nil 
					isSpectating = false 
				end
			end
			local player = GetPlayerPed(-1)
			local spectatedCoords = GetEntityCoords(GetPlayerPed(spectatedUserClientID))
			-- Teleport them above the player 
			SetEntityCoords(player, spectatedCoords.x, spectatedCoords.y + 10, spectatedCoords.z)
			local players = GetPlayersButSkipMyself()
			if IsControlJustReleased(0, 174) then 
				-- Go backwards, spectatedUserClientID - 1
				local index = getPlayerIndex(spectatedUserClientID) - 1;

				index = index - 1;
				if players[index] == nil then 
					-- Can't go backwards anymore 
					index = #players 
				end
				local newSpectate = players[index]
				spectatedUserClientID = tonumber(newSpectate) 
				spectatedUserServerID = GetPlayerServerId(newSpectate)
				spectatePlayer(GetPlayerPed(spectatedUserClientID))
				ShowNotification('~b~Spectating ~f~' .. GetPlayerName(spectatedUserClientID))
				sendMsg('^5Spectating ^0' .. GetPlayerName(spectatedUserClientID))
			elseif IsControlJustReleased(0, 175) then 
				-- Go forwards, spectatedUserClientID + 1
				local index = getPlayerIndex(spectatedUserClientID);
				index = index + 1
				if players[index] == nil then 
					-- Can't go forward anymore 
					index = 1 
				end
				local newSpectate = players[index]
				spectatedUserClientID = tonumber(newSpectate) 
				spectatedUserServerID = GetPlayerServerId(newSpectate)
				spectatePlayer(GetPlayerPed(spectatedUserClientID))
				ShowNotification('~b~Spectating ~f~' .. GetPlayerName(spectatedUserClientID))
				sendMsg('^5Spectating ^0' .. GetPlayerName(spectatedUserClientID))
			end
		end
	end
end)

colorIndex = 1;
colors = {"~g~", "~b~", "~y~", "~o~", "~r~", "~p~", "~w~"}
timer = 500;
-- Voice Chat Handler --
ooc = Config.EnableVoiceOOC;
Citizen.CreateThread(function() 
	while true do 
		Citizen.Wait(0)
		-- Runs every millisecond 
		-- DrawText2("~f~" .. tag .. name, .50, 0.030 + (0.025*(counter)))
		local players = GetPlayers()
		local counter = 0;
		for i=1, #players do 
			local clientID = players[i]
			local serverID = GetPlayerServerId(players[i])
			timer = timer - 10;
			if not ooc then 
				-- Normal talking shit cause they have it disabled 
				if NetworkIsPlayerTalking(clientID) and activeTagsHandler[serverID] ~= nil then 
					-- They are talking, draw them on screen 
					local playerName = GetPlayerName(clientID)
					local playerCoords2 = GetEntityCoords(GetPlayerPed(clientID))
					local playerCoords = GetEntityCoords(GetPlayerPed(-1))
					if(GetDistanceBetweenCoords(playerCoords.x, playerCoords.y, 
						playerCoords.z, playerCoords2.x, playerCoords2.y, playerCoords2.z, true) <= proximity) then
						-- They are in distance, draw them 
						local hasColorPerms = colorPerms[serverID]
						local activeTag = activeTagsHandler[serverID]
						if activeTag:find("~RGB~") then 
							tag = activeTag;
							tag = tag:gsub("~RGB~", colors[colorIndex]);
							if timer <= 0 then 
								colorIndex = colorIndex + 1;
								--print("Changed color to rainbow color: " .. colors[colorIndex]);
								if colorIndex >= #colors then 
									colorIndex = 1;
								end
								timer = 3000;
							end
							activeTag = tag;
						else 
							-- Don't do anything 
						end
						local colors = {"~b~", "~g~", "~y~", "~p~", "~c~", "~m~", "~u~", "~o~", "~w~", "~r~"}
						if not hasColorPerms then 
							for i = 1, #colors do
								playerName = playerName:gsub(colors[i], "")
							end
						end
						if activeTag ~= nil then 
							DrawText2("~f~" .. activeTag .. playerName, .50, 0.050 + (0.040*(counter)))
							counter = counter + 1
						end
					end
				end 
			else 
				-- They have OOC enabled, set it up 
				if NetworkIsPlayerTalking(clientID) and activeTagsHandler[serverID] ~= nil then 
					-- They are talking, draw them on screen 
					local playerPed = GetPlayerPed(clientID);
					local isDead = IsEntityDead(playerPed);
					if not (isDead) then
						local playerName = GetPlayerName(clientID)
						local playerCoords2 = GetEntityCoords(GetPlayerPed(clientID))
						local playerCoords = GetEntityCoords(GetPlayerPed(-1))
						if(GetDistanceBetweenCoords(playerCoords.x, playerCoords.y, 
							playerCoords.z, playerCoords2.x, playerCoords2.y, playerCoords2.z, true) <= proximity) then
							-- They are in distance, draw them 
							local hasColorPerms = colorPerms[serverID]
							local activeTag = activeTagsHandler[serverID]
							if activeTag:find("~RGB~") then 
								tag = activeTag;
								tag = tag:gsub("~RGB~", colors[colorIndex]);
								if timer <= 0 then 
									colorIndex = colorIndex + 1;
									--print("Changed color to rainbow color: " .. colors[colorIndex]);
									if colorIndex >= #colors then 
										colorIndex = 1;
									end
									timer = 3000;
								end
								activeTag = tag;
							else 
								-- Don't do anything 
							end
							local colors = {"~b~", "~g~", "~y~", "~p~", "~c~", "~m~", "~u~", "~o~", "~w~", "~r~"}
							if not hasColorPerms then 
								for i = 1, #colors do
									playerName = playerName:gsub(colors[i], "")
								end
							end
							if activeTag ~= nil then 
								DrawText2("~f~" .. activeTag .. playerName, .50, 0.050 + (0.040*(counter)))
								counter = counter + 1
							end
						end
					else 
						-- They are dead, print their speaking as using OOC 
						local name = GetPlayerName(clientID);
						local playerCoords2 = GetEntityCoords(GetPlayerPed(clientID))
						local playerCoords = GetEntityCoords(GetPlayerPed(-1))
						if(GetDistanceBetweenCoords(playerCoords.x, playerCoords.y, 
							playerCoords.z, playerCoords2.x, playerCoords2.y, playerCoords2.z, true) <= proximity) then
							-- In distance, draw it 
							DrawText2(Config.OOC_Prefix .. name, .50, 0.050 + (0.040*(counter)))
							counter = counter + 1
						end
					end
				end
			end 
		end
	end
end)

if Config.EnableVoiceOOC then 
	Citizen.CreateThread(function()
		while true do 
			Wait(0);
			local ped = GetPlayerPed(-1);
			local isDead = IsEntityDead(ped);
			if (isDead) then 
				for i = 1, #Config.OOC_Messages do 
					DrawText2WithSize(Config.OOC_Messages[i].msg, Config.OOC_Messages[i].size, Config.OOC_Messages[i].x, Config.OOC_Messages[i].y); 
				end
			end 
		end
	end)
end 
spectatedUserServerID = nil 
spectatedUserClientID = nil 

function DrawText2WithSize(text, size, x, y)
        SetTextFont(0)
        SetTextProportional(1)
        SetTextScale(0.0, size)
		SetTextJustification(1) -- Center Text
		SetTextCentre(true)
        SetTextDropshadow(1, 0, 0, 0, 255)
        SetTextEdge(1, 0, 0, 0, 255)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        AddTextComponentString(text)
        DrawText(x, y)
end

function DrawText2(text, x, y)
        SetTextFont(0)
        SetTextProportional(1)
        SetTextScale(0.0, 0.45)
		SetTextJustification(1) -- Center Text
		SetTextCentre(true)
        SetTextDropshadow(1, 0, 0, 0, 255)
        SetTextEdge(1, 0, 0, 0, 255)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        AddTextComponentString(text)
        DrawText(x, y)
end
local savedCoords = nil 
RegisterNetEvent('BT:Client:SpectateID')
AddEventHandler('BT:Client:SpectateID', function(id)
	-- Spectate the specified ID 
	if not isSpectating then 
		-- They were not spectating, give them cycle spectate, but start from specified ID 
		spectatedUserServerID = tonumber(id)
		local players = GetPlayersButSkipMyself()
		local found = false 
		for i = 1, #players do 
			local playerID = players[i] -- Their client side ID 
			if spectatedUserServerID == GetPlayerServerId(playerID) then 
				spectatedUserClientID = playerID
				found = true 
			end
		end
		if found then 
			-- SAVE THEIR LOCATION:
			savedCoords = GetEntityCoords(PlayerPedId())
			TriggerServerEvent('BadgerTools:Server:UserTag', false) -- Hide UserTag
			spectatePlayer(GetPlayerPed(spectatedUserClientID))
			ShowNotification('~b~Spectating ~f~' .. GetPlayerName(spectatedUserClientID))
			sendMsg('^5Spectating ^0' .. GetPlayerName(spectatedUserClientID))
			isSpectating = true 
		else 
			-- Send message, can't find that ID 
			sendMsg('^1ERROR: Cannot find the user with that ID')
		end
	else
		-- They were spectating, just change the person they are spectating 
		local serverID = tonumber(id)
		local players = GetPlayersButSkipMyself()
		local found = false 
		for i = 1, #players do 
			local playerID = players[i] -- Their client side ID 
			if serverID == GetPlayerServerId(playerID) then 
				spectatedUserClientID = playerID
				spectatedUserServerID = serverID
				found = true 
			end
		end
		if found then 
			TriggerServerEvent('BadgerTools:Server:UserTag', false) -- Hide UserTag
			spectatePlayer(GetPlayerPed(spectatedUserClientID))
			ShowNotification('~b~Spectating ~f~' .. GetPlayerName(spectatedUserClientID))
			sendMsg('^5Spectating ^0' .. GetPlayerName(spectatedUserClientID))
			isSpectating = true 
		else 
			-- Send message, can't find that ID 
			sendMsg('^1ERROR: Cannot find the user with that ID')
		end
	end 
end)

RegisterNetEvent('BT:Client:Spectate')
AddEventHandler('BT:Client:Spectate', function()
	-- Regular cycling spectate 
	if not isSpectating then 
		-- They are not spectating, spectate cycle start:
		if GetPlayersCountButSkipMe() >= 1 then 
			local players = GetPlayersButSkipMyself()
			spectatedUserClientID = players[1]
			spectatedUserServerID = GetPlayerServerId(spectatedUserClientID)
			isSpectating = true 
			-- SAVE THEIR LOCATION:
			savedCoords = GetEntityCoords(PlayerPedId()) 
			TriggerServerEvent('BadgerTools:Server:UserTag', false) -- Hide UserTag
			spectatePlayer(GetPlayerPed(spectatedUserClientID))
			ShowNotification('~b~Spectating ~f~' .. GetPlayerName(spectatedUserClientID))
			sendMsg('^5Spectating ^0' .. GetPlayerName(spectatedUserClientID))
		else
			sendMsg('^1ERROR: Not enough players on to spectate') 
		end 
	else 
		-- They were spectating, stop their spectate 
		ShowNotification("~g~Success: No longer spectating anyone!")
		spectatePlayer(GetPlayerPed(-1))
		sendMsg('^2Success: No longer spectating anyone!')
		spectatedUserServerID = nil 
		spectatedUserClientID = nil 
		isSpectating = false 
		SetEntityCoords(GetPlayerPed(-1), savedCoords.x, savedCoords.y, savedCoords.z) -- Teleport them
		TriggerServerEvent('BadgerTools:Server:UserTag', true) -- Show UserTag
	end
end)

function has_value (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end
    return false
end
function get_index (tab, val)
	local counter = 1
    for index, value in ipairs(tab) do
        if value == val then
            return counter
        end
		counter = counter + 1
    end

    return nil
end

function getPlayerIndex(id, skipMe) 
	local counter = 0;
	for _, i in ipairs(GetActivePlayers()) do
        if NetworkIsPlayerActive(i) then
        	if i ~= skipMe then 
        		counter = counter + 1;
			end
			if i == id then
				return counter;
			end
		end
    end
    return nil;
end
function GetPlayers()
    local players = {}

    for _, i in ipairs(GetActivePlayers()) do
        if NetworkIsPlayerActive(i) then
            table.insert(players, i)
        end
    end

    return players
end
function GetPlayersButSkipMyself()
    local players = {}
    local ind = 1;
    for _, i in ipairs(GetActivePlayers()) do
        if NetworkIsPlayerActive(i) then
			if i ~= PlayerId() then
				players[ind] = i;
				ind = ind + 1;
			end
		end
    end

    return players
end
function GetPlayersCountButSkipMe()
    local count = 0
    for _, i in ipairs(GetActivePlayers()) do
        if NetworkIsPlayerActive(i) then
			if GetPlayerPed(i) ~= GetPlayerPed(-1) then
				count = count + 1
			end
		end
    end
    return count
end
function ShowNotification(text)
	SetNotificationTextEntry("STRING")
	AddTextComponentString(text)
	DrawNotification(0,1)
end