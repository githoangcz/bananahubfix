-- ============================================================
-- CONFIG RIÊNG: AUTO ATTACK (RANGE 60) + DLCBOX + AUTO STATS
-- KHÔNG BAO GỒM BANANACAT (CHỈ CHẠY BỔ SUNG)
-- ============================================================

repeat wait() until game:IsLoaded() and game.Players.LocalPlayer

-- ===== 1. CẤU HÌNH =====
getgenv().AttackRange = 60  -- Tầm đánh (có thể chỉnh)
-- ===== 2. TẮT FAST ATTACK CỦA BANANACAT (NẾU CÓ) ĐỂ TRÁNH XUNG ĐỘT =====
pcall(function()
    if getgenv().BANANACATBF then
        getgenv().BANANACATBF["Fast Attack Duration/Cooldown"] = {0, 0}
    end
end)

-- ===== 3. AUTO ATTACK (DÙNG TASK.WAIT 0.01) =====
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local Net = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Net")

task.spawn(function()
    while task.wait(0.01) do
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

-- ===== 4. AUTO DLCBOX (CLAIM MỖI 1 GIỜ) =====
local function claimDLCBox()
    pcall(function()
        local args = {"Cousin", "DLCBoxData"}
        game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer(unpack(args))
    end)
end

claimDLCBox()  -- Lần đầu
task.spawn(function()
    while task.wait(3600) do
        claimDLCBox()
    end
end)

-- ===== 5. AUTO STATS RIÊNG (CỘNG HẾT POINTS VÀO MELEE -> DEFENSE -> SWORD) =====
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

        local meleeLevel = stats.Melee.Level.Value
        local defenseLevel = stats.Defense.Level.Value
        local swordLevel = stats.Sword.Level.Value

        local targetStat = nil
        if meleeLevel < maxLevel then
            targetStat = "Melee"
        elseif defenseLevel < maxLevel then
            targetStat = "Defense"
        elseif swordLevel < maxLevel then
            targetStat = "Sword"
        else
            break  -- tất cả đã max
        end

        local currentLevel = stats[targetStat].Level.Value
        local pointsNeeded = maxLevel - currentLevel
        local addAmount = math.min(points, pointsNeeded)

        if addAmount > 0 then
            addStat(targetStat, addAmount)
        end
    end
end)

-- ============================================================
-- SẴN SÀNG – BẠN CÓ THỂ CHẠY CÙNG BANANACAT (KHÔNG LOAD LẠI)
-- ============================================================
