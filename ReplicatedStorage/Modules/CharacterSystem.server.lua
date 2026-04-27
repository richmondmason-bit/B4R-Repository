-- CharacterSystem.server.lua - Handles character morphing and loading
local ServerStorage = game:GetService("ServerStorage")
local CharacterData = require(ServerStorage.Modules.CharacterData)
local PlayerData = require(ServerStorage.Modules.PlayerData)
local Shared = require(game:GetService("ReplicatedStorage").Modules.Shared)

local CharacterSystem = {}

-- Create a humanoid rig (blank character model that players morph into)
local function createCharacterRig()
	local character = Instance.new("Model")
	character.Name = "BlankCharacter"
	
	-- Head
	local head = Instance.new("Part")
	head.Name = "Head"
	head.Shape = Enum.PartType.Ball
	head.Size = Vector3.new(2, 2, 2)
	head.TopSurface = Enum.SurfaceType.Smooth
	head.BottomSurface = Enum.SurfaceType.Smooth
	head.CanCollide = false
	head.Parent = character
	
	-- Torso
	local torso = Instance.new("Part")
	torso.Name = "Torso"
	torso.Shape = Enum.PartType.Block
	torso.Size = Vector3.new(2, 2, 1)
	torso.TopSurface = Enum.SurfaceType.Smooth
	torso.BottomSurface = Enum.SurfaceType.Smooth
	torso.CanCollide = false
	torso.Parent = character
	
	-- HumanoidRootPart
	local humanoidRootPart = Instance.new("Part")
	humanoidRootPart.Name = "HumanoidRootPart"
	humanoidRootPart.Transparency = 1
	humanoidRootPart.CanCollide = false
	humanoidRootPart.Size = Vector3.new(2, 2, 1)
	humanoidRootPart.Parent = character
	
	-- Left Arm
	local leftArm = Instance.new("Part")
	leftArm.Name = "Left Arm"
	leftArm.Shape = Enum.PartType.Block
	leftArm.Size = Vector3.new(1, 2, 1)
	leftArm.CanCollide = false
	leftArm.Parent = character
	
	-- Right Arm
	local rightArm = Instance.new("Part")
	rightArm.Name = "Right Arm"
	rightArm.Shape = Enum.PartType.Block
	rightArm.Size = Vector3.new(1, 2, 1)
	rightArm.CanCollide = false
	rightArm.Parent = character
	
	-- Left Leg
	local leftLeg = Instance.new("Part")
	leftLeg.Name = "Left Leg"
	leftLeg.Shape = Enum.PartType.Block
	leftLeg.Size = Vector3.new(1, 2, 1)
	leftLeg.CanCollide = false
	leftLeg.Parent = character
	
	-- Right Leg
	local rightLeg = Instance.new("Part")
	rightLeg.Name = "Right Leg"
	rightLeg.Shape = Enum.PartType.Block
	rightLeg.Size = Vector3.new(1, 2, 1)
	rightLeg.CanCollide = false
	rightLeg.Parent = character
	
	-- Humanoid
	local humanoid = Instance.new("Humanoid")
	humanoid.Parent = character
	
	-- Create Motor6Ds for joints
	local neck = Instance.new("Motor6D")
	neck.Name = "Neck"
	neck.C0 = CFrame.new(0, 1, 0)
	neck.C1 = CFrame.new(0, -1, 0)
	neck.Part0 = torso
	neck.Part1 = head
	neck.Parent = torso
	
	local rootJoint = Instance.new("Motor6D")
	rootJoint.Name = "RootJoint"
	rootJoint.C0 = CFrame.new(0, 0, 0)
	rootJoint.C1 = CFrame.new(0, 0, 0)
	rootJoint.Part0 = humanoidRootPart
	rootJoint.Part1 = torso
	rootJoint.Parent = humanoidRootPart
	
	local leftShoulder = Instance.new("Motor6D")
	leftShoulder.Name = "Left Shoulder"
	leftShoulder.C0 = CFrame.new(-1, 0.5, 0)
	leftShoulder.C1 = CFrame.new(0.5, 0.5, 0)
	leftShoulder.Part0 = torso
	leftShoulder.Part1 = leftArm
	leftShoulder.Parent = torso
	
	local rightShoulder = Instance.new("Motor6D")
	rightShoulder.Name = "Right Shoulder"
	rightShoulder.C0 = CFrame.new(1, 0.5, 0)
	rightShoulder.C1 = CFrame.new(-0.5, 0.5, 0)
	rightShoulder.Part0 = torso
	rightShoulder.Part1 = rightArm
	rightShoulder.Parent = torso
	
	local leftHip = Instance.new("Motor6D")
	leftHip.Name = "Left Hip"
	leftHip.C0 = CFrame.new(-1, -1, 0)
	leftHip.C1 = CFrame.new(-0.5, 1, 0)
	leftHip.Part0 = torso
	leftHip.Part1 = leftLeg
	leftHip.Parent = torso
	
	local rightHip = Instance.new("Motor6D")
	rightHip.Name = "Right Hip"
	rightHip.C0 = CFrame.new(1, -1, 0)
	rightHip.C1 = CFrame.new(0.5, 1, 0)
	rightHip.Part0 = torso
	rightHip.Part1 = rightLeg
	rightHip.Parent = torso
	
	return character
end

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
		if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
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
	Shared:TeleportPlayer(killer, killerSpawn.Position + Vector3.new(0, 3, 0))
	
	-- Morph survivors
	for _, survivor in pairs(survivors) do
		local survivorCharId, survivorSkin = PlayerData:GetSelectedSurvivor(survivor)
		self:MorphPlayer(survivor, survivorCharId, survivorSkin, false)
		
		-- Teleport survivor to random spawn
		local spawnPoint = require(ServerStorage.Modules.MapManager):GetRandomSurvivorSpawn(map)
		Shared:TeleportPlayer(survivor, spawnPoint.Position + Vector3.new(0, 3, 0))
	end
end

return CharacterSystem