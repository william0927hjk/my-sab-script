-- === Safe SAB Script - Error Fixed ===

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local root = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

print("✅ Safe SAB Script Loaded")

local playerGui = (gethui and gethui()) or player:WaitForChild("PlayerGui")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = playerGui

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 260, 0, 340)
Frame.Position = UDim2.new(0, 20, 0.3, 0)
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui

Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 12)

-- Draggable
local dragging = false
Frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        local startPos = Frame.Position
        local dragStart = input.Position
        
        local conn
        conn = UserInputService.InputChanged:Connect(function(inp)
            if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
                local delta = inp.Position - dragStart
                Frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
                if conn then conn:Disconnect() end
            end
        end)
    end
end)

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,40)
title.BackgroundTransparency = 1
title.Text = "SAB Script"
title.TextColor3 = Color3.fromRGB(0, 200, 255)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = Frame

local function createToggle(name, yPos)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9,0,0,38)
    btn.Position = UDim2.new(0.05,0,0,yPos)
    btn.BackgroundColor3 = Color3.fromRGB(45,45,60)
    btn.Text = name .. ": OFF"
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamSemibold
    btn.Parent = Frame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)

    local enabled = false
    btn.MouseButton1Click:Connect(function()
        enabled = not enabled
        btn.Text = name .. ": " .. (enabled and "ON" or "OFF")
        btn.BackgroundColor3 = enabled and Color3.fromRGB(0,170,0) or Color3.fromRGB(45,45,60)
    end)
    return function() return enabled end
end

local autoSteal = createToggle("Auto Steal", 50)
local autoCollect = createToggle("Auto Collect", 95)
local speedHack = createToggle("Speed", 140)
local noclipToggle = createToggle("Noclip", 185)
local flyToggle = createToggle("Fly (F)", 230)
local antiHit = createToggle("Anti-Hit", 275)

-- Features with safety
speedHack(function(state)
    pcall(function() humanoid.WalkSpeed = state and 75 or 16 end)
end)

local ncConn
noclipToggle(function(state)
    if state then
        ncConn = RunService.Stepped:Connect(function()
            pcall(function()
                for _, part in ipairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end)
        end)
    elseif ncConn then
        ncConn:Disconnect()
    end
end)

-- Fly
local flying = false
local bv
UserInputService.InputBegan:Connect(function(input, gp)
    if gp or input.KeyCode ~= Enum.KeyCode.F or not flyToggle() then return end
    flying = not flying
    pcall(function()
        if flying then
            bv = Instance.new("BodyVelocity")
            bv.MaxForce = Vector3.new(1e5,1e5,1e5)
            bv.Parent = root
        elseif bv then
            bv:Destroy()
            bv = nil
        end
    end)
end)

RunService.Heartbeat:Connect(function()
    pcall(function()
        if flying and bv then
            local cam = workspace.CurrentCamera
            local dir = Vector3.new()
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
            bv.Velocity = dir.Unit * 55
        end
    end)
end)

-- Safe Auto Features
RunService.Heartbeat:Connect(function()
    if not root or not root.Parent then return end

    if autoSteal() then
        pcall(function()
            for _, obj in ipairs(workspace:GetDescendants()) do
                local prompt = obj:FindFirstChildOfClass("ProximityPrompt")
                if prompt then
                    prompt.HoldDuration = 0
                    fireproximityprompt(prompt)
                end
            end
        end)
    end

    if autoCollect() then
        pcall(function()
            for _, v in ipairs(workspace:GetDescendants()) do
                if v.Name:lower():find("cash") or v.Name:lower():find("money") or v.Name:lower():find("drop") then
                    if (v.Position - root.Position).Magnitude < 90 then
                        root.CFrame = CFrame.new(v.Position)
                    end
                end
            end
        end)
    end

    if antiHit() then
        pcall(function()
            humanoid.PlatformStand = false
            humanoid:ChangeState(Enum.HumanoidStateType.Running)
        end)
    end
end)

player.CharacterAdded:Connect(function(new)
    character = new
    root = new:WaitForChild("HumanoidRootPart")
    humanoid = new:WaitForChild("Humanoid")
end)

print("✅ Drag GUI to side. Red text should be gone. Test Auto Steal near bases.")
