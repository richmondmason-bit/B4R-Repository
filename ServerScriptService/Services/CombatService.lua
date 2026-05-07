-- CombatService.lua
local CombatService = {}
CombatService.__index = CombatService

-- Dependencies: lagComp, enemyService, remotesFolder
function CombatService.new(lagComp, enemyService, remotesFolder)
    return setmetatable({
        lagComp = lagComp,
        enemyService = enemyService,
        remotes = remotesFolder,
        lastAttack = {}, -- player -> timestamp for rate limiting
        attackCooldown = 0.25,
        maxAttackRange = 12,
        maxDamage = 40,
    }, CombatService)
end

-- Validate an attack intent from player at clientTimestamp
function CombatService:ValidateAttack(player, enemyId, clientTimestamp)
    -- rate limit
    local last = self.lastAttack[player] or 0
    if tick() - last < self.attackCooldown then
        return false, "rate_limited"
    end
    self.lastAttack[player] = tick()

    -- ensure enemy exists
    local enemyPos = self.enemyService:GetEnemyPosition(enemyId)
    if not enemyPos then return false, "no_enemy" end

    -- get enemy state at clientTimestamp using lag compensation
    local state, stateTime = nil, nil
    if self.lagComp then
        state, stateTime = self.lagComp:GetStateAt(enemyId, clientTimestamp)
    end
    -- fallback to current position if no history
    local posToCheck = (state and state.pos) or enemyPos

    -- get player character position server-side
    local char = player.Character
    if not char or not char.PrimaryPart then return false, "no_character" end
    local playerPos = char.PrimaryPart.Position

    local dist = (posToCheck - playerPos).Magnitude
    if dist > self.maxAttackRange then
        return false, "out_of_range"
    end

    -- additional checks could include line of sight, facing, etc.
    return true
end

-- Apply attack: compute damage and call enemyService:ApplyDamage
function CombatService:ApplyAttack(player, enemyId, clientTimestamp)
    local ok, reason = self:ValidateAttack(player, enemyId, clientTimestamp)
    if not ok then return false, reason end

    local damage = math.random(8, self.maxDamage)
    local success, err = self.enemyService:ApplyDamage(enemyId, damage, player, clientTimestamp)
    return success, err
end

return CombatService


