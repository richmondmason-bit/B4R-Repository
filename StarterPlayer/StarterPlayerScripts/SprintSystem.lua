

-- SprintSystem v3.9.5 - fixed edge cases
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- VARIABLES
local character, humanoid, rootPart, animator
local sprintTrack, walkTrack, idleTrack, injuredWalkTrack, injuredSprintTrack
local jumpTrack, fallTrack, slideTrack, vaultTrack
local leftWallRunTrack, rightWallRunTrack, wallJumpTrack
local rollTrack

local isSprinting = false
local isSliding = false
local isAirborne = false
local isVaulting = false
local isWallRunning = false
local isExhausted = false
local isSlideOnCooldown = false
local isDashing = false
local isDashOnCooldown = false
local isLedgeGrabbing = false
local isLedgeGrabOnCooldown = false
local isRolling = false

local lastMoveState = "Idle"

-- STAMINA
local STAMINA_MAX = 100
local stamina = STAMINA_MAX
local displayedStamina = STAMINA_MAX
local DRAIN_RATE = 9
local JUMP_DRAIN = 8
local REGEN_RATE = 33
local STAMINA_REGEN_DELAY = 0.8
local EXHAUSTION_DURATION = 0.6
local EXHAUSTED_SPEED = 15

local lastSprintTime = 0
local exhaustionEndTime = 0

-- Slide (Shorter Burst + Cooldown)
local MAX_SLIDE_DISTANCE = 25
local SLIDE_ACTIVATION_COST = 19
local SLIDE_JOLT_BOOST = 38
local SLIDE_COAST_SPEED = 44
local SLIDE_MIN_FORWARD_DOT = 0.3
local SLIDE_COOLDOWN = 3

local slideCooldownEndTime = 0
local slideStartPos = Vector3.new()

-- Dash
local DASH_KEY = Enum.KeyCode.Tab
local DASH_ACTIVATION_COST = 12
local DASH_SPEED = 100
local DASH_DURATION = 0.3
local DASH_COOLDOWN = 1.2
local dashCooldownEndTime = 0
local lastDashPressTime = 0
local DASH_PRESS_WINDOW = 0.12

-- Ledge Grab
local LEDGE_GRAB_KEY = Enum.KeyCode.Space
local LEDGE_GRAB_COST = 5
local LEDGE_GRAB_COOLDOWN = 2
local LEDGE_GRAB_DETECTION_DISTANCE = 5
local LEDGE_GRAB_HEIGHT_RANGE = {min = 2, max = 5}
local ledgeGrabCooldownEndTime = 0
local ledgeGrabEndTime = 0
local LEDGE_GRAB_MAX_TIME = 5

-- Fall Roll System
local FALL_ROLL_KEY = Enum.KeyCode.Space
local FALL_ROLL_MIN_HEIGHT = 8
local FALL_DAMAGE_THRESHOLD = 10
local FALL_DAMAGE_MULTIPLIER = 2
local FALL_ROLL_FORWARD_BOOST = 40
local FALL_ROLL_COOLDOWN = 0.5
local fallStartHeight = 0
local fallStartTime = 0
local canPerformRoll = false
local lastRollTime = 0

-- Speeds / Visuals
local WALK_SPEED = 18
local SPRINT_SPEED = 34
local WALK_FOV = 65
local SPRINT_FOV = 85
local SLIDE_FOV = 89
local DASH_FOV = 95
local LEDGE_GRAB_FOV = 55
local SLIDE_HIPHEIGHT_MULTIPLIER = 0.4
local DEFAULT_HIP_HEIGHT = 0

local ANIM_FADE = 0.13
local bobTime = 0
local BOB_SPEED = 10
local BOB_AMOUNT = 0.07

local SLIDE_KEY = Enum.KeyCode.C
local SPRINT_KEY = Enum.KeyCode.Lshift

-- Input buffering
local lastSlidePressTime = 0
local SLIDE_PRESS_WINDOW = 0.12

-- Vaulting
local VAULT_FORWARD_BOOST = 45
local VAULT_UP_BOOST = 27
local VAULT_STAMINA_COST = 8
local VAULT_DETECTION_DISTANCE = 6
local VAULT_DETECTION_HEIGHT = 2.8
local JUMP_COOLDOWN_TIME = 0.34
local jumpCooldown = 0

-- Wall running & wall jumps
local WALLRUN_MAX_TIME = 2
local WALLRUN_DRAIN_MULTIPLIER = 1.5
local WALLRUN_SPEED = 32
local WALLRUN_INITIAL_COST = 8
local WALLJUMP_BOOST = 100
local WALLJUMP_FORWARD_BOOST = 72
local WALLJUMP_UP_BOOST = 32
local WALLJUMP_STAMINA_COST = 10
local WALL_DETECTION_DISTANCE = 3.5

local wallNormal = Vector3.new()
local wallRunEndTime = 0
local DEFAULT_JUMP_POWER = 50

-- Camera Effects
local normalFOV = 65
local cameraShakeIntensity = 0
local baseCameraPos = Vector3.new()


local SPRINT_ANIM_ID = "rbxassetid://102981744469535"
local WALK_ANIM_ID = "rbxassetid://115621394601470"
local IDLE_ANIM_ID = "rbxassetid://73546288362576"
local JUMP_ANIM_ID = "rbxassetid://133807241213526"
local FALL_ANIM_ID = "rbxassetid://96420440880814"
local INJURED_WALK_ANIM_ID = "rbxassetid://75721158532569"
local INJURED_SPRINT_ANIM_ID = "rbxassetid://77599359577586"
local SLIDE_ANIM_ID = "rbxassetid://84580604097398"
local VAULT_ANIM_ID = "rbxassetid://119576414987575"
local LEFT_WALLRUN_ANIM_ID = "rbxassetid://88414621371705"
local RIGHT_WALLRUN_ANIM_ID = "rbxassetid://131608867325804"
local WALLJUMP_ANIM_ID = "rbxassetid://76099378386490"
-- BUG FIX #2: Use unique roll animation instead of walk animation
local ROLL_ANIM_ID = "rbxassetid://115621394601470"  -- CHANGE THIS to a unique roll animation ID

-- SOUND IDS (Using Free Roblox Asset IDs)
local SOUND_IDS = {
	Sprint = "rbxassetid://12222058",       -- Whoosh
	Slide = "rbxassetid://12222058",        -- Slide sound
	Jump = "rbxassetid://12221967",         -- Jump sound
	Land = "rbxassetid://12221967",         -- Land impact
	Dash = "rbxassetid://12222058",         -- Fast whoosh
	Vault = "rbxassetid://12222058",        -- Vault boost
	WallRun = "rbxassetid://12222057",      -- Wall contact
	WallJump = "rbxassetid://12222058",     -- Wall jump whoosh
	Roll = "rbxassetid://12222057",         -- Roll/tumble
	LedgeGrab = "rbxassetid://12221967",    -- Grab sound
	Footstep = "rbxassetid://12221967",     -- Footstep
	Exhausted = "rbxassetid://12222200",    -- Low stamina beep
}


local function createSound(id, volume, pitch, parent)
	local sound = Instance.new("Sound")
	sound.SoundId = id
	sound.Volume = volume or 0.5
	sound.Pitch = pitch or 1
	sound.Parent = parent or rootPart
	return sound
end

local soundCache = {}

local function playSound(soundName, volume, pitch)
	if not rootPart then return end
	
	if not soundCache[soundName] then
		soundCache[soundName] = createSound(SOUND_IDS[soundName], volume or 0.7, pitch or 1)
	end
	
	local sound = soundCache[soundName]
	sound.Volume = volume or 0.7
	sound.Pitch = pitch or (0.95 + math.random() * 0.1) -- Slight randomization
	sound:Stop()
	sound:Play()
end


local function createDustParticles(position, size, count, color)
	local folder = Instance.new("Folder")
	folder.Parent = workspace
	
	for i = 1, count do
		local particle = Instance.new("Part")
		particle.Shape = Enum.PartType.Ball
		particle.Size = Vector3.new(size, size, size)
		particle.Color = color or Color3.fromRGB(200, 200, 200)
		particle.Material = Enum.Material.SmoothPlastic
		particle.CanCollide = false
		particle.CFrame = CFrame.new(position + Vector3.new((math.random() - 0.5) * 2, 0, (math.random() - 0.5) * 2))
		particle.TopSurface = Enum.SurfaceType.Smooth
		particle.BottomSurface = Enum.SurfaceType.Smooth
		particle.Parent = folder
		
		local velocity = Vector3.new(
			(math.random() - 0.5) * 30,
			math.random() * 20 + 10,
			(math.random() - 0.5) * 30
		)
		particle.AssemblyLinearVelocity = velocity
		
		-- Fade out and destroy
		task.spawn(function()
			for t = 1, 20 do
				particle.Transparency = (t / 20)
				task.wait(0.05)
			end
			particle:Destroy()
		end)
	end
end

local function createTrailEffect(startPos, endPos, color, thickness)
	local beam = Instance.new("Part")
	beam.Shape = Enum.PartType.Ball
	beam.Size = Vector3.new(thickness, thickness, (endPos - startPos).Magnitude)
	beam.Color = color or Color3.fromRGB(100, 200, 255)
	beam.Material = Enum.Material.Neon
	beam.CanCollide = false
	beam.CFrame = CFrame.new((startPos + endPos) / 2, endPos)
	beam.TopSurface = Enum.SurfaceType.Smooth
	beam.BottomSurface = Enum.SurfaceType.Smooth
	beam.Parent = workspace
	
	task.spawn(function()
		for t = 1, 10 do
			beam.Transparency = (t / 10) * 0.8
			task.wait(0.03)
		end
		beam:Destroy()
	end)
end

local function screenShake(intensity, duration)
	cameraShakeIntensity = intensity
	task.spawn(function()
		local elapsed = 0
		while elapsed < duration and cameraShakeIntensity > 0 do
			elapsed = elapsed + RunService.Heartbeat:Wait()
			cameraShakeIntensity = math.max(0, cameraShakeIntensity - (intensity / (duration / 0.016)))
		end
		cameraShakeIntensity = 0
	end)
end

local function createMotionBlur(duration)
	-- Create temporary motion blur effect
	local blur = Instance.new("BlurEffect")
	blur.Size = 15
	blur.Parent = camera
	
	task.spawn(function()
		for t = 1, 20 do
			blur.Size = 15 * ((20 - t) / 20)
			task.wait(duration / 20)
		end
		blur:Destroy()
	end)
end

local function tweenSpeed(speed, time)
	time = time or 0.25
	if humanoid then
		TweenService:Create(humanoid, TweenInfo.new(time, Enum.EasingStyle.Quad), {WalkSpeed = speed}):Play()
	end
end

local function tweenFOV(fov)
	if camera then
		TweenService:Create(camera, TweenInfo.new(0.35, Enum.EasingStyle.Quad), {FieldOfView = fov}):Play()
	end
end


local staminaGui = Instance.new("ScreenGui")
staminaGui.Name = "StaminaSystemGui"
staminaGui.ResetOnSpawn = false
staminaGui.Parent = player:WaitForChild("PlayerGui")

local guiFrame = Instance.new("Frame")
guiFrame.Size = UDim2.new(0.32, 0, 0.055, 0)
guiFrame.Position = UDim2.new(0.5, 0, 0.94, 0)
guiFrame.AnchorPoint = Vector2.new(0.5, 0.5)
guiFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
guiFrame.BackgroundTransparency = 0.25
guiFrame.BorderSizePixel = 0
guiFrame.Parent = staminaGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 8)
uiCorner.Parent = guiFrame

local staminaBar = Instance.new("Frame")
staminaBar.Name = "StaminaBar"
staminaBar.Size = UDim2.new(1, 0, 1, 0)
staminaBar.BackgroundColor3 = Color3.fromRGB(80, 255, 120)
staminaBar.BorderSizePixel = 0
staminaBar.Parent = guiFrame

local barCorner = Instance.new("UICorner")
barCorner.CornerRadius = UDim.new(0, 8)
barCorner.Parent = staminaBar

local staminaText = Instance.new("TextLabel")
staminaText.Name = "StaminaText"
staminaText.Size = UDim2.new(1, 0, 1, 0)
staminaText.BackgroundTransparency = 1
staminaText.Text = "100/100"
staminaText.TextColor3 = Color3.fromRGB(255, 255, 255)
staminaText.TextScaled = true
staminaText.Font = Enum.Font.GothamBold
staminaText.Parent = guiFrame

-- Slide Cooldown Label
local slideCooldownLabel = Instance.new("TextLabel")
slideCooldownLabel.Name = "SlideCooldownLabel"
slideCooldownLabel.Size = UDim2.new(0.6, 0, 0.035, 0)
slideCooldownLabel.Position = UDim2.new(0.5, 0, 0.88, 0)
slideCooldownLabel.AnchorPoint = Vector2.new(0.5, 1)
slideCooldownLabel.BackgroundTransparency = 1
slideCooldownLabel.Text = ""
slideCooldownLabel.TextColor3 = Color3.fromRGB(255, 180, 80)
slideCooldownLabel.TextScaled = true
slideCooldownLabel.Font = Enum.Font.GothamSemibold
slideCooldownLabel.TextStrokeTransparency = 0.7
slideCooldownLabel.Parent = staminaGui

-- Dash Cooldown Label
local dashCooldownLabel = Instance.new("TextLabel")
dashCooldownLabel.Name = "DashCooldownLabel"
dashCooldownLabel.Size = UDim2.new(0.6, 0, 0.035, 0)
dashCooldownLabel.Position = UDim2.new(0.5, 0, 0.84, 0)
dashCooldownLabel.AnchorPoint = Vector2.new(0.5, 1)
dashCooldownLabel.BackgroundTransparency = 1
dashCooldownLabel.Text = ""
dashCooldownLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
dashCooldownLabel.TextScaled = true
dashCooldownLabel.Font = Enum.Font.GothamSemibold
dashCooldownLabel.TextStrokeTransparency = 0.7
dashCooldownLabel.Parent = staminaGui

-- Ledge Grab Cooldown Label
local ledgeGrabCooldownLabel = Instance.new("TextLabel")
ledgeGrabCooldownLabel.Name = "LedgeGrabCooldownLabel"
ledgeGrabCooldownLabel.Size = UDim2.new(0.6, 0, 0.035, 0)
ledgeGrabCooldownLabel.Position = UDim2.new(0.5, 0, 0.80, 0)
ledgeGrabCooldownLabel.AnchorPoint = Vector2.new(0.5, 1)
ledgeGrabCooldownLabel.BackgroundTransparency = 1
ledgeGrabCooldownLabel.Text = ""
ledgeGrabCooldownLabel.TextColor3 = Color3.fromRGB(220, 100, 255)
ledgeGrabCooldownLabel.TextScaled = true
ledgeGrabCooldownLabel.Font = Enum.Font.GothamSemibold
ledgeGrabCooldownLabel.TextStrokeTransparency = 0.7
ledgeGrabCooldownLabel.Parent = staminaGui

-- Fall Damage Indicator
local fallDamageLabel = Instance.new("TextLabel")
fallDamageLabel.Name = "FallDamageLabel"
fallDamageLabel.Size = UDim2.new(0.3, 0, 0.08, 0)
fallDamageLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
fallDamageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
fallDamageLabel.BackgroundTransparency = 1
fallDamageLabel.Text = ""
fallDamageLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
fallDamageLabel.TextScaled = true
fallDamageLabel.Font = Enum.Font.GothamBold
fallDamageLabel.TextStrokeTransparency = 0.5
fallDamageLabel.Parent = staminaGui


local function stopAll()
	if not sprintTrack then return end
	walkTrack:Stop(ANIM_FADE)
	sprintTrack:Stop(ANIM_FADE)
	idleTrack:Stop(ANIM_FADE)
	injuredWalkTrack:Stop(ANIM_FADE)
	injuredSprintTrack:Stop(ANIM_FADE)
	slideTrack:Stop(ANIM_FADE)
	if vaultTrack then vaultTrack:Stop(ANIM_FADE) end
	if leftWallRunTrack then leftWallRunTrack:Stop(ANIM_FADE) end
	if rightWallRunTrack then rightWallRunTrack:Stop(ANIM_FADE) end
	if wallJumpTrack then wallJumpTrack:Stop(ANIM_FADE) end
	if jumpTrack then jumpTrack:Stop(ANIM_FADE) end
	if fallTrack then fallTrack:Stop(ANIM_FADE) end
	if rollTrack then rollTrack:Stop(ANIM_FADE) end
end

local function setMoveState(state)
	if lastMoveState == state then return end
	lastMoveState = state
	stopAll()

	if state == "Idle" and idleTrack then idleTrack:Play(ANIM_FADE)
	elseif state == "Walk" and walkTrack then walkTrack:Play(ANIM_FADE)
	elseif state == "Sprint" and sprintTrack then sprintTrack:Play(ANIM_FADE)
	elseif state == "Slide" and slideTrack then slideTrack:Play(ANIM_FADE)
	elseif state == "InjuredWalk" and injuredWalkTrack then injuredWalkTrack:Play(ANIM_FADE)
	elseif state == "InjuredSprint" and injuredSprintTrack then injuredSprintTrack:Play(ANIM_FADE)
	elseif state == "LeftWallRun" and leftWallRunTrack then leftWallRunTrack:Play(ANIM_FADE)
	elseif state == "RightWallRun" and rightWallRunTrack then rightWallRunTrack:Play(ANIM_FADE)
	elseif state == "Roll" and rollTrack then rollTrack:Play(0.15)
	end
end

-- VAULT & WALL DETECTION

local function canVault()
	if not rootPart then return false end
	local forward = rootPart.CFrame.LookVector * VAULT_DETECTION_DISTANCE
	local rayParams = RaycastParams.new()
	rayParams.FilterDescendantsInstances = {character}
	rayParams.FilterType = Enum.RaycastFilterType.Exclude
	rayParams.IgnoreWater = true

	local originHip = rootPart.Position + Vector3.new(0, VAULT_DETECTION_HEIGHT, 0)
	local resultHip = workspace:Raycast(originHip, forward, rayParams)
	if resultHip and (resultHip.Position.Y - rootPart.Position.Y) > 0.5 and (resultHip.Position.Y - rootPart.Position.Y) < 4.5 then return true end

	local originKnee = rootPart.Position + Vector3.new(0, 1.2, 0)
	local resultKnee = workspace:Raycast(originKnee, forward, rayParams)
	if resultKnee and (resultKnee.Position.Y - rootPart.Position.Y) > 0.5 and (resultKnee.Position.Y - rootPart.Position.Y) < 4.5 then return true end
	return false
end

local function getWallNormal()
	if not rootPart then return nil end
	local right = rootPart.CFrame.RightVector
	local rayParams = RaycastParams.new()
	rayParams.FilterDescendantsInstances = {character}
	rayParams.FilterType = Enum.RaycastFilterType.Exclude
	rayParams.IgnoreWater = true

	local resultRight = workspace:Raycast(rootPart.Position, right * WALL_DETECTION_DISTANCE, rayParams)
	if resultRight and resultRight.Instance and math.abs(resultRight.Normal.Y) < 0.8 then
		return {normal = resultRight.Normal, side = "Right"}
	end

	local resultLeft = workspace:Raycast(rootPart.Position, -right * WALL_DETECTION_DISTANCE, rayParams)
	if resultLeft and resultLeft.Instance and math.abs(resultLeft.Normal.Y) < 0.8 then
		return {normal = resultLeft.Normal, side = "Left"}
	end
	return nil
end

-- Ledge Detection
local function detectLedge()
	if not rootPart then return nil end
	local rayParams = RaycastParams.new()
	rayParams.FilterDescendantsInstances = {character}
	rayParams.FilterType = Enum.RaycastFilterType.Exclude
	rayParams.IgnoreWater = true

	local forward = rootPart.CFrame.LookVector * LEDGE_GRAB_DETECTION_DISTANCE
	local originHip = rootPart.Position + Vector3.new(0, LEDGE_GRAB_HEIGHT_RANGE.max, 0)
	
	local result = workspace:Raycast(originHip, forward, rayParams)
	if result then
		local heightDiff = result.Position.Y - rootPart.Position.Y
		if heightDiff >= LEDGE_GRAB_HEIGHT_RANGE.min and heightDiff <= LEDGE_GRAB_HEIGHT_RANGE.max then
			return result.Position
		end
	end
	return nil
end


local function performFallRoll()
	if not rootPart or not canPerformRoll or (tick() - lastRollTime) < FALL_ROLL_COOLDOWN then return end
	
	isRolling = true
	canPerformRoll = false
	lastRollTime = tick()
	
	setMoveState("Roll")
	tweenFOV(DASH_FOV)
	
	-- Sound & Effects
	playSound("Roll", 0.8, 1.2)
	createDustParticles(rootPart.Position, 0.3, 12, Color3.fromRGB(150, 150, 150))
	screenShake(0.15, 0.2)
	
	-- Apply forward boost
	local forwardBoost = rootPart.CFrame.LookVector * FALL_ROLL_FORWARD_BOOST
	rootPart.AssemblyLinearVelocity = rootPart.AssemblyLinearVelocity + forwardBoost
	
	fallStartHeight = rootPart.Position.Y
end


local function performWallJump()
	if not isWallRunning or not wallNormal then return end
	isWallRunning = false
	wallNormal = Vector3.new()
	stopAll()
	if wallJumpTrack then wallJumpTrack:Play(0.15) end

	-- Sound & Effects
	playSound("WallJump", 0.9, 1.1)
	createDustParticles(rootPart.Position, 0.25, 10, Color3.fromRGB(100, 150, 200))
	screenShake(0.2, 0.15)
	createMotionBlur(0.2)

	if rootPart then
		local awayBoost = wallNormal * WALLJUMP_BOOST
		local forwardBoost = rootPart.CFrame.LookVector * WALLJUMP_FORWARD_BOOST
		rootPart.AssemblyLinearVelocity += awayBoost + forwardBoost + Vector3.new(0, WALLJUMP_UP_BOOST, 0)
	end

	stamina = math.max(0, stamina - WALLJUMP_STAMINA_COST)
	lastSprintTime = tick()
	if humanoid then humanoid.JumpPower = DEFAULT_JUMP_POWER end
end

-- LEDGE GRAB
local function grabLedge(ledgePos)
	if isLedgeGrabOnCooldown or not rootPart then return end
	
	-- BUG FIX #1: Stop sprint state before grabbing ledge
	isSprinting = false
	isSliding = false
	
	isLedgeGrabbing = true
	isLedgeGrabOnCooldown = true
	ledgeGrabCooldownEndTime = tick() + LEDGE_GRAB_COOLDOWN
	ledgeGrabEndTime = tick() + LEDGE_GRAB_MAX_TIME
	
	stamina = math.max(0, stamina - LEDGE_GRAB_COST)
	tweenFOV(LEDGE_GRAB_FOV)
	tweenSpeed(0, 0.1) -- Stop movement
	
	-- Sound & Effects
	playSound("LedgeGrab", 0.7, 1.3)
	createDustParticles(ledgePos, 0.2, 8, Color3.fromRGB(180, 180, 180))
	screenShake(0.1, 0.15)
	
	-- Lock player to ledge
	rootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
	rootPart.CFrame = CFrame.new(ledgePos + Vector3.new(0, -2, 0), ledgePos)
end

-- DASH
local function performDash(moveDir)
	if isDashOnCooldown or stamina < DASH_ACTIVATION_COST or isAirborne then return end
	
	isDashing = true
	isDashOnCooldown = true
	dashCooldownEndTime = tick() + DASH_COOLDOWN
	
	stamina = math.max(0, stamina - DASH_ACTIVATION_COST)
	tweenFOV(DASH_FOV)
	
	-- Sound & Effects
	playSound("Dash", 0.85, 1.4)
	createDustParticles(rootPart.Position, 0.35, 15, Color3.fromRGB(100, 200, 255))
	createTrailEffect(rootPart.Position, rootPart.Position + moveDir.Unit * 20, Color3.fromRGB(100, 200, 255), 0.5)
	screenShake(0.25, 0.2)
	createMotionBlur(0.15)
	
	if rootPart then
		local dashDirection = moveDir.Unit * DASH_SPEED
		rootPart.AssemblyLinearVelocity = dashDirection
	end
	
	lastSprintTime = tick()
end


local function loadCharacter(char)
	character = char
	humanoid = character:WaitForChild("Humanoid")
	rootPart = character:WaitForChild("HumanoidRootPart")
	-- BUG FIX #7: Add safety check for animator creation
	animator = humanoid:FindFirstChildOfClass("Animator")
	if not animator then
		animator = Instance.new("Animator")
		animator.Parent = humanoid
	end

	DEFAULT_HIP_HEIGHT = humanoid.HipHeight
	DEFAULT_JUMP_POWER = humanoid.JumpPower

	local animateScript = character:FindFirstChild("Animate")
	if animateScript then animateScript.Disabled = true end

	local function loadAnim(id, priority, looped)
		local anim = Instance.new("Animation")
		anim.AnimationId = id
		local track = animator:LoadAnimation(anim)
		track.Priority = priority
		track.Looped = looped or false
		return track
	end

	walkTrack = loadAnim(WALK_ANIM_ID, Enum.AnimationPriority.Movement, true)
	sprintTrack = loadAnim(SPRINT_ANIM_ID, Enum.AnimationPriority.Action4, true)
	idleTrack = loadAnim(IDLE_ANIM_ID, Enum.AnimationPriority.Movement, true)
	injuredWalkTrack = loadAnim(INJURED_WALK_ANIM_ID, Enum.AnimationPriority.Movement, true)
	injuredSprintTrack = loadAnim(INJURED_SPRINT_ANIM_ID, Enum.AnimationPriority.Action4, true)
	slideTrack = loadAnim(SLIDE_ANIM_ID, Enum.AnimationPriority.Action4, true)
	jumpTrack = loadAnim(JUMP_ANIM_ID, Enum.AnimationPriority.Action, false)
	fallTrack = loadAnim(FALL_ANIM_ID, Enum.AnimationPriority.Action, false)
	vaultTrack = loadAnim(VAULT_ANIM_ID, Enum.AnimationPriority.Action4, false)
	leftWallRunTrack = loadAnim(LEFT_WALLRUN_ANIM_ID, Enum.AnimationPriority.Action4, true)
	rightWallRunTrack = loadAnim(RIGHT_WALLRUN_ANIM_ID, Enum.AnimationPriority.Action4, true)
	wallJumpTrack = loadAnim(WALLJUMP_ANIM_ID, Enum.AnimationPriority.Action, false)
	rollTrack = loadAnim(ROLL_ANIM_ID, Enum.AnimationPriority.Action, false)

	humanoid.HealthChanged:Connect(function(health)
		if health <= 30 and (lastMoveState == "Walk" or lastMoveState == "Sprint" or lastMoveState == "Idle") then
			setMoveState("InjuredSprint")
		end
	end)

	local fallStart = 0
	humanoid.StateChanged:Connect(function(_, newState)
		if newState == Enum.HumanoidStateType.Jumping then
			if tick() < jumpCooldown then
				humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
				return
			end

			isAirborne = true
			fallStart = tick()
			fallStartHeight = rootPart.Position.Y
			canPerformRoll = false
			stopAll()

			-- Sound & Effects
			playSound("Jump", 0.6, 1.1)
			createDustParticles(rootPart.Position, 0.25, 8, Color3.fromRGB(200, 200, 200))
			screenShake(0.12, 0.1)

			local wallData = getWallNormal()
			if wallData then
				isWallRunning = true
				wallNormal = wallData.normal
				wallRunEndTime = tick() + WALLRUN_MAX_TIME
				if humanoid then humanoid.JumpPower = 0 end
				if rootPart then
					local projectedLook = rootPart.CFrame.LookVector - rootPart.CFrame.LookVector:Dot(wallNormal) * wallNormal
					local alongWall = projectedLook.Unit * WALLRUN_SPEED
					rootPart.AssemblyLinearVelocity = alongWall + Vector3.new(0, 12, 0)
				end
				stamina = math.max(0, stamina - WALLRUN_INITIAL_COST)
				
				-- Wall Run SFX
				playSound("WallRun", 0.5, 1.0)
				
				setMoveState(wallData.side == "Left" and "LeftWallRun" or "RightWallRun")
			elseif canVault() then
				if vaultTrack then vaultTrack:Play(0.15) end
				if rootPart then
					local forward = rootPart.CFrame.LookVector
					rootPart.AssemblyLinearVelocity += forward * VAULT_FORWARD_BOOST + Vector3.new(0, VAULT_UP_BOOST, 0)
				end
				stamina = math.max(0, stamina - VAULT_STAMINA_COST)
				isVaulting = true
				
				-- Vault SFX & Effects
				playSound("Vault", 0.8, 1.2)
				createDustParticles(rootPart.Position, 0.3, 12, Color3.fromRGB(150, 200, 100))
				screenShake(0.15, 0.15)
			else
				if jumpTrack then jumpTrack:Play(0.15) end
				if isSliding and rootPart then
					local forwardBoost = rootPart.CFrame.LookVector * 22
					rootPart.AssemblyLinearVelocity += forwardBoost
				end
			end

			stamina = math.max(0, stamina - JUMP_DRAIN)
			if stamina <= 0 and not isExhausted then
				isExhausted = true
				exhaustionEndTime = tick() + EXHAUSTION_DURATION
				tweenSpeed(EXHAUSTED_SPEED, 0.4)
				playSound("Exhausted", 0.6, 0.8)
			end
			jumpCooldown = tick() + JUMP_COOLDOWN_TIME

		elseif newState == Enum.HumanoidStateType.Freefall then
			if not isVaulting and tick() - fallStart > 0.35 then
				if jumpTrack then jumpTrack:Stop(0.2) end
				if fallTrack then fallTrack:Play(0.2) end
				if vaultTrack then vaultTrack:Stop(0.2) end
			end
			
			if (fallStartHeight - rootPart.Position.Y) >= FALL_ROLL_MIN_HEIGHT then
				canPerformRoll = true
			end
			
		elseif newState == Enum.HumanoidStateType.Landed then
			isAirborne = false
			isVaulting = false
			isRolling = false
			isDashing = false
			isLedgeGrabbing = false
			
			if isWallRunning then
				isWallRunning = false
				if humanoid then humanoid.JumpPower = DEFAULT_JUMP_POWER end
			end
			
			-- Land Sound & Effects
			playSound("Land", 0.7, 1.0)
			createDustParticles(rootPart.Position, 0.3, 10, Color3.fromRGB(180, 180, 180))
			screenShake(0.15, 0.12)
			
			-- Fall damage calculation
			local fallHeight = fallStartHeight - rootPart.Position.Y
			if fallHeight >= FALL_DAMAGE_THRESHOLD and not canPerformRoll then
				local damage = math.floor(fallHeight * FALL_DAMAGE_MULTIPLIER)
				humanoid:TakeDamage(damage)
				fallDamageLabel.Text = "FALL DAMAGE: -" .. damage
				fallDamageLabel.TextTransparency = 0
				screenShake(0.3, 0.3)
				task.wait(1.5)
				fallDamageLabel.TextTransparency = 1
			end
			
			canPerformRoll = false
			stopAll()
			lastMoveState = "Idle"
			tweenFOV(WALK_FOV)
		end
	end)

	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		
		if input.KeyCode == Enum.KeyCode.Space then
			if isWallRunning then
				performWallJump()
			elseif isAirborne and canPerformRoll then
				performFallRoll()
			elseif isAirborne then
				local ledgePos = detectLedge()
				if ledgePos then
					grabLedge(ledgePos)
				end
			end
		elseif input.KeyCode == SLIDE_KEY then
			lastSlidePressTime = tick()
		elseif input.KeyCode == DASH_KEY then
			lastDashPressTime = tick()
		end
	end)
end

player.CharacterAdded:Connect(loadCharacter)
if player.Character then loadCharacter(player.Character) end


RunService.RenderStepped:Connect(function(dt)
	if not humanoid or not ((isSprinting or isSliding) and not isAirborne and humanoid.MoveDirection.Magnitude > 0.1) then return end
	bobTime += dt * BOB_SPEED
	local bobY = math.sin(bobTime) * BOB_AMOUNT
	camera.CFrame = camera.CFrame * CFrame.new(0, bobY, 0)
end)

RunService.RenderStepped:Connect(function(dt)
	if camera and cameraShakeIntensity > 0 then
		local shakeAmount = Vector3.new(
			(math.random() - 0.5) * 2 * cameraShakeIntensity,
			(math.random() - 0.5) * 2 * cameraShakeIntensity,
			(math.random() - 0.5) * 2 * cameraShakeIntensity
		)
		camera.CFrame = camera.CFrame * CFrame.new(shakeAmount * 0.01)
	end
end)


RunService.Heartbeat:Connect(function(dt)
	if not humanoid or not rootPart then return end

	local moving = humanoid.MoveDirection.Magnitude > 0.1
	local moveDir = humanoid.MoveDirection
	local sprintKey = UserInputService:IsKeyDown(SPRINT_KEY)
	local slideKey = UserInputService:IsKeyDown(SLIDE_KEY)
	local dashKey = UserInputService:IsKeyDown(DASH_KEY)
	local forwardDot = rootPart.CFrame.LookVector:Dot(humanoid.MoveDirection)
	local canSprint = stamina > 0 and not isExhausted
	local canSlideBurst = stamina >= SLIDE_ACTIVATION_COST and not isExhausted and moving and not isAirborne and forwardDot > SLIDE_MIN_FORWARD_DOT and not isSlideOnCooldown
	local freshSlidePress = (tick() - lastSlidePressTime) < SLIDE_PRESS_WINDOW
	local freshDashPress = (tick() - lastDashPressTime) < DASH_PRESS_WINDOW
	local currentTime = tick()

	-- Update cooldown statuses
	if isSlideOnCooldown and currentTime >= slideCooldownEndTime then
		isSlideOnCooldown = false
	end
	
	if isDashOnCooldown and currentTime >= dashCooldownEndTime then
		isDashOnCooldown = false
	end
	
	if isLedgeGrabOnCooldown and currentTime >= ledgeGrabCooldownEndTime then
		isLedgeGrabOnCooldown = false
	end
	
	if isLedgeGrabbing and currentTime >= ledgeGrabEndTime then
		isLedgeGrabbing = false
		tweenFOV(WALK_FOV)
		tweenSpeed(WALK_SPEED, 0.15) -- BUG FIX #5: Reset speed when ledge grab times out
	end
	
	if isDashing and currentTime >= (lastSprintTime + DASH_DURATION) then
		isDashing = false -- BUG FIX #3: Explicitly reset isDashing flag
		tweenSpeed(WALK_SPEED, 0.15)
		tweenFOV(WALK_FOV)
	end

	-- Slide end condition
	if isSliding and (not slideKey or forwardDot <= 0.1) then
		isSliding = false
		humanoid.HipHeight = DEFAULT_HIP_HEIGHT
		lastSprintTime = currentTime
		tweenSpeed(WALK_SPEED, 0.15)
		tweenFOV(WALK_FOV)
		playSound("Slide", 0.6, 0.9)

		isSlideOnCooldown = true
		slideCooldownEndTime = currentTime + SLIDE_COOLDOWN
	end

	if not isAirborne and not isLedgeGrabbing then
		-- Trigger dash
		if dashKey and moving and freshDashPress and not isDashing and not isDashOnCooldown then
			performDash(moveDir)
		end
		
		-- Trigger slide burst
		if slideKey and canSlideBurst and not isSliding and freshSlidePress then
			isSliding = true
			isSprinting = false
			tweenSpeed(SLIDE_COAST_SPEED, 0.12)
			tweenFOV(SLIDE_FOV)
			humanoid.HipHeight = DEFAULT_HIP_HEIGHT * SLIDE_HIPHEIGHT_MULTIPLIER
			lastSprintTime = currentTime
			slideStartPos = rootPart.Position
			stamina = math.max(0, stamina - SLIDE_ACTIVATION_COST)

			rootPart.AssemblyLinearVelocity += rootPart.CFrame.LookVector * SLIDE_JOLT_BOOST

			-- Slide SFX & Effects
			playSound("Slide", 0.8, 1.1)
			createDustParticles(rootPart.Position, 0.4, 20, Color3.fromRGB(180, 180, 180))
			screenShake(0.2, 0.25)

			setMoveState("Slide")

		elseif isSliding then
			local currentVel = rootPart.AssemblyLinearVelocity
			local forwardDir = rootPart.CFrame.LookVector
			local distanceTraveled = (rootPart.Position - slideStartPos).Magnitude
			local lockStrength = math.clamp(0.85 - (distanceTraveled / MAX_SLIDE_DISTANCE) * 0.45, 0.4, 0.85)

			local lockedVel = forwardDir * currentVel.Magnitude
			rootPart.AssemblyLinearVelocity = currentVel:Lerp(lockedVel, lockStrength)

			if distanceTraveled > MAX_SLIDE_DISTANCE then
				isSliding = false
				humanoid.HipHeight = DEFAULT_HIP_HEIGHT
				lastSprintTime = currentTime
				tweenSpeed(WALK_SPEED, 0.15)
				tweenFOV(WALK_FOV)
				playSound("Slide", 0.5, 0.8)

				isSlideOnCooldown = true
				slideCooldownEndTime = currentTime + SLIDE_COOLDOWN
			end

			setMoveState("Slide")

		elseif sprintKey and moving and canSprint then
			if not isSprinting then
				isSprinting = true
				tweenSpeed(SPRINT_SPEED, 0.2)
				tweenFOV(SPRINT_FOV)
				lastSprintTime = currentTime
				playSound("Sprint", 0.5, 1.0)
			end

			stamina = math.max(0, stamina - DRAIN_RATE * dt)

			if humanoid.Health <= 30 then
				setMoveState("InjuredSprint")
			else
				setMoveState("Sprint")
			end

			if stamina <= 0 and not isExhausted then
				isExhausted = true
				exhaustionEndTime = currentTime + EXHAUSTION_DURATION
				tweenSpeed(EXHAUSTED_SPEED, 0.4)
				playSound("Exhausted", 0.7, 0.7)
			end

		else
			if isSprinting then
				isSprinting = false
				tweenSpeed(WALK_SPEED, 0.2)
				tweenFOV(WALK_FOV)
				lastSprintTime = currentTime
			end

			if isExhausted and currentTime >= exhaustionEndTime then
				isExhausted = false
				tweenSpeed(WALK_SPEED, 0.4)
			end

			if not isExhausted and currentTime - lastSprintTime > STAMINA_REGEN_DELAY then
				stamina = math.min(STAMINA_MAX, stamina + REGEN_RATE * dt)
			end

			if moving then
				setMoveState(humanoid.Health <= 30 and "InjuredWalk" or "Walk")
			else
				setMoveState("Idle")
			end
		end
	end

	-- === MID-AIR WALL RUN ACTIVATION ===
	if not isWallRunning then
		local wallData = getWallNormal()
		if wallData and (isAirborne or humanoid:GetState() == Enum.HumanoidStateType.Freefall) then
			local moveDir = humanoid.MoveDirection
			-- BUG FIX #4: Prevent wall run while sliding
			if moveDir.Magnitude > 0.1 and wallData.normal:Dot(moveDir) < -0.3 and not isSliding then
				isWallRunning = true
				wallNormal = wallData.normal
				wallRunEndTime = currentTime + WALLRUN_MAX_TIME
				if humanoid then humanoid.JumpPower = 0 end

				if rootPart then
					local projectedLook = rootPart.CFrame.LookVector - rootPart.CFrame.LookVector:Dot(wallNormal) * wallNormal
					local alongWall = projectedLook.Unit * WALLRUN_SPEED
					rootPart.AssemblyLinearVelocity = alongWall + Vector3.new(0, 8, 0)
				end

				stamina = math.max(0, stamina - WALLRUN_INITIAL_COST)
				setMoveState(wallData.side == "Left" and "LeftWallRun" or "RightWallRun")
			end
		end
	end

	-- Wall run maintenance
	if isWallRunning then
		local wallData = getWallNormal()

		if currentTime > wallRunEndTime or stamina <= 0 or not wallData or isExhausted then -- BUG FIX #6: Exit wall run if exhausted
			isWallRunning = false
			wallNormal = Vector3.new()
			if humanoid then humanoid.JumpPower = DEFAULT_JUMP_POWER end
			stopAll()
			lastSprintTime = currentTime
		else
			if rootPart then
				local currentVel = rootPart.AssemblyLinearVelocity
				local projected = currentVel - currentVel:Dot(wallNormal) * wallNormal
				local forwardAlongWall = (rootPart.CFrame.LookVector - rootPart.CFrame.LookVector:Dot(wallNormal) * wallNormal).Unit * WALLRUN_SPEED
				rootPart.AssemblyLinearVelocity = projected:Lerp(forwardAlongWall, 0.5) + Vector3.new(0, 3, 0)
			end

			stamina = math.max(0, stamina - DRAIN_RATE * WALLRUN_DRAIN_MULTIPLIER * dt)

			if wallData.side == "Left" then
				setMoveState("LeftWallRun")
			else
				setMoveState("RightWallRun")
			end

			if stamina <= 0 and not isExhausted then
				isExhausted = true
				exhaustionEndTime = currentTime + EXHAUSTION_DURATION
				tweenSpeed(EXHAUSTED_SPEED, 0.4)
			end
		end
	end

	-- GUI Update
	displayedStamina = displayedStamina + (stamina - displayedStamina) * (18 * dt)
	local percent = math.clamp(displayedStamina / STAMINA_MAX, 0, 1)
	staminaBar.Size = UDim2.new(percent, 0, 1, 0)

	local isLowStamina = isExhausted or percent <= 0.2
	local inSlideCooldown = isSlideOnCooldown
	local inDashCooldown = isDashOnCooldown
	local inLedgeGrabCooldown = isLedgeGrabOnCooldown

	if inSlideCooldown then
		staminaBar.BackgroundColor3 = Color3.fromRGB(255, 140, 50)
	elseif isLowStamina then
		staminaBar.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
	elseif percent <= 0.5 then
		staminaBar.BackgroundColor3 = Color3.fromRGB(255, 190, 50)
	else
		staminaBar.BackgroundColor3 = Color3.fromRGB(80, 255, 120)
	end

	staminaText.Text = math.floor(displayedStamina + 0.5) .. "/" .. STAMINA_MAX
	staminaText.TextColor3 = isLowStamina and Color3.fromRGB(255, 90, 90) or Color3.fromRGB(255, 255, 255)

	-- Slide Cooldown Label
	if inSlideCooldown then
		local remaining = math.max(0, math.ceil(slideCooldownEndTime - currentTime))
		slideCooldownLabel.Text = "SLIDE COOLDOWN (" .. remaining .. "s)"
		slideCooldownLabel.TextTransparency = 0
	else
		slideCooldownLabel.TextTransparency = 1
	end
	
	-- Dash Cooldown Label
	if inDashCooldown then
		local remaining = math.max(0, math.ceil(dashCooldownEndTime - currentTime))
		dashCooldownLabel.Text = "DASH COOLDOWN (" .. remaining .. "s)"
		dashCooldownLabel.TextTransparency = 0
	else
		dashCooldownLabel.TextTransparency = 1
	end
	
	-- Ledge Grab Cooldown Label
	if inLedgeGrabCooldown then
		local remaining = math.max(0, math.ceil(ledgeGrabCooldownEndTime - currentTime))
		ledgeGrabCooldownLabel.Text = "LEDGE COOLDOWN (" .. remaining .. "s)"
		ledgeGrabCooldownLabel.TextTransparency = 0
	else
		ledgeGrabCooldownLabel.TextTransparency = 1
	end
end)

print("SprintSystem v3.9.5 loaded ")

