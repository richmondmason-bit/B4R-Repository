-- MapManager.lua - Handles map loading and spawn point management
local MapManager = {}

local ServerStorage = game:GetService("ServerStorage")
local MapsFolder = ServerStorage:WaitForChild("Maps")

-- Get all available maps
function MapManager:GetAvailableMaps()
	local maps = {}
	for _, map in pairs(MapsFolder:GetChildren()) do
		if map:IsA("Model") then
			table.insert(maps, map.Name)
		end
	end
	return maps
end

-- Get a specific map by name
function MapManager:GetMap(mapName)
	local map = MapsFolder:FindFirstChild(mapName)
	if not map then
		error("Map '" .. mapName .. "' not found in ServerStorage/Maps")
	end
	return map
end

-- Get survivor spawn points from a map
function MapManager:GetSurvivorSpawns(map)
	local spawns = {}
	local spawnFolder = map:FindFirstChild("SurvivorSpawns")
	
	if not spawnFolder then
		error("Map '" .. map.Name .. "' missing SurvivorSpawns folder")
	end
	
	for _, spawn in pairs(spawnFolder:GetChildren()) do
		if spawn:IsA("Part") or spawn:IsA("BasePart") then
			table.insert(spawns, spawn)
		end
	end
	
	if #spawns == 0 then
		error("Map '" .. map.Name .. "' has no survivor spawn points")
	end
	
	return spawns
end

-- Get killer spawn point from a map
function MapManager:GetKillerSpawn(map)
	local spawn = map:FindFirstChild("KillerSpawn")
	
	if not spawn then
		error("Map '" .. map.Name .. "' missing KillerSpawn part")
	end
	
	return spawn
end

-- Get generator parts from a map
function MapManager:GetGenerators(map)
	local gens = {}
	local gensFolder = map:FindFirstChild("Generators")
	
	if not gensFolder then
		return gens -- Generators optional
	end
	
	for i = 1, 5 do
		local gen = gensFolder:FindFirstChild("Generator" .. i)
		if gen then
			table.insert(gens, gen)
		end
	end
	
	return gens
end

-- Clone and return a map instance
function MapManager:LoadMap(mapName)
	local mapTemplate = self:GetMap(mapName)
	local mapClone = mapTemplate:Clone()
	mapClone.Parent = workspace
	return mapClone
end

-- Unload (delete) a map
function MapManager:UnloadMap(map)
	map:Destroy()
end

-- Get a random survivor spawn point
function MapManager:GetRandomSurvivorSpawn(map)
	local spawns = self:GetSurvivorSpawns(map)
	return spawns[math.random(1, #spawns)]
end

return MapManager