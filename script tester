--[[
    EclipseX Style UI Library
    مع توثيق كامل للدوال
    تقدر تضيف أزرارك وتتحكم فيها
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Stats = game:GetService("Stats")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Colors
local ACCENT  = Color3.fromRGB(180,100,255)
local WHITE   = Color3.fromRGB(240,240,255)
local BG      = Color3.fromRGB(8,8,12)
local CARD    = Color3.fromRGB(14,14,22)
local OFF_CLR = Color3.fromRGB(35,35,50)
local MOB_ON  = Color3.fromRGB(130,60,220)
local MOB_OFF = Color3.fromRGB(14,10,24)

-- State
local toggleStates = {}
local mobileButtons = {}
local mobBtnRefs = {}
local changingKeybind = nil

-- Config
local CONFIG_KEY = "EclipseX_UI_Config"
local Keybinds = {
    AutoLeft = Enum.KeyCode.Q,
    AutoRight = Enum.KeyCode.E,
    AutoSteal = Enum.KeyCode.V,
    BatAimbot = Enum.KeyCode.Z,
    AntiRagdoll = Enum.KeyCode.X,
    Unwalk = Enum.KeyCode.N,
    SlowDown = Enum.KeyCode.F7,
    RagdollTP = Enum.KeyCode.F8,
    Drop = Enum.KeyCode.F3,
    Taunt = Enum.KeyCode.F4,
    TPDown = Enum.KeyCode.G,
}
local KeybindButtons = {}

local function saveConfig()
    pcall(function()
        if writefile then
            local data = {}
            for k,v in pairs(toggleStates) do data["TOGGLE_"..k] = v.state end
            for k,v in pairs(Keybinds) do data["KEY_"..k] = v.Name end
            writefile(CONFIG_KEY..".json", game:GetService("HttpService"):JSONEncode(data))
        end
    end)
end

local function loadConfig()
    pcall(function()
        if readfile and isfile and isfile(CONFIG_KEY..".json") then
            local ok, data = pcall(function() return game:GetService("HttpService"):JSONDecode(readfile(CONFIG_KEY..".json")) end)
            if ok and data then
                for k,_ in pairs(Keybinds) do
                    if data["KEY_"..k] then pcall(function() Keybinds[k] = Enum.KeyCode[data["KEY_"..k]] end) end
                end
            end
        end
    end)
end
loadConfig()

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "EclipseX_UI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = false
ScreenGui.Parent = player:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 360, 0, 580)
MainFrame.Position = UDim2.new(0.5, -180, 0.5, -290)
MainFrame.BackgroundColor3 = BG
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Visible = false
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 16)

local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Thickness = 2
MainStroke.Color = ACCENT
MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

task.spawn(function()
    while MainFrame and MainFrame.Parent do
        for i = 0, 20 do MainStroke.Thickness = 2 + i*0.05 task.wait(0.04) end
        for i = 0, 20 do MainStroke.Thickness = 3 - i*0.05 task.wait(0.04) end
    end
end)

local TitleBar = Instance.new("Frame", MainFrame)
TitleBar.Size = UDim2.new(1, 0, 0, 52)
TitleBar.BackgroundColor3 = Color3.fromRGB(10, 8, 18)
TitleBar.BorderSizePixel = 0
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 16)

local TitleFix = Instance.new("Frame", TitleBar)
TitleFix.Size = UDim2.new(1, 0, 0, 16)
TitleFix.Position = UDim2.new(0, 0, 1, -16)
TitleFix.BackgroundColor3 = Color3.fromRGB(10, 8, 18)
TitleFix.BorderSizePixel = 0

local TitleLbl = Instance.new("TextLabel", TitleBar)
TitleLbl.Size = UDim2.new(1, 0, 1, 0)
TitleLbl.BackgroundTransparency = 1
TitleLbl.Text = "EclipseX UI"
TitleLbl.Font = Enum.Font.GothamBlack
TitleLbl.TextSize = 22
TitleLbl.TextColor3 = WHITE
TitleLbl.TextStrokeColor3 = ACCENT
TitleLbl.TextStrokeTransparency = 0.5

-- Scale buttons
do
    local guiScale = 1.0
    local BASE_W, BASE_H = 360, 580
    local plusBtn = Instance.new("TextButton", TitleBar)
    plusBtn.Size = UDim2.new(0, 26, 0, 26)
    plusBtn.Position = UDim2.new(1, -58, 0.5, -13)
    plusBtn.BackgroundColor3 = Color3.fromRGB(30, 20, 50)
    plusBtn.Text = "+"
    plusBtn.Font = Enum.Font.GothamBlack
    plusBtn.TextSize = 16
    plusBtn.TextColor3 = ACCENT
    plusBtn.BorderSizePixel = 0
    Instance.new("UICorner", plusBtn).CornerRadius = UDim.new(0, 6)
    
    local minusBtn = Instance.new("TextButton", TitleBar)
    minusBtn.Size = UDim2.new(0, 26, 0, 26)
    minusBtn.Position = UDim2.new(1, -28, 0.5, -13)
    minusBtn.BackgroundColor3 = Color3.fromRGB(30, 20, 50)
    minusBtn.Text = "-"
    minusBtn.Font = Enum.Font.GothamBlack
    minusBtn.TextSize = 16
    minusBtn.TextColor3 = ACCENT
    minusBtn.BorderSizePixel = 0
    Instance.new("UICorner", minusBtn).CornerRadius = UDim.new(0, 6)
    
    plusBtn.MouseButton1Click:Connect(function()
        guiScale = math.min(guiScale + 0.1, 2.0)
        local w = math.floor(BASE_W * guiScale)
        local h = math.floor(BASE_H * guiScale)
        MainFrame.Size = UDim2.new(0, w, 0, h)
        MainFrame.Position = UDim2.new(0.5, -w/2, 0.5, -h/2)
    end)
    
    minusBtn.MouseButton1Click:Connect(function()
        guiScale = math.max(guiScale - 0.1, 0.4)
        local w = math.floor(BASE_W * guiScale)
        local h = math.floor(BASE_H * guiScale)
        MainFrame.Size = UDim2.new(0, w, 0, h)
        MainFrame.Position = UDim2.new(0.5, -w/2, 0.5, -h/2)
    end)
end

local DiscordLbl = Instance.new("TextLabel", MainFrame)
DiscordLbl.Size = UDim2.new(1, 0, 0, 18)
DiscordLbl.Position = UDim2.new(0, 0, 1, -22)
DiscordLbl.BackgroundTransparency = 1
DiscordLbl.Text = "UI Library - EclipseX Style"
DiscordLbl.Font = Enum.Font.GothamBold
DiscordLbl.TextSize = 11
DiscordLbl.TextColor3 = ACCENT

-- Tabs
local TabContainer = Instance.new("Frame", MainFrame)
TabContainer.Size = UDim2.new(1, -20, 0, 34)
TabContainer.Position = UDim2.new(0, 10, 0, 60)
TabContainer.BackgroundTransparency = 1

local function makeTab(text, xScale, xPos)
    local t = Instance.new("TextButton", TabContainer)
    t.Size = UDim2.new(xScale, -4, 1, 0)
    t.Position = UDim2.new(xPos, 2, 0, 0)
    t.BackgroundColor3 = OFF_CLR
    t.Text = text
    t.Font = Enum.Font.GothamBold
    t.TextSize = 11
    t.TextColor3 = Color3.fromRGB(160, 160, 160)
    t.BorderSizePixel = 0
    Instance.new("UICorner", t).CornerRadius = UDim.new(0, 8)
    return t
end

local FeatTab = makeTab("FEATURES", 0.2, 0)
local MovTab = makeTab("MOVEMENT", 0.2, 0.2)
local VisTab = makeTab("VISUALS", 0.2, 0.4)
local SetTab = makeTab("SETTINGS", 0.2, 0.6)
local BindTab = makeTab("BINDS", 0.2, 0.8)

local function makeScrollFrame()
    local sf = Instance.new("ScrollingFrame", MainFrame)
    sf.Size = UDim2.new(1, -20, 1, -148)
    sf.Position = UDim2.new(0, 10, 0, 103)
    sf.BackgroundTransparency = 1
    sf.BorderSizePixel = 0
    sf.ScrollBarThickness = 4
    sf.ScrollBarImageColor3 = ACCENT
    sf.CanvasSize = UDim2.new(0, 0, 0, 0)
    sf.AutomaticCanvasSize = Enum.AutomaticSize.Y
    sf.Visible = false
    local ll = Instance.new("UIListLayout", sf)
    ll.Padding = UDim.new(0, 6)
    ll.SortOrder = Enum.SortOrder.LayoutOrder
    return sf
end

local FeatFrame = makeScrollFrame()
local MovFrame = makeScrollFrame()
local VisFrame = makeScrollFrame()
local SetFrame = makeScrollFrame()
local BindFrame = makeScrollFrame()
FeatFrame.Visible = true

local frames = {FeatFrame, MovFrame, VisFrame, SetFrame, BindFrame}
local tabs = {FeatTab, MovTab, VisTab, SetTab, BindTab}

local function selectTab(idx)
    for i, sf in ipairs(frames) do sf.Visible = (i == idx) end
    for i, tb in ipairs(tabs) do
        tb.BackgroundColor3 = (i == idx) and ACCENT or OFF_CLR
        tb.TextColor3 = (i == idx) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(160, 160, 160)
    end
end

for i, tb in ipairs(tabs) do
    tb.MouseButton1Click:Connect(function() selectTab(i) end)
end
selectTab(1)

-- ============================================
-- LIBRARY API (الدوال اللي تقدر تستخدمها)
-- ============================================

local Library = {}

--[[
    إضافة تبويب جديد
    Library:AddTab(name) -> Frame
]]
function Library:AddTab(name)
    local oldCount = #tabs
    local newCount = oldCount + 1
    local xScale = 1 / newCount
    
    -- إعادة تحجيم التبويبات القديمة
    for i, tb in ipairs(tabs) do
        tb.Size = UDim2.new(xScale, -4, 1, 0)
        tb.Position = UDim2.new((i-1) * xScale, 2, 0, 0)
    end
    
    -- إنشاء تبويب جديد
    local newTab = makeTab(name, xScale, oldCount * xScale)
    table.insert(tabs, newTab)
    
    -- إنشاء صفحة جديدة
    local newFrame = makeScrollFrame()
    table.insert(frames, newFrame)
    
    -- تحديث الضغطات
    local idx = newCount
    newTab.MouseButton1Click:Connect(function() selectTab(idx) end)
    
    return newFrame
end

--[[
    إضافة قسم
    Library:AddSection(parent, text, order) -> Label
]]
function Library:AddSection(parent, text, order)
    local lbl = Instance.new("TextLabel", parent)
    lbl.Size = UDim2.new(1, 0, 0, 26)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = ACCENT
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.LayoutOrder = order or 1
    return lbl
end

--[[
    إضافة مفتاح Toggle
    Library:AddToggle(parent, name, order, callback, defaultOn) -> Row, State
]]
function Library:AddToggle(parent, name, order, callback, defaultOn)
    local row = Instance.new("Frame", parent)
    row.Size = UDim2.new(1, 0, 0, 44)
    row.BackgroundColor3 = CARD
    row.BorderSizePixel = 0
    row.LayoutOrder = order or 1
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 10)
    
    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(1, -70, 1, 0)
    lbl.Position = UDim2.new(0, 14, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = name
    lbl.TextColor3 = WHITE
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    
    local pW, pH, dSz = 46, 24, 18
    local track = Instance.new("Frame", row)
    track.Size = UDim2.new(0, pW, 0, pH)
    track.Position = UDim2.new(1, -(pW+12), 0.5, -pH/2)
    local initState = defaultOn or false
    track.BackgroundColor3 = initState and ACCENT or OFF_CLR
    track.BorderSizePixel = 0
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)
    
    local dot = Instance.new("Frame", track)
    dot.Size = UDim2.new(0, dSz, 0, dSz)
    dot.Position = initState and UDim2.new(1, -dSz-3, 0.5, -dSz/2) or UDim2.new(0, 3, 0.5, -dSz/2)
    dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    dot.BorderSizePixel = 0
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
    
    toggleStates[name] = {track = track, dot = dot, state = initState, dotSz = dSz}
    
    if initState and callback then task.defer(function() callback(true) end) end
    
    local btn = Instance.new("TextButton", row)
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.MouseButton1Click:Connect(function()
        local ns = not toggleStates[name].state
        toggleStates[name].state = ns
        track.BackgroundColor3 = ns and ACCENT or OFF_CLR
        dot.Position = ns and UDim2.new(1, -dSz-3, 0.5, -dSz/2) or UDim2.new(0, 3, 0.5, -dSz/2)
        if callback then callback(ns) end
        if mobBtnRefs[name] then
            TweenService:Create(mobBtnRefs[name], TweenInfo.new(0.15), {
                BackgroundColor3 = ns and MOB_ON or MOB_OFF
            }):Play()
        end
        task.defer(saveConfig)
    end)
    
    return {
        Row = row,
        SetState = function(state)
            toggleStates[name].state = state
            track.BackgroundColor3 = state and ACCENT or OFF_CLR
            dot.Position = state and UDim2.new(1, -dSz-3, 0.5, -dSz/2) or UDim2.new(0, 3, 0.5, -dSz/2)
        end,
        GetState = function() return toggleStates[name].state end,
    }
end

--[[
    إضافة زر عادي
    Library:AddButton(parent, text, order, callback) -> Row
]]
function Library:AddButton(parent, text, order, callback)
    local row = Instance.new("Frame", parent)
    row.Size = UDim2.new(1, 0, 0, 40)
    row.BackgroundColor3 = Color3.fromRGB(25, 20, 40)
    row.BorderSizePixel = 0
    row.LayoutOrder = order or 1
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 10)
    Instance.new("UIStroke", row).Color = ACCENT
    
    local btn = Instance.new("TextButton", row)
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = text
    btn.Font = Enum.Font.GothamBlack
    btn.TextSize = 13
    btn.TextColor3 = ACCENT
    btn.MouseButton1Click:Connect(callback)
    
    return row
end

--[[
    إضافة مدخل رقمي
    Library:AddNumberInput(parent, label, default, order, callback) -> Row
]]
function Library:AddNumberInput(parent, label, default, order, callback)
    local row = Instance.new("Frame", parent)
    row.Size = UDim2.new(1, 0, 0, 44)
    row.BackgroundColor3 = CARD
    row.BorderSizePixel = 0
    row.LayoutOrder = order or 1
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 10)
    
    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(1, -90, 1, 0)
    lbl.Position = UDim2.new(0, 14, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = WHITE
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    
    local box = Instance.new("TextBox", row)
    box.Size = UDim2.new(0, 68, 0, 28)
    box.Position = UDim2.new(1, -78, 0.5, -14)
    box.BackgroundColor3 = Color3.fromRGB(20, 18, 32)
    box.Text = tostring(default)
    box.TextColor3 = ACCENT
    box.Font = Enum.Font.GothamBold
    box.TextSize = 13
    box.TextXAlignment = Enum.TextXAlignment.Center
    box.BorderSizePixel = 0
    box.ClearTextOnFocus = false
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)
    
    box.FocusLost:Connect(function()
        local n = tonumber(box.Text)
        if n then
            if callback then callback(n) end
            task.defer(saveConfig)
        else
            box.Text = tostring(default)
        end
    end)
    
    return row
end

--[[
    إضافة زر موبايل
    Library:AddMobileButton(label, xOffset, yOffset, toggleName, callback) -> Button
]]
function Library:AddMobileButton(label, xOffset, yOffset, toggleName, callback)
    local btn = Instance.new("TextButton", ScreenGui)
    btn.Size = UDim2.new(0, 58, 0, 58)
    btn.Position = UDim2.new(1, xOffset, 0.5, yOffset)
    btn.BackgroundColor3 = MOB_OFF
    btn.BackgroundTransparency = 0.1
    btn.Text = label
    btn.TextColor3 = WHITE
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 9
    btn.TextWrapped = true
    btn.BorderSizePixel = 0
    btn.ZIndex = 20
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
    local s = Instance.new("UIStroke", btn)
    s.Color = ACCENT
    s.Thickness = 1.5
    s.Transparency = 0.3
    table.insert(mobileButtons, btn)
    if toggleName then mobBtnRefs[toggleName] = btn end
    btn.MouseButton1Click:Connect(callback)
    return btn
end

--[[
    تحديث حالة Toggle
    Library:SetToggleState(name, state)
]]
function Library:SetToggleState(name, state)
    local t = toggleStates[name]
    if not t then return end
    t.state = state
    t.track.BackgroundColor3 = state and ACCENT or OFF_CLR
    t.dot.Position = state and UDim2.new(1, -t.dotSz-3, 0.5, -t.dotSz/2) or UDim2.new(0, 3, 0.5, -t.dotSz/2)
    if mobBtnRefs[name] then
        TweenService:Create(mobBtnRefs[name], TweenInfo.new(0.15), {
            BackgroundColor3 = state and MOB_ON or MOB_OFF
        }):Play()
    end
end

--[[
    الحصول على حالة Toggle
    Library:GetToggleState(name) -> boolean
]]
function Library:GetToggleState(name)
    return toggleStates[name] and toggleStates[name].state or false
end

--[[
    إظهار/إخفاء القائمة الرئيسية
]]
function Library:Show()
    MainFrame.Visible = true
end

function Library:Hide()
    MainFrame.Visible = false
end

function Library:Toggle()
    MainFrame.Visible = not MainFrame.Visible
end

-- ============================================
-- مثال عملي على استخدام المكتبة
-- ============================================

print("====================================")
print("EclipseX Style UI Library Loaded!")
print("Use Library:AddTab(), Library:AddToggle(), etc.")
print("====================================")

-- مثال: إضافة تبويب جديد وعناصر فيه
local CustomTab = Library:AddTab("CUSTOM")

Library:AddSection(CustomTab, "  MY CUSTOM SECTION", 1)

Library:AddToggle(CustomTab, "My Custom Toggle", 2, function(state)
    print("My Custom Toggle is now:", state)
end, false)

Library:AddButton(CustomTab, "CLICK ME", 3, function()
    print("Button clicked!")
end)

Library:AddNumberInput(CustomTab, "Custom Value", 100, 4, function(value)
    print("Value changed to:", value)
end)

-- مثال: إضافة زر موبايل جديد
Library:AddMobileButton("CUSTOM\nBTN", -120, -350, nil, function()
    print("Custom mobile button clicked!")
end)

-- ============================================
-- تبويبات جاهزة (للمثال فقط - فاضية)
-- ============================================

Library:AddSection(FeatFrame, "  COMBAT", 1)
Library:AddToggle(FeatFrame, "Bat Aimbot", 2, function(v) print("Bat Aimbot:", v) end)
Library:AddToggle(FeatFrame, "Anti Ragdoll", 3, function(v) print("Anti Ragdoll:", v) end)

Library:AddSection(MovFrame, "  MOVEMENT", 1)
Library:AddToggle(MovFrame, "Speed Hack", 2, function(v) print("Speed Hack:", v) end)
Library:AddToggle(MovFrame, "Fly Hack", 3, function(v) print("Fly Hack:", v) end)

Library:AddSection(VisFrame, "  VISUALS", 1)
Library:AddToggle(VisFrame, "Player ESP", 2, function(v) print("ESP:", v) end, true)

-- ============================================
-- زر فتح/إغلاق
-- ============================================
do
    local OCGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
    OCGui.Name = "EclipseX_OpenClose"
    OCGui.ResetOnSpawn = false
    OCGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local OBtn = Instance.new("TextButton", OCGui)
    OBtn.Size = UDim2.new(0, 52, 0, 52)
    OBtn.Position = UDim2.new(0, 10, 0.5, -26)
    OBtn.BackgroundColor3 = Color3.fromRGB(10, 8, 18)
    OBtn.Text = "💠"
    OBtn.TextSize = 26
    OBtn.Font = Enum.Font.GothamBold
    OBtn.TextColor3 = WHITE
    OBtn.BorderSizePixel = 0
    OBtn.Active = true
    Instance.new("UICorner", OBtn).CornerRadius = UDim.new(0, 14)
    
    local OS = Instance.new("UIStroke", OBtn)
    OS.Thickness = 2
    OS.Color = ACCENT
    OS.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    
    task.spawn(function()
        while OBtn and OBtn.Parent do
            for i = 0, 20 do OS.Thickness = 2 + i*0.05 task.wait(0.04) end
            for i = 0, 20 do OS.Thickness = 3 - i*0.05 task.wait(0.04) end
        end
    end)
    
    do
        local dragging, dragStart, startPos = false, nil, nil
        OBtn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                dragStart = input.Position
                startPos = OBtn.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then dragging = false end
                end)
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
                local d = input.Position - dragStart
                OBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
            end
        end)
    end
    
    OBtn.MouseButton1Click:Connect(function()
        Library:Toggle()
        TweenService:Create(OS, TweenInfo.new(0.15), {
            Color = MainFrame.Visible and WHITE or ACCENT
        }):Play()
    end)
end

-- ============================================
-- Drag Main Frame
-- ============================================
do
    local dragging, dragStart, startPos = false, nil, nil
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
            local d = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- ============================================
-- FPS & Ping
-- ============================================
do
    local FPSLbl = Instance.new("TextLabel", TitleBar)
    FPSLbl.Size = UDim2.new(0, 70, 0, 16)
    FPSLbl.Position = UDim2.new(0, 10, 0, 5)
    FPSLbl.BackgroundTransparency = 1
    FPSLbl.Text = "0 FPS"
    FPSLbl.Font = Enum.Font.GothamBold
    FPSLbl.TextSize = 11
    FPSLbl.TextColor3 = ACCENT
    FPSLbl.TextXAlignment = Enum.TextXAlignment.Left
    
    local PingLbl = Instance.new("TextLabel", TitleBar)
    PingLbl.Size = UDim2.new(0, 70, 0, 16)
    PingLbl.Position = UDim2.new(1, -80, 0, 5)
    PingLbl.BackgroundTransparency = 1
    PingLbl.Text = "0ms"
    PingLbl.Font = Enum.Font.GothamBold
    PingLbl.TextSize = 11
    PingLbl.TextColor3 = ACCENT
    PingLbl.TextXAlignment = Enum.TextXAlignment.Right
    
    local fc, lft = 0, tick()
    RunService.RenderStepped:Connect(function()
        fc = fc + 1
        local ct = tick()
        if ct - lft >= 1 then
            FPSLbl.Text = fc .. " FPS"
            fc = 0
            lft = ct
        end
        pcall(function()
            PingLbl.Text = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) .. "ms"
        end)
    end)
end

return Library
