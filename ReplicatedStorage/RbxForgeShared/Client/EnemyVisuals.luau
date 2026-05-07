--This is a modulescript
-- EnemyVisuals.lua
local EnemyVisuals = {}
EnemyVisuals.__index = EnemyVisuals

function EnemyVisuals.new()
    return setmetatable({
        visuals = {}, -- id -> { modelRef = optional, proxy = part, targetPos, state }
    }, EnemyVisuals)
end

function EnemyVisuals:OnSpawn(id, pos, serverModel)
    -- if serverModel is replicated to client, you can reference it; otherwise create a proxy
    if self.visuals[id] then return end
    local proxy = Instance.new("Part")
    proxy.Size = Vector3.new(2,2,2)
    proxy.Anchored = true
    proxy.CanCollide = false
    proxy.Position = pos or Vector3.new()
    proxy.Name = "EnemyProxy_"..id
    proxy.Parent = workspace
    self.visuals[id] = { proxy = proxy, targetPos = pos or proxy.Position, state = "idle" }
end

function EnemyVisuals:OnUpdate(id, pos, state)
    local v = self.visuals[id]
    if not v then
        self:OnSpawn(id, pos)
        v = self.visuals[id]
    end
    v.targetPos = pos or v.targetPos
    v.state = state or v.state
end

function EnemyVisuals:OnDamaged(id, hp)
    local v = self.visuals[id]
    if not v then return end
    spawn(function()
        local p = v.proxy
        if not p then return end
        local orig = p.Color
        p.Color = Color3.new(1, 0.2, 0.2)
        wait(0.12)
        if p then p.Color = orig end
    end)
end

function EnemyVisuals:OnDestroyed(id)
    local v = self.visuals[id]
    if not v then return end
    if v.proxy then v.proxy:Destroy() end
    self.visuals[id] = nil
end

function EnemyVisuals:Step(dt)
    for id, v in pairs(self.visuals) do
        if v.proxy and v.targetPos then
            local cur = v.proxy.Position
            v.proxy.Position = cur:Lerp(v.targetPos, math.clamp(12 * dt, 0, 1))
        end
    end
end

return EnemyVisuals


