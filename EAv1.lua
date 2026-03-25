--[[ 
    SUPREME V27 - INTRO EDITION - BY THIEN
    - Intro: Khổng lồ "by thien", lắc lư, màu vàng, màn hình mờ.
    - Gui: Chữ "by thien" nhỏ bth, Hard Lock, Rainbow Dot.
    - Credits: BY THIEN
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- States
local isAimbotOn = false
local currentMode = "AIMLOCK"
local aimPart = "Head"
local espEnabled = false
local dotEnabled = false 
local lockedTarget = nil 
local hue = 0 

---------------------------------------------------
-- 0. INTRO SETUP (HIỆN TRƯỚC GUI)
---------------------------------------------------
local introSg = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
introSg.Name = "Thien_Intro"; introSg.ResetOnSpawn = false

-- Làm mờ màn hình
local blur = Instance.new("BlurEffect", Lighting)
blur.Size = 0; blur.Enabled = true

-- Chữ "by thien" khổng lồ
local introText = Instance.new("TextLabel", introSg)
introText.Size = UDim2.new(0, 500, 0, 200) -- To đùng
introText.Position = UDim2.new(0.5, -250, 0.5, -100) -- Giữa màn hình
introText.Text = "by thien"
introText.TextColor3 = Color3.fromRGB(255, 255, 0) -- Màu vàng rực
introText.BackgroundTransparency = 1
introText.Font = Enum.Font.LuckiestGuy -- Phông chữ nhìn ngầu hơn
introText.TextSize = 100 -- Cực to
introText.TextStrokeTransparency = 0 -- Viền đen rõ
introText.TextStrokeColor3 = Color3.new(0,0,0)
introText.Visible = true

-- Hiệu ứng Intro: Mờ dần màn hình, Chữ to đùng, Lắc lư, Phóng to thu nhỏ
local introConn
introConn = RunService.RenderStepped:Connect(function()
    -- Tăng độ mờ
    blur.Size = math.min(blur.Size + 0.5, 25)
    
    -- Lắc lư chữ dữ dội
    local shakeX = math.random(-10, 10)
    local shakeY = math.random(-10, 10)
    introText.Position = UDim2.new(0.5, -250 + shakeX, 0.5, -100 + shakeY)
    
    -- Phóng to thu nhỏ chữ liên tục (Pulsing)
    local pulse = 100 + math.sin(tick() * 10) * 15 -- Phóng từ 85 - 115
    introText.TextSize = pulse
end)

---------------------------------------------------
-- 1. DOT CROSSHAIR (DÙNG CHO GUI CHÍNH)
---------------------------------------------------
local dot = Drawing.new("Circle")
dot.Thickness = 1; dot.Radius = 3; dot.Filled = true; dot.Visible = false

---------------------------------------------------
-- 2. GUI CHÍNH SETUP (HIỆN SAU INTRO)
---------------------------------------------------
local function makeDraggable(frame)
    local dragging, dragInput, dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true; dragStart = input.Position; startPos = frame.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end) end end)
    frame.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end end)
    UserInputService.InputChanged:Connect(function(input) if dragging and input == dragInput then local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) end end)
end

local sg = Instance.new("ScreenGui", LocalPlayer.PlayerGui); sg.Name = "Thien_V27_Core"; sg.ResetOnSpawn = false
local main = Instance.new("Frame", sg); main.Size = UDim2.new(0, 180, 0, 150); main.Position = UDim2.new(0.8, 0, 0.4, 0); main.BackgroundColor3 = Color3.fromRGB(10, 10, 10); main.BorderSizePixel = 0; makeDraggable(main)
local stroke = Instance.new("UIStroke", main); stroke.Thickness = 2; stroke.Color = Color3.fromHSV(0, 1, 1); Instance.new("UICorner", main)
main.Visible = false -- Ẩn đi để chờ intro

local topBar = Instance.new("Frame", main); topBar.Size = UDim2.new(1, 0, 0, 25); topBar.BackgroundTransparency = 1
local closeBtn = Instance.new("TextButton", topBar); closeBtn.Size = UDim2.new(0, 25, 1, 0); closeBtn.Position = UDim2.new(1, -30, 0, 0); closeBtn.Text = "-"; closeBtn.TextColor3 = Color3.new(1,1,1); closeBtn.BackgroundTransparency = 1; closeBtn.TextSize = 20

-- Chữ "by thien" nhỏ bth trong GUI
local credit = Instance.new("TextLabel", topBar); credit.Size = UDim2.new(0, 60, 1, 0); credit.Position = UDim2.new(1, -95, 0, 0); credit.Text = "by thien"; credit.TextColor3 = Color3.fromRGB(200, 200, 200); credit.BackgroundTransparency = 1; credit.Font = Enum.Font.Code; credit.TextSize = 10; credit.TextStrokeTransparency = 1

local scroll = Instance.new("ScrollingFrame", main); scroll.Size = UDim2.new(1, -10, 1, -35); scroll.Position = UDim2.new(0, 5, 0, 30); scroll.BackgroundTransparency = 1; scroll.BorderSizePixel = 0; scroll.CanvasSize = UDim2.new(0, 0, 1.6, 0); scroll.ScrollBarThickness = 2
Instance.new("UIListLayout", scroll).Padding = UDim.new(0, 5); scroll.UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local function createBtn(txt, color) local b = Instance.new("TextButton", scroll); b.Size = UDim2.new(0.95, 0, 0, 30); b.BackgroundColor3 = color or Color3.fromRGB(25, 25, 25); b.Text = txt; b.TextColor3 = Color3.new(1,1,1); b.Font = Enum.Font.GothamBold; b.TextSize = 10; Instance.new("UICorner", b); return b end
local aimBtn = createBtn("AIM: OFF"); aimBtn.TextColor3 = Color3.new(0.6,0.6,0.6)
local dotBtn = createBtn("DOT CROSSHAIR: OFF"); dotBtn.TextColor3 = Color3.new(0.6,0.6,0.6)
local modeBtn = createBtn("MODE: AIMLOCK")
local targetBtn = createBtn("TARGET: HEAD"); targetBtn.TextColor3 = Color3.new(0,1,1)
local espBtn = createBtn("ESP: OFF"); espBtn.TextColor3 = Color3.new(0.6,0.6,0.6)
local removeBtn = createBtn("REMOVE SCRIPT", Color3.fromRGB(60, 0, 0)); removeBtn.TextColor3 = Color3.fromRGB(255, 50, 50)

---------------------------------------------------
-- 3. CORE LOGIC (VẪN GIỮ NGUYÊN)
---------------------------------------------------
local function clearESP() for _, v in pairs(workspace:GetDescendants()) do if v.Name == "ThienESP" or v.Name == "ThienTag" then v:Destroy() end end end
local function getClosest() local target = nil; local dist = math.huge; for _, obj in pairs(workspace:GetDescendants()) do if obj:IsA("Humanoid") and obj.Parent ~= LocalPlayer.Character and obj.Health > 0 then local part = obj.Parent:FindFirstChild(aimPart == "Head" and "Head" or "HumanoidRootPart"); if part then local pos, onScreen = Camera:WorldToViewportPoint(part.Position); if onScreen then local d = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude; if d < dist then dist = d; target = part end end end end end return target end

RunService.RenderStepped:Connect(function() hue = tick() % 3 / 3; local rainbowColor = Color3.fromHSV(hue, 1, 1); stroke.Color = rainbowColor
    if dotEnabled then dot.Visible = true; dot.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2); dot.Color = rainbowColor else dot.Visible = false end
    if isAimbotOn then if not lockedTarget or not lockedTarget.Parent or not lockedTarget.Parent:FindFirstChild("Humanoid") or lockedTarget.Parent.Humanoid.Health <= 0 then lockedTarget = getClosest() end
        if lockedTarget then if currentMode == "AIMLOCK" then Camera.CFrame = CFrame.new(Camera.CFrame.Position, lockedTarget.Position) elseif currentMode == "SILENT AIM" then local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart"); if hrp then hrp.CFrame = CFrame.new(hrp.Position, Vector3.new(lockedTarget.Position.X, hrp.Position.Y, lockedTarget.Position.Z)) end end end end
    if espEnabled then for _, obj in pairs(workspace:GetDescendants()) do if obj:IsA("Humanoid") and obj.Parent ~= LocalPlayer.Character then local char = obj.Parent; local hrp = char:FindFirstChild("HumanoidRootPart"); if hrp then local isPlr = Players:GetPlayerFromCharacter(char); local h = char:FindFirstChild("ThienESP") or Instance.new("Highlight", char); h.Name = "ThienESP"; h.FillTransparency = 0.5; h.OutlineTransparency = 0; h.FillColor = isPlr and rainbowColor or Color3.new(0,0,0) end end end end
end)

-- BUTTON ACTIONS (VẪN GIỮ NGUYÊN)
aimBtn.MouseButton1Click:Connect(function() isAimbotOn = not isAimbotOn; aimBtn.Text = isAimbotOn and "AIM: ON" or "AIM: OFF"; aimBtn.TextColor3 = isAimbotOn and Color3.new(1,0,0) or Color3.new(0.6,0.6,0.6); if not isAimbotOn then lockedTarget = nil end end)
dotBtn.MouseButton1Click:Connect(function() dotEnabled = not dotEnabled; dotBtn.Text = dotEnabled and "DOT CROSSHAIR: ON" or "DOT CROSSHAIR: OFF"; dotBtn.TextColor3 = dotEnabled and Color3.new(0,1,1) or Color3.new(0.6,0.6,0.6) end)
modeBtn.MouseButton1Click:Connect(function() currentMode = (currentMode == "AIMLOCK") and "SILENT AIM" or "AIMLOCK"; modeBtn.Text = "MODE: " .. currentMode end)
targetBtn.MouseButton1Click:Connect(function() aimPart = (aimPart == "Head") and "Body" or "Head"; targetBtn.Text = "TARGET: " .. aimPart:upper(); lockedTarget = nil end)
espBtn.MouseButton1Click:Connect(function() espEnabled = not espEnabled; espBtn.Text = espEnabled and "ESP: ON" or "ESP: OFF"; espBtn.TextColor3 = espEnabled and Color3.new(0,1,0) or Color3.new(0.6,0.6,0.6); if not espEnabled then clearESP() end end)
removeBtn.MouseButton1Click:Connect(function() clearESP(); dot:Remove(); sg:Destroy() end)
closeBtn.MouseButton1Click:Connect(function() main.Visible = false; local open = Instance.new("TextButton", sg); open.Size = UDim2.new(0,35,0,35); open.Position = UDim2.new(0,10,0.5,0); open.Text = "+"; open.BackgroundColor3 = Color3.new(0,0,0); Instance.new("UICorner", open); local s = Instance.new("UIStroke", open); s.Color = Color3.new(0,1,1)
    open.MouseButton1Click:Connect(function() main.Visible = true; open:Destroy() end) end)

---------------------------------------------------
-- 4. KẾT THÚC INTRO VÀ HIỆN GUI
---------------------------------------------------
task.delay(3, function() -- Intro chạy trong 3 giây
    -- Ngắt kết nối intro loop
    if introConn then introConn:Disconnect() end
    
    -- Xóa các hiệu ứng intro
    if blur then blur:Destroy() end
    if introSg then introSg:Destroy() end
    
    -- Hiện menu chính
    main.Visible = true
end)
