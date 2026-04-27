-- PlayerData.lua - Persistent player data (Malice, selected character, stats)
local PlayerData = {}
local playersData = {} -- In-game storage (replace with DataStoreService for production)

-- Initialize player data
function PlayerData:InitializePlayer(player)
	if not playersData[player.UserId] then
		playersData[player.UserId] = {
			userId = player.UserId,
			username = player.Name,
			malice = 0,
			selectedSurvivor = "Scout",
			selectedSurvivorSkin = "Default",
			selectedKiller = "Specter",
			selectedKillerSkin = "Default",
			level = 1,
			exp = 0,
			playerPoints = 0,
			stats = {
				survivorWins = 0,
				killerWins = 0,
				totalRoundsPlayed = 0,
				totalSurvivalTime = 0
			}
		}
	end
	return playersData[player.UserId]
end

-- Get player data
function PlayerData:GetPlayerData(player)
	if not playersData[player.UserId] then
		self:InitializePlayer(player)
	end
	return playersData[player.UserId]
end

-- Add Malice to a player
function PlayerData:AddMalice(player, amount)
	local data = self:GetPlayerData(player)
	data.malice = data.malice + amount
	print(player.Name .. " gained " .. amount .. " Malice (Total: " .. data.malice .. ")")
	return data.malice
end

-- Set selected character
function PlayerData:SetSelectedSurvivor(player, survivorId, skin)
	local data = self:GetPlayerData(player)
	data.selectedSurvivor = survivorId
	data.selectedSurvivorSkin = skin or "Default"
end

function PlayerData:SetSelectedKiller(player, killerId, skin)
	local data = self:GetPlayerData(player)
	data.selectedKiller = killerId
	data.selectedKillerSkin = skin or "Default"
end

-- Get selected character
function PlayerData:GetSelectedSurvivor(player)
	local data = self:GetPlayerData(player)
	return data.selectedSurvivor, data.selectedSurvivorSkin
end

function PlayerData:GetSelectedKiller(player)
	local data = self:GetPlayerData(player)
	return data.selectedKiller, data.selectedKillerSkin
end

-- Add rewards
function PlayerData:AddRewards(player, exp, points)
	local data = self:GetPlayerData(player)
	data.exp = data.exp + exp
	data.playerPoints = data.playerPoints + points
	print(player.Name .. " gained " .. exp .. " EXP and " .. points .. " Points")
	return data.exp, data.playerPoints
end

-- Get player with highest Malice
function PlayerData:GetHighestMalicePlayer(players)
	local highestPlayer = nil
	local highestMalice = -1
	
	for _, player in pairs(players) do
		if player then
			local data = self:GetPlayerData(player)
			if data.malice > highestMalice then
				highestMalice = data.malice
				highestPlayer = player
			end
		end
	end
	
	return highestPlayer, highestMalice
end

-- Reset Malice (optional - called after each round or manually)
function PlayerData:ResetMalice(player)
	local data = self:GetPlayerData(player)
	data.malice = 0
end

return PlayerData