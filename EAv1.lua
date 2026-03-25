--[[ 
    SUPREME V38 - SILENT FIXED - BY THIEN
    - Aim FOV: Viền siêu mảnh (1) + Có khoảng trống nhìn mặt địch.
    - Dot: Hiện ở tâm (Bật/Tắt qua nút DOT).
    - Silent Aim: Đã sửa - Ghim mục tiêu gần nhất tới chết (Xoay nhân vật).
    - ESP: Giữ nguyên từ bản V38.
    - Các tính năng khác: Giữ nguyên y hệt yêu cầu.
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- States
local isAimbotOn = false
local aimMode = "Aim FOV" 
local espEnabled = false
local dotEnabled = false
local fovRadius = 90
local aimPart = "Head"
local running = true 
local lockedTarget = nil 

-- 0. SOUNDS
local pGui = LocalPlayer:WaitForChild("PlayerGui")
local function playSound(id) 
    local s = Instance.new("Sound", pGui); s.SoundId = "rbxassetid://"..id; s:Play()
    game:GetService("Debris"):AddItem(s, 1) 
end
local function playClick() playSound("6895079853") end
local function playLaser() playSound("5835258957") end

-- 1. DRAWINGS (FIX VISUAL MẢNH)
local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = 1 -- Viền mảnh theo ý bro
fovCircle.NumSides = 60
fovCircle.Filled = false
fovCircle.Visible = false

local dot = Drawing.new("Circle")
dot.Thickness = 1
dot.Radius = 2.5 -- Chấm tâm gọn
dot.Filled = true
dot.Visible = false

-- 2. GUI SETUP (KHUNG V38 GIỮ NGUYÊN)
local sg = Instance.new("ScreenGui", pGui); sg.Name = "Thien_V38_SilentFix"; sg.ResetOnSpawn = false
local main = Instance.new("Frame", sg); main.Size = UDim2.new(0, 180, 0, 340); main.Position = UDim2.new(0.8, 0, 0.4, 0); main.BackgroundColor3 = Color3.fromRGB(10, 10, 10); main.BorderSizePixel = 0
local stroke = Instance.new("UIStroke", main); stroke.Thickness = 2; stroke.Color = Color3.fromHSV(0, 1, 1); Instance.new("UICorner", main)

local title = Instance.new("TextLabel", main); title.Size = UDim2.new(1, -30, 0, 30); title.Position = UDim2.new(0, 5, 0, 0); title.Text = "SUPREME V38 FIX"; title.TextColor3 = Color3.new(1,1,1); title.BackgroundTransparency = 1; title.TextXAlignment = "Left"; title.Font = "GothamBold"
local minBtn = Instance.new("TextButton", main); minBtn.Size = UDim2.new(0, 25, 0, 25); minBtn.Position = UDim2.new(1, -30, 0, 2); minBtn.Text = "-"; minBtn.TextColor3 = Color3.new(1,1,1); minBtn.BackgroundTransparency = 1; minBtn.TextSize = 25

local scroll = Instance.new("ScrollingFrame", main); scroll.Size = UDim2.new(1, -10, 1, -85); scroll.Position = UDim2.new(0, 5, 0, 35); scroll.BackgroundTransparency = 1; scroll.CanvasSize = UDim2.new(0, 0, 3.2, 0); scroll.ScrollBarThickness = 2
Instance.new("UIListLayout", scroll).Padding = UDim.new(0, 5); scroll.UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local function createBtn(txt, parent) 
    local b = Instance.new("TextButton", parent or scroll); b.Size = UDim2.new(0.95, 0, 0, 30); b.BackgroundColor3 = Color3.fromRGB(25, 25, 25); b.Text = txt; b.TextColor3 = Color3.new(1,1,1); b.Font = "GothamBold"; b.TextSize = 9; Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(playClick); return b 
end

local aimBtn = createBtn("AIM: OFF")
local modeBtn = createBtn("MODE: AIM FOV")
local partBtn = createBtn("GHIM: ĐẦU")
local espBtn = createBtn("ESP: OFF")
local dotBtn = createBtn("DOT: OFF")

local sliderFrame = Instance.new("Frame", scroll); sliderFrame.Size = UDim2.new(0.95, 0, 0, 45); sliderFrame.BackgroundTransparency = 1
local sliderLabel = Instance.new("TextLabel", sliderFrame); sliderLabel.Size = UDim2.new(1, 0, 0, 20); sliderLabel.Text = "FOV SIZE: 90"; sliderLabel.TextColor3 = Color3.new(1,1,1); sliderLabel.BackgroundTransparency = 1; sliderLabel.TextSize = 10
local sliderMain = Instance.new("Frame", sliderFrame); sliderMain.Size = UDim2.new(0.9, 0, 0, 6); sliderMain.Position = UDim2.new(0.05, 0, 0.6, 0); sliderMain.BackgroundColor3 = Color3.new(0.2,0.2,0.2); Instance.new("UICorner", sliderMain)
local sliderDot = Instance.new("TextButton", sliderMain); sliderDot.Size = UDim2.new(0, 14, 0, 14); sliderDot.Position = UDim2.new(0, 0, 0.5, -7); sliderDot.Text = ""; sliderDot.BackgroundColor3 = Color3.new(0,1,1); Instance.new("UICorner", sliderDot)

local removeBtn = createBtn("REMOVE SCRIPT", main); removeBtn.Position = UDim2.new(0.025, 0, 1, -40); removeBtn.BackgroundColor3 = Color3.fromRGB(50, 0, 0)

-- 3. CORE LOGIC (FIX THEO YÊU CẦU)
local function isAlive(part) return part and part.Parent and part.Parent:FindFirstChild("Humanoid") and part.Parent.Humanoid.Health > 0 end

local function getTargetByDistance()
    local t, dist = nil, math.huge
    local myP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.Position or Vector3.new(0,0,0)
    for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer and isAlive(p.Character and p.Character:FindFirstChild(aimPart)) then
        local d = (p.Character[aimPart].Position - myP).Magnitude
        if d < dist then dist = d; t = p.Character[aimPart] end
    end end return t
end

local function getTargetByFOV()
    local t, dist = nil, math.huge; local mPos = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer and isAlive(p.Character and p.Character:FindFirstChild(aimPart)) then
        local pos, vis = Camera:WorldToViewportPoint(p.Character[aimPart].Position)
        if vis then local mag = (Vector2.new(pos.X, pos.Y) - mPos).Magnitude if mag <= fovRadius and mag < dist then dist = mag; t = p.Character[aimPart] end end
    end end return t
end

local function clearESP() for _, o in pairs(workspace:GetDescendants()) do if o.Name == "ThienHigh" or o.Name == "ThienTag" then o:Destroy() end end end

RunService:BindToRenderStep("ThienV38_Fixed", 201, function()
    if not running then return end
    local col = Color3.fromHSV(tick() % 3 / 3, 1, 1); stroke.Color = col
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

    fovCircle.Visible = (isAimbotOn and aimMode == "Aim FOV"); fovCircle.Position = center; fovCircle.Radius = fovRadius; fovCircle.Color = col
    dot.Visible = (isAimbotOn and dotEnabled); dot.Position = center; dot.Color = col

    -- ESP (GIỮ NGUYÊN V38)
    if espEnabled then
        for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer and p.Character then 
            local h = p.Character:FindFirstChild("ThienHigh") or Instance.new("Highlight", p.Character); h.Name = "ThienHigh"; h.FillColor = col; h.Enabled = true 
            local head = p.Character:FindFirstChild("Head")
            if head then
                local bg = head:FindFirstChild("ThienTag") or Instance.new("BillboardGui", head); bg.Name = "ThienTag"; bg.Size = UDim2.new(0,100,0,50); bg.AlwaysOnTop = true; bg.ExtentsOffset = Vector3.new(0,3,0)
                local l = bg:FindFirstChild("L") or Instance.new("TextLabel", bg); l.Name = "L"; l.Size = UDim2.new(1,0,1,0); l.BackgroundTransparency = 1; l.TextColor3 = col; l.Text = p.Name; l.Font = "GothamBold"; l.TextSize = 10
            end
        end end
    else clearESP() end

    -- AIM LOGIC (SỬA PHẦN SILENT)
    if isAimbotOn then
        if aimMode == "Silent Aim" then
            if not isAlive(lockedTarget) then lockedTarget = getTargetByDistance() end
            if lockedTarget and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local lp = LocalPlayer.Character.HumanoidRootPart
                lp.CFrame = CFrame.new(lp.Position, Vector3.new(lockedTarget.Position.X, lp.Position.Y, lockedTarget.Position.Z))
            end
        elseif aimMode == "Aimlock" then
            if not isAlive(lockedTarget) then lockedTarget = getTargetByFOV() end
            if lockedTarget then Camera.CFrame = CFrame.new(Camera.CFrame.Position, lockedTarget.Position) end
        elseif aimMode == "Aim FOV" then
            if not isAlive(lockedTarget) then lockedTarget = getTargetByFOV() 
            else
                local pos, vis = Camera:WorldToViewportPoint(lockedTarget.Position)
                local mag = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                if not vis or mag > (fovRadius * 1.8) then lockedTarget = getTargetByFOV() end
            end
            if lockedTarget then 
                -- Khoảng trống nhìn địch: Ghim hơi lệch xuống (0.4 unit)
                local targetPos = lockedTarget.Position - Vector3.new(0, 0.4, 0)
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPos) 
            end
        end
    else lockedTarget = nil end
end)

-- 4. INTERACTIONS
minBtn.MouseButton1Click:Connect(function()
    playClick()
    scroll.Visible = not scroll.Visible; removeBtn.Visible = scroll.Visible
    main.Size = scroll.Visible and UDim2.new(0, 180, 0, 340) or UDim2.new(0, 180, 0, 35)
end)

removeBtn.MouseButton1Click:Connect(function() playLaser(); running = false; fovCircle:Remove(); dot:Remove(); clearESP(); sg:Destroy() end)

sliderDot.MouseButton1Down:Connect(function()
    local move = UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            local p = math.clamp((input.Position.X - sliderMain.AbsolutePosition.X) / sliderMain.AbsoluteSize.X, 0, 1)
            sliderDot.Position = UDim2.new(p, -7, 0.5, -7); fovRadius = math.floor(30 + (p * 270)); sliderLabel.Text = "FOV SIZE: " .. fovRadius
        end
    end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then move:Disconnect() end end)
end)

aimBtn.MouseButton1Click:Connect(function() isAimbotOn = not isAimbotOn; lockedTarget = nil; aimBtn.Text = "AIM: " .. (isAimbotOn and "ON" or "OFF") end)
modeBtn.MouseButton1Click:Connect(function() if aimMode == "Aim FOV" then aimMode = "Aimlock" elseif aimMode == "Aimlock" then aimMode = "Silent Aim" else aimMode = "Aim FOV" end lockedTarget = nil; modeBtn.Text = "MODE: " .. aimMode:upper() end)
partBtn.MouseButton1Click:Connect(function() if aimPart == "Head" then aimPart = "HumanoidRootPart"; partBtn.Text = "GHIM: THÂN" else aimPart = "Head"; partBtn.Text = "GHIM: ĐẦU" end end)
espBtn.MouseButton1Click:Connect(function() espEnabled = not espEnabled; espBtn.Text = "ESP: " .. (espEnabled and "ON" or "OFF") end)
dotBtn.MouseButton1Click:Connect(function() dotEnabled = not dotEnabled; dotBtn.Text = "DOT: " .. (dotEnabled and "ON" or "OFF") end)

local d,s,p;main.InputBegan:Connect(function(i)if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then d=true;s=i.Position;p=main.Position end end)
UserInputService.InputChanged:Connect(function(i)if d and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then local delta=i.Position-s;main.Position=UDim2.new(p.X.Scale,p.X.Offset+delta.X,p.Y.Scale,p.Y.Offset+delta.Y) end end)
UserInputService.InputEnded:Connect(function(i)if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then d=false end end)
