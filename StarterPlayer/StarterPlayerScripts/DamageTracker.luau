--this is a modulescript
-- DamageTracker.lua
-- Tracks humanoid health changes and reports damage events with attributed source.
local DamageTracker = {}
DamageTracker.__index = DamageTracker

-- options: { eventBus = optional, remotes = optional }
function DamageTracker.new(options)
    options = options or {}
    return setmetatable({
        tracked = {}, -- humanoid -> { lastHealth = number }
        eventBus = options.eventBus,
        remotes = options.remotes,
    }, DamageTracker)
end

local function getAttackerFromHumanoid(humanoid)
    -- common tag patterns: ObjectValue named "LastAttacker" or "creator"
    local v = humanoid:FindFirstChild("LastAttacker") or humanoid:FindFirstChild("creator")
    if v and v.Value and v.Value:IsA("Player") then
        return v.Value
    elseif v and v.Value and v.Value:IsA("Instance") then
        -- could be a tool or projectile; try to find player from it
        local inst = v.Value
        local player = game.Players:GetPlayerFromCharacter(inst.Parent)
        if player then return player end
    end
    return nil
end

function DamageTracker:TrackHumanoid(humanoid, enemyId)
    if not humanoid or not humanoid:IsA("Humanoid") then return end
    if self.tracked[humanoid] then return end

    local state = { lastHealth = humanoid.Health, enemyId = enemyId }
    self.tracked[humanoid] = state

    humanoid.HealthChanged:Connect(function(newHealth)
        local prev = state.lastHealth or humanoid.MaxHealth
        local delta = prev - newHealth
        if delta > 0 then
            -- damage occurred
            local attacker = getAttackerFromHumanoid(humanoid)
            -- publish via eventBus if present
            if self.eventBus and type(self.eventBus.Publish) == "function" then
                self.eventBus:Publish("EnemyDamagedServer", state.enemyId, delta, attacker)
            end
            -- fire remote if provided
            if self.remotes and self.remotes:FindFirstChild("EnemyDamaged") then
                local evt = self.remotes.EnemyDamaged
                -- send attacker UserId if available
                local attackerId = attacker and attacker.UserId or nil
                evt:FireAllClients(state.enemyId, humanoid.Health, attackerId)
            end
        end
        state.lastHealth = newHealth
    end)

    humanoid.Died:Connect(function()
        if self.eventBus and type(self.eventBus.Publish) == "function" then
            self.eventBus:Publish("EnemyDiedServer", state.enemyId)
        end
        if self.remotes and self.remotes:FindFirstChild("EnemyDestroyed") then
            self.remotes.EnemyDestroyed:FireAllClients(state.enemyId)
        end
        self.tracked[humanoid] = nil
    end)
end

function DamageTracker:UntrackHumanoid(humanoid)
    self.tracked[humanoid] = nil
end

return DamageTracker


