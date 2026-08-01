-- AUTO ATTACK - Blox Fruits
-- Disable Fast Attack của BananaCat, dùng attack riêng 18 studs trên mob

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local RootPart = Character:WaitForChild("HumanoidRootPart")

local ATTACK_OFFSET = Vector3.new(0, 18, 0)
local LOOP_DELAY = 0.12

-- Tắt Fast Attack của BananaCat để tránh xung đột
pcall(function()
    if getgenv().BANANACATBF then
        getgenv().BANANACATBF["Fast Attack Duration/Cooldown"] = {0, 0}
    end
end)

local function refreshChar()
    Character = LocalPlayer.Character
    if not Character then return false end
    local hum = Character:FindFirstChild("Humanoid")
    local hrp = Character:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp or hum.Health <= 0 then return false end
    RootPart = hrp
    return true
end

local function findNearestEnemy()
    local folder = workspace:FindFirstChild("Enemies")
    if not folder then return nil end
    local nearest, nearestDist = nil, math.huge
    for _, enemy in ipairs(folder:GetChildren()) do
        local hrp = enemy:FindFirstChild("HumanoidRootPart")
        local hum = enemy:FindFirstChild("Humanoid")
        if hrp and hum and hum.Health > 0 then
            local dist = (RootPart.Position - hrp.Position).Magnitude
            if dist < nearestDist then
                nearest = enemy
                nearestDist = dist
            end
        end
    end
    return nearest
end

local function doAttack(enemy)
    local hrp = enemy:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    RootPart.CFrame = CFrame.new(hrp.Position + ATTACK_OFFSET)
    task.wait(0.05)

    pcall(function()
        ReplicatedStorage.Modules.Net["RE/RegisterAttack"]:FireServer()
    end)
    task.wait(0.05)
    pcall(function()
        ReplicatedStorage.Modules.Net["RE/RegisterHit"]:FireServer(enemy)
    end)
    pcall(function()
        ReplicatedStorage.Remotes.SegmentHit:FireServer(enemy)
    end)
end

LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    RootPart = newChar:WaitForChild("HumanoidRootPart")
end)

-- Chờ BananaCat load xong rồi mới disable Fast Attack
task.spawn(function()
    task.wait(5)
    pcall(function()
        if getgenv().BANANACATBF then
            getgenv().BANANACATBF["Fast Attack Duration/Cooldown"] = {0, 0}
            print("[AutoAttack] Đã tắt Fast Attack của BananaCat")
        end
    end)
end)

print("[AutoAttack] Bắt đầu...")

while task.wait(LOOP_DELAY) do
    if refreshChar() then
        local enemy = findNearestEnemy()
        if enemy then doAttack(enemy) end
    else
        task.wait(2)
    end
end
