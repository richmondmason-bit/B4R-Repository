-- CombatHelper.lua
-- Small helper to tag a Humanoid with the source of damage before applying damage.
local CombatHelper = {}
CombatHelper.__index = CombatHelper

-- Tag a humanoid with an attacker instance (Player, Tool, Projectile instance, etc.)
function CombatHelper.TagDamageSource(humanoid, sourceInstance, lifetime)
    if not humanoid or not humanoid:IsA("Humanoid") then return end
    lifetime = lifetime or 1.5 -- seconds the tag remains
    -- prefer "LastAttacker" name to avoid conflicts
    local tag = humanoid:FindFirstChild("LastAttacker")
    if not tag then
        tag = Instance.new("ObjectValue")
        tag.Name = "LastAttacker"
        tag.Parent = humanoid
    end
    tag.Value = sourceInstance
    -- cleanup after lifetime
    spawn(function()
        local start = tick()
        while tick() - start < lifetime do
            if not humanoid or not humanoid.Parent then break end
            wait(0.1)
        end
        if tag and tag.Parent then
            tag:Destroy()
        end
    end)
end

-- Convenience: tag by player (store the Player instance)
function CombatHelper.TagByPlayer(humanoid, player, lifetime)
    if not player then return end
    CombatHelper.TagDamageSource(humanoid, player, lifetime)
end

return CombatHelper


