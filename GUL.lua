--[[
    EclipseX Style UI Library - Red Version
    زر الفتح: LZ - قابل للسحب
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

-- Colors - أحمر
local ACCENT  = Color3.fromRGB(255, 60, 60)
local WHITE   = Color3.fromRGB(240, 240, 240)
local BG      = Color3.fromRGB(12, 8, 8)
local CARD    = Color3.fromRGB(22, 14, 14)
local OFF_CLR = Color3.fromRGB(50, 35, 35)
local MOB_ON  = Color3.fromRGB(220, 60, 60)
local MOB_OFF = Color3.fromRGB(24, 10, 10)

-- State
local toggleStates = {}
local mobileButtons = {}
local mobBtnRefs = {}

-- Config
local CONFIG_KEY = "EclipseX_Red_UI_Config"

local function saveConfig()
    pcall(function()
        if writefile then
            local data = {positions = {}}
            for name, btn in pairs(mobBtnRefs) do
                data.positions["mob_"..name] = {x = btn.Position.X.Offset, y = btn.Position.Y.Offset}
            end
            for _, btn in ipairs(mobileButtons) do
                if not btn:GetAttribute("hasToggle") then
                    data.positions["mob_"..btn.Name] = {x = btn.Position.X.Offset, y = btn.Position.Y.Offset}
                end
            end
            -- حفظ موقع زر LZ
            if LZButton then
                data.positions["LZButton"] = {x = LZButton.Position.X.Offset, y = LZButton.Position.Y.Offset}
            end
            writefile(CONFIG_KEY..".json", game:GetService("HttpService"):JSONEncode(data))
        end
    end)
end

local function loadConfig()
    pcall(function()
        if readfile and isfile and isfile(CONFIG_KEY..".json") then
            local ok, data = pcall(function() return game:GetService("HttpService"):JSONDecode(readfile(CONFIG_KEY..".json")) end)
            if ok and data and data.positions then
                return data.positions
            end
        end
    end)
    return {}
end

local savedPositions = loadConfig()

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "EclipseX_Red"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = player:WaitForChild("PlayerGui")

-- قائمة صغيرة: 220x340
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 220, 0, 340)
MainFrame.Position = UDim2.new(0.5, -110, 0.5, -170)
MainFrame.BackgroundColor3 = BG
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Visible = false
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Thickness = 1
MainStroke.Color = ACCENT

-- Title Bar
local TitleBar = Instance.new("Frame", MainFrame)
TitleBar.Size = UDim2.new(1, 0, 0, 28)
TitleBar.BackgroundColor3 = Color3.fromRGB(18, 10, 10)
TitleBar.BorderSizePixel = 0
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 10)

local TitleFix = Instance.new("Frame", TitleBar)
TitleFix.Size = UDim2.new(1, 0, 0, 10)
TitleFix.Position = UDim2.new(0, 0, 1, -10)
TitleFix.BackgroundColor3 = Color3.fromRGB(18, 10, 10)
TitleFix.BorderSizePixel = 0

local TitleLbl = Instance.new("TextLabel", TitleBar)
TitleLbl.Size = UDim2.new(1, 0, 1, 0)
TitleLbl.BackgroundTransparency = 1
TitleLbl.Text = "EclipseX"
TitleLbl.Font = Enum.Font.GothamBlack
TitleLbl.TextSize = 13
TitleLbl.TextColor3 = WHITE

-- Tabs
local TabContainer = Instance.new("Frame", MainFrame)
TabContainer.Size = UDim2.new(1, -12, 0, 22)
TabContainer.Position = UDim2.new(0, 6, 0, 32)
TabContainer.BackgroundTransparency = 1

local function makeTab(text, xScale, xPos)
    local t = Instance.new("TextButton", TabContainer)
    t.Size = UDim2.new(xScale, -2, 1, 0)
    t.Position = UDim2.new(xPos, 1, 0, 0)
    t.BackgroundColor3 = OFF_CLR
    t.Text = text
    t.Font = Enum.Font.GothamBold
    t.TextSize = 9
    t.TextColor3 = Color3.fromRGB(160, 160, 160)
    t.BorderSizePixel = 0
    Instance.new("UICorner", t).CornerRadius = UDim.new(0, 5)
    return t
end

local Tab1 = makeTab("MAIN", 0.5, 0)
local Tab2 = makeTab("VISUAL", 0.5, 0.5)

local function makeScrollFrame()
    local sf = Instance.new("ScrollingFrame", MainFrame)
    sf.Size = UDim2.new(1, -12, 1, -82)
    sf.Position = UDim2.new(0, 6, 0, 56)
    sf.BackgroundTransparency = 1
    sf.BorderSizePixel = 0
    sf.ScrollBarThickness = 2
    sf.ScrollBarImageColor3 = ACCENT
    sf.CanvasSize = UDim2.new(0, 0, 0, 0)
    sf.AutomaticCanvasSize = Enum.AutomaticSize.Y
    sf.Visible = false
    local ll = Instance.new("UIListLayout", sf)
    ll.Padding = UDim.new(0, 3)
    ll.SortOrder = Enum.SortOrder.LayoutOrder
    return sf
end

local Tab1Frame = makeScrollFrame()
local Tab2Frame = makeScrollFrame()
Tab1Frame.Visible = true

local frames = {Tab1Frame, Tab2Frame}
local tabs = {Tab1, Tab2}

local function selectTab(idx)
    for i, sf in ipairs(frames) do sf.Visible = (i == idx) end
    for i, tb in ipairs(tabs) do
        tb.BackgroundColor3 = (i == idx) and ACCENT or OFF_CLR
        tb.TextColor3 = (i == idx) and WHITE or Color3.fromRGB(160, 160, 160)
    end
end

for i, tb in ipairs(tabs) do
    tb.MouseButton1Click:Connect(function() selectTab(i) end)
end

-- ============================================
-- نظام السحب للأزرار
-- ============================================
local function makeDraggable(btn, saveName)
    local dragging, dragStart, startPos = false, nil, nil
    
    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = btn.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    if saveName then saveConfig() end
                end
            end)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
            local d = input.Position - dragStart
            btn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
end

-- ============================================
-- LIBRARY API
-- ============================================

local Library = {}

function Library:AddSection(parent, text, order)
    local lbl = Instance.new("TextLabel", parent)
    lbl.Size = UDim2.new(1, 0, 0, 16)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = ACCENT
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 9
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.LayoutOrder = order or 1
    return lbl
end

function Library:AddToggle(parent, name, order, callback, defaultOn)
    local row = Instance.new("Frame", parent)
    row.Size = UDim2.new(1, 0, 0, 28)
    row.BackgroundColor3 = CARD
    row.BorderSizePixel = 0
    row.LayoutOrder = order or 1
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)
    
    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(1, -50, 1, 0)
    lbl.Position = UDim2.new(0, 8, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = name
    lbl.TextColor3 = WHITE
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 10
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    
    local pW, pH, dSz = 32, 16, 12
    local track = Instance.new("Frame", row)
    track.Size = UDim2.new(0, pW, 0, pH)
    track.Position = UDim2.new(1, -(pW+8), 0.5, -pH/2)
    local initState = defaultOn or false
    track.BackgroundColor3 = initState and ACCENT or OFF_CLR
    track.BorderSizePixel = 0
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)
    
    local dot = Instance.new("Frame", track)
    dot.Size = UDim2.new(0, dSz, 0, dSz)
    dot.Position = initState and UDim2.new(1, -dSz-2, 0.5, -dSz/2) or UDim2.new(0, 2, 0.5, -dSz/2)
    dot.BackgroundColor3 = WHITE
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
        dot.Position = ns and UDim2.new(1, -dSz-2, 0.5, -dSz/2) or UDim2.new(0, 2, 0.5, -dSz/2)
        if callback then callback(ns) end
        if mobBtnRefs[name] then
            TweenService:Create(mobBtnRefs[name], TweenInfo.new(0.15), {
                BackgroundColor3 = ns and MOB_ON or MOB_OFF
            }):Play()
        end
    end)
    
    return {
        SetState = function(state)
            toggleStates[name].state = state
            track.BackgroundColor3 = state and ACCENT or OFF_CLR
            dot.Position = state and UDim2.new(1, -dSz-2, 0.5, -dSz/2) or UDim2.new(0, 2, 0.5, -dSz/2)
            if mobBtnRefs[name] then
                TweenService:Create(mobBtnRefs[name], TweenInfo.new(0.15), {
                    BackgroundColor3 = state and MOB_ON or MOB_OFF
                }):Play()
            end
        end,
        GetState = function() return toggleStates[name].state end,
    }
end

function Library:AddButton(parent, text, order, callback)
    local row = Instance.new("Frame", parent)
    row.Size = UDim2.new(1, 0, 0, 26)
    row.BackgroundColor3 = Color3.fromRGB(40, 20, 20)
    row.BorderSizePixel = 0
    row.LayoutOrder = order or 1
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)
    
    local btn = Instance.new("TextButton", row)
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 10
    btn.TextColor3 = ACCENT
    btn.MouseButton1Click:Connect(callback)
    
    return row
end

function Library:AddSlider(parent, label, min, max, default, order, callback)
    local row = Instance.new("Frame", parent)
    row.Size = UDim2.new(1, 0, 0, 42)
    row.BackgroundColor3 = CARD
    row.BorderSizePixel = 0
    row.LayoutOrder = order or 1
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)
    
    local value = default or min
    
    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(1, -12, 0, 14)
    lbl.Position = UDim2.new(0, 6, 0, 3)
    lbl.BackgroundTransparency = 1
    lbl.Text = label .. ": " .. value
    lbl.TextColor3 = WHITE
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 9
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    
    local sliderBg = Instance.new("Frame", row)
    sliderBg.Size = UDim2.new(1, -12, 0, 3)
    sliderBg.Position = UDim2.new(0, 6, 0, 22)
    sliderBg.BackgroundColor3 = Color3.fromRGB(40, 30, 30)
    Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(1, 0)
    
    local fill = Instance.new("Frame", sliderBg)
    fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = ACCENT
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
    
    local dragging = false
    
    local sliderBtn = Instance.new("TextButton", sliderBg)
    sliderBtn.Size = UDim2.new(1, 0, 1, 8)
    sliderBtn.Position = UDim2.new(0, 0, 0, -4)
    sliderBtn.BackgroundTransparency = 1
    sliderBtn.Text = ""
    
    local function updateSlider(input)
        local relX = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
        value = math.floor(min + (max - min) * relX)
        fill.Size = UDim2.new(relX, 0, 1, 0)
        lbl.Text = label .. ": " .. value
        callback(value)
    end
    
    sliderBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateSlider(input)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateSlider(input)
        end
    end)
    
    return {
        Set = function(val)
            value = math.clamp(val, min, max)
            local relX = (value - min) / (max - min)
            fill.Size = UDim2.new(relX, 0, 1, 0)
            lbl.Text = label .. ": " .. value
            callback(value)
        end,
        Get = function() return value end
    }
end

function Library:AddMobileButton(label, xOffset, yOffset, toggleName, callback)
    local btn = Instance.new("TextButton", ScreenGui)
    btn.Size = UDim2.new(0, 48, 0, 48)
    
    local savedPos = nil
    if toggleName then
        savedPos = savedPositions["mob_"..toggleName]
    else
        savedPos = savedPositions["mob_"..label]
    end
    
    if savedPos then
        btn.Position = UDim2.new(0, savedPos.x, 0, savedPos.y)
    else
        btn.Position = UDim2.new(1, xOffset, 0.5, yOffset)
    end
    
    btn.BackgroundColor3 = MOB_OFF
    btn.BackgroundTransparency = 0.1
    btn.Text = label
    btn.TextColor3 = WHITE
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 8
    btn.TextWrapped = true
    btn.BorderSizePixel = 0
    btn.ZIndex = 20
    btn.Name = toggleName or label
    
    if not toggleName then
        btn:SetAttribute("hasToggle", false)
    else
        btn:SetAttribute("hasToggle", true)
    end
    
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    local s = Instance.new("UIStroke", btn)
    s.Color = ACCENT
    s.Thickness = 1
    s.Transparency = 0.3
    
    makeDraggable(btn, true)
    
    table.insert(mobileButtons, btn)
    if toggleName then mobBtnRefs[toggleName] = btn end
    
    btn.MouseButton1Click:Connect(function()
        if toggleName then
            local state = not Library:GetToggleState(toggleName)
            Library:SetToggleState(toggleName, state)
        end
        callback()
    end)
    
    return btn
end

function Library:Show() MainFrame.Visible = true end
function Library:Hide() MainFrame.Visible = false end
function Library:Toggle() MainFrame.Visible = not MainFrame.Visible end
function Library:GetToggleState(name) return toggleStates[name] and toggleStates[name].state or false end
function Library:SetToggleState(name, state)
    local t = toggleStates[name]
    if not t then return end
    t.state = state
    t.track.BackgroundColor3 = state and ACCENT or OFF_CLR
    t.dot.Position = state and UDim2.new(1, -t.dotSz-2, 0.5, -t.dotSz/2) or UDim2.new(0, 2, 0.5, -t.dotSz/2)
    if mobBtnRefs[name] then
        TweenService:Create(mobBtnRefs[name], TweenInfo.new(0.15), {
            BackgroundColor3 = state and MOB_ON or MOB_OFF
        }):Play()
    end
end

-- ============================================
-- إضافة العناصر للقائمة
-- ============================================

Library:AddSection(Tab1Frame, "COMBAT", 1)
Library:AddToggle(Tab1Frame, "Aimbot", 2, function(v) end)
Library:AddToggle(Tab1Frame, "Trigger Bot", 3, function(v) end)

Library:AddSection(Tab1Frame, "MOVEMENT", 4)
Library:AddToggle(Tab1Frame, "Speed Hack", 5, function(v) end)
Library:AddSlider(Tab1Frame, "Speed", 16, 200, 50, 6, function(v) end)
Library:AddToggle(Tab1Frame, "Fly Hack", 7, function(v) end)

Library:AddSection(Tab1Frame, "ACTIONS", 8)
Library:AddButton(Tab1Frame, "Kill All", 9, function() print("Kill All!") end)
Library:AddButton(Tab1Frame, "Teleport", 10, function() print("Teleport!") end)

Library:AddSection(Tab2Frame, "ESP", 1)
Library:AddToggle(Tab2Frame, "Player ESP", 2, function(v) end, true)
Library:AddToggle(Tab2Frame, "Boxes", 3, function(v) end)
Library:AddToggle(Tab2Frame, "Tracers", 4, function(v) end)

Library:AddSection(Tab2Frame, "WORLD", 5)
Library:AddToggle(Tab2Frame, "Full Bright", 6, function(v) end)
Library:AddToggle(Tab2Frame, "No Fog", 7, function(v) end)

-- ============================================
-- أزرار الموبايل - عمودين (3 في كل عمود) - مطلوعين يمين أكثر
-- ============================================
do
    local startY = -100   -- نقطة البداية العمودية
    local gapY = 55       -- المسافة بين الأزرار عمودياً
    local col1 = -45      -- العمود الأيسر (قيمة أصغر = أقرب لليمين)
    local col2 = -5       -- العمود الأيمن (ملاصق للحافة تقريباً)
    
    -- العمود الأيسر (3 أزرار)
    Library:AddMobileButton("AIMBOT", col1, startY, "Aimbot", function()
        print("Aimbot toggled!")
    end)
    
    Library:AddMobileButton("SPEED", col1, startY + gapY, "Speed Hack", function()
        print("Speed toggled!")
    end)
    
    Library:AddMobileButton("FLY", col1, startY + gapY*2, "Fly Hack", function()
        print("Fly toggled!")
    end)
    
    -- العمود الأيمن (3 أزرار) - ملاصق لليمين
    Library:AddMobileButton("ESP", col2, startY, "Player ESP", function()
        print("ESP toggled!")
    end)
    
    Library:AddMobileButton("KILL", col2, startY + gapY, nil, function()
        print("Kill All!")
    end)
    
    Library:AddMobileButton("TP", col2, startY + gapY*2, nil, function()
        print("Teleport!")
    end)
end

-- ============================================
-- زر LZ - يسار الشاشة (قابل للسحب)
-- ============================================
local LZButton = nil

do
    local OCGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
    OCGui.Name = "LZ_Button"
    OCGui.ResetOnSpawn = false
    OCGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    LZButton = Instance.new("TextButton", OCGui)
    LZButton.Size = UDim2.new(0, 40, 0, 40)
    
    local savedPos = savedPositions["LZButton"]
    if savedPos then
        LZButton.Position = UDim2.new(0, savedPos.x, 0, savedPos.y)
    else
        LZButton.Position = UDim2.new(0, 10, 0.5, -20)
    end
    
    LZButton.BackgroundColor3 = Color3.fromRGB(18, 10, 10)
    LZButton.Text = "LZ"
    LZButton.TextSize = 16
    LZButton.Font = Enum.Font.GothamBlack
    LZButton.TextColor3 = ACCENT
    LZButton.BorderSizePixel = 0
    LZButton.Active = true
    LZButton.Name = "LZButton"
    Instance.new("UICorner", LZButton).CornerRadius = UDim.new(0, 8)
    
    local OS = Instance.new("UIStroke", LZButton)
    OS.Thickness = 1.5
    OS.Color = ACCENT
    
    -- تأثير نبضي على الـ Stroke
    task.spawn(function()
        while LZButton and LZButton.Parent do
            for i = 0, 10 do OS.Thickness = 1.5 + i*0.1 task.wait(0.03) end
            for i = 0, 10 do OS.Thickness = 2.5 - i*0.1 task.wait(0.03) end
        end
    end)
    
    makeDraggable(LZButton, true)
    
    LZButton.MouseButton1Click:Connect(function()
        Library:Toggle()
        -- تأثير بصري عند الضغط
        TweenService:Create(LZButton, TweenInfo.new(0.1), {
            Size = UDim2.new(0, 44, 0, 44)
        }):Play()
        task.wait(0.1)
        TweenService:Create(LZButton, TweenInfo.new(0.1), {
            Size = UDim2.new(0, 40, 0, 40)
        }):Play()
    end)
end

-- Drag Main Frame
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

-- FPS
do
    local FPSLbl = Instance.new("TextLabel", TitleBar)
    FPSLbl.Size = UDim2.new(0, 40, 0, 12)
    FPSLbl.Position = UDim2.new(1, -44, 0, 2)
    FPSLbl.BackgroundTransparency = 1
    FPSLbl.Text = "0 FPS"
    FPSLbl.Font = Enum.Font.GothamBold
    FPSLbl.TextSize = 8
    FPSLbl.TextColor3 = ACCENT
    FPSLbl.TextXAlignment = Enum.TextXAlignment.Right
    
    local fc, lft = 0, tick()
    RunService.RenderStepped:Connect(function()
        fc = fc + 1
        local ct = tick()
        if ct - lft >= 1 then
            FPSLbl.Text = fc .. " FPS"
            fc = 0
            lft = ct
        end
    end)
end

-- Auto-save كل 5 ثواني
task.spawn(function()
    while task.wait(5) do
        saveConfig()
    end
end)

print("LZ Button UI Loaded! Drag the LZ button anywhere.")
return Library
