-- ============================================
-- AUTO ATTACK - Blox Fruits
-- Enlarge hitbox + fire attack remotes trong range
-- ============================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local Net = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Net")

-- Lấy range từ getgenv() nếu có, fallback 60
local function getRange()
    return getgenv().AttackRange or 60
end

task.spawn(function()
    while task.wait(0.05) do
        local char = LocalPlayer.Character
        if not char then continue end

        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChild("Humanoid")
        if not hrp or not hum or hum.Health <= 0 then continue end

        pcall(function()
            local enemyFolder = Workspace:FindFirstChild("Enemies")
            if not enemyFolder then return end

            for _, enemy in ipairs(enemyFolder:GetChildren()) do
                if not enemy:IsA("Model") then continue end

                local eHRP = enemy:FindFirstChild("HumanoidRootPart")
                local eHum = enemy:FindFirstChild("Humanoid")
                if not eHRP or not eHum or eHum.Health <= 0 then continue end

                local dist = (hrp.Position - eHRP.Position).Magnitude
                if dist <= getRange() then
                    -- Enlarge hitbox để server nhận hit
                    eHRP.Size = Vector3.new(10, 10, 10)
                    eHRP.Transparency = 1

                    -- Fire attack remotes
                    Net["RE/RegisterAttack"]:FireServer()
                    Net["RE/RegisterHit"]:FireServer(eHRP)
                    Remotes.SegmentHit:FireServer(enemy)
                end
            end
        end)
    end
end)
