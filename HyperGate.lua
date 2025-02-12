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

-- SaveSettings function (customize as needed)
local function SaveSettings(player)
    local settingsJson = HttpService:JSONEncode(PlayerSettings)
    print("Settings saved for " .. player.Name .. ": " .. settingsJson)
end

-- Draggable GUI System (Mobile-Friendly)
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
local function CreateBackground(parent)
    local background = Instance.new("ImageLabel")
    background.Size = UDim2.new(1, 0, 1, 0)
    background.Image = PlayerSettings.Background or HyperGate.Backgrounds[1]
    background.ScaleType = Enum.ScaleType.Tile
    background.TileSize = UDim2.new(0, 512, 0, 512)
    background.BackgroundTransparency = 1
    background.ZIndex = -1
    background.Parent = parent

    -- Animate background
    TweenService:Create(background, TweenInfo.new(30, Enum.EasingStyle.Linear), {
        Position = UDim2.new(-1, 0, -1, 0)
    }):Play()
end

-- Keyless Profile System
local function CreateProfile()
    local player = Players.LocalPlayer
    local avatar = gui.MainFrame.ProfileFrame.Avatar
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
-- Smart AI System with Command Response
local function CreateAIChat(parent)
    local chatFrame = Instance.new("Frame")
    chatFrame.Size = UDim2.new(1, -20, 0, 150)
    chatFrame.Position = UDim2.new(0, 10, 0, 350)
    chatFrame.BackgroundColor3 = HyperGate.Theme.Primary
    chatFrame.Parent = parent

    local chatScroll = Instance.new("ScrollingFrame")
    chatScroll.Size = UDim2.new(1, -10, 1, -40)
    chatScroll.Position = UDim2.new(0, 5, 0, 5)
    chatScroll.BackgroundTransparency = 1
    chatScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    chatScroll.Parent = chatFrame

    local chatInput = Instance.new("TextBox")
    chatInput.Size = UDim2.new(1, -10, 0, 30)
    chatInput.Position = UDim2.new(0, 5, 1, -35)
    chatInput.PlaceholderText = "Ask me something..."
    chatInput.BackgroundColor3 = HyperGate.Theme.Primary
    chatInput.TextColor3 = HyperGate.Theme.Secondary
    chatInput.Parent = chatFrame

    local function addChatBubble(text, isAI)
        local bubble = Instance.new("TextLabel")
        bubble.Size = UDim2.new(0.8, 0, 0, 40)
        bubble.BackgroundColor3 = isAI and HyperGate.Theme.Primary or HyperGate.Theme.Accent
        bubble.TextColor3 = Color3.new(1, 1, 1)
        bubble.Text = text
        bubble.TextWrapped = true
        bubble.Parent = chatScroll

        if not isAI then
            bubble.AnchorPoint = Vector2.new(1, 0)
            bubble.Position = UDim2.new(1, -5, 0, #chatScroll:GetChildren() * 45)
        else
            bubble.Position = UDim2.new(0, 5, 0, #chatScroll:GetChildren() * 45)
        end

        chatScroll.CanvasSize = UDim2.new(0, 0, 0, #chatScroll:GetChildren() * 45)
        chatScroll.CanvasPosition = Vector2.new(0, chatScroll.CanvasSize.Y.Offset)
    end

    local function handleCommand(message)
        local response
        if message:lower() == "time" then
            response = "Current Time: " .. os.date("%X")
        elseif message:lower() == "date" then
            response = "Today's Date: " .. os.date("%x")
        elseif message:lower() == "hello" then
            response = "Hello! How can I assist you today?"
        elseif message:lower():find("teleport") then
            response = "Teleportation is not yet configured."
        else
            response = "I'm not sure how to respond to that."
        end
        return response
    end

    chatInput.FocusLost:Connect(function(enter)
        if enter then
            local message = chatInput.Text
            chatInput.Text = ""

            -- Add user message
            addChatBubble(message, false)

            -- AI response with command handling
            task.wait(0.5)
            addChatBubble(handleCommand(message), true)
        end
    end)
end

-- Settings System
local function CreateSettings()
    local settingsFrame = Instance.new("Frame")
    settingsFrame.Size = UDim2.new(0, 300, 0, 200)
    settingsFrame.Position = UDim2.new(0.5, -150, 0.5, -100)
    settingsFrame.BackgroundColor3 = HyperGate.Theme.Primary
    settingsFrame.Parent = gui

    -- Background Selector
    local bgSelector = Instance.new("ScrollingFrame")
    bgSelector.Size = UDim2.new(1, 0, 0, 80)
    bgSelector.Parent = settingsFrame

    for _, bg in ipairs(HyperGate.Backgrounds) do
        local thumb = Instance.new("ImageButton")
        thumb.Image = bg
        thumb.Size = UDim2.new(0, 80, 0, 80)
        thumb.BackgroundTransparency = 1
        thumb.MouseButton1Click:Connect(function()
            PlayerSettings.Background = bg
            CreateBackground(mainFrame)
        end)
        thumb.Parent = bgSelector
    end
end

-- Main GUI Setup
local gui = Instance.new("ScreenGui")
gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 400, 0, 500)
mainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
mainFrame.BackgroundColor3 = HyperGate.Theme.Primary
mainFrame.Parent = gui

-- Create ProfileFrame and Avatar UI elements so CreateProfile can reference them
local profileFrame = Instance.new("Frame")
profileFrame.Name = "ProfileFrame"
profileFrame.Size = UDim2.new(0, 150, 0, 150)
profileFrame.Position = UDim2.new(0, 20, 0, 20)
profileFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
profileFrame.Parent = mainFrame

local avatar = Instance.new("ImageLabel")
avatar.Name = "Avatar"
avatar.Size = UDim2.new(1, 0, 1, 0)
avatar.Position = UDim2.new(0, 0, 0, 0)
avatar.BackgroundTransparency = 1
avatar.Parent = profileFrame

MakeDraggable(mainFrame)
CreateBackground(mainFrame)
CreateProfile()
CreateAIChat(mainFrame)
CreateSettings()

-- Auto-save on game close
game:BindToClose(function()
    pcall(function()
        SaveSettings(Players.LocalPlayer)
    end)
end)

-- Save the settings when the player leaves
Players.PlayerRemoving:Connect(function(player)
    if player == Players.LocalPlayer then
        pcall(function()
            SaveSettings(player)
        end)
    end
end)-- Smart AI System with Command Response
local function CreateAIChat(parent)
    local chatFrame = Instance.new("Frame")
    chatFrame.Size = UDim2.new(1, -20, 0, 150)
    chatFrame.Position = UDim2.new(0, 10, 0, 350)
    chatFrame.BackgroundColor3 = HyperGate.Theme.Primary
    chatFrame.Parent = parent

    local chatScroll = Instance.new("ScrollingFrame")
    chatScroll.Size = UDim2.new(1, -10, 1, -40)
    chatScroll.Position = UDim2.new(0, 5, 0, 5)
    chatScroll.BackgroundTransparency = 1
    chatScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    chatScroll.Parent = chatFrame

    local chatInput = Instance.new("TextBox")
    chatInput.Size = UDim2.new(1, -10, 0, 30)
    chatInput.Position = UDim2.new(0, 5, 1, -35)
    chatInput.PlaceholderText = "Ask me something..."
    chatInput.BackgroundColor3 = HyperGate.Theme.Primary
    chatInput.TextColor3 = HyperGate.Theme.Secondary
    chatInput.Parent = chatFrame

    local function addChatBubble(text, isAI)
        local bubble = Instance.new("TextLabel")
        bubble.Size = UDim2.new(0.8, 0, 0, 40)
        bubble.BackgroundColor3 = isAI and HyperGate.Theme.Primary or HyperGate.Theme.Accent
        bubble.TextColor3 = Color3.new(1, 1, 1)
        bubble.Text = text
        bubble.TextWrapped = true
        bubble.Parent = chatScroll

        if not isAI then
            bubble.AnchorPoint = Vector2.new(1, 0)
            bubble.Position = UDim2.new(1, -5, 0, #chatScroll:GetChildren() * 45)
        else
            bubble.Position = UDim2.new(0, 5, 0, #chatScroll:GetChildren() * 45)
        end

        chatScroll.CanvasSize = UDim2.new(0, 0, 0, #chatScroll:GetChildren() * 45)
        chatScroll.CanvasPosition = Vector2.new(0, chatScroll.CanvasSize.Y.Offset)
    end

    local function handleCommand(message)
        local response
        if message:lower() == "time" then
            response = "Current Time: " .. os.date("%X")
        elseif message:lower() == "date" then
            response = "Today's Date: " .. os.date("%x")
        elseif message:lower() == "hello" then
            response = "Hello! How can I assist you today?"
        elseif message:lower():find("teleport") then
            response = "Teleportation is not yet configured."
        else
            response = "I'm not sure how to respond to that."
        end
        return response
    end

    chatInput.FocusLost:Connect(function(enter)
        if enter then
            local message = chatInput.Text
            chatInput.Text = ""

            -- Add user message
            addChatBubble(message, false)

            -- AI response with command handling
            task.wait(0.5)
            addChatBubble(handleCommand(message), true)
        end
    end)
end

-- Settings System
local function CreateSettings()
    local settingsFrame = Instance.new("Frame")
    settingsFrame.Size = UDim2.new(0, 300, 0, 200)
    settingsFrame.Position = UDim2.new(0.5, -150, 0.5, -100)
    settingsFrame.BackgroundColor3 = HyperGate.Theme.Primary
    settingsFrame.Parent = gui

    -- Background Selector
    local bgSelector = Instance.new("ScrollingFrame")
    bgSelector.Size = UDim2.new(1, 0, 0, 80)
    bgSelector.Parent = settingsFrame

    for _, bg in ipairs(HyperGate.Backgrounds) do
        local thumb = Instance.new("ImageButton")
        thumb.Image = bg
        thumb.Size = UDim2.new(0, 80, 0, 80)
        thumb.BackgroundTransparency = 1
        thumb.MouseButton1Click:Connect(function()
            PlayerSettings.Background = bg
            CreateBackground(mainFrame)
        end)
        thumb.Parent = bgSelector
    end
end

-- Main GUI Setup
local gui = Instance.new("ScreenGui")
gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 400, 0, 500)
mainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
mainFrame.BackgroundColor3 = HyperGate.Theme.Primary
mainFrame.Parent = gui

-- Create ProfileFrame and Avatar UI elements so CreateProfile can reference them
local profileFrame = Instance.new("Frame")
profileFrame.Name = "ProfileFrame"
profileFrame.Size = UDim2.new(0, 150, 0, 150)
profileFrame.Position = UDim2.new(0, 20, 0, 20)
profileFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
profileFrame.Parent = mainFrame

local avatar = Instance.new("ImageLabel")
avatar.Name = "Avatar"
avatar.Size = UDim2.new(1, 0, 1, 0)
avatar.Position = UDim2.new(0, 0, 0, 0)
avatar.BackgroundTransparency = 1
avatar.Parent = profileFrame

MakeDraggable(mainFrame)
CreateBackground(mainFrame)
CreateProfile()
CreateAIChat(mainFrame)
CreateSettings()

-- Auto-save on game close
game:BindToClose(function()
    pcall(function()
        SaveSettings(Players.LocalPlayer)
    end)
end)

-- Save the settings when the player leaves
Players.PlayerRemoving:Connect(function(player)
    if player == Players.LocalPlayer then
        pcall(function()
            SaveSettings(player)
        end)
    end
end)
