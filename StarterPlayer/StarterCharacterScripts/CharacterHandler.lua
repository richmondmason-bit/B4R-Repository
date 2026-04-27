-- CharacterHandler.localscript - Handles character spawning with blank rig
local character = script.Parent
local humanoid = character:WaitForChild("Humanoid")
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- This script runs when the player spawns
-- The server will morph the character into the selected character model during the round

print("Character spawned: " .. character.Name)