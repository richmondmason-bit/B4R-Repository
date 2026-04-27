-- Shared.lua - Shared utilities and RemoteEvents
local Shared = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Create or get RemoteEvents
local function getOrCreateRemoteEvent(name)
	local remote = ReplicatedStorage:FindFirstChild(name)
	if not remote then
		remote = Instance.new("RemoteEvent")
		remote.Name = name
		remote.Parent = ReplicatedStorage
	end
	return remote
end

-- Game Events
Shared.Events = {
	RoundStarted = getOrCreateRemoteEvent("RoundStarted"),
	RoundEnded = getOrCreateRemoteEvent("RoundEnded"),
	PlayerMorphed = getOrCreateRemoteEvent("PlayerMorphed"),
	TimerUpdate = getOrCreateRemoteEvent("TimerUpdate"),
	PlayerKilled = getOrCreateRemoteEvent("PlayerKilled"),
	MaliceUpdated = getOrCreateRemoteEvent("MaliceUpdated"),
	CharacterSelected = getOrCreateRemoteEvent("CharacterSelected")
}

-- Utility function: Get all players
function Shared:GetPlayers()
	return game:GetService("Players"):GetPlayers()
end

-- Utility function: Wait for player character
function Shared:WaitForCharacter(player, timeout)
	timeout = timeout or 10
	local startTime = tick()
	while not player.Character and (tick() - startTime) < timeout do
		wait(0.1)
	end
	return player.Character
end

-- Utility function: Teleport player
function Shared:TeleportPlayer(player, position)
	local character = player.Character
	if character and character:FindFirstChild("HumanoidRootPart") then
		character:MoveTo(position)
	end
end

return Shared