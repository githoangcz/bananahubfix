-- ============================================
-- AUTO STATS + AUTO DLCBOX + AUTO ATTACK
-- ============================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local CommF_ = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local Net = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Net")
local LocalPlayer = Players.LocalPlayer

local MAX_STAT = 2800

-- ===== CHỜ DATA LOAD =====
local function waitForData()
    while not pcall(function()
        local _ = LocalPlayer.Data.Stats.Melee.Level.Value
    end) do
        task.wait(0.5)
    end
end

waitForData()
print("[Script] Data đã load xong")

-- ===== HELPERS =====
local function getPoints()
    local ok, val = pcall(function() return LocalPlayer.Data.Points.Value end)
    return ok and val or 0
end

local function getStat(name)
    local ok, val = pcall(function() return LocalPlayer.Data.Stats[name].Level.Value end)
    return ok and val or 0
end

local function addPoint(stat, amount)
    pcall(function()
        CommF_:InvokeServer("AddPoint", stat, amount)
    end)
    task.wait(0.3) -- tránh throttle
end

-- ===== AUTO STATS =====
task.spawn(function()
    while task.wait(2) do
        pcall(function()
            local points = getPoints()
            if points <= 0 then return end

            local melee = getStat("Melee")
            local defense = getStat("Defense")
            local sword = getStat("Sword")

            if melee < MAX_STAT then
                local amt = math.min(MAX_STAT - melee, points)
                if amt > 0 then
                    addPoint("Melee", amt)
                    print("[Stats] Melee: " .. getStat("Melee") .. "/" .. MAX_STAT)
                end
            elseif defense < MAX_STAT then
                local amt = math.min(MAX_STAT - defense, points)
                if amt > 0 then
                    addPoint("Defense", amt)
                    print("[Stats] Defense: " .. getStat("Defense") .. "/" .. MAX_STAT)
                end
            elseif sword < MAX_STAT then
                local amt = math.min(MAX_STAT - sword, points)
                if amt > 0 then
                    addPoint("Sword", amt)
                    print("[Stats] Sword: " .. getStat("Sword") .. "/" .. MAX_STAT)
                end
            end
        end)
    end
end)

-- ===== AUTO DLCBOX (MỖI 15 PHÚT) =====
task.spawn(function()
    while true do
        pcall(function()
            CommF_:InvokeServer("Cousin", "DLCBoxData")
            print("[DLCBox] Đã claim")
        end)
        task.wait(900)
    end
end)

-- ===== AUTO ATTACK =====
-- Dùng cooldown để tránh server throttle
local lastAttack = 0
local ATTACK_COOLDOWN = 0.3 -- giây giữa mỗi lần fire

task.spawn(function()
    while task.wait(0.1) do
        local char = LocalPlayer.Character
        if not char then continue end

        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChild("Humanoid")
        if not hrp or not hum or hum.Health <= 0 then continue end

        local now = tick()
        if now - lastAttack < ATTACK_COOLDOWN then continue end

        pcall(function()
            local enemyFolder = Workspace:FindFirstChild("Enemies")
            if not enemyFolder then return end

            local range = getgenv().AttackRange or 60
            local hit = false

            for _, enemy in ipairs(enemyFolder:GetChildren()) do
                if not enemy:IsA("Model") then continue end

                local eHRP = enemy:FindFirstChild("HumanoidRootPart")
                local eHum = enemy:FindFirstChild("Humanoid")
                if not eHRP or not eHum or eHum.Health <= 0 then continue end

                local dist = (hrp.Position - eHRP.Position).Magnitude
                if dist <= range then
                    -- Enlarge hitbox
                    eHRP.Size = Vector3.new(10, 10, 10)
                    eHRP.Transparency = 1

                    -- Fire từng remote có delay nhỏ
                    Net["RE/RegisterAttack"]:FireServer()
                    task.wait(0.05)
                    Net["RE/RegisterHit"]:FireServer(eHRP)
                    task.wait(0.05)
                    Remotes.SegmentHit:FireServer(enemy)

                    hit = true
                end
            end

            if hit then
                lastAttack = tick()
            end
        end)
    end
end)

print("[Script] Đã khởi động xong!")
