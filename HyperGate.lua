-- HyperGate Client v2.0 (Stable)
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local UserInputService = game:GetService("UserInputService") -- Added missing import

-- Configuration
local HyperGate = {
    Theme = {
        Primary = Color3.fromRGB(15, 15, 25),
        Secondary = Color3.fromRGB(0, 255, 163),
        Accent = Color3.fromRGB(140, 0, 255)
    },
    DiscordLink = "https://discord.com/invite/jBtSMu6NCf"
}

-- UI Core
local gui = Instance.new("ScreenGui")
gui.Name = "HyperGateUI"
gui.ResetOnSpawn = false
gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

local function ApplyCorners(instance, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(radius, 0)
    corner.Parent = instance
end

-- Main Window
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
mainFrame.Size = UDim2.new(0, 400, 0, 500)
mainFrame.BackgroundColor3 = HyperGate.Theme.Primary
ApplyCorners(mainFrame, 0.15)
mainFrame.Parent = gui

-- Header Section
local headerFrame = Instance.new("Frame")
headerFrame.Size = UDim2.new(1, 0, 0, 60)
headerFrame.BackgroundTransparency = 1
headerFrame.Parent = mainFrame

-- Profile Section
local avatar = Instance.new("ImageLabel")
avatar.Size = UDim2.new(0, 50, 0, 50)
avatar.Position = UDim2.new(0, 10, 0, 5)
avatar.Image = string.format("rbxthumb://type=AvatarHeadShot&id=%d&w=150&h=150", Players.LocalPlayer.UserId)
avatar.BackgroundTransparency = 1
avatar.Parent = headerFrame

local usernameLabel = Instance.new("TextLabel")
usernameLabel.Text = Players.LocalPlayer.Name
usernameLabel.TextColor3 = HyperGate.Theme.Secondary
usernameLabel.Size = UDim2.new(0, 200, 0, 20)
usernameLabel.Position = UDim2.new(0, 70, 0, 10)
usernameLabel.Font = Enum.Font.SourceSansBold
usernameLabel.BackgroundTransparency = 1
usernameLabel.Parent = headerFrame

-- Session Timer
local sessionTime = Instance.new("TextLabel")
sessionTime.Text = "Session: 00:00:00"
sessionTime.TextColor3 = HyperGate.Theme.Secondary
sessionTime.Size = UDim2.new(0, 200, 0, 20)
sessionTime.Position = UDim2.new(0, 70, 0, 30)
sessionTime.BackgroundTransparency = 1
sessionTime.Font = Enum.Font.SourceSans
sessionTime.Parent = headerFrame

-- Teleport Section
local teleportFrame = Instance.new("Frame")
teleportFrame.Size = UDim2.new(1, -20, 0, 100)
teleportFrame.Position = UDim2.new(0, 10, 0, 70)
teleportFrame.BackgroundTransparency = 1
teleportFrame.Parent = mainFrame

local teleportInput = Instance.new("TextBox")
teleportInput.PlaceholderText = "Enter player name"
teleportInput.Size = UDim2.new(1, 0, 0, 40)
teleportInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
teleportInput.TextColor3 = Color3.new(1, 1, 1)
ApplyCorners(teleportInput, 0.1)
teleportInput.Parent = teleportFrame

local teleportButton = Instance.new("TextButton")
teleportButton.Text = "TELEPORT"
teleportButton.Size = UDim2.new(1, 0, 0, 40)
teleportButton.Position = UDim2.new(0, 0, 0, 50)
teleportButton.BackgroundColor3 = HyperGate.Theme.Accent
teleportButton.TextColor3 = Color3.new(1, 1, 1)
ApplyCorners(teleportButton, 0.1)
teleportButton.Parent = teleportFrame

-- Discord Button
local discordButton = Instance.new("TextButton")
discordButton.Text = "JOIN DISCORD"
discordButton.Size = UDim2.new(1, -20, 0, 40)
discordButton.Position = UDim2.new(0, 10, 1, -50)
discordButton.AnchorPoint = Vector2.new(0, 1)
discordButton.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
discordButton.TextColor3 = Color3.new(1, 1, 1)
ApplyCorners(discordButton, 0.1)
discordButton.Parent = mainFrame

-- Minimize System
local minimizeButton = Instance.new("TextButton")
minimizeButton.Size = UDim2.new(0, 30, 0, 30)
minimizeButton.Position = UDim2.new(1, -35, 0, 10)
minimizeButton.AnchorPoint = Vector2.new(1, 0)
minimizeButton.BackgroundColor3 = HyperGate.Theme.Accent
minimizeButton.TextColor3 = Color3.new(1, 1, 1)
minimizeButton.Text = "-"
ApplyCorners(minimizeButton, 0.2)
minimizeButton.Parent = mainFrame

-- Draggable System
local dragging, dragStart, startPos
mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- Minimize Handler
local isMinimized = false
local originalSize = mainFrame.Size
minimizeButton.Activated:Connect(function()
    isMinimized = not isMinimized
    TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
        Size = isMinimized and UDim2.new(0, 100, 0, 40) or originalSize
    }):Play()
    
    for _, child in ipairs(mainFrame:GetChildren()) do
        if child ~= minimizeButton then
            child.Visible = not isMinimized
        end
    end
    minimizeButton.Text = isMinimized and "+" or "-"
end)

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

-- Discord Handler
discordButton.Activated:Connect(function()
    setclipboard(HyperGate.DiscordLink)
    local notif = Instance.new("TextLabel")
    notif.Text = "Discord link copied!"
    notif.TextColor3 = HyperGate.Theme.Secondary
    notif.BackgroundTransparency = 1
    notif.Size = UDim2.new(1, 0, 0, 20)
    notif.Position = UDim2.new(0, 0, 1, -25)
    notif.Parent = mainFrame
    task.wait(2)
    notif:Destroy()
end)

-- Teleport Functionality
local function GetPlayerByName(name)
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Name:lower() == name:lower() then
            return player
        end
    end
    return nil
end

teleportButton.Activated:Connect(function()
    local targetName = teleportInput.Text
    if #targetName < 3 then return end
    
    local targetPlayer = GetPlayerByName(targetName)
    
    if targetPlayer then
        -- Teleport to the target player's server
        TeleportService:TeleportToPlayer(targetPlayer)
    else
        local notif = Instance.new("TextLabel")
        notif.Text = "Player not found!"
        notif.TextColor3 = Color3.fromRGB(255, 50, 50)
        notif.BackgroundTransparency = 1
        notif.Size = UDim2.new(1, 0, 0, 20)
        notif.Position = UDim2.new(0, 0, 1, -25)
        notif.Parent = mainFrame
        task.wait(2)
        notif:Destroy()
    end
end)
