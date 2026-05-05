--this is a modulescript
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Config = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Config"))

local CameraController = {}
CameraController.__index = CameraController

-- Types
export type CameraMode = "Default" | "ShiftLock"

export type CameraControllerType = typeof(setmetatable(
	{} :: {
		_inputManager: any,
		_mode: CameraMode,
		_yaw: number,
		_pitch: number,
		_currentZoom: number,
		_targetZoom: number,
		_camera: Camera,
		_crosshair: ImageLabel,
	},
	CameraController
))

function CameraController.new(inputManager: any): CameraControllerType
	local self = setmetatable({}, CameraController)

	self._inputManager = inputManager
	self._mode = "Default" :: CameraMode
	self._yaw = 0
	self._pitch = 0
	self._currentZoom = Config.Camera.DefaultZoom
	self._targetZoom = Config.Camera.DefaultZoom
	self._camera = Workspace.CurrentCamera

	-- ShiftLock crosshair UI
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "ShiftLockCrosshair"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	local crosshair = Instance.new("ImageLabel")
	crosshair.Name = "Crosshair"
	-- Using rbxthumb to ensure the image loads
	crosshair.Image = "rbxthumb://type=Asset&id=5976163147&w=420&h=420"
	crosshair.BackgroundTransparency = 1
	crosshair.Size = UDim2.fromOffset(32, 32)
	crosshair.AnchorPoint = Vector2.new(0.5, 0.5)
	crosshair.Position = UDim2.fromScale(0.5, 0.5)
	crosshair.Visible = false
	crosshair.Parent = screenGui

	screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
	self._crosshair = crosshair

	return self
end

function CameraController.Init(self: CameraControllerType)
	self._camera = Workspace.CurrentCamera
	self._camera.CameraType = Enum.CameraType.Scriptable

	-- Initialize yaw from the camera's current orientation
	local lookVector = self._camera.CFrame.LookVector
	self._yaw = math.atan2(-lookVector.X, -lookVector.Z)
	self._pitch = 0

	-- Listen for shift-lock toggle from InputManager
	self._inputManager:OnShiftLockToggled(function(enabled: boolean)
		if enabled then
			self:SetMode("ShiftLock")
		else
			self:SetMode("Default")
		end
	end)
end

-- Mode Switching
function CameraController.SetMode(self: CameraControllerType, mode: CameraMode)
	self._mode = mode

	if mode == "ShiftLock" then
		UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
		UserInputService.MouseIconEnabled = false
		self._crosshair.Visible = true
	else
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		UserInputService.MouseIconEnabled = true
		self._crosshair.Visible = false
	end
end

function CameraController.GetMode(self: CameraControllerType): CameraMode
	return self._mode
end

--- Returns the camera's flat (Y=0) look direction as a unit vector.
function CameraController.GetLookDirection(self: CameraControllerType): Vector3
	local lookDir = self._camera.CFrame.LookVector
	local flat = Vector3.new(lookDir.X, 0, lookDir.Z)
	return if flat.Magnitude > 0 then flat.Unit else Vector3.new(0, 0, -1)
end

--- Returns the current yaw angle in radians.
function CameraController.GetYaw(self: CameraControllerType): number
	return self._yaw
end

function CameraController.Update(self: CameraControllerType, dt: number)
	local player = Players.LocalPlayer
	local character = player and player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart") :: BasePart
	if not humanoidRootPart then
		return
	end

	-- Ensure camera is scriptable
	if self._camera.CameraType ~= Enum.CameraType.Scriptable then
		self._camera.CameraType = Enum.CameraType.Scriptable
	end

	-- Process mouse input for camera rotation
	local mouseDelta = self._inputManager:ConsumeMouseDelta()
	local shouldRotate = (self._mode == "ShiftLock") or self._inputManager:IsRightMouseDown()

	if shouldRotate then
		local sensitivity = math.rad(Config.Camera.Sensitivity)
		self._yaw -= mouseDelta.X * sensitivity
		self._pitch -= mouseDelta.Y * sensitivity

		-- Clamp pitch
		local minPitch = math.rad(Config.Camera.MinPitch)
		local maxPitch = math.rad(Config.Camera.MaxPitch)
		self._pitch = math.clamp(self._pitch, minPitch, maxPitch)
	end

	-- Lock mouse when right-click is held in default mode
	if self._mode == "Default" then
		if self._inputManager:IsRightMouseDown() then
			UserInputService.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
		else
			UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		end
	end

	-- Process zoom
	local scrollDelta = self._inputManager:ConsumeScrollDelta()
	if scrollDelta ~= 0 then
		self._targetZoom = math.clamp(
			self._targetZoom - scrollDelta * Config.Camera.ZoomStep,
			Config.Camera.MinZoom,
			Config.Camera.MaxZoom
		)
	end

	-- Smoothly interpolate zoom
	self._currentZoom += (self._targetZoom - self._currentZoom) * math.min(1, dt * Config.Camera.ZoomSmoothing)

	-- Compute camera position
	local offset = if self._mode == "ShiftLock" then Config.Camera.ShiftLockOffset else Config.Camera.DefaultOffset

	-- Focus point: the character's root + vertical offset
	local focusPoint = humanoidRootPart.Position + Vector3.new(offset.X, offset.Y, offset.Z)

	-- Camera rotation CFrame
	local rotation = CFrame.fromEulerAnglesYXZ(self._pitch, self._yaw, 0)

	-- Camera position = focusPoint + rotated offset at zoom distance
	local cameraPosition = focusPoint + rotation:VectorToWorldSpace(Vector3.new(0, 0, self._currentZoom))

	-- Camera collision (prevent clipping through walls)
	local rayDirection = cameraPosition - focusPoint
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = { character }

	local result = Workspace:Raycast(focusPoint, rayDirection, raycastParams)
	if result then
		-- Pull camera in front of the wall
		local hitDistance = (result.Position - focusPoint).Magnitude
		local safeDistance = math.max(hitDistance - Config.Camera.CollisionRadius, Config.Camera.MinZoom)
		cameraPosition = focusPoint + rayDirection.Unit * safeDistance
	end

	-- Apply camera CFrame
	self._camera.CFrame = CFrame.lookAt(cameraPosition, focusPoint)

	-- In ShiftLock mode, apply a horizontal offset so camera is over the right shoulder
	if self._mode == "ShiftLock" then
		local rightVector = self._camera.CFrame.RightVector
		self._camera.CFrame = self._camera.CFrame + rightVector * offset.X
	end
end

return CameraController

