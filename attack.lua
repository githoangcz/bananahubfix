-- Auto Attack Full - Không log
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Net = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Net")
local RegisterAttack = Net:WaitForChild("RE/RegisterAttack")
local RegisterHit = Net:WaitForChild("RE/RegisterHit")
local SegmentHit = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("SegmentHit")

local ATTACK_RANGE = 30
local COOLDOWN = 0.15
local active = true

local function getEnemies()
    local list = {}
    local containers = {workspace.Enemies, workspace._WorldOrigin and workspace._WorldOrigin.EnemySpawns}
    for _, c in ipairs(containers) do
        if c then
            for _, v in ipairs(c:GetChildren()) do
                if v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") then
                    table.insert(list, v)
                end
            end
        end
    end
    return list
end

local function getNearest()
    local enemies = getEnemies()
    local nearest, minDist = nil, math.huge
    local rootPos = HumanoidRootPart.Position
    for _, e in ipairs(enemies) do
        local hrp = e:FindFirstChild("HumanoidRootPart")
        if hrp then
            local d = (hrp.Position - rootPos).Magnitude
            if d < minDist then
                minDist = d
                nearest = e
            end
        end
    end
    return nearest, minDist
end

local function attack(target)
    if not target then return end
    local hrp = target:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local pos = hrp.Position
    local dist = (pos - HumanoidRootPart.Position).Magnitude
    if dist > ATTACK_RANGE then
        Humanoid:MoveTo(pos)
        return
    end
    Humanoid:MoveTo(HumanoidRootPart.Position)
    RegisterAttack:FireServer(pos)
    RegisterHit:FireServer(pos)
    SegmentHit:FireServer(target)
end

coroutine.wrap(function()
    while true do
        if active then
            local target, dist = getNearest()
            if target and dist < ATTACK_RANGE + 15 then
                attack(target)
            else
                Humanoid:MoveTo(HumanoidRootPart.Position)
            end
            task.wait(COOLDOWN)
        else
            task.wait(0.5)
        end
    end
end)()

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.G then
        active = not active
        if not active then Humanoid:MoveTo(HumanoidRootPart.Position) end
    end
end)

-- Xử lý nhân vật mới
LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    Humanoid = char:WaitForChild("Humanoid")
    HumanoidRootPart = char:WaitForChild("HumanoidRootPart")
end)
