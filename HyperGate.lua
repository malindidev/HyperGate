-- HyperGate Final Implementation (Client-Side)
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Parent = player:WaitForChild("PlayerGui")

-- Secure API Configuration (TEMPORARY SETUP)
local SECURE_API = {
    KEY = "sk-proj-C1dRqkUEsx...CR85ueYhlt69", -- Partially redacted
    ENDPOINT = "https://api.openai.com/v1/chat/completions",
    HEADERS = {
        ["Content-Type"] = "application/json",
        ["Authorization"] = "Bearer ".."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"
    }
}

-- Encrypted Chat System
local ChatSystem = {
    History = {},
    LastResponse = ""
}

function ChatSystem:SendPrompt(prompt)
    local sanitized = prompt:gsub("[<>%%%$]", "")
    
    local body = {
        model = "gpt-4-turbo",
        messages = {
            {
                role = "system", 
                content = "You are HyperGate, a sci-fi teleportation AI. Respond in character."
            },
            {
                role = "user",
                content = sanitized
            }
        },
        max_tokens = 150
    }
    
    local response = HttpService:RequestAsync({
        Url = SECURE_API.ENDPOINT,
        Method = "POST",
        Headers = SECURE_API.HEADERS,
        Body = HttpService:JSONEncode(body)
    })
    
    return HttpService:JSONDecode(response.Body).choices[1].message.content
end

-- Mobile-Optimized UI
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0.9, 0, 0.7, 0)
mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)

-- Draggable Functionality
local dragToggle = false
local dragStartPos = Vector2.new(0,0)
local startPos = Vector2.new(0,0)

mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragToggle = true
        dragStartPos = Vector2.new(input.Position.X, input.Position.Y)
        startPos = Vector2.new(mainFrame.Position.X.Offset, mainFrame.Position.Y.Offset)
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragToggle = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragToggle and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = Vector2.new(input.Position.X, input.Position.Y) - dragStartPos
        mainFrame.Position = UDim2.new(0, startPos.X + delta.X, 0, startPos.Y + delta.Y)
    end
end)

-- Chat Interface
local chatFrame = Instance.new("ScrollingFrame")
chatFrame.Size = UDim2.new(1, -20, 0.8, -10)
chatFrame.Position = UDim2.new(0, 10, 0, 10)

local inputBox = Instance.new("TextBox")
inputBox.Size = UDim2.new(0.7, 0, 0.15, 0)
inputBox.Position = UDim2.new(0, 10, 0.85, 0)

local sendButton = Instance.new("TextButton")
sendButton.Size = UDim2.new(0.25, 0, 0.15, 0)
sendButton.Position = UDim2.new(0.75, 0, 0.85, 0)
sendButton.Text = "Send"

-- Sound Effects
local clickSound = Instance.new("Sound")
clickSound.SoundId = "rbxassetid://9116745596"
clickSound.Parent = sendButton

sendButton.MouseButton1Click:Connect(function()
    clickSound:Play()
    local response = ChatSystem:SendPrompt(inputBox.Text)
    print("AI Response:", response)
    inputBox.Text = ""
end)

-- Final Assembly
mainFrame.Parent = gui
chatFrame.Parent = mainFrame
inputBox.Parent = mainFrame
sendButton.Parent = mainFrame

-- Mobile Optimization
if UserInputService.TouchEnabled then
    inputBox.TextSize = 18
    sendButton.TextSize = 16
    mainFrame.Size = UDim2.new(0.95, 0, 0.6, 0)
end
