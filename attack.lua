-- ============================================================
-- FULL CONFIG: BANANACAT + AUTO ATTACK TỐC ĐỘ CAO + DLCBOX
-- ĐÃ TẮT AUTO STATS MELEE
-- ============================================================

repeat wait() until game:IsLoaded() and game.Players.LocalPlayer

-- ===== 1. CẤU HÌNH BANANACAT (GIỮ NGUYÊN + THÊM TẮT AUTO STATS) =====
getgenv().Key = ""
getgenv().SettingFarm = {
    ["Hide UI"] = false,
    ["Reset Teleport"] = {
        ["Enabled"] = false,
        ["Delay Reset"] = 3,
        ["Item Dont Reset"] = {
            ["Fruit"] = {
                ["Enabled"] = true,
                ["All Fruit"] = true, 
                ["Select Fruit"] = {
                    ["Enabled"] = false,
                    ["Fruit"] = {},
                },
            },
        },
    },
    ["White Screen"] = false,
    ["Lock Fps"] = {
        ["Enabled"] = false,
        ["FPS"] = 20,
    },
    ["Auto Stats"] = {           -- <-- THÊM DÒNG NÀY ĐỂ TẮT AUTO STATS
        ["Enabled"] = false,     -- TẮT HOÀN TOÀN
        ["Stat"] = "Melee",
    },
    ["Get Items"] = {
        ["Saber"] = true,
        ["Godhuman"] =  true,
        ["Skull Guitar"] = true,
        ["Mirror Fractal"] = true,
        ["Cursed Dual Katana"] = true,
        ["Upgrade Race V2-V3"] = true,
        ["Auto Pull Lever"] = true,
        ["Shark Anchor"] = true,
    },
    ["Get Rare Items"] = {
        ["Rengoku"] = false,
        ["Dragon Trident"] = false, 
        ["Pole (1st Form)"] = false,
        ["Gravity Blade"]  = false,
    },
    ["Farm Fragments"] = {
        ["Enabled"]  = false,
        ["Fragment"] = 50000,
    },
    ["Auto Chat"] = {
        ["Enabled"] = false,
        ["Text"] = "",
    },
    ["Auto Summon Rip Indra"] = true,
    ["Select Hop"] = {
        ["Hop Server If Have Player Near"] = false, 
        ["Hop Find Rip Indra Get Valkyrie Helm or Get Tushita"] = true, 
        ["Hop Find Dough King Get Mirror Fractal"] = false,
        ["Hop Find Raids Castle [CDK]"] = true,
        ["Hop Find Cake Queen [CDK]"] = true,
        ["Hop Find Soul Reaper [CDK]"] = true,
        ["Hop Find Darkbeard [SG]"] = true,
        ["Hop Find Mirage [ Pull Lever ]"] = false,
    },
    ["Farm Mastery"] = {
        ["Melee"] = false,
        ["Sword"] = false,
    },
    ["Buy Haki"] = {
        ["Enhancement"] = true,
        ["Skyjump"] = true,
        ["Flash Step"] = true,
        ["Observation"] = true,
    },
    ["Sniper Fruit Shop"] = {
        ["Enabled"] = true,
        ["Fruit"] = {"Leopard-Leopard","Kitsune-Kitsune","Dragon-Dragon","Yeti-Yeti","Gas-Gas"},
    },
    ["Lock Fruit"] = {},
    ["Webhook"] = {
        ["Enabled"] = false,
        ["WebhookUrl"] = "",
    }
}

-- ===== 2. TẮT FAST ATTACK CỦA BANANACAT (TRÁNH XUNG ĐỘT) =====
getgenv().BANANACATBF = {
    ["Performance"] = {
        ["Black Screen"] = false,
        ["Lock FPS"] = 60,
    },
    ["Fast Attack Duration/Cooldown"] = {0, 0},
    ["Raid if Maxed Blox Fruit"] = true,
    ["Farm boss drops while not maxed"] = false,
    ["Farm Blox Fruit Mastery if maxed"] = true,
    ["Farm method after maxed"] = "Raid Boss Farm - Cake Prince Farm",
    ["Extra time Farm until unlock skills"] = true,
    ["Hop Server"] = {
        ["Type"] = {
            ["[Main] Server Hop"] = false,
            ["[Farm] Server Hop if Player nearby"] = false,
            ["[Sea 3 Quest] Server Hop for 1M+ Blox Fruit"] = true,
        },
        ["Delay"] = 0,
    },
    ["Do Action"] = {
        ["Get Godhuman"] = true,
        ["Get Rengoku"] = false,
        ["Get True Triple Katana"] = false,
        ["Get Hallow Scythe"] = false,
        ["Get Cursed Dual Katana"] = true,
        ["Get Soul Guitar"] = true,
        ["Awake Current Blox Fruit"] = true,
        ["Get Mirror Fractal"] = true,
    },
    ["Buy Haki"] = {
        ["Enhancement"] = false,
        ["Skyjump"] = true,
        ["Flash Step"] = true,
        ["Observation"] = true,
        ["Legendary Enhancement"] = false,
    },
    ["Auto Race"] = "None",
    ["Blox Fruit Sniper"] = {},
    ["Main Blox Fruit"] = {},
    ["Eat Sniper Blox Fruits"] = true,
}

-- ===== 3. CẤU HÌNH AUTO ATTACK TỐC ĐỘ CAO =====
getgenv().AttackRange = 60          -- Tầm đánh
getgenv().AutoAttack = true         -- Bật/tắt (nếu muốn tắt, set false)

-- ===== 4. AUTO ATTACK (DÙNG RENDERSTEPPED – RẤT NHANH) =====
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local Net = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Net")

-- Kiểm tra nếu AutoAttack được bật
if getgenv().AutoAttack then
    RunService.RenderStepped:Connect(function()
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

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
    end)
end

-- ===== 5. AUTO DLCBOX (CLAIM MỖI 1 GIỜ) =====
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

-- ============================================================
-- SẴN SÀNG – SAU ĐÓ BẠN LOAD BANANACAT HUB RIÊNG (NẾU MUỐN)
-- ============================================================
-- loadstring(game:HttpGet("https://raw.githubusercontent.com/obiiyeuem/vthangsitink/main/BananaCat-kaitunBF.lua"))()
