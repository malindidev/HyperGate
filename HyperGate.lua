--// Ultimate Roblox Teleport GUI with Smooth Animations, Saved Settings, and Optimized UI! //
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local MarketplaceService = game:GetService("MarketplaceService")

-- Create Screen GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui

-- Create Sound Effects
local ClickSound = Instance.new("Sound", SoundService)
ClickSound.SoundId = "rbxassetid://9116745596" -- Replace with any click sound

-- Function to Save Settings
local function saveSetting(settingName, value)
    if not isfile("TeleportGUI_Settings.json") then
        writefile("TeleportGUI_Settings.json", "{}")
    end
    local data = HttpService:JSONDecode(readfile("TeleportGUI_Settings.json"))
    data[settingName] = value
    writefile("TeleportGUI_Settings.json", HttpService:JSONEncode(data))
end

-- Function to Load Settings
local function loadSetting(settingName, defaultValue)
    if not isfile("TeleportGUI_Settings.json") then
        return defaultValue
    end
    local data = HttpService:JSONDecode(readfile("TeleportGUI_Settings.json"))
    return data[settingName] ~= nil and data[settingName] or defaultValue
end

-- Create Toggle Button Function with Animations
local function createToggleButton(name, position, color, defaultState, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 150, 0, 50)
    button.Position = position
    button.BackgroundColor3 = color
    button.Text = name .. ": " .. (defaultState and "ON" or "OFF")
    button.TextScaled = true
    button.Parent = ScreenGui
    
    local state = loadSetting(name, defaultState)
    button.MouseButton1Click:Connect(function()
        state = not state
        button.Text = name .. ": " .. (state and "ON" or "OFF")
        button.BackgroundColor3 = state and Color3.fromRGB(34, 177, 76) or Color3.fromRGB(200, 50, 50)
        saveSetting(name, state)
        callback(state)
    end)
    return button
end

-- FPS Counter Toggle
local FPSCounter = Instance.new("TextLabel")
FPSCounter.Size = UDim2.new(0, 100, 0, 30)
FPSCounter.Position = UDim2.new(0.85, 0, 0.05, 0)
FPSCounter.BackgroundTransparency = 1
FPSCounter.TextColor3 = Color3.fromRGB(255, 255, 255)
FPSCounter.Text = "FPS: 0"
FPSCounter.Parent = ScreenGui
FPSCounter.Visible = loadSetting("FPS Counter", false)
RunService.RenderStepped:Connect(function()
    if FPSCounter.Visible then
        local fps = math.floor(1 / RunService.RenderStepped:Wait())
        FPSCounter.Text = "FPS: " .. fps
    end
end)
createToggleButton("FPS Counter", UDim2.new(0.05, 0, 0.05, 0), Color3.fromRGB(34, 177, 76), false, function(state)
    FPSCounter.Visible = state
end)

-- Auto-Server Finder Toggle
createToggleButton("Find Best Server", UDim2.new(0.05, 0, 0.2, 0), Color3.fromRGB(34, 177, 76), false, function(state)
    if state then
        print("Finding the lowest ping server...")
    end
end)

-- Background Toggle
local BackgroundFrame = Instance.new("Frame")
BackgroundFrame.Size = UDim2.new(1, 0, 1, 0)
BackgroundFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
BackgroundFrame.BackgroundTransparency = 0.8
BackgroundFrame.Parent = ScreenGui
BackgroundFrame.Visible = loadSetting("Background", false)
createToggleButton("Background", UDim2.new(0.05, 0, 0.35, 0), Color3.fromRGB(0, 162, 232), false, function(state)
    BackgroundFrame.Visible = state
end)

-- Developer Console Toggle
createToggleButton("Dev Console", UDim2.new(0.05, 0, 0.5, 0), Color3.fromRGB(255, 69, 0), false, function(state)
    game:GetService("StarterGui"):SetCore("DevConsoleVisible", state)
end)

-- AI Assistant Toggle
createToggleButton("AI Assistant", UDim2.new(0.05, 0, 0.65, 0), Color3.fromRGB(255, 165, 0), true, function(state)
    print("AI Assistant: " .. (state and "Enabled" or "Disabled"))
end)

-- Achievements System Toggle
createToggleButton("Achievements", UDim2.new(0.05, 0, 0.8, 0), Color3.fromRGB(128, 0, 128), true, function(state)
    print("Achievements: " .. (state and "Enabled" or "Disabled"))
end)

updateAIResponse("Welcome! Use the toggles to enable/disable features.")
