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
        "rbxassetid://7125432456",
        "rbxassetid://7125432457",
        "rbxassetid://7125432458",
        "rbxassetid://7125432459"
    }
}

local PlayerSettings = {}

local function MakeDraggable(frame)
    local dragging, dragInput, dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
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
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
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

local gui = Instance.new("ScreenGui")
gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0.9, 0, 0.9, 0)  -- Scaled for mobile
mainFrame.Position = UDim2.new(0.05, 0, 0.05, 0)  -- Centered for mobile
mainFrame.BackgroundColor3 = HyperGate.Theme.Primary
mainFrame.Parent = gui

MakeDraggable(mainFrame)
-- Adjustments for Mobile Devices
local function AdjustForMobile()
    if UserInputService.TouchEnabled then
        mainFrame.Size = UDim2.new(0.8, 0, 0.8, 0)
        mainFrame.Position = UDim2.new(0.1, 0, 0.1, 0)
        chatFrame.Size = UDim2.new(1, -20, 0.4, 0)
        chatFrame.Position = UDim2.new(0, 10, 0, mainFrame.Size.Y.Offset - chatFrame.Size.Y.Offset - 20)
        chatInput.Size = UDim2.new(1, -10, 0, 40)
        chatInput.Position = UDim2.new(0, 5, 1, -45)
        settingsFrame.Size = UDim2.new(0.9, 0, 0.6, 0)
        settingsFrame.Position = UDim2.new(0.05, 0, 0.2, 0)
    end
end

AdjustForMobile()

UserInputService.OrientationChanged:Connect(function()
    AdjustForMobile()
end)
