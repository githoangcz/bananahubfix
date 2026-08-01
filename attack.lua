-- ============================================================
-- CONFIG: AUTO ATTACK (FALLBACK REMOTES) + DLCBOX + AUTO STATS
-- KHÔNG BAO GỒM BANANACAT
-- ============================================================

repeat wait() until game:IsLoaded() and game.Players.LocalPlayer

-- ===== CẤU HÌNH =====
getgenv().AttackRange = 60
getgenv().Debug = false  -- bật lên true để xem log lỗi

-- ===== Tắt Fast Attack của BananaCat nếu có =====
pcall(function()
    if getgenv().BANANACATBF then
        getgenv().BANANACATBF["Fast Attack Duration/Cooldown"] = {0, 0}
    end
end)

-- ===== Tìm remote attack =====
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
local Modules = ReplicatedStorage:FindFirstChild("Modules")
local Net = Modules and Modules:FindFirstChild("Net")

-- Tìm các remote cần thiết
local registerAttack, registerHit, segmentHit

-- Cách 1: thử lấy từ Remotes
if Remotes then
    registerAttack = Remotes:FindFirstChild("RE/RegisterAttack") or Remotes:FindFirstChild("RegisterAttack")
    registerHit = Remotes:FindFirstChild("RE/RegisterHit") or Remotes:FindFirstChild("RegisterHit")
    segmentHit = Remotes:FindFirstChild("SegmentHit")
end

-- Cách 2: thử lấy từ Modules.Net
if not registerAttack and Net then
    -- Nếu Net là ModuleScript, cần require để lấy table
    local success, netTable = pcall(require, Net)
    if success and type(netTable) == "table" then
        registerAttack = netTable["RE/RegisterAttack"] or netTable["RegisterAttack"]
        registerHit = netTable["RE/RegisterHit"] or netTable["RegisterHit"]
        segmentHit = segmentHit or netTable["SegmentHit"]
    else
        -- Nếu không require được, thử truy cập trực tiếp (có thể Net là table được define ở nơi khác)
        registerAttack = Net:FindFirstChild("RE/RegisterAttack") or Net:FindFirstChild("RegisterAttack")
        registerHit = Net:FindFirstChild("RE/RegisterHit") or Net:FindFirstChild("RegisterHit")
        segmentHit = segmentHit or Net:FindFirstChild("SegmentHit")
    end
end

-- Cách 3: tìm trong toàn bộ ReplicatedStorage (dự phòng)
if not registerAttack then
    for _, child in ipairs(ReplicatedStorage:GetChildren()) do
        if child:IsA("RemoteEvent") and (child.Name == "RE/RegisterAttack" or child.Name == "RegisterAttack") then
            registerAttack = child
            break
        end
    end
end
if not registerHit then
    for _, child in ipairs(ReplicatedStorage:GetChildren()) do
        if child:IsA("RemoteEvent") and (child.Name == "RE/RegisterHit" or child.Name == "RegisterHit") then
            registerHit = child
            break
        end
    end
end
if not segmentHit then
    for _, child in ipairs(ReplicatedStorage:GetChildren()) do
        if child:IsA("RemoteEvent") and child.Name == "SegmentHit" then
            segmentHit = child
            break
        end
    end
end

if getgenv().Debug then
    print("registerAttack:", registerAttack and "found" or "nil")
    print("registerHit:", registerHit and "found" or "nil")
    print("segmentHit:", segmentHit and "found" or "nil")
end

-- ===== AUTO ATTACK =====
task.spawn(function()
    while task.wait(0.01) do
        local char = LocalPlayer.Character
        if not char then continue end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end

        if not (registerAttack and registerHit and segmentHit) then
            if getgenv().Debug then
                warn("Remote chưa sẵn sàng, đợi...")
            end
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

                        registerAttack:FireServer()
                        registerHit:FireServer(enemy.HumanoidRootPart)
                        segmentHit:FireServer(enemy)
                    end
                end
            end
        end)
    end
end)

-- ===== AUTO DLCBOX =====
local function claimDLCBox()
    pcall(function()
        local args = {"Cousin", "DLCBoxData"}
        game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer(unpack(args))
    end)
end

claimDLCBox()
task.spawn(function()
    while task.wait(3600) do
        claimDLCBox()
    end
end)

-- ===== AUTO STATS (cộng hết points theo thứ tự Melee -> Defense -> Sword) =====
local function addStat(statName, amount)
    pcall(function()
        local args = {"AddPoint", statName, amount}
        game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer(unpack(args))
    end)
end

task.spawn(function()
    local maxLevel = 2800
    while task.wait(0.5) do
        local stats = LocalPlayer.Data.Stats
        local points = LocalPlayer.Data.Points.Value
        if points <= 0 then continue end

        local melee = stats.Melee.Level.Value
        local defense = stats.Defense.Level.Value
        local sword = stats.Sword.Level.Value

        local targetStat = nil
        if melee < maxLevel then
            targetStat = "Melee"
        elseif defense < maxLevel then
            targetStat = "Defense"
        elseif sword < maxLevel then
            targetStat = "Sword"
        else
            break
        end

        local current = stats[targetStat].Level.Value
        local need = maxLevel - current
        local add = math.min(points, need)
        if add > 0 then
            addStat(targetStat, add)
        end
    end
end)

-- ============================================================
print("✅ Config đã sẵn sàng! (Debug=" .. tostring(getgenv().Debug) .. ")")
-- ============================================================
