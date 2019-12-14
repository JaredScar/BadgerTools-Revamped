-------------------
--- BadgerTools ---
-------------------

--- Config ---
roleList = {
{0, "~y~Civilian | ~w~"}, -- 1
{577635624618819593, '~r~Fire/EMS | ~w~'},
{581881252907319369, '~g~LSPD | ~w~'},
{577622764618383380, '~o~Sheriff | ~w~'},
{506276895935954944, '~b~Highway | ~w~'},
{609828128432586752, '~y~NG | ~w~'},
{604137659836661760, '~p~Jr. Dev | ~w~'},
{600800070618841098, '~b~E~g~L~y~I~o~T~p~E ~b~| '},
{577661583497363456, "~g~Donator | "}, -- 3
{577631197987995678, "~r~T-Mod | "}, -- 4
{506211787214159872, "~r~Mod | "}, -- 5
{506212543749029900, "~r~Admin | "}, -- 6
{577966729981067305, "~p~Management | "}, -- 7
{506212786481922058, "~o~Owner | "}, -- 8
}

function GetPlayersSkip(_source) 
	local players = {}
	for _, i in ipairs(GetPlayers()) do 
		if not i == _source then
			table.insert(players, i) 
		end 
	end
	return players;
end
function GetPlayerWithHighestID(src)
	local highest = nil;
	for _, i in ipairs(GetPlayers()) do 
		if i ~= src then 
			if (highest == nil) or (tonumber(i) > tonumber(highest)) then 
				highest = i;
			end
		end
	end
	return highest;
end
-- START BadgerTools
RegisterCommand('kickRecent', function(source, args, rawCommand)
	-- Kick the 3 most recent players 
	if IsPlayerAceAllowed(source, 'BadgerTools.Commands.KickRecent') then 
		if GetPlayerWithHighestID(source) ~= nil then 
			DropPlayer(GetPlayerWithHighestID(source), "Server Care (Most recent ID)")
		end 
		if GetPlayerWithHighestID(source) ~= nil then 
			DropPlayer(GetPlayerWithHighestID(source), "Server Care (Most recent ID)")
		end 
		if GetPlayerWithHighestID(source) ~= nil then 
			DropPlayer(GetPlayerWithHighestID(source), "Server Care (Most recent ID)")
		end 
	end 
end)

prefix = '^9[^5BadgerTools^9] ^3';

RegisterCommand('spectate', function(source, args, rawCommand)
	if IsPlayerAceAllowed(source, 'BadgerTools.Commands.Spectate') then 
		if #args > 0 then
			-- /spectate 123 
			local id = tonumber(args[1])
			if GetPlayerIdentifiers(id)[2] ~= nil then 
				TriggerClientEvent('BT:Client:SpectateID', source, id)
			else 
				TriggerClientEvent('chatMessage', source, prefix .. '^1ERROR: ^1That player cannot be found...')
			end 
		else
			-- No args 
			TriggerClientEvent('BT:Client:Spectate', source)
		end
	end -- End PlayerAceAllowed 
end)

RegisterCommand('tp', function(source, args, rawCommand)
	if IsPlayerAceAllowed(source, 'BadgerTools.Commands.Tp') then 
		if #args < 1 then 
			-- /tp <id>
			TriggerClientEvent('chatMessage', source, prefix .. '^1ERROR: Invalid Usage. ^1Proper: /tp <id>')
			return;
		end
		for _, id in pairs(GetPlayers()) do
			if tonumber(args[1]) == tonumber(id) then  
				-- /tp <id> 
				TriggerClientEvent('BT:Client:TeleportPlayerToPlayer', source, id);
				return;
			end
		end
		TriggerClientEvent('chatMessage', source, prefix .. '^1ERROR: Could not find that player...')
	end
end)
RegisterCommand('summon', function(source, args, rawCommand)
	if IsPlayerAceAllowed(source, 'BadgerTools.Commands.Summon') then 
		if #args < 1 then 
			-- /summon <id>
			TriggerClientEvent('chatMessage', source, prefix .. '^1ERROR: Invalid Usage. ^1Proper: /summon <id>')
			return;
		end
		for _, id in pairs(GetPlayers()) do
			if tonumber(args[1]) == tonumber(id) then 
				-- /tp <id> 
				TriggerClientEvent('BT:Client:TeleportPlayerToPlayer', id, source);
				return;
			end
		end
		TriggerClientEvent('chatMessage', source, prefix .. '^1ERROR: Could not find that player...')
	end
end)

-- Holds the VoiceTags of all users they are allowed to use 
voiceTagHandler = {}

-- Honds the active tags of all users 
activeTagsHandler = {}

-- List the voice tags you have access to: 
RegisterCommand('voicetag', function(source, args, rawCommand)
	if #args == 0 then 
		-- They want the voicetags they have access to listed 
		TriggerClientEvent('chatMessage', source, prefix .. 'You have access to the following voice-tags:')
		local tags = voiceTagHandler[source]
		for i=1, #tags do
			TriggerClientEvent('chatMessage', source, '   ^3' .. tostring(i) .. ': ^5' .. tostring(tags[i]))
		end  
	else
		-- They are selecting their voicetag  
		local tagSelect = tonumber(args[1]);
		local foundTag = false;
		local tags = voiceTagHandler[source];
		for i=1, #tags do
			if i == tagSelect then 
				TriggerClientEvent('chatMessage', source, prefix .. 'You have changed your voice-tag to: ^5' .. tags[i])
				activeTagsHandler[source] = tags[i]
				foundTag = true;
			end
		end
		if not foundTag then 
			TriggerClientEvent('chatMessage', source, prefix .. '^1ERROR: That voice-tag does not exist!')
		else 
			TriggerEvent('BT:Server:UpdateClients')
		end
	end 
end)

RegisterNetEvent('BT:Server:UpdateClients')
AddEventHandler('BT:Server:UpdateClients', function()
	TriggerClientEvent('BT:Client:Update', -1, activeTagsHandler)
end)

AddEventHandler('playerDropped', function (reason) 
	-- Source is here, remove them from the dicts 
	activeTagsHandler[source] = nil;
	voiceTagHandler[source] = nil;
	allowedColors[source] = nil;
	TriggerEvent('BT:Server:UpdateClients')
end)
allowedColors = {}
RegisterNetEvent('BT:Server:PlayerSpawned')
AddEventHandler('BT:Server:PlayerSpawned', function()
	-- Player joining the server
	local src = source;
	-- Code:
	allowedColors[src] = false 
	if IsPlayerAceAllowed(src, "BadgerTools.Colors") then 
		allowedColors[src] = true 
		TriggerClientEvent('BT:Client:UpdateColors', -1, allowedColors)
	end
	TriggerClientEvent('BT:Client:SetTalkerProximity', source, 15)
	local identifierDiscord = nil 
	for k, v in ipairs(GetPlayerIdentifiers(src)) do
		if string.sub(v, 1, string.len("discord:")) == "discord:" then
			identifierDiscord = v
		end
	end
	local roleTags = {};
	table.insert(roleTags, roleList[1][2])
	activeTagsHandler[src] = roleList[1][2]
	if identifierDiscord ~= nil then
		-- Discord was found, get their roles 
		local roleIDs = exports.discord_perms:GetRoles(src)
		if roleIDs ~= false then 
			for i=1, #roleList do 
				for j=1, #roleIDs do 
					if tostring(roleList[i][1]) == tostring(roleIDs[j]) then 
						-- They have access to this role tag:
						table.insert(roleTags, roleList[i][2]);
						activeTagsHandler[src] = roleList[i][2];
						print("[BadgerTools] Player " .. GetPlayerName(src) .. " has access to voicetag: " .. roleList[i][2])
					end
				end 
			end
		end
	end
	-- Set their tags they have access to: 
	voiceTagHandler[src] = roleTags;

	TriggerEvent('BT:Server:UpdateClients')
end)

RegisterNetEvent('BadgerTools:Server:UserTag')
AddEventHandler('BadgerTools:Server:UserTag', function(bool)
	if bool then
		-- Show tag
		exports.DiscordTagIDs:ShowUserTag(source)
		--print("There usertag should be shown now") -- DEBUG - Get rid of
	else
		-- Don't show tag
		exports.DiscordTagIDs:HideUserTag(source)
		--print("There usertag should be hidden now") -- DEBUG - Get rid of
	end
end)
-- END BadgerTools