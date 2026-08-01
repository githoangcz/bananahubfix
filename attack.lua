local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local Net = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Net")

getgenv().AttackRange = 35

task.spawn(function()
    while task.wait(0.05) do
        local char = LocalPlayer.Character
        if not char then continue end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end

        pcall(function()
            for _, enemy in pairs(Workspace.Enemies:GetChildren()) do
                if enemy:IsA("Model") and enemy:FindFirstChild("HumanoidRootPart") 
                   and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                    
                    local dist = (hrp.Position - enemy.HumanoidRootPart.Position).Magnitude
                    if dist <= getgenv().AttackRange then
                        enemy.HumanoidRootPart.Size = Vector3.new(10, 10, 10)
                        enemy.HumanoidRootPart.Transparency = 1

                        Net["RE/RegisterAttack"]:FireServer()
                        Net["RE/RegisterHit"]:FireServer(enemy.HumanoidRootPart)
                        Remotes.SegmentHit:FireServer(enemy)
                    end
                end
            end
        end)
    end
end)
