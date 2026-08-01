-- ============================================================
-- AUTO ATTACK RIÊNG (RANGE 60, SPAM NHANH)
-- ============================================================

repeat wait() until game:IsLoaded() and game.Players.LocalPlayer

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- ===== CẤU HÌNH =====
getgenv().AttackRange = 60

-- ===== TÌM REMOTE TẤN CÔNG =====
local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
local Modules = ReplicatedStorage:FindFirstChild("Modules")
local Net = Modules and Modules:FindFirstChild("Net")

local attackRemote, hitRemote, segmentRemote

-- Tìm trong Remotes
if Remotes then
    attackRemote = Remotes:FindFirstChild("RE/RegisterAttack") or Remotes:FindFirstChild("RegisterAttack")
    hitRemote = Remotes:FindFirstChild("RE/RegisterHit") or Remotes:FindFirstChild("RegisterHit")
    segmentRemote = Remotes:FindFirstChild("SegmentHit")
end

-- Nếu không có, thử từ Modules.Net
if not attackRemote and Net then
    local success, netTable = pcall(require, Net)
    if success and type(netTable) == "table" then
        attackRemote = netTable["RE/RegisterAttack"] or netTable["RegisterAttack"]
        hitRemote = netTable["RE/RegisterHit"] or netTable["RegisterHit"]
        segmentRemote = segmentRemote or netTable["SegmentHit"]
    else
        attackRemote = Net:FindFirstChild("RE/RegisterAttack") or Net:FindFirstChild("RegisterAttack")
        hitRemote = Net:FindFirstChild("RE/RegisterHit") or Net:FindFirstChild("RegisterHit")
        segmentRemote = segmentRemote or Net:FindFirstChild("SegmentHit")
    end
end

-- Dự phòng: tìm trong toàn bộ ReplicatedStorage
if not attackRemote then
    for _, child in ipairs(ReplicatedStorage:GetChildren()) do
        if child:IsA("RemoteEvent") and (child.Name == "RE/RegisterAttack" or child.Name == "RegisterAttack") then
            attackRemote = child
            break
        end
    end
end
if not hitRemote then
    for _, child in ipairs(ReplicatedStorage:GetChildren()) do
        if child:IsA("RemoteEvent") and (child.Name == "RE/RegisterHit" or child.Name == "RegisterHit") then
            hitRemote = child
            break
        end
    end
end
if not segmentRemote then
    for _, child in ipairs(ReplicatedStorage:GetChildren()) do
        if child:IsA("RemoteEvent") and child.Name == "SegmentHit" then
            segmentRemote = child
            break
        end
    end
end

-- ===== AUTO ATTACK LOOP =====
task.spawn(function()
    while task.wait(0.01) do
        local char = LocalPlayer.Character
        if not char then continue end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end

        if not (attackRemote and hitRemote and segmentRemote) then
            task.wait(1)
            continue
        end

        pcall(function()
            for _, enemy in pairs(Workspace.Enemies:GetChildren()) do
                if enemy:IsA("Model") and enemy:FindFirstChild("HumanoidRootPart") 
                   and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                    
                    local dist = (hrp.Position - enemy.HumanoidRootPart.Position).Magnitude
                    if dist <= getgenv().AttackRange then
                        enemy.HumanoidRootPart.Size = Vector3.new(10, 10, 10)
                        enemy.HumanoidRootPart.Transparency = 1

                        attackRemote:FireServer()
                        hitRemote:FireServer(enemy.HumanoidRootPart)
                        segmentRemote:FireServer(enemy)
                    end
                end
            end
        end)
    end
end)

print("✅ Auto Attack đã sẵn sàng! Range = " .. tostring(getgenv().AttackRange))
