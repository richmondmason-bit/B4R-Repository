-- ServerBootstrap.lua (excerpt)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local shared = ReplicatedStorage:FindFirstChild("RbxForgeShared") or Instance.new("Folder", ReplicatedStorage)
shared.Name = "RbxForgeShared"
local remotes = shared:FindFirstChild("Remotes") or Instance.new("Folder", shared)
remotes.Name = "Remotes"

-- ensure remotes exist (EnemySpawn, EnemyUpdate, EnemyDamaged, EnemyDestroyed, RequestAttack)
local function ensure(name)
    local r = remotes:FindFirstChild(name)
    if not r then
        r = Instance.new("RemoteEvent")
        r.Name = name
        r.Parent = remotes
    end
    return r
end
ensure("EnemySpawn"); ensure("EnemyUpdate"); ensure("EnemyDamaged"); ensure("EnemyDestroyed"); ensure("RequestAttack")

local DamageTracker = require(script.Services.DamageTracker)
local CombatHelper = require(script.Services.CombatHelper)
local EnemyService = require(script.Services.EnemyService)
local MeleeBehavior = require(script.Services.Behaviors.MeleeBehavior)

local eventBus = {
    Publish = function() end, -- optional; replace with your EventBus
}

local enemyService = EnemyService.new(remotes, eventBus)
enemyService:RegisterBehavior("Melee", MeleeBehavior)

-- Example: register template from ServerStorage
local ServerStorage = game:GetService("ServerStorage")
local template = ServerStorage:FindFirstChild("EnemyTemplate")
if template then
    enemyService:RegisterTemplate("Default", template)
    -- spawn a few
    for i = 1, 3 do
        enemyService:SpawnFromTemplate("Default", CFrame.new(Vector3.new(i*6, 5, 0)), "Melee")
    end
end

-- wire DamageTracker events to EnemyService
-- if you use eventBus in DamageTracker, subscribe to "EnemyDamagedServer"
if eventBus and type(eventBus.Publish) == "function" then
    -- replace with your EventBus subscribe pattern
end

-- wire RequestAttack remote (example: client intent)
remotes.RequestAttack.OnServerEvent:Connect(function(player, payload)
    if type(payload) ~= "table" then return end
    local enemyId = payload.enemyId
    local ts = payload.ts or tick()
    -- validate and apply via your CombatService; for simple example:
    -- tag and apply small damage
    local success, reason = enemyService:ApplyDamageByServer(enemyId, 10, player)
    if not success then warn("Attack failed:", reason) end
end)


