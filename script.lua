--[[
    مثال متكامل لاستخدام OR's Advanced UI Library v3.0
    يشمل: Aimbot, ESP, Speed, Fly, TP, Auto Farm
]]

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/oday018/Steal-A-Brainrot-Script-LUX/refs/heads/main/GUL.lua"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

local lp = Players.LocalPlayer
local mouse = lp:GetMouse()

-- ============================================
-- إعدادات عامة
-- ============================================
local Settings = {
    -- Combat
    Aimbot = {
        Enabled = false,
        Smoothness = 50,
        FOV = 100,
        TargetPart = "Head",
        Prediction = false,
    },
    
    -- Visual
    ESP = {
        Enabled = false,
        Boxes = true,
        Tracers = true,
        Names = true,
        Distance = true,
        Health = true,
        Color = Color3.fromRGB(255, 0, 0),
    },
    
    -- Movement
    Movement = {
        Speed = 16,
        SpeedEnabled = false,
        FlyEnabled = false,
        FlySpeed = 50,
        JumpPower = 50,
        InfJump = false,
    },
    
    -- Auto Farm
    AutoFarm = {
        Enabled = false,
        Method = "Distance",
        Range = 100,
    },
}

local ESPObjects = {}
local Connections = {}

-- ============================================
-- إنشاء النافذة الرئيسية
-- ============================================
Library:SetTheme("Blue")
Library:Notification("OR's Hub", "Welcome " .. lp.Name .. "!", 3, "success")

local Window = Library:CreateWindow({
    Title = "OR's Ultimate Hub",
    Theme = "Dark",
    Keybind = Enum.KeyCode.RightShift,
})

-- ============================================
-- التبويبات
-- ============================================
local CombatTab = Window:AddTab({Name = "Combat", Icon = "⚔️"})
local VisualTab = Window:AddTab({Name = "Visual", Icon = "👁️"})
local MovementTab = Window:AddTab({Name = "Movement", Icon = "🏃"})
local AutoFarmTab = Window:AddTab({Name = "Auto Farm", Icon = "🤖"})
local SettingsTab = Window:AddTab({Name = "Settings", Icon = "⚙️"})

-- ============================================
-- Combat Tab
-- ============================================
Window:AddSection("Combat", "Aimbot Settings")

-- Aimbot Toggle
Window:Toggle("Combat", "Enable Aimbot", false, function(state)
    Settings.Aimbot.Enabled = state
    Library:Notification("Aimbot", state and "Enabled" or "Disabled", 2, state and "success" or "warning")
    
    if state then
        startAimbot()
    else
        stopAimbot()
    end
end)

-- Aimbot Smoothness
Window:Slider("Combat", "Smoothness", 1, 100, 50, function(value)
    Settings.Aimbot.Smoothness = value
end)

-- Aimbot FOV
Window:Slider("Combat", "FOV Circle", 50, 500, 100, function(value)
    Settings.Aimbot.FOV = value
end)

-- Target Part Dropdown
Window:Dropdown("Combat", "Target Part", {"Head", "Torso", "HumanoidRootPart"}, "Head", function(selected)
    Settings.Aimbot.TargetPart = selected
end)

-- Prediction Toggle
Window:Toggle("Combat", "Movement Prediction", false, function(state)
    Settings.Aimbot.Prediction = state
end)

-- Trigger Bot
Window:Toggle("Combat", "Trigger Bot", false, function(state)
    if state then
        Connections.TriggerBot = RunService.Heartbeat:Connect(function()
            local target = getNearestTarget()
            if target and target.Parent and target.Parent:FindFirstChildOfClass("Humanoid") then
                local hum = target.Parent:FindFirstChildOfClass("Humanoid")
                if hum.Health > 0 then
                    mouse1press()
                    task.wait(0.05)
                    mouse1release()
                end
            end
        end)
    else
        if Connections.TriggerBot then
            Connections.TriggerBot:Disconnect()
            Connections.TriggerBot = nil
        end
    end
end)

-- Kill All Button
Window:Button("Combat", "Kill All", function()
    Library:Notification("Combat", "Searching for enemies...", 2, "info")
    
    local count = 0
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= lp and plr.Character then
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local weapon = lp.Character and lp.Character:FindFirstChildOfClass("Tool")
                if weapon then
                    firetouchinterest(lp.Character.HumanoidRootPart, plr.Character.HumanoidRootPart, 0)
                    firetouchinterest(lp.Character.HumanoidRootPart, plr.Character.HumanoidRootPart, 1)
                    count = count + 1
                end
            end
        end
    end
    
    Library:Notification("Combat", "Killed " .. count .. " enemies!", 2, "success")
end)

-- ============================================
-- Visual Tab
-- ============================================
Window:AddSection("Visual", "ESP Settings")

-- ESP Toggle
Window:Toggle("Visual", "Enable ESP", false, function(state)
    Settings.ESP.Enabled = state
    
    if state then
        startESP()
        Library:Notification("ESP", "Enabled", 2, "success")
    else
        stopESP()
        Library:Notification("ESP", "Disabled", 2, "warning")
    end
end)

-- ESP Boxes
Window:Toggle("Visual", "Boxes", true, function(state)
    Settings.ESP.Boxes = state
    updateESP()
end)

-- ESP Tracers
Window:Toggle("Visual", "Tracers", true, function(state)
    Settings.ESP.Tracers = state
    updateESP()
end)

-- ESP Names
Window:Toggle("Visual", "Names", true, function(state)
    Settings.ESP.Names = state
    updateESP()
end)

-- ESP Distance
Window:Toggle("Visual", "Distance", true, function(state)
    Settings.ESP.Distance = state
    updateESP()
end)

-- ESP Health
Window:Toggle("Visual", "Health Bar", true, function(state)
    Settings.ESP.Health = state
    updateESP()
end)

-- ESP Color Picker
Window:ColorPicker("Visual", "ESP Color", Color3.fromRGB(255, 0, 0), function(color)
    Settings.ESP.Color = color
    updateESP()
end)

-- Chams
Window:Toggle("Visual", "Chams", false, function(state)
    if state then
        Connections.Chams = RunService.Heartbeat:Connect(function()
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= lp and plr.Character then
                    for _, part in ipairs(plr.Character:GetDescendants()) do
                        if part:IsA("BasePart") and part.Transparency < 1 then
                            part.Material = Enum.Material.ForceField
                        end
                    end
                end
            end
        end)
    else
        if Connections.Chams then
            Connections.Chams:Disconnect()
            Connections.Chams = nil
        end
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr.Character then
                for _, part in ipairs(plr.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.Material = Enum.Material.Plastic
                    end
                end
            end
        end
    end
end)

-- Full Bright
Window:Toggle("Visual", "Full Bright", false, function(state)
    if state then
        game:GetService("Lighting").Brightness = 3
        game:GetService("Lighting").ClockTime = 14
    else
        game:GetService("Lighting").Brightness = 2
    end
end)

-- ============================================
-- Movement Tab
-- ============================================
Window:AddSection("Movement", "Speed Settings")

-- Speed Toggle
Window:Toggle("Movement", "Enable Speed", false, function(state)
    Settings.Movement.SpeedEnabled = state
    if state then
        startSpeed()
    else
        stopSpeed()
    end
end)

-- Speed Slider
Window:Slider("Movement", "Speed Value", 16, 200, 16, function(value)
    Settings.Movement.Speed = value
end)

-- Fly Toggle
Window:Toggle("Movement", "Enable Fly", false, function(state)
    Settings.Movement.FlyEnabled = state
    if state then
        startFly()
        Library:Notification("Fly", "Press E to go up, Q to go down", 3, "info")
    else
        stopFly()
    end
end)

-- Fly Speed Slider
Window:Slider("Movement", "Fly Speed", 10, 200, 50, function(value)
    Settings.Movement.FlySpeed = value
end)

-- Infinite Jump
Window:Toggle("Movement", "Infinite Jump", false, function(state)
    Settings.Movement.InfJump = state
    if state then
        Connections.InfJump = UIS.JumpRequest:Connect(function()
            if Settings.Movement.InfJump and lp.Character then
                local hum = lp.Character:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end)
    else
        if Connections.InfJump then
            Connections.InfJump:Disconnect()
            Connections.InfJump = nil
        end
    end
end)

-- Jump Power Slider
Window:Slider("Movement", "Jump Power", 50, 200, 50, function(value)
    Settings.Movement.JumpPower = value
    if lp.Character then
        local hum = lp.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.JumpPower = value
        end
    end
end)

-- Teleport Buttons
Window:Button("Movement", "TP to Mouse", function()
    if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = lp.Character.HumanoidRootPart
        local target = mouse.Hit.Position
        hrp.CFrame = CFrame.new(target.X, target.Y + 3, target.Z)
        Library:Notification("Teleport", "Teleported to mouse position!", 1.5, "success")
    end
end)

Window:Button("Movement", "TP to Spawn", function()
    if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = lp.Character.HumanoidRootPart
        local spawns = Workspace:FindFirstChild("SpawnLocation")
        if spawns then
            hrp.CFrame = spawns.CFrame + Vector3.new(0, 3, 0)
            Library:Notification("Teleport", "Teleported to spawn!", 1.5, "success")
        end
    end
end)

-- ============================================
-- Auto Farm Tab
-- ============================================
Window:AddSection("AutoFarm", "Auto Farm Settings")

-- Auto Farm Toggle
Window:Toggle("AutoFarm", "Enable Auto Farm", false, function(state)
    Settings.AutoFarm.Enabled = state
    if state then
        startAutoFarm()
        Library:Notification("Auto Farm", "Started farming!", 2, "success")
    else
        stopAutoFarm()
        Library:Notification("Auto Farm", "Stopped!", 2, "warning")
    end
end)

-- Method Dropdown
Window:Dropdown("AutoFarm", "Target Method", {"Distance", "Weakest", "Random"}, "Distance", function(selected)
    Settings.AutoFarm.Method = selected
end)

-- Range Slider
Window:Slider("AutoFarm", "Farm Range", 20, 500, 100, function(value)
    Settings.AutoFarm.Range = value
end)

-- ============================================
-- Settings Tab
-- ============================================
Window:AddSection("Settings", "General Settings")

-- Theme Dropdown
Window:Dropdown("Settings", "Theme", {"Dark", "Light", "Blue", "Red"}, "Blue", function(selected)
    Library:SetTheme(selected)
    Library:Notification("Theme", "Changed to " .. selected, 1.5, "info")
end)

-- Config Buttons
Window:Button("Settings", "Save Config", function()
    Library:Notification("Config", "Configuration saved!", 2, "success")
end)

Window:Button("Settings", "Load Config", function()
    Library:Notification("Config", "Configuration loaded!", 2, "success")
end)

-- Custom Message TextBox
Window:TextBox("Settings", "Custom Message", "Type here...", function(text, enterPressed)
    if enterPressed and text ~= "" then
        local chatService = game:GetService("TextChatService")
        local channel = chatService:FindFirstChild("TextChannels"):FindFirstChild("RBXGeneral")
        if channel then
            channel:SendAsync(text)
        end
        Library:Notification("Message", "Sent: " .. text, 2, "success")
    end
end)

-- Status Label
local statusLabel = Window:Label("Settings", "Status: Ready")
statusLabel:Set("Status: Connected")

-- FPS Counter Label
local fpsLabel = Window:Label("Settings", "FPS: 60")
RunService.RenderStepped:Connect(function(dt)
    if dt > 0 then
        local fps = math.floor(1 / dt)
        fpsLabel:Set("FPS: " .. fps)
    end
end)

-- ============================================
-- External Hubs (أزرار خارجية)
-- ============================================

-- Speed Hub (سرعة سريعة)
local speedHub = Library:CreateExternalHub({
    Name = "QuickSpeed",
    ButtonText = "⚡ SPEED",
    Width = 110,
    CollapsedHeight = 32,
    ExpandedHeight = 100,
    CanExpand = true,
    ShowDot = true,
    PositionX = 20,
    PositionY = 80,
    OnEnable = function()
        Settings.Movement.SpeedEnabled = true
        startSpeed()
    end,
    OnDisable = function()
        Settings.Movement.SpeedEnabled = false
        stopSpeed()
    end,
})

speedHub:AddToggle("Bunny Hop", false, function(state)
    Settings.Movement.InfJump = state
end)

speedHub:AddSlider("Speed", 16, 200, 50, function(value)
    Settings.Movement.Speed = value
end)

-- Fly Hub
local flyHub = Library:CreateExternalHub({
    Name = "QuickFly",
    ButtonText = "🦅 FLY",
    Width = 90,
    CollapsedHeight = 32,
    ExpandedHeight = 80,
    CanExpand = true,
    ShowDot = true,
    PositionX = 140,
    PositionY = 80,
    OnEnable = function()
        Settings.Movement.FlyEnabled = true
        startFly()
    end,
    OnDisable = function()
        Settings.Movement.FlyEnabled = false
        stopFly()
    end,
})

flyHub:AddSlider("Fly Speed", 20, 200, 50, function(value)
    Settings.Movement.FlySpeed = value
end)

-- ESP Hub
local espHub = Library:CreateExternalHub({
    Name = "QuickESP",
    ButtonText = "👁 ESP",
    Width = 90,
    CollapsedHeight = 32,
    CanExpand = false,
    ShowDot = true,
    PositionX = 240,
    PositionY = 80,
    OnEnable = function()
        Settings.ESP.Enabled = true
        startESP()
    end,
    OnDisable = function()
        Settings.ESP.Enabled = false
        stopESP()
    end,
})

-- Aimbot Hub
local aimbotHub = Library:CreateExternalHub({
    Name = "QuickAimbot",
    ButtonText = "🎯 AIM",
    Width = 90,
    CollapsedHeight = 32,
    CanExpand = false,
    ShowDot = true,
    PositionX = 340,
    PositionY = 80,
    Keybind = Enum.KeyCode.V, -- يشتغل بضغطة V
    OnEnable = function()
        Settings.Aimbot.Enabled = true
        startAimbot()
    end,
    OnDisable = function()
        Settings.Aimbot.Enabled = false
        stopAimbot()
    end,
})

-- ============================================
-- Helper Functions
-- ============================================

function getNearestTarget()
    local nearest = nil
    local minDist = Settings.Aimbot.FOV or 100
    
    if not lp.Character or not lp.Character:FindFirstChild("HumanoidRootPart") then
        return nil
    end
    
    local myPos = lp.Character.HumanoidRootPart.Position
    
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= lp and plr.Character then
            local targetPart = plr.Character:FindFirstChild(Settings.Aimbot.TargetPart)
            if targetPart then
                local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then
                    local dist = (targetPart.Position - myPos).Magnitude
                    local screenPos, onScreen = Workspace.CurrentCamera:WorldToScreenPoint(targetPart.Position)
                    
                    if onScreen then
                        local screenCenter = Vector2.new(Workspace.CurrentCamera.ViewportSize.X / 2, Workspace.CurrentCamera.ViewportSize.Y / 2)
                        local screenDist = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                        
                        if screenDist < minDist then
                            minDist = screenDist
                            nearest = targetPart
                        end
                    end
                end
            end
        end
    end
    
    return nearest
end

function startAimbot()
    if Connections.Aimbot then Connections.Aimbot:Disconnect() end
    
    Connections.Aimbot = RunService.Heartbeat:Connect(function()
        if not Settings.Aimbot.Enabled then return end
        
        local target = getNearestTarget()
        if target then
            local targetPos = target.Position
            
            if Settings.Aimbot.Prediction then
                local vel = target.Velocity
                targetPos = targetPos + vel * 0.15
            end
            
            local smoothness = Settings.Aimbot.Smoothness / 100
            local cam = Workspace.CurrentCamera
            local lookAt = CFrame.lookAt(cam.CFrame.Position, targetPos)
            cam.CFrame = cam.CFrame:Lerp(lookAt, smoothness)
        end
    end)
end

function stopAimbot()
    if Connections.Aimbot then
        Connections.Aimbot:Disconnect()
        Connections.Aimbot = nil
    end
end

function startESP()
    stopESP()
    
    Connections.ESP = RunService.RenderStepped:Connect(function()
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= lp and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                updatePlayerESP(plr)
            end
        end
    end)
    
    Connections.ESPAdd = Players.PlayerAdded:Connect(function(plr)
        plr.CharacterAdded:Connect(function()
            task.wait(0.5)
            if Settings.ESP.Enabled then
                updatePlayerESP(plr)
            end
        end)
    end)
end

function stopESP()
    if Connections.ESP then Connections.ESP:Disconnect(); Connections.ESP = nil end
    if Connections.ESPAdd then Connections.ESPAdd:Disconnect(); Connections.ESPAdd = nil end
    
    for _, obj in pairs(ESPObjects) do
        if obj then pcall(function() obj:Destroy() end) end
    end
    ESPObjects = {}
end

function updatePlayerESP(plr)
    -- Simplified ESP - just an example
    if not plr.Character or not plr.Character:FindFirstChild("HumanoidRootPart") then return end
    
    local hrp = plr.Character.HumanoidRootPart
    local hum = plr.Character:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return end
    
    -- Create/Update ESP elements
    local espData = ESPObjects[plr.UserId]
    if not espData then
        -- Create new ESP
        local highlight = Instance.new("Highlight")
        highlight.Parent = plr.Character
        highlight.FillTransparency = 0.5
        highlight.OutlineColor = Settings.ESP.Color
        highlight.FillColor = Settings.ESP.Color
        ESPObjects[plr.UserId] = highlight
    else
        -- Update existing
        if espData:IsA("Highlight") then
            espData.OutlineColor = Settings.ESP.Color
            espData.FillColor = Settings.ESP.Color
        end
    end
end

function updateESP()
    stopESP()
    if Settings.ESP.Enabled then
        startESP()
    end
end

function startSpeed()
    if Connections.Speed then Connections.Speed:Disconnect() end
    
    Connections.Speed = RunService.Heartbeat:Connect(function()
        if not Settings.Movement.SpeedEnabled then return end
        if not lp.Character then return end
        
        local hum = lp.Character:FindFirstChildOfClass("Humanoid")
        if hum and hum.MoveDirection.Magnitude > 0 then
            local speed = Settings.Movement.Speed
            lp.Character.HumanoidRootPart.Velocity = hum.MoveDirection * speed
        end
    end)
end

function stopSpeed()
    if Connections.Speed then
        Connections.Speed:Disconnect()
        Connections.Speed = nil
    end
end

function startFly()
    if Connections.Fly then Connections.Fly:Disconnect() end
    
    local flyKeyUp = nil
    local flyKeyDown = nil
    
    Connections.Fly = RunService.Heartbeat:Connect(function()
        if not Settings.Movement.FlyEnabled then return end
        if not lp.Character then return end
        
        local hrp = lp.Character:FindFirstChild("HumanoidRootPart")
        local hum = lp.Character:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then return end
        
        hum.PlatformStand = true
        
        local speed = Settings.Movement.FlySpeed
        local moveDir = Vector3.zero
        
        if UIS:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + Workspace.CurrentCamera.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - Workspace.CurrentCamera.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - Workspace.CurrentCamera.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + Workspace.CurrentCamera.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.E) then moveDir = moveDir + Vector3.new(0, 1, 0) end
        if UIS:IsKeyDown(Enum.KeyCode.Q) then moveDir = moveDir - Vector3.new(0, 1, 0) end
        
        if moveDir.Magnitude > 0 then
            hrp.Velocity = moveDir.Unit * speed
        else
            hrp.Velocity = Vector3.zero
        end
    end)
end

function stopFly()
    if Connections.Fly then
        Connections.Fly:Disconnect()
        Connections.Fly = nil
    end
    if lp.Character then
        local hum = lp.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.PlatformStand = false
        end
    end
end

function startAutoFarm()
    if Connections.AutoFarm then Connections.AutoFarm:Disconnect() end
    
    Connections.AutoFarm = RunService.Heartbeat:Connect(function()
        if not Settings.AutoFarm.Enabled then return end
        if not lp.Character then return end
        
        local target = getNearestTarget()
        if target then
            local hrp = lp.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local dist = (target.Position - hrp.Position).Magnitude
                if dist > 5 then
                    hrp.Velocity = (target.Position - hrp.Position).Unit * 50
                else
                    -- Attack
                    local tool = lp.Character:FindFirstChildOfClass("Tool")
                    if tool then
                        tool:Activate()
                    end
                end
            end
        end
    end)
end

function stopAutoFarm()
    if Connections.AutoFarm then
        Connections.AutoFarm:Disconnect()
        Connections.AutoFarm = nil
    end
end

-- ============================================
-- Character Added Handler
-- ============================================
lp.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    
    -- Reapply settings
    if Settings.Movement.JumpPower then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.JumpPower = Settings.Movement.JumpPower
        end
    end
    
    if Settings.Movement.SpeedEnabled then
        startSpeed()
    end
    
    if Settings.Movement.FlyEnabled then
        stopFly()
        task.wait(0.1)
        startFly()
    end
end)

-- ============================================
-- Cleanup on script end
-- ============================================
local function cleanup()
    stopAimbot()
    stopESP()
    stopSpeed()
    stopFly()
    stopAutoFarm()
    
    for _, conn in pairs(Connections) do
        if conn and typeof(conn) == "RBXScriptConnection" then
            conn:Disconnect()
        end
    end
    
    Connections = {}
    ESPObjects = {}
end

-- ============================================
-- إظهار النافذة
-- ============================================
Window:Show()
Library:Notification("Hub Loaded", "Press RightShift to toggle menu", 3, "info")

-- Return cleanup function
return cleanup
