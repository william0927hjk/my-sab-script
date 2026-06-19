-- === Will's Custom Hub - SAB Edition (Rebranded) ===

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local root = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

print("✅ Will's Custom Hub Loaded for SAB")

local playerGui = gethui and gethui() or player:WaitForChild("PlayerGui")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = playerGui

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 300, 0, 420)
Frame.Position = UDim2.new(0, 30, 0.2, 0)
Frame.BackgroundColor3 = Color3.fromRGB(15, 15, 30)
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui

Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 12)

-- Title Bar (Nameless-style)
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
TitleBar.Parent = Frame
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 12)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -80, 1, 0)
Title.BackgroundTransparency = 1
Title.Text = "Will's Custom Hub"
Title.TextColor3 = Color3.new(1,1,1)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.Parent = TitleBar

-- Draggable
local dragging = false
TitleBar.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        local dragStart = inp.Position
        local startPos = Frame.Position
        local conn = UserInputService.InputChanged:Connect(function(i)
            if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                local delta = i.Position - dragStart
                Frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
        inp.Changed:Connect(function()
            if inp.UserInputState == Enum.UserInputState.End then dragging = false; conn:Disconnect() end
        end)
    end
end)

local function createToggle(name, y)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9,0,0,40)
    btn.Position = UDim2.new(0.05,0,0,y)
    btn.BackgroundColor3 = Color3.fromRGB(40,40,60)
    btn.Text = name .. ": OFF"
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamSemibold
    btn.Parent = Frame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)

    local on = false
    btn.MouseButton1Click:Connect(function()
        on = not on
        btn.Text = name .. ": " .. (on and "ON" or "OFF")
        btn.BackgroundColor3 = on and Color3.fromRGB(0, 180, 80) or Color3.fromRGB(40,40,60)
    end)
    return function() return on end
end

local autoSteal = createToggle("Auto Steal", 60)
local autoCollect = createToggle("Auto Collect", 110)
local speed = createToggle("Speed Hack", 160)
local noclip = createToggle("Noclip", 210)
local fly = createToggle("Fly (F)", 260)
local antiHit = createToggle("Anti-Hit", 310)

-- Features
speed(function(s) pcall(function() humanoid.WalkSpeed = s and 80 or 16 end) end)

local ncConn
noclip(function(s)
    if s then
        ncConn = RunService.Stepped:Connect(function()
            pcall(function()
                for _, p in character:GetDescendants() do
                    if p:IsA("BasePart") then p.CanCollide = false end
                end
            end)
        end)
    elseif ncConn then ncConn:Disconnect() end
end)

-- Fly
local flying, bv
UserInputService.InputBegan:Connect(function(i, gp)
    if gp or i.KeyCode ~= Enum.KeyCode.F or not fly() then return end
    flying = not flying
    pcall(function()
        if flying then
            bv = Instance.new("BodyVelocity")
            bv.MaxForce = Vector3.new(1e5,1e5,1e5)
            bv.Parent = root
        elseif bv then bv:Destroy() bv = nil end
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
            bv.Velocity = dir.Unit * 60
        end
    end)
end)

-- Auto Steal (Balanced)
RunService.Heartbeat:Connect(function()
    if not root then return end

    if autoSteal() then
        pcall(function()
            for _, obj in ipairs(workspace:GetDescendants()) do
                local prompt = obj:FindFirstChildOfClass("ProximityPrompt")
                if prompt then
                    local n = (obj.Name or ""):lower()
                    local pn = (obj.Parent and obj.Parent.Name or ""):lower()
                    local a = (prompt.ActionText or ""):lower()
                    if n:find("brain") or n:find("steal") or n:find("grab") or pn:find("podium") or pn:find("base") or a:find("steal") or a:find("grab") then
                        if (obj.Position - root.Position).Magnitude < 70 then
                            prompt.HoldDuration = 0
                            fireproximityprompt(prompt)
                        end
                    end
                end
            end
        end)
    end

    if autoCollect() then
        pcall(function()
            for _, v in ipairs(workspace:GetDescendants()) do
                if v.Name:lower():find("cash") or v.Name:lower():find("money") or v.Name:lower():find("drop") then
                    if (v.Position - root.Position).Magnitude < 100 then
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

player.CharacterAdded:Connect(function(c)
    character = c
    root = c:WaitForChild("HumanoidRootPart")
    humanoid = c:WaitForChild("Humanoid")
end)

print("✅ Drag the GUI. Turn on Auto Steal near brainrots.")
