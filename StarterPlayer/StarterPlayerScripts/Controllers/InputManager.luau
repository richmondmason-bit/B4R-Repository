--this is a modulescript
local UserInputService = game:GetService("UserInputService")

local InputManager = {}
InputManager.__index = InputManager

-- Types
export type InputManagerType = typeof(setmetatable(
	{} :: {
		_moveInput: Vector3,
		_isRunning: boolean,
		_jumpRequested: boolean,
		_shiftLockEnabled: boolean,
		_mouseDelta: Vector2,
		_scrollDelta: number,
		_rightMouseDown: boolean,
		_connections: { RBXScriptConnection },
		_shiftLockCallbacks: { (enabled: boolean) -> () },
		_jumpCallbacks: { () -> () },
	},
	InputManager
))

function InputManager.new(): InputManagerType
	local self = setmetatable({}, InputManager)

	self._moveInput = Vector3.zero
	self._isRunning = false
	self._jumpRequested = false
	self._shiftLockEnabled = false
	self._mouseDelta = Vector2.zero
	self._scrollDelta = 0
	self._rightMouseDown = false
	self._connections = {}
	self._shiftLockCallbacks = {}
	self._jumpCallbacks = {}

	return self
end

-- Keys-Direction mapping
local KEY_DIRECTIONS = {
	[Enum.KeyCode.W] = Vector3.new(0, 0, -1),
	[Enum.KeyCode.S] = Vector3.new(0, 0, 1),
	[Enum.KeyCode.A] = Vector3.new(-1, 0, 0),
	[Enum.KeyCode.D] = Vector3.new(1, 0, 0),
}

function InputManager.Init(self: InputManagerType)
	-- Track which movement keys are held
	local heldKeys: { [Enum.KeyCode]: boolean } = {}

	local function recalcMoveInput()
		local dir = Vector3.zero
		for keyCode, vec in KEY_DIRECTIONS do
			if heldKeys[keyCode] then
				dir += vec
			end
		end
		self._moveInput = if dir.Magnitude > 0 then dir.Unit else Vector3.zero
	end

	-- Input Began
	table.insert(
		self._connections,
		UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if gameProcessed then
				return
			end

			if input.UserInputType == Enum.UserInputType.Keyboard then
				local keyCode = input.KeyCode

				-- Main Movement keys
				if KEY_DIRECTIONS[keyCode] then
					heldKeys[keyCode] = true
					recalcMoveInput()
				end

				-- Sprint (Left Shift)
				if keyCode == Enum.KeyCode.LeftShift then
					self._isRunning = true
				end

				-- Jump
				if keyCode == Enum.KeyCode.Space then
					self._jumpRequested = true
					for _, callback in self._jumpCallbacks do
						callback()
					end
				end

				-- ShiftLock Toggle (Left Ctrl)
				if keyCode == Enum.KeyCode.LeftControl then
					self._shiftLockEnabled = not self._shiftLockEnabled
					for _, callback in self._shiftLockCallbacks do
						callback(self._shiftLockEnabled)
					end
				end
			end

			-- Right mouse button
			if input.UserInputType == Enum.UserInputType.MouseButton2 then
				self._rightMouseDown = true
			end
		end)
	)

	-- Input Ended
	table.insert(
		self._connections,
		UserInputService.InputEnded:Connect(function(input, _gameProcessed)
			if input.UserInputType == Enum.UserInputType.Keyboard then
				local keyCode = input.KeyCode

				if KEY_DIRECTIONS[keyCode] then
					heldKeys[keyCode] = nil
					recalcMoveInput()
				end

				if keyCode == Enum.KeyCode.LeftShift then
					self._isRunning = false
				end
			end

			if input.UserInputType == Enum.UserInputType.MouseButton2 then
				self._rightMouseDown = false
			end
		end)
	)

	-- Mouse movement
	table.insert(
		self._connections,
		UserInputService.InputChanged:Connect(function(input, _gameProcessed)
			if input.UserInputType == Enum.UserInputType.MouseMovement then
				self._mouseDelta = Vector2.new(input.Delta.X, input.Delta.Y)
			end

			if input.UserInputType == Enum.UserInputType.MouseWheel then
				self._scrollDelta = input.Position.Z
			end
		end)
	)
end

--- Returns the current WASD movement direction as a unit vector.
function InputManager.GetMoveDirection(self: InputManagerType): Vector3
	return self._moveInput
end

--- Returns true if the player is holding the run key.
function InputManager.IsRunning(self: InputManagerType): boolean
	return self._isRunning
end

--- Returns true if the player pressed jump this frame, then clears the flag.
function InputManager.ConsumeJump(self: InputManagerType): boolean
	if self._jumpRequested then
		self._jumpRequested = false
		return true
	end
	return false
end

--- Returns true if ShiftLock mode is enabled.
function InputManager.IsShiftLockEnabled(self: InputManagerType): boolean
	return self._shiftLockEnabled
end

--- Returns the mouse delta accumulated since last call, then resets it.
function InputManager.ConsumeMouseDelta(self: InputManagerType): Vector2
	local delta = self._mouseDelta
	self._mouseDelta = Vector2.zero
	return delta
end

--- Returns the scroll delta since last call, then resets it.
function InputManager.ConsumeScrollDelta(self: InputManagerType): number
	local delta = self._scrollDelta
	self._scrollDelta = 0
	return delta
end

--- Returns true if the right mouse button is currently held down.
function InputManager.IsRightMouseDown(self: InputManagerType): boolean
	return self._rightMouseDown
end

--- Register a callback for when shift-lock is toggled.
function InputManager.OnShiftLockToggled(self: InputManagerType, callback: (enabled: boolean) -> ())
	table.insert(self._shiftLockCallbacks, callback)
end

--- Register a callback for when jump is pressed.
function InputManager.OnJump(self: InputManagerType, callback: () -> ())
	table.insert(self._jumpCallbacks, callback)
end

-- Cleanup
function InputManager.Destroy(self: InputManagerType)
	for _, conn in self._connections do
		conn:Disconnect()
	end
	table.clear(self._connections)
	table.clear(self._shiftLockCallbacks)
	table.clear(self._jumpCallbacks)
end

return InputManager

