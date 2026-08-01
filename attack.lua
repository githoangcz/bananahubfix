-- Auto Attack cho Sea 3 (dùng Remote "114")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

local Remote = ReplicatedStorage:WaitForChild("Util"):WaitForChild("114")

local ATTACK_RANGE = 30
local COOLDOWN = 0.2
local active = true

local function getEnemies()
    local list = {}
    local container = workspace:FindFirstChild("Enemies")
    if container then
        for _, v in ipairs(container:GetChildren()) do
            if v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") then
                table.insert(list, v)
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
    local part = target:FindFirstChild("HumanoidRootPart") or target:FindFirstChild("RightUpperLeg")
    if not part then return end
    local pos = part.Position
    if (pos - HumanoidRootPart.Position).Magnitude > ATTACK_RANGE then
        Humanoid:MoveTo(pos)
        return
    end
    Humanoid:MoveTo(HumanoidRootPart.Position)

    local args = {
        "W@*W`blvq`wMlq",
        LocalPlayer.UserId,
        part,
        {},
        [6] = "1279ede2"
    }
    Remote:FireServer(unpack(args))
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
        if not active then
            Humanoid:MoveTo(HumanoidRootPart.Position)
        end
    end
end)

LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    Humanoid = char:WaitForChild("Humanoid")
    HumanoidRootPart = char:WaitForChild("HumanoidRootPart")
end)
