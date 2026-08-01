-- ============================================
-- AUTO STATS + AUTO DLCBOX + AUTO ATTACK
-- ============================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local CommF_ = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local Net = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Net")
local LocalPlayer = Players.LocalPlayer

local MAX_STAT = 2800

local function getPoints()
    return LocalPlayer.Data.Points.Value
end

local function getStat(name)
    return LocalPlayer.Data.Stats[name].Level.Value
end

local function addPoint(stat, amount)
    pcall(function()
        CommF_:InvokeServer("AddPoint", stat, amount)
    end)
end

local function calcAdd(stat)
    local current = getStat(stat)
    if current >= MAX_STAT then return 0 end
    local points = getPoints()
    if points <= 0 then return 0 end
    local need = MAX_STAT - current
    return math.min(need, points)
end

-- ===== AUTO STATS =====
task.spawn(function()
    while task.wait(1) do
        pcall(function()
            if getStat("Melee") < MAX_STAT then
                local amt = calcAdd("Melee")
                if amt > 0 then addPoint("Melee", amt) end
                return
            end

            if getStat("Defense") < MAX_STAT then
                local amt = calcAdd("Defense")
                if amt > 0 then addPoint("Defense", amt) end
                return
            end

            if getStat("Sword") < MAX_STAT then
                local amt = calcAdd("Sword")
                if amt > 0 then addPoint("Sword", amt) end
            end
        end)
    end
end)

-- ===== AUTO DLCBOX (MỖI 15 PHÚT) =====
task.spawn(function()
    while true do
        pcall(function()
            CommF_:InvokeServer("Cousin", "DLCBoxData")
        end)
        task.wait(900)
    end
end)

-- ===== AUTO ATTACK =====
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
                if dist <= (getgenv().AttackRange or 60) then
                    eHRP.Size = Vector3.new(10, 10, 10)
                    eHRP.Transparency = 1
                    Net["RE/RegisterAttack"]:FireServer()
                    Net["RE/RegisterHit"]:FireServer(eHRP)
                    Remotes.SegmentHit:FireServer(enemy)
                end
            end
        end)
    end
end)
