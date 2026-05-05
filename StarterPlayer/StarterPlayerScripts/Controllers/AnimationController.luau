--this is a modulescript
local Players = game:GetService("Players")

local Config = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Config"))

local AnimationController = {}
AnimationController.__index = AnimationController

-- Types
export type AnimationControllerType = typeof(setmetatable(
	{} :: {
		_movementController: any,
		_tracks: { [string]: AnimationTrack },
		_currentAnim: string,
		_isTransitioning: boolean,
		_transitionTrack: AnimationTrack?,
		_characterConnection: RBXScriptConnection?,
		_diedConnection: RBXScriptConnection?,
	},
	AnimationController
))

-- State-Animation mapping
local STATE_TO_ANIM: { [string]: string } = {
	Idle = "Idle",
	Walk = "Walk",
	WalkRight = "WalkRight",
	WalkLeft = "WalkLeft",
	WalkBack = "WalkBack",
	Run = "Run",
	RunRight = "RunRight",
	RunLeft = "RunLeft",
	RunBack = "RunBack",
	Jump = "Jump",
	Fall = "Fall",
	Land = "Land",
}

-- Transition animation mapping: { fromState -> toState -> transitionAnimName }
local TRANSITIONS: { [string]: { [string]: string } } = {
	Walk = {
		Idle = "WalkEnd",
		Run = "WalkToRun",
	},
	WalkBack = {
		Idle = "BackWalkEnd",
	},
	WalkLeft = {
		Idle = "LeftWalkEnd",
	},
	WalkRight = {
		Idle = "RightWalkEnd",
	},
	Run = {
		Idle = "RunEnd",
		Walk = "RunToWalk",
	},
	RunBack = {
		Idle = "RunEnd",
	},
	RunLeft = {
		Idle = "RunEnd",
	},
	RunRight = {
		Idle = "RunEnd",
	},
}

function AnimationController.new(movementController: any): AnimationControllerType
	local self = setmetatable({}, AnimationController)

	self._movementController = movementController
	self._tracks = {}
	self._currentAnim = ""
	self._isTransitioning = false
	self._transitionTrack = nil
	self._characterConnection = nil
	self._diedConnection = nil

	return self
end

function AnimationController.Init(self: AnimationControllerType)
	local player = Players.LocalPlayer

	-- Load animations when character spawns
	local function onCharacterAdded(character: Model)
		self:_ClearTracks()

		-- Wait for the Humanoid and its Animator
		local humanoid = character:WaitForChild("Humanoid") :: Humanoid
		local animator = humanoid:WaitForChild("Animator") :: Animator

		-- Disable default Roblox animations:
		-- The Animate script may not exist yet when the character first loads,
		-- so we both check immediately AND watch for it to be added later.
		local function destroyAnimateScript()
			local animate = character:FindFirstChild("Animate")
			if animate then
				animate:Destroy()
			end
		end

		destroyAnimateScript()

		-- Watch for the Animate script being added after our check
		local childAddedConn: RBXScriptConnection
		childAddedConn = character.ChildAdded:Connect(function(child)
			if child.Name == "Animate" then
				child:Destroy()
			end
		end)

		-- Also give it a moment to appear and re-check
		task.delay(0.5, destroyAnimateScript)

		-- Stop any default animation tracks that Roblox may have already loaded
		for _, track in animator:GetPlayingAnimationTracks() do
			track:Stop(0)
			track:Destroy()
		end

		-- Load all animation tracks
		self:_LoadAnimations(animator)

		-- Reset state
		self._currentAnim = ""
		self._isTransitioning = false

		-- Play idle immediately
		if self._tracks["Idle"] then
			self._tracks["Idle"]:Play(0.1)
			self._currentAnim = "Idle"
		end

		-- Handle death (stop all animations and clean up)
		if self._diedConnection then
			self._diedConnection:Disconnect()
		end
		self._diedConnection = humanoid.Died:Connect(function()
			self:_StopAllTracks()
			childAddedConn:Disconnect()
		end)
	end

	if player.Character then
		task.spawn(onCharacterAdded, player.Character)
	end

	self._characterConnection = player.CharacterAdded:Connect(onCharacterAdded)
end

-- Animation Loading
function AnimationController._LoadAnimations(self: AnimationControllerType, animator: Animator)
	for name, assetId in Config.Animations do
		local animation = Instance.new("Animation")
		animation.AnimationId = assetId
		local track = animator:LoadAnimation(animation)

		-- Configure track properties
		track.Priority = Enum.AnimationPriority.Action

		-- Looping for movement anims, not for one-shots
		local isOneShot = (
			name == "Jump"
			or name == "Land"
			or name == "WalkEnd"
			or name == "RunEnd"
			or name == "WalkToRun"
			or name == "RunToWalk"
			or name == "BackWalkEnd"
			or name == "LeftWalkEnd"
			or name == "RightWalkEnd"
		)

		track.Looped = not isOneShot

		self._tracks[name] = track
	end
end

function AnimationController.Update(self: AnimationControllerType, _dt: number)
	local state = self._movementController:GetState()
	local _previousState = self._movementController:GetPreviousState()
	local targetAnim = STATE_TO_ANIM[state]

	if not targetAnim then
		return
	end
	if targetAnim == self._currentAnim then
		return
	end

	-- Interrupt any in-progress transition immediately
	if self._isTransitioning then
		self._isTransitioning = false
		if self._transitionTrack then
			self._transitionTrack:Stop(0)
			self._transitionTrack = nil
		end
	end

	-- Check if there's a transition animation to play
	local fromState = self._currentAnim
	local transitions = TRANSITIONS[fromState]
	local transitionAnim = transitions and transitions[targetAnim]

	if transitionAnim and self._tracks[transitionAnim] then
		self:_PlayTransition(transitionAnim, targetAnim)
	else
		self:_CrossfadeTo(targetAnim)
	end
end

-- Internal animation playback
function AnimationController._CrossfadeTo(self: AnimationControllerType, animName: string)
	local track = self._tracks[animName]
	if not track then
		return
	end

	-- Determine fade time based on animation type
	local fadeTime = Config.AnimationBlend.DefaultFade
	if animName == "Jump" then
		fadeTime = Config.AnimationBlend.JumpFade
	elseif animName == "Land" then
		fadeTime = Config.AnimationBlend.LandFade
	end

	-- Stop the old animation
	local oldTrack = self._tracks[self._currentAnim]
	if oldTrack and oldTrack.IsPlaying then
		oldTrack:Stop(fadeTime)
	end

	-- Play the new animation
	track:Play(fadeTime)
	self._currentAnim = animName
end

function AnimationController._PlayTransition(self: AnimationControllerType, transitionName: string, targetAnim: string)
	local transTrack = self._tracks[transitionName]
	if not transTrack then
		-- Fallback to direct crossfade
		self:_CrossfadeTo(targetAnim)
		return
	end

	local fadeTime = Config.AnimationBlend.TransitionFade

	-- Stop old animation
	local oldTrack = self._tracks[self._currentAnim]
	if oldTrack and oldTrack.IsPlaying then
		oldTrack:Stop(fadeTime)
	end

	-- Play transition animation
	self._isTransitioning = true
	self._transitionTrack = transTrack
	transTrack:Play(fadeTime)

	-- When transition ends, crossfade to target
	local connection: RBXScriptConnection
	connection = transTrack.Stopped:Connect(function()
		connection:Disconnect()
		if self._isTransitioning then
			self._isTransitioning = false
			self._transitionTrack = nil
			self:_CrossfadeTo(targetAnim)
		end
	end)

	-- Update current anim to the transition so we don't re-trigger
	self._currentAnim = transitionName
end

function AnimationController._StopAllTracks(self: AnimationControllerType)
	for _, track in self._tracks do
		if track.IsPlaying then
			track:Stop(0.1)
		end
	end
	self._currentAnim = ""
	self._isTransitioning = false
end

function AnimationController._ClearTracks(self: AnimationControllerType)
	self:_StopAllTracks()
	table.clear(self._tracks)
end

-- Cleanup
function AnimationController.Destroy(self: AnimationControllerType)
	self:_ClearTracks()
	if self._characterConnection then
		self._characterConnection:Disconnect()
	end
	if self._diedConnection then
		self._diedConnection:Disconnect()
	end
end

return AnimationController

