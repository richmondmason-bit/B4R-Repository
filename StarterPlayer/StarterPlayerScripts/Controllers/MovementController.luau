local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")

local Config = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Config"))

local jumpSound = Instance.new("Sound")
jumpSound.Name = "JumpSound"
jumpSound.SoundId = "rbxassetid://109397400639910"
jumpSound.Volume = 0.5
jumpSound.Parent = SoundService

local MovementController = {}
MovementController.__index = MovementController

export type MovementState =
	"Idle"
	| "Walk"
	| "WalkRight"
	| "WalkLeft"
	| "WalkBack"
	| "Run"
	| "RunRight"
	| "RunLeft"
	| "RunBack"
	| "Jump"
	| "Fall"
	| "Land"

export type MovementControllerType = typeof(setmetatable(
	{} :: {
		_inputManager: any,
		_cameraController: any,
		_state: MovementState,
		_previousState: MovementState,
		_isGrounded: boolean,
		_wasGrounded: boolean,
		_landingTimer: number,
		_moveAngle: number,
		_jumpBufferTimer: number,
	},
	MovementController
))

local LANDING_DURATION = 0.25 -- how long the "Land" state lasts

-- Angle thresholds for determining directional movement
-- Forward zone: -45 to 45, Right: 45 to 135, Back: 135 to 180 / -180 to -135, Left: -135 to -45
local ANGLE_FORWARD = 60 -- half-angle of the forward zone
local ANGLE_SIDE = 60 -- half-angle for left/right before it becomes back

function MovementController.new(inputManager: any, cameraController: any): MovementControllerType
	local self = setmetatable({}, MovementController)

	self._inputManager = inputManager
	self._cameraController = cameraController
	self._state = "Idle" :: MovementState
	self._previousState = "Idle" :: MovementState
	self._isGrounded = true
	self._wasGrounded = true
	self._landingTimer = 0
	self._moveAngle = 0
	self._jumpBufferTimer = 0

	return self
end

function MovementController.Init(self: MovementControllerType)
	-- Listen for jump requests and buffer them
	self._inputManager:OnJump(function()
		self._jumpBufferTimer = 0.2
	end)
end

function MovementController.GetState(self: MovementControllerType): MovementState
	return self._state
end

function MovementController.GetPreviousState(self: MovementControllerType): MovementState
	return self._previousState
end

--- Returns the angle between the character's facing direction and movement direction in degrees.
function MovementController.GetMoveAngle(self: MovementControllerType): number
	return self._moveAngle
end

function MovementController.Update(self: MovementControllerType, dt: number)
	local player = Players.LocalPlayer
	local character = player and player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local rootPart = character and character:FindFirstChild("HumanoidRootPart") :: BasePart
	if not humanoid or not rootPart or not player.Character then
		return
	end

	-- Set walk speed based on run state and any other upgrade attributes
	local baseWalk = humanoid:GetAttribute("BaseWalkSpeed") or Config.Movement.BaseWalkSpeed
	local baseRun = baseWalk * (Config.Movement.BaseRunSpeed / Config.Movement.BaseWalkSpeed)
	local baseJump = humanoid:GetAttribute("BaseJumpPower") or Config.Movement.BaseJumpPower

	local isRunning = self._inputManager:IsRunning()
	humanoid.WalkSpeed = if isRunning then baseRun else baseWalk
	humanoid.JumpPower = baseJump

	-- Calculate movement direction relative to camera
	local rawInput = self._inputManager:GetMoveDirection()
	local moveDirection = Vector3.zero

	if rawInput.Magnitude > 0 then
		local cameraYaw = self._cameraController:GetYaw()
		local rotation = CFrame.fromEulerAnglesYXZ(0, cameraYaw, 0)
		moveDirection = rotation:VectorToWorldSpace(rawInput)
		moveDirection = Vector3.new(moveDirection.X, 0, moveDirection.Z)
		if moveDirection.Magnitude > 0 then
			moveDirection = moveDirection.Unit
		end
	end

	humanoid:Move(moveDirection, false)

	-- Character rotation
	local cameraMode = self._cameraController:GetMode()
	humanoid.AutoRotate = false

	if cameraMode == "ShiftLock" then
		-- In ShiftLock, character always faces camera direction
		local lookDir = self._cameraController:GetLookDirection()
		local targetCFrame = CFrame.lookAt(rootPart.Position, rootPart.Position + lookDir)
		rootPart.CFrame = rootPart.CFrame:Lerp(targetCFrame, math.min(1, dt * Config.Movement.TurnSpeed))
	else
		-- In Default mode, character faces movement direction
		if moveDirection.Magnitude > 0 then
			local targetCFrame = CFrame.lookAt(rootPart.Position, rootPart.Position + moveDirection)
			rootPart.CFrame = rootPart.CFrame:Lerp(targetCFrame, math.min(1, dt * Config.Movement.TurnSpeed))
		end
	end

	-- Determine move angle (for directional animations)
	self._moveAngle = 0
	if moveDirection.Magnitude > 0 then
		local facingDir: Vector3
		if cameraMode == "ShiftLock" then
			facingDir = self._cameraController:GetLookDirection()
		else
			facingDir = rootPart.CFrame.LookVector
		end
		facingDir = Vector3.new(facingDir.X, 0, facingDir.Z)
		if facingDir.Magnitude > 0 then
			facingDir = facingDir.Unit
		end

		-- Calculate signed angle between facing direction and move direction
		local cross = facingDir:Cross(moveDirection)
		local dot = facingDir:Dot(moveDirection)
		self._moveAngle = math.deg(math.atan2(cross.Y, dot))
	end

	-- Determine grounded state
	self._wasGrounded = self._isGrounded
	local humanoidState = humanoid:GetState()
	self._isGrounded = (humanoidState ~= Enum.HumanoidStateType.Jumping)
		and (humanoidState ~= Enum.HumanoidStateType.Freefall)

	-- Update landing timer
	if self._isGrounded and not self._wasGrounded then
		-- Just landed
		self._landingTimer = LANDING_DURATION
	end

	if self._landingTimer > 0 then
		self._landingTimer -= dt
	end

	-- Handle Jump
	if self._jumpBufferTimer > 0 then
		self._jumpBufferTimer -= dt
	end

	if
		(self._jumpBufferTimer > 0 or humanoid.Jump)
		and self._isGrounded
		and humanoidState ~= Enum.HumanoidStateType.Jumping
	then
		self._jumpBufferTimer = 0
		humanoid.Jump = false
		humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		humanoidState = Enum.HumanoidStateType.Jumping
		jumpSound:Play()
	end

	-- Determine movement state
	self._previousState = self._state

	if humanoidState == Enum.HumanoidStateType.Jumping then
		self._state = "Jump"
	elseif humanoidState == Enum.HumanoidStateType.Freefall then
		self._state = "Fall"
	elseif self._landingTimer > 0 and moveDirection.Magnitude == 0 then
		self._state = "Land"
	elseif moveDirection.Magnitude > 0 then
		-- Determine directional state based on move angle
		local angle = math.abs(self._moveAngle)

		if cameraMode == "ShiftLock" then
			-- In ShiftLock, we have full directional animations
			if angle < ANGLE_FORWARD then
				-- Moving forward
				self._state = if isRunning then "Run" else "Walk"
			elseif angle > (180 - ANGLE_SIDE) then
				-- Moving backward
				self._state = if isRunning then "RunBack" else "WalkBack"
			elseif self._moveAngle < 0 then
				-- Moving right
				self._state = if isRunning then "RunRight" else "WalkRight"
			else
				-- Moving left
				self._state = if isRunning then "RunLeft" else "WalkLeft"
			end
		else
			-- In Default mode, character's direction is always forward
			self._state = if isRunning then "Run" else "Walk"
		end
	else
		self._state = "Idle"
	end
end

return MovementController

