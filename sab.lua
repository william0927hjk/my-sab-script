-- === Simple & Strong SAB Script - Draggable GUI ===

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local root = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

print("✅ Simple SAB Script Loaded - Drag GUI to side!")

local playerGui = gethui and gethui() or player:WaitForChild("PlayerGui")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = playerGui

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 250, 0, 320)
Frame.Position = UDim2.new(0, 30, 0.4, 0)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui

Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 12)

-- Draggable
local dragging, dragStart, startPos
Frame.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = inp.Position
        startPos = Frame.Position
    end
end)

UserInputService.InputChanged:Connect(function(inp)
    if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
        local delta = inp.Position - dragStart
        Frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

Frame.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,35)
title.BackgroundTransparency = 1
title.Text = "SAB Script"
title.TextColor3 = Color3.fromRGB(0, 200, 255)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = Frame

local function createToggle(name, y)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9,0,0,36)
    btn.Position = UDim2.new(0.05,0,0,y)
    btn.BackgroundColor3 = Color3.fromRGB(45,45,60)
    btn.Text = name..": OFF"
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamSemibold
    btn.Parent = Frame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)

    local on = false
    btn.MouseButton1Click:Connect(function()
        on = not on
        btn.Text = name..": "..(on and "ON" or "OFF")
        btn.BackgroundColor3 = on and Color3.fromRGB(0,180,0) or Color3.fromRGB(45,45,60)
    end)
    return function() return on end
end

local autoSteal = createToggle("Auto Steal", 45)
local autoCollect = createToggle("Auto Collect", 88)
local speed = createToggle("Speed", 131)
local noclip = createToggle("Noclip", 174)
local fly = createToggle("Fly (F)", 217)
local anti = createToggle("Anti-Hit", 260)

-- Speed
speed(function(s) humanoid.WalkSpeed = s and 80 or 16 end)

-- Noclip
local nc
noclip(function(s)
    if s then
        nc = RunService.Stepped:Connect(function()
            for _,p in character:GetDescendants() do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end)
    elseif nc then nc:Disconnect() end
end)

-- Fly
local flying, bv
UserInputService.InputBegan:Connect(function(i,gp)
    if gp or i.KeyCode ~= Enum.KeyCode.F or not fly() then return end
    flying = not flying
    if flying then
        bv = Instance.new("BodyVelocity")
        bv.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
        bv.Parent = root
    elseif bv then bv:Destroy() bv = nil end
end)

RunService.Heartbeat:Connect(function()
    if flying and bv then
        local cam = workspace.CurrentCamera
        local dir = Vector3.new()
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
        bv.Velocity = dir.Unit * 60
    end
end)

-- Strong Auto Steal (searches ALL prompts)
RunService.Heartbeat:Connect(function()
    if not root then return end

    if autoSteal() then
        for _, obj in ipairs(workspace:GetDescendants()) do
            local prompt = obj:FindFirstChildOfClass("ProximityPrompt")
            if prompt then
                pcall(function()
                    prompt.HoldDuration = 0
                    fireproximityprompt(prompt)
                end)
            end
        end
    end

    if autoCollect() then
        for _, v in ipairs(workspace:GetDescendants()) do
            if v.Name:lower():find("cash") or v.Name:lower():find("money") or v.Name:lower():find("drop") then
                pcall(function()
                    if (v.Position - root.Position).Magnitude < 100 then
                        root.CFrame = CFrame.new(v.Position)
                    end
                end)
            end
        end
    end

    if anti() then
        pcall(function()
            humanoid.PlatformStand = false
            humanoid:ChangeState(Enum.HumanoidStateType.Running)
        end)
    end
end)

player.CharacterAdded:Connect(function(c)
    character = c
    root = c:WaitForChild("HumanoidRootPart")
    humanoid = c:WaitForChild("Humanoid")
end)

print("✅ Drag the small box to the side. Turn Auto Steal on near other players' bases.")
