-- GameManager.server.lua - Main game loop coordinator
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local RoundConfig = require(ServerStorage.Modules.RoundConfig)
local PlayerData = require(ServerStorage.Modules.PlayerData)
local MapManager = require(ServerStorage.Modules.MapManager)
local Shared = require(ReplicatedStorage.Modules.Shared)

local gameState = {
	phase = RoundConfig.PHASES.INTERMISSION,
	timer = RoundConfig.INTERMISSION_LENGTH,
	currentMap = nil,
	currentKiller = nil,
	survivors = {}
}

-- Initialize players on join
Players.PlayerAdded:Connect(function(player)
	PlayerData:InitializePlayer(player)
	print(player.Name .. " joined the game")
end)

Players.PlayerRemoving:Connect(function(player)
	print(player.Name .. " left the game")
	if gameState.currentKiller == player then
		gameState.currentKiller = nil
	end
end)

-- Main game loop
local function gameLoop()
	while true do
		local players = Players:GetPlayers()
		
		-- INTERMISSION PHASE
		if gameState.phase == RoundConfig.PHASES.INTERMISSION then
			print("📍 INTERMISSION PHASE")
			gameState.timer = RoundConfig.INTERMISSION_LENGTH
			
			while gameState.timer > 0 and gameState.phase == RoundConfig.PHASES.INTERMISSION do
				gameState.timer = gameState.timer - 1
				Shared.Events.TimerUpdate:FireAllClients("Intermission", gameState.timer)
				wait(1)
			end
			
			-- Check if enough players
			if #players < RoundConfig.MIN_PLAYERS_TO_START then
				print("⚠️ Not enough players. Waiting in intermission...")
				gameState.timer = 10
				wait(10)
				continue
			end
			
			gameState.phase = RoundConfig.PHASES.PREPARING
		end
		
		-- PREPARING PHASE
		if gameState.phase == RoundConfig.PHASES.PREPARING then
			print("🎯 PREPARING PHASE")
			
			-- Select Killer based on Malice
			local killer, malice = PlayerData:GetHighestMalicePlayer(players)
			gameState.currentKiller = killer
			gameState.survivors = {}
			
			for _, player in pairs(players) do
				if player ~= killer then
					table.insert(gameState.survivors, player)
				end
			end
			
			print("🔴 Killer selected: " .. killer.Name .. " (Malice: " .. malice .. ")")
			print("🔵 Survivors: " .. #gameState.survivors)
			
			-- Load random map
			local availableMaps = MapManager:GetAvailableMaps()
			if #availableMaps == 0 then
				error("No maps found in ServerStorage/Maps!")
			end
			gameState.currentMap = MapManager:LoadMap(availableMaps[math.random(1, #availableMaps)])
			print("📍 Map loaded: " .. gameState.currentMap.Name)
			
			-- Teleport players and morph them
			require(ServerStorage:WaitForChild("CharacterSystem")):MorphPlayers(gameState.currentKiller, gameState.survivors, gameState.currentMap)
			
			gameState.timer = RoundConfig.PREPARING_LENGTH
			while gameState.timer > 0 do
				gameState.timer = gameState.timer - 1
				wait(1)
			end
			
			gameState.phase = RoundConfig.PHASES.PLAYING
		end
		
		-- PLAYING PHASE
		if gameState.phase == RoundConfig.PHASES.PLAYING then
			print("⚔️ PLAYING PHASE")
			gameState.timer = RoundConfig.ROUND_LENGTH
			
			while gameState.timer > 0 and gameState.phase == RoundConfig.PHASES.PLAYING do
				gameState.timer = gameState.timer - 1
				Shared.Events.TimerUpdate:FireAllClients("Round", gameState.timer)
				
				-- Check if any survivors alive
				local aliveCount = 0
				for _, player in pairs(gameState.survivors) do
					if player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
						aliveCount = aliveCount + 1
					end
				end
				
				-- All survivors dead = Killer wins
				if aliveCount == 0 then
					print(" Killer won")
					gameState.phase = RoundConfig.PHASES.ENDING
					break
				end
				
				wait(1)
			end
			
			-- Timer reached 0 = Survivors win
			if gameState.timer <= 0 and gameState.phase == RoundConfig.PHASES.PLAYING then
				print("🎉 Survivors WIN!")
				gameState.phase = RoundConfig.PHASES.ENDING
			end
		end
		
		-- ENDING PHASE
		if gameState.phase == RoundConfig.PHASES.ENDING then
			print("🏁 ENDING PHASE")
			Shared.Events.RoundEnded:FireAllClients()
			
			-- Distribute rewards
			local killerData = PlayerData:GetPlayerData(gameState.currentKiller)
			if killerData.stats.killerWins then
				killerData.stats.killerWins = killerData.stats.killerWins + 1
			end
			PlayerData:AddRewards(gameState.currentKiller, RoundConfig.REWARDS.KILLER_WIN.exp, RoundConfig.REWARDS.KILLER_WIN.points)
			
			for _, survivor in pairs(gameState.survivors) do
				local survivorData = PlayerData:GetPlayerData(survivor)
				if survivorData.stats.survivorWins then
					survivorData.stats.survivorWins = survivorData.stats.survivorWins + 1
				end
				PlayerData:AddRewards(survivor, RoundConfig.REWARDS.SURVIVOR_WIN.exp, RoundConfig.REWARDS.SURVIVOR_WIN.points)
			end
			
			-- Cleanup
			if gameState.currentMap then
				MapManager:UnloadMap(gameState.currentMap)
				gameState.currentMap = nil
			end
			
			wait(RoundConfig.ENDING_LENGTH)
			gameState.phase = RoundConfig.PHASES.INTERMISSION
		end
	end
end

-- Start game loop
gameLoop()