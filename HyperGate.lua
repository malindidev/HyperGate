local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")

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
    },
    Responsive = {
        MobileBreakpoint = 600,
        MaxWidth = 600,
        MaxHeight = 800
    }
}

-- Client-Side Settings
local PlayerSettings = {}
local isMinimized = false

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

-- Main GUI Setup
local gui = Instance.new("ScreenGui")
gui.Name = "HyperGateUI"
gui.Enabled = false
gui.Parent = Players.LocalPlayer.PlayerGui

-- Rounded corners function
local function ApplyCorners(instance, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(radius, 0)
    corner.Parent = instance
end

-- Dynamic UI Scaling
local function UpdateUIScale()
    local viewport = workspace.CurrentCamera.ViewportSize
    local isMobile = viewport.X < HyperGate.Responsive.MobileBreakpoint
    
    local widthScale = math.min(0.9, HyperGate.Responsive.MaxWidth/viewport.X)
    local heightScale = math.min(0.9, HyperGate.Responsive.MaxHeight/viewport.Y)
    
    gui.MainFrame.Size = UDim2.new(
        isMobile and 0.95 or widthScale,
        0,
        isMobile and 0.9 or heightScale,
        0
    )
end

-- Discord Button
local function CreateDiscordButton(parent)
    local discordButton = Instance.new("TextButton")
    discordButton.Name = "DiscordButton"
    discordButton.Size = UDim2.new(0, 100, 0, 40)
    discordButton.Position = UDim2.new(1, -110, 0, 10)
    discordButton.AnchorPoint = Vector2.new(1, 0)
    discordButton.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
    discordButton.Text = "Join Discord"
    discordButton.TextColor3 = Color3.new(1, 1, 1)
    ApplyCorners(discordButton, 0.2)

    discordButton.MouseButton1Click:Connect(function()
        setclipboard("https://discord.com/invite/jBtSMu6NCf")
        local notification = Instance.new("TextLabel")
        notification.Text = "Discord link copied!"
        notification.TextColor3 = HyperGate.Theme.Secondary
        notification.BackgroundTransparency = 1
        notification.Parent = parent
        task.wait(2)
        notification:Destroy()
    end)
    
    discordButton.Parent = parent
end

-- Minimize/Maximize System
local function CreateMinimizeButton(parent)
    local minimizeButton = Instance.new("TextButton")
    minimizeButton.Name = "MinimizeButton"
    minimizeButton.Size = UDim2.new(0, 30, 0, 30)
    minimizeButton.Position = UDim2.new(1, -40, 0, 10)
    minimizeButton.AnchorPoint = Vector2.new(1, 0)
    minimizeButton.BackgroundColor3 = HyperGate.Theme.Accent
    minimizeButton.Text = "-"
    minimizeButton.TextColor3 = Color3.new(1, 1, 1)
    ApplyCorners(minimizeButton, 0.2)

    minimizeButton.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        if isMinimized then
            TweenService:Create(parent, TweenInfo.new(0.3), {
                Size = UDim2.new(0, 100, 0, 40)
            }):Play()
            minimizeButton.Text = "+"
        else
            UpdateUIScale()
            minimizeButton.Text = "-"
        end
    end)
    
    minimizeButton.Parent = parent
end

-- Main Frame Construction
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
mainFrame.BackgroundColor3 = HyperGate.Theme.Primary
ApplyCorners(mainFrame, 0.1)
mainFrame.Parent = gui

-- Initialize UI Scaling
UpdateUIScale()
workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(UpdateUIScale)

-- Create Profile Frame
local profileFrame = Instance.new("Frame")
profileFrame.Name = "ProfileFrame"
profileFrame.Size = UDim2.new(0, 150, 0, 150)
profileFrame.Position = UDim2.new(0, 20, 0, 20)
profileFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ApplyCorners(profileFrame, 0.1)
profileFrame.Parent = mainFrame

local avatar = Instance.new("ImageLabel")
avatar.Name = "Avatar"
avatar.Size = UDim2.new(1, 0, 1, 0)
avatar.BackgroundTransparency = 1
avatar.Parent = profileFrame

-- Add Components
CreateDiscordButton(mainFrame)
CreateMinimizeButton(mainFrame)
MakeDraggable(mainFrame)
CreateBackground(mainFrame)
CreateProfile(mainFrame)

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
