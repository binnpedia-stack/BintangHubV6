-- BINTANGHUB V6.1 | Violence District
-- Full Body Object Chams | Custom Colors | Gen Progress | Labu & Trap Name

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Config = {
    AutoSkill = false, AutoTrap = false,
    Fullbright = false, NoShadow = false, NoClip = false,
    ESP_Survivor = false, ESP_Killer = false, ESP_Name = true,
    ESP_Gen = false, ESP_Pallet = false, ESP_Hook = false, ESP_Window = false, ESP_Trap = false, ESP_Pumpkin = false,
    
    -- Warna Default
    Color_Survivor = Color3.fromRGB(40, 255, 40),
    Color_Killer = Color3.fromRGB(255, 40, 40),
    Color_Gen = Color3.fromRGB(255, 255, 0),
    Color_Pallet = Color3.fromRGB(0, 150, 255),
    Color_Hook = Color3.fromRGB(200, 200, 200),
    Color_Window = Color3.fromRGB(0, 255, 255),
    Color_Trap = Color3.fromRGB(255, 0, 255),
    Color_Pumpkin = Color3.fromRGB(255, 165, 0)
}

-- ==========================================
-- RAYFIELD UI
-- ==========================================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
   Name = "BINTANGHUB V6.1",
   LoadingTitle = "BINTANGHUB",
   LoadingSubtitle = "by Owner BintangHub",
   KeySystem = false, Theme = "Amethyst"
})

local TabMain = Window:CreateTab("Main", 4483362458)
local TabSurvivor = Window:CreateTab("Survivor", 4483362458)
local TabESP = Window:CreateTab("ESP", 4483362458)

-- MAIN
TabMain:CreateToggle({Name = "Fullbright", CurrentValue = false, Callback = function(v) Config.Fullbright = v end})
TabMain:CreateToggle({Name = "No Clip", CurrentValue = false, Callback = function(v) Config.NoClip = v end})

-- SURVIVOR
TabSurvivor:CreateToggle({Name = "Auto Skillcheck (Gen)", CurrentValue = false, Callback = function(v) Config.AutoSkill = v end})
TabSurvivor:CreateToggle({Name = "Auto Trap Release", CurrentValue = false, Callback = function(v) Config.AutoTrap = v end})

-- ESP PLAYER
TabESP:CreateSection("Player ESP (Full Body + Name)")
TabESP:CreateToggle({Name = "ESP Survivor", CurrentValue = false, Callback = function(v) Config.ESP_Survivor = v end})
TabESP:CreateColorPicker({Name = "Survivor Color", Color = Config.Color_Survivor, Callback = function(v) Config.Color_Survivor = v end})

TabESP:CreateToggle({Name = "ESP Killer", CurrentValue = false, Callback = function(v) Config.ESP_Killer = v end})
TabESP:CreateColorPicker({Name = "Killer Color", Color = Config.Color_Killer, Callback = function(v) Config.Color_Killer = v end})

-- ESP OBJECT (Full Body + Name)
TabESP:CreateSection("Object ESP")
TabESP:CreateToggle({Name = "ESP Generator", CurrentValue = false, Callback = function(v) Config.ESP_Gen = v end})
TabESP:CreateColorPicker({Name = "Gen Color", Color = Config.Color_Gen, Callback = function(v) Config.Color_Gen = v end})

TabESP:CreateToggle({Name = "ESP Pallet", CurrentValue = false, Callback = function(v) Config.ESP_Pallet = v end})
TabESP:CreateColorPicker({Name = "Pallet Color", Color = Config.Color_Pallet, Callback = function(v) Config.Color_Pallet = v end})

TabESP:CreateToggle({Name = "ESP Hook", CurrentValue = false, Callback = function(v) Config.ESP_Hook = v end})
TabESP:CreateColorPicker({Name = "Hook Color", Color = Config.Color_Hook, Callback = function(v) Config.Color_Hook = v end})

TabESP:CreateToggle({Name = "ESP Window", CurrentValue = false, Callback = function(v) Config.ESP_Window = v end})
TabESP:CreateColorPicker({Name = "Window Color", Color = Config.Color_Window, Callback = function(v) Config.Color_Window = v end})

TabESP:CreateToggle({Name = "ESP Trap", CurrentValue = false, Callback = function(v) Config.ESP_Trap = v end})
TabESP:CreateColorPicker({Name = "Trap Color", Color = Config.Color_Trap, Callback = function(v) Config.Color_Trap = v end})

TabESP:CreateToggle({Name = "ESP Labu (Pumpkin)", CurrentValue = false, Callback = function(v) Config.ESP_Pumpkin = v end})
TabESP:CreateColorPicker({Name = "Pumpkin Color", Color = Config.Color_Pumpkin, Callback = function(v) Config.Color_Pumpkin = v end})

-- ==========================================
-- ESP LOGIC (HIGHLIGHT / CHAMS)
-- ==========================================
local espCache = {}

local function ApplyHighlight(obj, color)
    if not obj then return end
    local hl = Instance.new("Highlight")
    hl.Name = "BH_Highlight"
    hl.Adornee = obj
    hl.FillColor = color
    hl.FillTransparency = 0.4
    hl.OutlineColor = color
    hl.OutlineTransparency = 0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Parent = obj
    return hl
end

local function CreateText(parent, text, color)
    local hrp = parent:FindFirstChild("HumanoidRootPart") or parent:FindFirstChildWhichIsA("BasePart") or parent
    if not hrp then return end
    
    local b = Instance.new("BillboardGui")
    b.Name = "BH_Text"
    b.Size = UDim2.new(0, 150, 0, 50)
    b.StudsOffset = Vector3.new(0, 3, 0)
    b.AlwaysOnTop = true
    b.Parent = hrp
    
    local t = Instance.new("TextLabel")
    t.Size = UDim2.new(1, 0, 1, 0)
    t.BackgroundTransparency = 1
    t.Text = text
    t.TextColor3 = color
    t.TextStrokeTransparency = 0
    t.Font = Enum.Font.GothamBold
    t.TextSize = 14
    t.Parent = b
    return b
end

local function UpdateESP()
    -- 1. PLAYER ESP
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local char = plr.Character
            local hum = char:FindFirstChild("Humanoid")
            
            if hum and hum.Health > 0 then
                local isKiller = char:FindFirstChildOfClass("Tool") ~= nil
                local active = (isKiller and Config.ESP_Killer) or (not isKiller and Config.ESP_Survivor)
                
                if active then
                    local color = isKiller and Config.Color_Killer or Config.Color_Survivor
                    
                    if not espCache[plr] or not espCache[plr].Parent then
                        espCache[plr] = ApplyHighlight(char, color)
                    end
                    espCache[plr].Enabled = true
                    espCache[plr].FillColor = color
                    espCache[plr].OutlineColor = color
                    
                    local nameTag = char:FindFirstChild("HumanoidRootPart") and char.HumanoidRootPart:FindFirstChild("BH_Text")
                    if not nameTag then
                        nameTag = CreateText(char, plr.Name, color)
                    end
                    if nameTag and nameTag:FindFirstChild("TextLabel") then
                        nameTag.TextLabel.Text = plr.Name
                        nameTag.TextLabel.TextColor3 = color
                        nameTag.Enabled = true
                    end
                else
                    if espCache[plr] then espCache[plr].Enabled = false end
                    local nameTag = char:FindFirstChild("HumanoidRootPart") and char.HumanoidRootPart:FindFirstChild("BH_Text")
                    if nameTag then nameTag.Enabled = false end
                end
            end
        end
    end

    -- 2. OBJECT ESP
    for _, obj in pairs(workspace:GetDescendants()) do
        local n = obj.Name:lower()
        
        local isGen = Config.ESP_Gen and (n:find("generator") or n:find("gen"))
        local isPallet = Config.ESP_Pallet and n:find("pallet")
        local isHook = Config.ESP_Hook and n:find("hook")
        local isWindow = Config.ESP_Window and n:find("window")
        local isTrap = Config.ESP_Trap and (n:find("trap") or n:find("beartrap"))
        local isPumpkin = Config.ESP_Pumpkin and (n:find("pumpkin") or n:find("labu") or n:find("halloween"))
        
        if isGen or isPallet or isHook or isWindow or isTrap or isPumpkin then
            local color = isGen and Config.Color_Gen or isPallet and Config.Color_Pallet or isHook and Config.Color_Hook or isWindow and Config.Color_Window or isTrap and Config.Color_Trap or Config.Color_Pumpkin
            
            if not espCache[obj] then
                espCache[obj] = ApplyHighlight(obj, color)
                
                -- Teks Nama Objek
                local objName = isGen and "[ GEN ]" or isPallet and "[ PALLET ]" or isHook and "[ HOOK ]" or isWindow and "[ WINDOW ]" or isTrap and "[ TRAP ]" or "[ LABU ]"
                local textBill = CreateText(obj, objName, color)
                if textBill then espCache[obj.."_text"] = textBill end
                
                -- Progress Generator
                if isGen then
                    local progBill = CreateText(obj, "[ 0% ]", Config.Color_Gen)
                    if progBill then
                        progBill.Name = "BH_GenProgress"
                        progBill.StudsOffset = Vector3.new(0, 4.5, 0) -- Naikin dikit biar ga nabrak teks nama
                        espCache[obj.."_prog"] = progBill
                    end
                end
            end
            
            if espCache[obj] then
                espCache[obj].Enabled = true
                espCache[obj].FillColor = color
                espCache[obj].OutlineColor = color
                
                -- Update Nama Object
                if espCache[obj.."_text"] and espCache[obj.."_text"]:FindFirstChild("TextLabel") then
                    espCache[obj.."_text"].Enabled = true
                    espCache[obj.."_text"].TextLabel.TextColor3 = color
                end
                
                -- Update Progress Generator
                if isGen and espCache[obj.."_prog"] then
                    local progBill = espCache[obj.."_prog"]
                    progBill.Enabled = true
                    if progBill:FindFirstChild("TextLabel") then
                        local progVal = obj:GetAttribute("Progress") or 0
                        local progText = obj:FindFirstChild("Progress") 
                        if progText and progText:IsA("NumberValue") then progVal = progText.Value end
                        
                        progBill.TextLabel.Text = "[ " .. math.floor(progVal) .. "% ]"
                        progBill.TextLabel.TextColor3 = color
                    end
                end
            end
        elseif espCache[obj] then
            espCache[obj].Enabled = false
            if espCache[obj.."_text"] then espCache[obj.."_text"].Enabled = false end
            if espCache[obj.."_prog"] then espCache[obj.."_prog"].Enabled = false end
        end
    end
end

-- ==========================================
-- AUTO SKILLCHECK (GUI WATCHER)
-- ==========================================
local vim = game:GetService("VirtualInputManager")
local isHitting = false

local function CheckForSkillcheck()
    if isHitting then return end
    local guis = game:GetService("CoreGui"):GetDescendants()
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    if pg then for _, v in pairs(pg:GetDescendants()) do table.insert(guis, v) end end

    for _, gui in pairs(guis) do
        if gui:IsA("Frame") or gui:IsA("ImageLabel") then
            local name = gui.Name:lower()
            if name:find("skill") or name:find("check") or name:find("minigame") then
                if gui.Visible then
                    isHitting = true
                    vim:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
                    task.wait(0.05)
                    vim:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
                    task.wait(0.5)
                    isHitting = false
                    break
                end
            end
        end
    end
end

-- ==========================================
-- MAIN LOOPS
-- ==========================================
RunService.RenderStepped:Connect(function()
    UpdateESP()
    if Config.AutoSkill or Config.AutoTrap then CheckForSkillcheck() end
end)

task.spawn(function()
    while task.wait(0.1) do
        local char = LocalPlayer.Character
        if char then
            if Config.NoClip then for _, v in pairs(char:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end end
        end
        if Config.Fullbright then Lighting.Brightness = 3; Lighting.ClockTime = 14; Lighting.GlobalShadows = false
        else Lighting.Brightness = 1; Lighting.GlobalShadows = true end
        if Config.NoShadow then for _, v in pairs(workspace:GetDescendants()) do if v:IsA("BasePart") then v.CastShadow = false end end end
    end
end)
