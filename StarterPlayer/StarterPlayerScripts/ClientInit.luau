-- this is a localscript
local RunService = game:GetService("RunService")
local PlayerScripts = game:GetService("Players").LocalPlayer:WaitForChild("PlayerScripts")

-- Disable default Roblox camera and controls
local PlayerModule = require(PlayerScripts:WaitForChild("PlayerModule"))
local controls = PlayerModule:GetControls()
controls:Disable()

local Controllers = script:WaitForChild("Controllers")

local InputManager = require(Controllers:WaitForChild("InputManager"))
local CameraController = require(Controllers:WaitForChild("CameraController"))
local MovementController = require(Controllers:WaitForChild("MovementController"))
local AnimationController = require(Controllers:WaitForChild("AnimationController"))

-- Create controller instances
local inputManager = InputManager.new()
local cameraController = CameraController.new(inputManager)
local movementController = MovementController.new(inputManager, cameraController)
local animationController = AnimationController.new(movementController)

-- Initialize all systems (order matters)
inputManager:Init()
cameraController:Init()
movementController:Init()
animationController:Init()

-- Main loop
RunService:BindToRenderStep("Movement_Update", Enum.RenderPriority.Camera.Value, function(dt: number)
	cameraController:Update(dt)
	movementController:Update(dt)
	animationController:Update(dt)
end)

