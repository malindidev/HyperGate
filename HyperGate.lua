-- HyperGate Client v1.2
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")

-- Configuration
local HyperGate = {
    Themes = {
        Cyber = {
            Primary = Color3.fromRGB(15, 15, 25),
            Secondary = Color3.fromRGB(0, 255, 163),
            Accent = Color3.fromRGB(140, 0, 255)
        },
        Midnight = {
            Primary = Color3.fromRGB(20, 20, 40),
            Secondary = Color3.fromRGB(140, 0, 255),
            Accent = Color3.fromRGB(200, 0, 255)
        }
    },
    Backgrounds = {
        "rbxassetid://7125432456",
        "rbxassetid://7125432457",
        "rbxassetid://7125432458",
        "rbxassetid://7125432459"
    },
    DefaultSettings = {
        Theme = "Cyber",
        Background = "rbxassetid://7125432456",
        Transparency = 0.1,
        SmartDefaults = false,
        PerformanceMode = true
    }
}

-- Client State
local PlayerSettings = table.clone(HyperGate.DefaultSettings)
local isMinimized = false
local heavyElements = {}
local activeTheme = HyperGate.Themes[PlayerSettings.Theme]

-- UI Core
local gui = Instance.new("ScreenGui")
gui.Name = "HyperGateUI"
gui.ResetOnSpawn = false

local function ApplyCorners(instance, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(radius, 0)
    corner.Parent = instance
end

-- Loading Screen
local loadingGui = Instance.new("ScreenGui")
loadingGui.Name = "LoadingScreen"
loadingGui.IgnoreGuiInset = true

local loadingFrame = Instance.new("Frame")
loadingFrame.Size = UDim2.new(1, 0, 1, 0)
loadingFrame.BackgroundColor3 = activeTheme.Primary
loadingFrame.Parent = loadingGui

local loadingBar = Instance.new("Frame")
loadingBar.Size = UDim2.new(0, 0, 0, 4)
loadingBar.Position = UDim2.new(0.5, 0, 0.5, 0)
loadingBar.AnchorPoint = Vector2.new(0.5, 0.5)
loadingBar.BackgroundColor3 = activeTheme.Secondary
loadingBar.Parent = loadingFrame

loadingGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

-- Main UI
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
mainFrame.BackgroundColor3 = activeTheme.Primary
mainFrame.BackgroundTransparency = PlayerSettings.Transparency
ApplyCorners(mainFrame, 0.1)

-- Profile System
local profileFrame = Instance.new("Frame")
profileFrame.Name = "ProfileFrame"
profileFrame.Size = UDim2.new(0, 150, 0, 150)
profileFrame.Position = UDim2.new(0, 20, 0, 20)
profileFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ApplyCorners(profileFrame, 0.2)
profileFrame.Parent = mainFrame

local avatar = Instance.new("ImageLabel")
avatar.Name = "Avatar"
avatar.Size = UDim2.new(1, 0, 1, 0)
avatar.BackgroundTransparency = 1
avatar.Image = string.format("rbxthumb://type=AvatarHeadShot&id=%d&w=150&h=150", Players.LocalPlayer.UserId)
avatar.Parent = profileFrame

-- Session Timer
local sessionTime = Instance.new("TextLabel")
sessionTime.Text = "Session: 00:00:00"
sessionTime.TextColor3 = activeTheme.Secondary
sessionTime.BackgroundTransparency = 1
sessionTime.Size = UDim2.new(1, 0, 0, 30)
sessionTime.Position = UDim2.new(0, 0, 1, 0)
sessionTime.Parent = avatar

-- Discord Button
local discordButton = Instance.new("TextButton")
discordButton.Name = "DiscordButton"
discordButton.Size = UDim2.new(0, 100, 0, 40)
discordButton.Position = UDim2.new(1, -110, 0, 10)
discordButton.AnchorPoint = Vector2.new(1, 0)
discordButton.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
discordButton.Text = "Join Discord"
discordButton.TextColor3 = Color3.new(1, 1, 1)
ApplyCorners(discordButton, 0.2)
discordButton.Parent = mainFrame

-- Minimize System
local minimizeButton = Instance.new("TextButton")
minimizeButton.Name = "MinimizeButton"
minimizeButton.Size = UDim2.new(0, 30, 0, 30)
minimizeButton.Position = UDim2.new(1, -40, 0, 10)
minimizeButton.AnchorPoint = Vector2.new(1, 0)
minimizeButton.BackgroundColor3 = activeTheme.Accent
minimizeButton.TextColor3 = Color3.new(1, 1, 1)
minimizeButton.Text = "-"
ApplyCorners(minimizeButton, 0.2)
minimizeButton.Parent = mainFrame

-- Draggable System
local function MakeDraggable(frame)
    local dragging, dragInput, dragStart, startPos

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- Settings System
local function CreateSettingsMenu()
    local settingsFrame = Instance.new("Frame")
    settingsFrame.Size = UDim2.new(0, 300, 0, 200)
    settingsFrame.Position = UDim2.new(0.5, -150, 0.5, -100)
    settingsFrame.BackgroundTransparency = 0.95
    settingsFrame.Parent = mainFrame

    -- Smart Defaults Toggle
    local defaultsToggle = Instance.new("TextButton")
    defaultsToggle.Size = UDim2.new(1, -20, 0, 30)
    defaultsToggle.Position = UDim2.new(0, 10, 0, 10)
    defaultsToggle.Text = "Auto-Repair: " .. (PlayerSettings.SmartDefaults and "ON" or "OFF")
    defaultsToggle.Activated:Connect(function()
        PlayerSettings.SmartDefaults = not PlayerSettings.SmartDefaults
        defaultsToggle.Text = "Auto-Repair: " .. (PlayerSettings.SmartDefaults and "ON" or "OFF")
    end)
    defaultsToggle.Parent = settingsFrame

    -- Performance Toggle
    local perfToggle = Instance.new("TextButton")
    perfToggle.Size = UDim2.new(1, -20, 0, 30)
    perfToggle.Position = UDim2.new(0, 10, 0, 50)
    perfToggle.Text = "Performance: " .. (PlayerSettings.PerformanceMode and "ON" or "OFF")
    perfToggle.Activated:Connect(function()
        PlayerSettings.PerformanceMode = not PlayerSettings.PerformanceMode
        perfToggle.Text = "Performance: " .. (PlayerSettings.PerformanceMode and "ON" or "OFF")
    end)
    perfToggle.Parent = settingsFrame
end

-- Final Initialization
MakeDraggable(mainFrame)
gui.Parent = Players.LocalPlayer.PlayerGui
mainFrame.Parent = gui

-- Loading Transition
local loadTween = TweenService:Create(loadingBar, TweenInfo.new(2), {Size = UDim2.new(0.7, 0, 0, 4)})
loadTween:Play()
loadTween.Completed:Wait()
loadingGui:Destroy()
gui.Enabled = true

-- Session Timer
local startTime = tick()
RunService.Heartbeat:Connect(function()
    local duration = tick() - startTime
    sessionTime.Text = string.format("Session: %02d:%02d:%02d",
        math.floor(duration / 3600),
        math.floor((duration % 3600) / 60),
        math.floor(duration % 60)
    )
end)

-- Discord Button Handler
discordButton.Activated:Connect(function()
    setclipboard("https://discord.com/invite/jBtSMu6NCf")
    local notif = Instance.new("TextLabel")
    notif.Text = "Copied Discord link!"
    notif.TextColor3 = activeTheme.Secondary
    notif.BackgroundTransparency = 1
    notif.Parent = mainFrame
    task.wait(2)
    notif:Destroy()
end)

-- Minimize Handler
minimizeButton.Activated:Connect(function()
    isMinimized = not isMinimized
    TweenService:Create(mainFrame, TweenInfo.new(0.3), {
        Size = isMinimized and UDim2.new(0, 100, 0, 40) or UDim2.new(0.8, 0, 0.8, 0)
    }):Play()
    minimizeButton.Text = isMinimized and "+" or "-"
end)

-- Auto-Save
game:BindToClose(function()
    pcall(function()
        HttpService:JSONEncode(PlayerSettings)
        -- Implement your save system here
    end)
end)
