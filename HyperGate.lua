local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")

-- HyperGate Configuration
local HyperGate = {
    Themes = {
        Cyber = {
            Primary = Color3.fromRGB(15, 15, 25),
            Secondary = Color3.fromRGB(0, 255, 163),
            Accent = Color3.fromRGB(140, 0, 255),
            Transparency = 0.1
        },
        Midnight = {
            Primary = Color3.fromRGB(20, 20, 40),
            Secondary = Color3.fromRGB(140, 0, 255),
            Accent = Color3.fromRGB(200, 0, 255),
            Transparency = 0.2
        }
    },
    Backgrounds = {
        "rbxassetid://7125432456", -- Nebula
        "rbxassetid://7125432457", -- Circuit
        "rbxassetid://7125432458", -- Particle
        "rbxassetid://7125432459"  -- Grid
    },
    Responsive = {
        MobileBreakpoint = 600,
        MaxWidth = 600,
        MaxHeight = 800
    }
}

-- Client-Side Settings
local PlayerSettings = {
    Theme = "Cyber",
    Transparency = 0.1,
    LastSave = os.time()
}
local isMinimized = false
local activeTooltip = nil

-- Performance Optimizations
local DEBOUNCE_TIME = 0.5
local function SafeAction(fn)
    return function(...)
        if not PlayerSettings.Debounce then
            PlayerSettings.Debounce = true
            fn(...)
            task.wait(DEBOUNCE_TIME)
            PlayerSettings.Debounce = false
        end
    end
end

-- Theme and Transparency System
local function ApplyVisualSettings()
    local theme = HyperGate.Themes[PlayerSettings.Theme]
    
    -- Apply colors and transparency
    mainFrame.BackgroundColor3 = theme.Primary
    mainFrame.BackgroundTransparency = PlayerSettings.Transparency
    
    -- Update all children
    for _, child in ipairs(mainFrame:GetChildren()) do
        if child:IsA("Frame") then
            child.BackgroundTransparency = PlayerSettings.Transparency + 0.1
        end
    end
end

-- Tooltip System
local function ShowTooltip(text, position)
    if activeTooltip then
        activeTooltip:Destroy()
    end
    
    activeTooltip = Instance.new("TextLabel")
    activeTooltip.Text = text
    activeTooltip.TextColor3 = HyperGate.Themes[PlayerSettings.Theme].Secondary
    activeTooltip.BackgroundColor3 = HyperGate.Themes[PlayerSettings.Theme].Primary
    activeTooltip.Position = UDim2.new(0, position.X, 0, position.Y + 20)
    activeTooltip.Parent = gui
    activeTooltip.ZIndex = 100
    
    task.wait(2)
    activeTooltip:Destroy()
    activeTooltip = nil
end

-- Enhanced AI Commands
local function HandleCommand(message)
    local cmd = message:lower()
    
    -- Performance-sensitive commands
    if cmd == "players" then
        return #Players:GetPlayers().. " online players"
    elseif cmd == "fps" then
        return math.floor(1/RunService.RenderStepped:Wait()).. " FPS"
    elseif cmd == "ping" then
        return "Your ping: "..game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValueString()
    elseif cmd == "time" then
        return "Server time: "..os.date("%X")
    elseif cmd == "theme" then
        return "Current theme: "..PlayerSettings.Theme
    end
    
    return "I'm not sure how to respond to that."
end

-- Mobile Support Enhancements
local touchStartPos, touchStartTime
local function SetupMobileControls()
    UserInputService.TouchStarted:Connect(function(touch)
        touchStartPos = touch.Position
        touchStartTime = os.clock()
    end)

    UserInputService.TouchEnded:Connect(function(touch)
        if isMinimized then return end
        
        local swipe = touch.Position - touchStartPos
        local duration = os.clock() - touchStartTime
        
        if duration < 0.3 then
            if swipe.Y > 50 then
                -- Swipe down to minimize
                MinimizeUI()
            elseif swipe.Y < -50 then
                -- Swipe up to maximize
                MaximizeUI()
            end
        end
    end)
end

-- Performance-Optimized UI Scaling
local lastScaleUpdate = 0
local function UpdateUIScale()
    if os.clock() - lastScaleUpdate < 0.5 then return end
    lastScaleUpdate = os.clock()
    
    local viewport = workspace.CurrentCamera.ViewportSize
    local isMobile = viewport.X < HyperGate.Responsive.MobileBreakpoint
    
    mainFrame.Size = UDim2.new(
        isMobile and 0.95 or 0.8,
        0,
        isMobile and 0.9 or 0.85,
        0
    )
    
    -- Mobile-specific adjustments
    if isMobile then
        profileFrame.Size = UDim2.new(0.4, 0, 0.3, 0)
        chatInput.FontSize = Enum.FontSize.Size14
    else
        profileFrame.Size = UDim2.new(0, 150, 0, 150)
        chatInput.FontSize = Enum.FontSize.Size18
    end
end

-- Low-Power Mode
local function ManagePerformance()
    RunService.Heartbeat:Connect(function()
        if isMinimized then
            task.wait(1/15) -- Reduced update rate
        elseif RunService:IsStudio() then
            task.wait(1/30)
        else
            task.wait(1/60)
        end
    end)
end

-- Initialize Core Systems
ManagePerformance()
SetupMobileControls()
ApplyVisualSettings()

-- Auto-Save System
task.spawn(function()
    while true do
        task.wait(300) -- 5 minutes
        PlayerSettings.LastSave = os.time()
        pcall(SaveSettings, Players.LocalPlayer)
    end
end)

-- Add tooltips to existing elements
discordButton.MouseEnter:Connect(function(input)
    ShowTooltip("Click to copy Discord invite link!", Vector2.new(input.X, input.Y))
end)

minimizeButton.MouseEnter:Connect(function(input)
    ShowTooltip(isMinimized and "Restore UI" or "Minimize UI", Vector2.new(input.X, input.Y))
end)

-- Modified AI Chat Handler with Performance
chatInput.FocusLost:Connect(SafeAction(function(enter)
    if enter then
        local message = chatInput.Text
        chatInput.Text = ""
        
        addChatBubble(message, false)
        task.wait(0.5)
        addChatBubble(HandleCommand(message), true)
    end
end))
