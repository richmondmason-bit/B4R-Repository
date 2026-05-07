-- EnemyService.lua
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DamageTracker = require(script.Parent:WaitForChild("DamageTracker"))
-- CombatHelper is optional for other systems to call
local CombatHelper = require(script.Parent:WaitForChild("CombatHelper"))

local EnemyService = {}
EnemyService.__index = EnemyService

function EnemyService.new(remotesFolder, eventBus, options)
    options = options or {}
    local self = setmetatable({
        remotes = remotesFolder,
        eventBus = eventBus,
        enemies = {}, -- id -> data
        nextId = 0,
        templates = {}, -- name -> model
        behaviors = {}, -- name -> behavior module
        damageTracker = DamageTracker.new({ eventBus = eventBus, remotes = remotesFolder }),
        updateInterval = options.updateInterval or 0.12,
    }, EnemyService)
    return self
end

-- Register a template model (must contain a Humanoid)
function EnemyService:RegisterTemplate(name, model)
    self.templates[name] = model
end

-- Register a behavior module (must implement hooks)
function EnemyService:RegisterBehavior(name, behaviorModule)
    self.behaviors[name] = behaviorModule
end

-- Spawn using template name and optional behaviorName
function EnemyService:SpawnFromTemplate(templateName, cframe, behaviorName)
    local template = self.templates[templateName]
    if not template then return nil, "no template" end
    return self:SpawnEnemy(template:Clone(), cframe, behaviorName)
end

function EnemyService:SpawnEnemy(model, cframe, behaviorName)
    self.nextId = self.nextId + 1
    local id = self.nextId

    -- ensure PrimaryPart and Humanoid
    model.Parent = workspace
    model.PrimaryPart = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
    if model.PrimaryPart then
        model:SetPrimaryPartCFrame(cframe)
    else
        model:PivotTo(cframe)
    end

    local humanoid = model:FindFirstChildOfClass("Humanoid")
    if not humanoid then
        warn("Enemy template missing Humanoid")
    end

    local behavior = nil
    if behaviorName and self.behaviors[behaviorName] then
        behavior = self.behaviors[behaviorName]
    end

    local data = {
        id = id,
        model = model,
        humanoid = humanoid,
        hp = humanoid and humanoid.Health or 0,
        behavior = behavior,
        created = tick(),
        lastUpdate = tick(),
    }
    self.enemies[id] = data

    -- attach damage tracking for any source of damage
    if humanoid then
        self.damageTracker:TrackHumanoid(humanoid, id)
    end

    -- call behavior OnSpawn
    if behavior and type(behavior.OnSpawn) == "function" then
        pcall(behavior.OnSpawn, behavior, data)
    end

    -- broadcast spawn to clients (send model position and optionally model reference)
    if self.remotes and self.remotes:FindFirstChild("EnemySpawn") then
        local pos = model.PrimaryPart and model.PrimaryPart.Position or model:GetModelCFrame().p
        self.remotes.EnemySpawn:FireAllClients(id, pos)
    end

    -- start update loop
    spawn(function()
        while self.enemies[id] do
            local ok, err = pcall(function()
                self:_updateEnemy(id)
            end)
            if not ok then warn("Enemy update error:", err) end
            wait(self.updateInterval)
        end
    end)

    return id
end

function EnemyService:_updateEnemy(id)
    local data = self.enemies[id]
    if not data then return end
    local humanoid = data.humanoid
    -- update behavior
    if data.behavior and type(data.behavior.OnUpdate) == "function" then
        pcall(data.behavior.OnUpdate, data.behavior, data, self)
    else
        -- default idle behavior: small jitter
        if data.model and data.model.PrimaryPart then
            local cur = data.model.PrimaryPart.Position
            local jitter = Vector3.new(math.sin(tick() + id) * 0.05, 0, math.cos(tick() + id) * 0.05)
            data.model:PivotTo(CFrame.new(cur + jitter))
        end
    end

    -- broadcast position/state
    if self.remotes and self.remotes:FindFirstChild("EnemyUpdate") then
        local pos = data.model.PrimaryPart and data.model.PrimaryPart.Position or nil
        local state = (humanoid and humanoid.Health > 0) and "alive" or "dead"
        self.remotes.EnemyUpdate:FireAllClients(id, pos, state)
    end
end

function EnemyService:ApplyDamageByServer(enemyId, amount, source)
    local data = self.enemies[enemyId]
    if not data or not data.humanoid then return false, "no enemy" end
    -- tag source for attribution
    if source then
        if source:IsA("Player") then
            CombatHelper.TagByPlayer(data.humanoid, source)
        else
            CombatHelper.TagDamageSource(data.humanoid, source)
        end
    end
    data.humanoid:TakeDamage(amount)
    return true
end

function EnemyService:DestroyEnemy(enemyId)
    local data = self.enemies[enemyId]
    if not data then return end
    if data.behavior and type(data.behavior.OnDeath) == "function" then
        pcall(data.behavior.OnDeath, data.behavior, data)
    end
    if data.model then
        data.model:Destroy()
    end
    self.enemies[enemyId] = nil
    if self.remotes and self.remotes:FindFirstChild("EnemyDestroyed") then
        self.remotes.EnemyDestroyed:FireAllClients(enemyId)
    end
end

-- Called by DamageTracker via eventBus or directly if you prefer
function EnemyService:OnDamagedServer(enemyId, amount, attacker)
    local data = self.enemies[enemyId]
    if not data then return end
    if data.behavior and type(data.behavior.OnDamaged) == "function" then
        pcall(data.behavior.OnDamaged, data.behavior, data, amount, attacker)
    end
    -- if dead, call DestroyEnemy
    if data.humanoid and data.humanoid.Health <= 0 then
        self:DestroyEnemy(enemyId)
    end
end

return EnemyService


