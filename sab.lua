-- === Your Custom SAB Script - Improved for Delta ===
-- Update this file anytime and it auto-updates for users

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local root = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

print("✅ Your SAB Script Loaded! GitHub version.")

-- GUI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "YourSABGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = player:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 320, 0, 480)
Frame.Position = UDim2.new(0.5, -160, 0.5, -240)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 50)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Title.Text = "Your SAB Script"
Title.TextColor3 = Color3.new(1,1,1)
Title.TextScaled = true
Title.Parent = Frame

local function createToggle(name, yPos, default)
    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0.9, 0, 0, 45)
    toggle.Position = UDim2.new(0.05, 0, 0, yPos)
    toggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    toggle.Text = name .. ": OFF"
    toggle.TextColor3 = Color3.new(1,1,1)
    toggle.TextScaled = true
    toggle.Parent = Frame
    
    local enabled = default or false
    local function updateUI()
        toggle.Text = name .. ": " .. (enabled and "ON" or "OFF")
        toggle.BackgroundColor3 = enabled and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(60, 60, 60)
    end
    updateUI()
    
    toggle.MouseButton1Click:Connect(function()
        enabled = not enabled
        updateUI()
    end)
    
    return function() return enabled end
end

-- Toggles
local autoStealToggle = createToggle("Auto Steal (Instant)", 60, false)
local autoCollectToggle = createToggle("Auto Collect", 115, false)
local speedToggle = createToggle("Speed Hack", 170, false)
local noclipToggle = createToggle("Noclip", 225, false)
local flyToggle = createToggle("Fly (Press F)", 280, false)
local antiHitToggle = createToggle("Anti-Hit / Godmode", 335, false)

-- Speed Hack
speedToggle(function(state)
    if state then
        humanoid.WalkSpeed = 80
    else
        humanoid.WalkSpeed = 16
    end
end)

-- Noclip
local noclipConn
noclipToggle(function(state)
    if state then
        noclipConn = RunService.Stepped:Connect(function()
            if character then
                for _, part in ipairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        if noclipConn then noclipConn:Disconnect() end
    end
end)

-- Fly (F key)
local flying = false
local bodyVelocity
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.F and flyToggle() then
        flying = not flying
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if flying and rootPart then
            bodyVelocity = Instance.new("BodyVelocity")
            bodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
            bodyVelocity.Velocity = Vector3.new(0,0,0)
            bodyVelocity.Parent = rootPart
        elseif bodyVelocity then
            bodyVelocity:Destroy()
            bodyVelocity = nil
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if flying and bodyVelocity then
        local cam = workspace.CurrentCamera
        local dir = Vector3.new()
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
        bodyVelocity.Velocity = dir.Unit * 60
    end
end)

-- Main Loop - Auto Steal & Collect
RunService.Heartbeat:Connect(function()
    if not character or not root then return end
    
    -- Auto Steal
    if autoStealToggle() then
        for _, obj in ipairs(workspace:GetDescendants()) do
            local prompt = obj:FindFirstChildOfClass("ProximityPrompt")
            if prompt and (obj.Name:lower():find("brain") or obj.Name:lower():find("steal") or obj.Name:lower():find("base") or obj.Name:lower():find("grab")) then
                pcall(function()
                    prompt.HoldDuration = 0
                    fireproximityprompt(prompt)
                end)
            end
        end
    end
    
    -- Auto Collect Cash / Drops
    if autoCollectToggle() then
        for _, drop in ipairs(workspace:GetDescendants()) do
            if drop.Name:lower():find("cash") or drop.Name:lower():find("money") or drop.Name:lower():find("drop") then
                pcall(function()
                    if (drop.Position - root.Position).Magnitude < 80 then
                        root.CFrame = CFrame.new(drop.Position)
                    end
                end)
            end
        end
    end
    
    -- Basic Anti-Hit
    if antiHitToggle() then
        pcall(function()
            humanoid.PlatformStand = false
            humanoid:ChangeState(Enum.HumanoidStateType.Running)
        end)
    end
end)

-- Character Respawn Handler
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    root = newChar:WaitForChild("HumanoidRootPart")
    humanoid = newChar:WaitForChild("Humanoid")
    print("Character respawned - features restored")
end)

print("✅ All features ready. Toggle them in the GUI!")
