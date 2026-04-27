-- CharacterSystem.server.lua - Handles character morphing and loading
local ServerStorage = game:GetService("ServerStorage")
local CharacterData = require(ServerStorage.Modules.CharacterData)
local PlayerData = require(ServerStorage.Modules.PlayerData)
local Shared = require(game:GetService("ReplicatedStorage").Modules.Shared)

local CharacterSystem = {}

-- Morph a player into their selected character
function CharacterSystem:MorphPlayer(player, characterId, skin, isKiller)
	local character = player.Character
	if not character then return end
	
	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid then return end
	
	-- Get character data
	local charData
	if isKiller then
		charData = CharacterData.KILLERS[characterId]
	else
		charData = CharacterData.SURVIVORS[characterId]
	end
	
	if not charData then
		warn("Character not found: " .. characterId)
		return
	end
	
	-- Get skin color
	skin = skin or "Default"
	local skinData = charData.skins[skin] or charData.skins.Default
	local skinColor = skinData.color or Color3.new(1, 1, 1)
	
	-- Update humanoid
	humanoid.MaxHealth = charData.health
	humanoid.Health = charData.health
	
	-- Color character
	for _, part in pairs(character:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Color = skinColor
		end
	end
	
	-- Add custom attributes
	character:SetAttribute("CharacterType", charData.role)
	character:SetAttribute("CharacterName", charData.displayName)
	character:SetAttribute("Speed", charData.speed)
	character:SetAttribute("Stamina", charData.stamina)
	character:SetAttribute("MaxStamina", charData.stamina)
	
	print(player.Name .. " morphed into " .. charData.displayName)
	Shared.Events.PlayerMorphed:FireAllClients(player, charData.displayName, skinColor)
end

-- Morph all players for round start
function CharacterSystem:MorphPlayers(killer, survivors, map)
	-- Morph killer
	local killerCharId, killerSkin = PlayerData:GetSelectedKiller(killer)
	self:MorphPlayer(killer, killerCharId, killerSkin, true)
	
	-- Teleport killer to spawn
	local killerSpawn = require(ServerStorage.Modules.MapManager):GetKillerSpawn(map)
	Shared:TeleportPlayer(killer, killerSpawn.Position)
	
	-- Morph survivors
	for _, survivor in pairs(survivors) do
		local survivorCharId, survivorSkin = PlayerData:GetSelectedSurvivor(survivor)
		self:MorphPlayer(survivor, survivorCharId, survivorSkin, false)
		
		-- Teleport survivor to random spawn
		local spawnPoint = require(ServerStorage.Modules.MapManager):GetRandomSurvivorSpawn(map)
		Shared:TeleportPlayer(survivor, spawnPoint.Position)
	end
end

return CharacterSystem