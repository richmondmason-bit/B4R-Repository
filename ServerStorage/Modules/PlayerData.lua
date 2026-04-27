-- PlayerData.lua - Persistent player data (Malice, selected character, stats)
local PlayerData = {}
local playersData = {} -- In-game storage (replace with DataStoreService for production)

-- Initialize player data
function PlayerData:InitializePlayer(player)
	if not playersData[player.UserId] then
		local RoundConfig = require(game:GetService("ServerStorage"):WaitForChild("Modules"):WaitForChild("RoundConfig"))
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
			playerPoints = RoundConfig.CURRENCY.START_POINTS,
			ownedCharacters = { Specter = true, Scout = true }, -- Free characters unlocked
			ownedSkins = {
				Specter = { Default = true },
				Scout = { Default = true }
			},
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

-- Buy a character
function PlayerData:BuyCharacter(player, characterId)
	local data = self:GetPlayerData(player)
	local CharacterData = require(game:GetService("ServerStorage"):WaitForChild("Modules"):WaitForChild("CharacterData"))
	
	-- Check if already owned
	if data.ownedCharacters[characterId] then
		return false, "Already owned"
	end
	
	-- Get character price
	local character = CharacterData.KILLERS[characterId] or CharacterData.SURVIVORS[characterId]
	if not character then
		return false, "Character not found"
	end
	
	-- Check funds
	if data.playerPoints < character.price then
		return false, "Insufficient funds"
	end
	
	-- Purchase
	data.playerPoints = data.playerPoints - character.price
	data.ownedCharacters[characterId] = true
	if not data.ownedSkins[characterId] then
		data.ownedSkins[characterId] = {}
	end
	data.ownedSkins[characterId].Default = true
	
	print(player.Name .. " purchased " .. character.displayName)
	return true, "Purchase successful"
end

-- Buy a skin
function PlayerData:BuySkin(player, characterId, skinId)
	local data = self:GetPlayerData(player)
	local CharacterData = require(game:GetService("ServerStorage"):WaitForChild("Modules"):WaitForChild("CharacterData"))
	
	-- Check if character owned
	if not data.ownedCharacters[characterId] then
		return false, "Character not owned"
	end
	
	-- Check if skin already owned
	if data.ownedSkins[characterId] and data.ownedSkins[characterId][skinId] then
		return false, "Skin already owned"
	end
	
	-- Get skin price
	local character = CharacterData.KILLERS[characterId] or CharacterData.SURVIVORS[characterId]
	if not character or not character.skins[skinId] then
		return false, "Skin not found"
	end
	
	local skinPrice = character.skins[skinId].price
	
	-- Check funds
	if data.playerPoints < skinPrice then
		return false, "Insufficient funds"
	end
	
	-- Purchase
	data.playerPoints = data.playerPoints - skinPrice
	if not data.ownedSkins[characterId] then
		data.ownedSkins[characterId] = {}
	end
	data.ownedSkins[characterId][skinId] = true
	
	print(player.Name .. " purchased skin " .. skinId .. " for " .. character.displayName)
	return true, "Purchase successful"
end

-- Check if player owns character
function PlayerData:OwnsCharacter(player, characterId)
	local data = self:GetPlayerData(player)
	return data.ownedCharacters[characterId] or false
end

-- Check if player owns skin
function PlayerData:OwnsSkin(player, characterId, skinId)
	local data = self:GetPlayerData(player)
	return data.ownedSkins[characterId] and data.ownedSkins[characterId][skinId] or false
end

return PlayerData