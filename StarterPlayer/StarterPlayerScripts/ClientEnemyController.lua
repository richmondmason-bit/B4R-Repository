--localscript
-- ClientEnemyController.lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local shared = ReplicatedStorage:WaitForChild("RbxForgeShared")
local remotes = shared:WaitForChild("Remotes")

local EnemyVisuals = require(shared:WaitForChild("Client"):WaitForChild("EnemyVisuals"))

local visuals = EnemyVisuals.new()

-- connect remotes
remotes.EnemySpawn.OnClientEvent:Connect(function(id, pos)
    visuals:OnSpawn(id, pos)
end)

remotes.EnemyUpdate.OnClientEvent:Connect(function(id, pos, state)
    visuals:OnUpdate(id, pos, state)
end)

remotes.EnemyDamaged.OnClientEvent:Connect(function(id, hp, attackerUserId)
    visuals:OnDamaged(id, hp)
    -- optional: if attackerUserId == player.UserId then show hit confirmation
end)

remotes.EnemyDestroyed.OnClientEvent:Connect(function(id)
    visuals:OnDestroyed(id)
end)

-- local prediction: when player clicks, show immediate effect and send RequestAttack
local UserInputService = game:GetService("UserInputService")
local lastLocalAttack = 0
local localAttackCooldown = 0.18

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        if tick() - lastLocalAttack < localAttackCooldown then return end
        lastLocalAttack = tick()

        -- pick nearest enemy under mouse or simple raycast
        local mouse = player:GetMouse()
        local targetPos = mouse.Hit and mouse.Hit.Position
        if not targetPos then return end

        -- find nearest visual enemy within a small radius
        local chosenId, chosenDist
        for id, v in pairs(visuals.visuals) do
            local d = (v.part.Position - targetPos).Magnitude
            if not chosenDist or d < chosenDist then
                chosenId = id
                chosenDist = d
            end
        end

        if not chosenId then return end

        -- local immediate effect (prediction)
        spawn(function()
            local v = visuals.visuals[chosenId]
            if v and v.part then
                -- small local hit flash
                local orig = v.part.Color
                v.part.Color = Color3.new(1, 0.6, 0.2)
                wait(0.08)
                if v.part then v.part.Color = orig end
            end
        end)

        -- send attack intent to server with client timestamp
        local payload = { enemyId = chosenId, ts = tick() }
        remotes.RequestAttack:FireServer(payload)
    end
end)

-- interpolation loop
RunService.RenderStepped:Connect(function(dt)
    visuals:Step(dt)
end)


