-- === Your SAB Script - FIXED & Enhanced (william0927hjk) ===
-- Reference: Clean GUI + Robust structure

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local root = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

print("✅ Your SAB Script Loaded! (Fixed Auto Steal)")

-- Safe GUI Parent
local function GetSafeGui()
    if gethui then return gethui() end
    return player:WaitForChild("PlayerGui")
end

local playerGui = GetSafeGui()

-- GUI Setup (Reference style)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "YourSABGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = playerGui

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 360, 0, 540)
Frame.Position = UDim2.new(0.5, -180, 0.5, -270)
Frame.BackgroundColor3 = Color3.fromRGB(16, 24, 39)
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui

-- Corner + Gradient
local corner = Instance.new("UICorner", Frame)
corner.CornerRadius = UDim.new(0, 20)

local grad = Instance.new("UIGradient", Frame)
grad.Rotation = 35
grad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(12, 18, 32)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(21, 30, 47)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 82, 120))
}

local stroke1 = Instance.new("UIStroke", Frame)
stroke1.Thickness = 2
stroke1.Color = Color3.fromRGB(56, 189, 248)
stroke1.Transparency = 0.2

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -20, 0, 50)
Title.Position = UDim2.new(0, 10, 0, 10)
Title.BackgroundTransparency = 1
Title.Text = "Your SAB Script"
Title.TextColor3 = Color3.fromRGB(241, 245, 249)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.Parent = Frame

local function createToggle(name, yPos, default)
    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0.9, 0, 0, 50)
    toggle.Position = UDim2.new(0.05, 0, 0, yPos)
    toggle.BackgroundColor3 = Color3.fromRGB(30, 41, 59)
    toggle.Text = name .. ": OFF"
    toggle.TextColor3 = Color3.fromRGB(241, 245, 249)
    toggle.TextScaled = true
    toggle.Font = Enum.Font.GothamSemibold
    toggle.Parent = Frame

    local tCorner = Instance.new("UICorner", toggle)
    tCorner.CornerRadius = UDim.new(0, 12)

    local enabled = default or false
    local function updateUI()
        toggle.Text = name .. ": " .. (enabled and "ON" or "OFF")
        toggle.BackgroundColor3 = enabled and Color3.fromRGB(52, 180, 230) or Color3.fromRGB(30, 41, 59)
    end
    updateUI()

    toggle.MouseButton1Click:Connect(function()
        enabled = not enabled
        updateUI()
    end)

    return function() return enabled end
end

-- Toggles
local autoStealToggle = createToggle("Auto Steal (Instant)", 80, false)
local autoCollectToggle = createToggle("Auto Collect", 140, false)
local speedToggle = createToggle("Speed Hack", 200, false)
local noclipToggle = createToggle("Noclip", 260, false)
local flyToggle = createToggle("Fly (Press F)", 320, false)
local antiHitToggle = createToggle("Anti-Hit", 380, false)

-- Speed
speedToggle(function(state)
    humanoid.WalkSpeed = state and 80 or 16
end)

-- Noclip
local noclipConn
noclipToggle(function(state)
    if state then
        noclipConn = RunService.Stepped:Connect(function()
            if character then
                for _, part in ipairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end)
    else
        if noclipConn then noclipConn:Disconnect() end
    end
end)

-- Fly
local flying = false
local bodyVelocity
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.F and flyToggle() then
        flying = not flying
        local rp = character:FindFirstChild("HumanoidRootPart")
        if flying and rp then
            bodyVelocity = Instance.new("BodyVelocity")
            bodyVelocity.MaxForce = Vector3.new(1e5,1e5,1e5)
            bodyVelocity.Velocity = Vector3.new(0,0,0)
            bodyVelocity.Parent = rp
        elseif bodyVelocity then
            bodyVelocity:Destroy()
            bodyVelocity = nil
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if flying and bodyVelocity and character then
        local cam = workspace.CurrentCamera
        local dir = Vector3.new()
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
        bodyVelocity.Velocity = dir.Unit * 60
    end
end)

-- FIXED Auto Features
RunService.Heartbeat:Connect(function()
    if not character or not root then return end

    -- Auto Steal (Improved for SAB Plots + Podiums)
    if autoStealToggle() then
        pcall(function()
            local plots = workspace:FindFirstChild("Plots")
            if plots then
                for _, plot in ipairs(plots:GetChildren()) do
                    local podiums = plot:FindFirstChild("AnimalPodiums")
                    if podiums then
                        for _, podium in ipairs(podiums:GetChildren()) do
                            local base = podium:FindFirstChild("Base")
                            if base then
                                local spawn = base:FindFirstChild("Spawn")
                                if spawn then
                                    local attach = spawn:FindFirstChild("PromptAttachment") or spawn:FindFirstChildWhichIsA("Attachment")
                                    if attach then
                                        local prompt = attach:FindFirstChildOfClass("ProximityPrompt")
                                        if prompt then
                                            prompt.HoldDuration = 0
                                            fireproximityprompt(prompt)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end)
    end

    -- Auto Collect
    if autoCollectToggle() then
        for _, drop in ipairs(workspace:GetDescendants()) do
            if drop.Name:lower():find("cash") or drop.Name:lower():find("money") or drop.Name:lower():find("drop") then
                pcall(function()
                    if drop.Position and (drop.Position - root.Position).Magnitude < 100 then
                        root.CFrame = CFrame.new(drop.Position)
                    end
                end)
            end
        end
    end

    -- Anti-Hit
    if antiHitToggle() then
        pcall(function()
            humanoid.PlatformStand = false
            humanoid:ChangeState(Enum.HumanoidStateType.Running)
        end)
    end
end)

-- Respawn Handler
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    root = newChar:WaitForChild("HumanoidRootPart", 5)
    humanoid = newChar:WaitForChild("Humanoid", 5)
end)

print("✅ GUI + Auto Steal ready. Test near other bases!")
