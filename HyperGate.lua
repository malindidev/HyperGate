local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- HyperGate Configuration
local HyperGate = {
    Theme = {
        Primary = Color3.fromRGB(15, 15, 25),
        Secondary = Color3.fromRGB(0, 255, 163),
        Accent = Color3.fromRGB(140, 0, 255)
    },
    Backgrounds = {
        "rbxassetid://7125432456", -- Nebula
        "rbxassetid://7125432457", -- Circuit
        "rbxassetid://7125432458", -- Particle
        "rbxassetid://7125432459"  -- Grid
    }
}

-- Client-Side Settings
local PlayerSettings = {}

-- Create loading screen
local loadingGui = Instance.new("ScreenGui")
loadingGui.Name = "LoadingScreen"
loadingGui.IgnoreGuiInset = true
loadingGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local loadingFrame = Instance.new("Frame")
loadingFrame.Size = UDim2.new(1, 0, 1, 0)
loadingFrame.BackgroundColor3 = HyperGate.Theme.Primary
loadingFrame.Parent = loadingGui

local loadingBar = Instance.new("Frame")
loadingBar.Size = UDim2.new(0, 0, 0, 4)
loadingBar.Position = UDim2.new(0.5, 0, 0.5, 0)
loadingBar.AnchorPoint = Vector2.new(0.5, 0.5)
loadingBar.BackgroundColor3 = HyperGate.Theme.Secondary
loadingBar.Parent = loadingFrame

local loadingText = Instance.new("TextLabel")
loadingText.Text = "HYPERGATE INITIALIZING"
loadingText.TextColor3 = Color3.new(1, 1, 1)
loadingText.Size = UDim2.new(1, 0, 0, 50)
loadingText.Position = UDim2.new(0, 0, 0.45, 0)
loadingText.BackgroundTransparency = 1
loadingText.Parent = loadingFrame

loadingGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

-- Animate loading bar
local loadTween = TweenService:Create(loadingBar, TweenInfo.new(2, Enum.EasingStyle.Quad), {
    Size = UDim2.new(0.7, 0, 0, 4)
})
loadTween:Play()

-- Main GUI Setup (hidden during loading)
local gui = Instance.new("ScreenGui")
gui.Name = "HyperGateUI"
gui.Enabled = false
gui.Parent = Players.LocalPlayer.PlayerGui

-- Rest of the code remains the same until we enable the GUI later

-- SaveSettings function
local function SaveSettings(player)
    local settingsJson = HttpService:JSONEncode(PlayerSettings)
    print("Settings saved for " .. player.Name .. ": " .. settingsJson)
end

-- Draggable GUI System
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

    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- Dynamic Background System
local currentBackground
local function CreateBackground(parent)
    if currentBackground then
        currentBackground:Destroy()
    end
    
    local background = Instance.new("ImageLabel")
    currentBackground = background
    background.Size = UDim2.new(1, 0, 1, 0)
    background.Image = PlayerSettings.Background or HyperGate.Backgrounds[1]
    background.ScaleType = Enum.ScaleType.Tile
    background.TileSize = UDim2.new(0, 512, 0, 512)
    background.BackgroundTransparency = 1
    background.ZIndex = -1
    background.Parent = parent

    TweenService:Create(background, TweenInfo.new(30, Enum.EasingStyle.Linear), {
        Position = UDim2.new(-1, 0, -1, 0)
    }):Play()
end

-- Keyless Profile System
local function CreateProfile(mainFrame)
    local player = Players.LocalPlayer
    local avatar = mainFrame.ProfileFrame.Avatar
    avatar.Image = string.format("rbxthumb://type=AvatarHeadShot&id=%d&w=150&h=150", player.UserId)

    -- Session Timer
    local sessionTime = Instance.new("TextLabel")
    sessionTime.Text = "Session: 00:00:00"
    sessionTime.TextColor3 = HyperGate.Theme.Secondary
    sessionTime.BackgroundTransparency = 1
    sessionTime.Size = UDim2.new(1, 0, 0, 30)
    sessionTime.Position = UDim2.new(0, 0, 1, 0)
    sessionTime.Parent = avatar

    local startTime = tick()
    RunService.Heartbeat:Connect(function()
        local duration = tick() - startTime
        sessionTime.Text = string.format("Session: %02d:%02d:%02d",
            math.floor(duration / 3600),
            math.floor((duration % 3600) / 60),
            math.floor(duration % 60)
        )
    end)
end

-- Smart AI System
-- ... (keep the original CreateAIChat and CreateSettings functions from first occurrence) ...

-- Main GUI Construction
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 400, 0, 500)
mainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
mainFrame.BackgroundColor3 = HyperGate.Theme.Primary
mainFrame.Parent = gui

-- Create ProfileFrame and Avatar
local profileFrame = Instance.new("Frame")
profileFrame.Name = "ProfileFrame"
profileFrame.Size = UDim2.new(0, 150, 0, 150)
profileFrame.Position = UDim2.new(0, 20, 0, 20)
profileFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
profileFrame.Parent = mainFrame

local avatar = Instance.new("ImageLabel")
avatar.Name = "Avatar"
avatar.Size = UDim2.new(1, 0, 1, 0)
avatar.BackgroundTransparency = 1
avatar.Parent = profileFrame

-- Initialize components
MakeDraggable(mainFrame)
CreateBackground(mainFrame)
CreateProfile(mainFrame)
CreateAIChat(mainFrame)
CreateSettings()

-- Finish loading sequence
loadTween.Completed:Wait()
loadingGui:Destroy()
gui.Enabled = true

-- Auto-save and cleanup
game:BindToClose(function()
    pcall(SaveSettings, Players.LocalPlayer)
end)

Players.PlayerRemoving:Connect(function(player)
    if player == Players.LocalPlayer then
        pcall(SaveSettings, player)
    end
end)
