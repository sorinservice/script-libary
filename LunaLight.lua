-- LunaLight.lua
-- Sorin Loader • LunaLight UI Library (remastered)
-- Features:
--  - Intro screen with glass + blur + spinner (configurable duration)
--  - Glassy main window (rounded corners, subtle shadow, hover effects)
--  - Draggable header
--  - Search filter
--  - AddGame(name, placeId, callback) with confirm popup before teleport
--  - Optional footer text and easy theme overrides
--  - Safe pcall teleport; if no placeId, runs callback
--
-- Usage (loader.lua):
-- local Luna = loadstring(game:HttpGet(".../LunaLight.lua"))()
-- Luna:Intro("Loading Sorin Loader...", 2.3)
-- local ui = Luna:CreateWindow({ Title="Supported Games", Subtitle="Sorin Loader v1.0", Count=#Games })
-- for _,g in ipairs(Games) do ui:AddGame(g.Name, g.PlaceId) end
-- ui:SetFooter("v1.0  •  Updated " .. os.date("%Y-%m-%d"))

local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local TeleportService  = game:GetService("TeleportService")
local UserInputService = game:GetService("UserInputService")
local Lighting         = game:GetService("Lighting")

local player = Players.LocalPlayer

local Luna = {}
Luna.__index = Luna

-- ===== THEME (can be overridden via Luna:Setup({Accent=...})) =====
local Theme = {
    Background   = Color3.fromRGB(22, 22, 28),
    Header       = Color3.fromRGB(28, 28, 36),
    Accent       = Color3.fromRGB(145, 105, 255),
    Button       = Color3.fromRGB(44, 44, 56),
    Hover        = Color3.fromRGB(80, 80, 120),
    Text         = Color3.fromRGB(235, 235, 245),
    SubText      = Color3.fromRGB(170, 170, 200),
    Stroke       = Color3.fromRGB(255, 255, 255), -- glass outline
    Shadow       = Color3.fromRGB(0, 0, 0),
}

-- ===== UTIL =====
local function tween(inst, t, props, style, dir)
    return TweenService:Create(inst, TweenInfo.new(t or 0.25, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props)
end

local function makeShadow(parent, radius, opacity)
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://5028857084" -- soft drop shadow (9-slice)
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(24,24,276,276)
    shadow.ImageColor3 = Theme.Shadow
    shadow.ImageTransparency = 1 - (opacity or 0.25)
    shadow.Size = UDim2.new(1, radius or 24, 1, radius or 24)
    shadow.Position = UDim2.new(0, -((radius or 24)/2), 0, -((radius or 24)/2))
    shadow.ZIndex = 0
    shadow.Parent = parent
    return shadow
end

local function glassify(frame, corner)
    local stroke = Instance.new("UIStroke")
    stroke.Color = Theme.Stroke
    stroke.Thickness = 1
    stroke.Transparency = 0.75
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = frame

    local uiCorner = corner or Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, 10)
    uiCorner.Parent = frame

    frame.BackgroundTransparency = 0.2
end

-- ===== PUBLIC: Setup theme overrides =====
function Luna:Setup(overrides)
    if typeof(overrides) ~= "table" then return end
    for k,v in pairs(overrides) do
        if Theme[k] ~= nil then Theme[k] = v end
    end
end

-- ===== INTRO (glass + blur + spinner) =====
function Luna:Intro(text, duration)
    duration = duration or 2.0
    text = text or "Loading..."

    local gui = Instance.new("ScreenGui")
    gui.Name = "LunaIntro"
    gui.IgnoreGuiInset = true
    gui.ResetOnSpawn = false
    gui.Parent = player:WaitForChild("PlayerGui")

    local overlay = Instance.new("Frame")
    overlay.Size = UDim2.new(1,0,1,0)
    overlay.BackgroundColor3 = Theme.Background
    overlay.BackgroundTransparency = 0.3
    overlay.BorderSizePixel = 0
    overlay.Parent = gui

    makeShadow(overlay, 80, 0.18)

    -- Gentle lighting blur (namespaced so we can remove our own)
    local blur = Instance.new("BlurEffect")
    blur.Name = "LunaIntroBlur"
    blur.Size = 0
    blur.Parent = Lighting
    tween(blur, 0.35, {Size = 15}):Play()

    -- Container for text + spinner
    local container = Instance.new("Frame")
    container.AnchorPoint = Vector2.new(0.5,0.5)
    container.Position = UDim2.new(0.5,0,0.5,0)
    container.Size = UDim2.new(0, 560, 0, 110)
    container.BackgroundColor3 = Theme.Header
    container.BorderSizePixel = 0
    container.BackgroundTransparency = 0.1
    container.Parent = overlay
    glassify(container)
    makeShadow(container, 36, 0.23)

    local spinner = Instance.new("ImageLabel")
    spinner.AnchorPoint = Vector2.new(0,0.5)
    spinner.Position = UDim2.new(0, 20, 0.5, 0)
    spinner.Size = UDim2.new(0, 56, 0, 56)
    spinner.BackgroundTransparency = 1
    spinner.Image = "rbxassetid://3926307971" -- UI icons sheet
    spinner.ImageRectOffset = Vector2.new(628, 420) -- spinner glyph
    spinner.ImageRectSize = Vector2.new(36, 36)
    spinner.ImageColor3 = Theme.Accent
    spinner.Parent = container

    local label = Instance.new("TextLabel")
    label.AnchorPoint = Vector2.new(0,0.5)
    label.Position = UDim2.new(0, 96, 0.5, -12)
    label.Size = UDim2.new(1, -116, 0, 42)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Theme.Text
    label.Font = Enum.Font.GothamBold
    label.TextScaled = true
    label.Parent = container

    local sub = Instance.new("TextLabel")
    sub.AnchorPoint = Vector2.new(0,0.5)
    sub.Position = UDim2.new(0, 96, 0.5, 24)
    sub.Size = UDim2.new(1, -116, 0, 22)
    sub.BackgroundTransparency = 1
    sub.Text = "Please wait…"
    sub.TextColor3 = Theme.SubText
    sub.Font = Enum.Font.Gotham
    sub.TextScaled = true
    sub.Parent = container

    -- fade in
    container.BackgroundTransparency = 0.4
    label.TextTransparency, sub.TextTransparency, overlay.BackgroundTransparency = 1, 1, 1
    tween(container, 0.3, {BackgroundTransparency = 0.1}):Play()
    tween(label, 0.35, {TextTransparency = 0}):Play()
    tween(sub, 0.35, {TextTransparency = 0}):Play()
    tween(overlay, 0.35, {BackgroundTransparency = 0.3}):Play()

    -- spinner rotation
    task.spawn(function()
        while spinner.Parent do
            spinner.Rotation += 10
            task.wait(0.03)
        end
    end)

    task.wait(duration)

    -- fade out & cleanup
    local t1 = tween(container, 0.25, {BackgroundTransparency = 1})
    local t2 = tween(label, 0.25, {TextTransparency = 1})
    local t3 = tween(sub, 0.25, {TextTransparency = 1})
    local t4 = tween(overlay, 0.25, {BackgroundTransparency = 1})
    t1:Play(); t2:Play(); t3:Play(); t4:Play()
    task.wait(0.26)
    pcall(function()
    if blur.Parent == Lighting then
        blur:Destroy()
    end
end)


-- ===== MAIN WINDOW =====
function Luna:CreateWindow(cfg)
    cfg = cfg or {}
    local Title    = cfg.Title or "Loader"
    local Subtitle = cfg.Subtitle or ""
    local Count    = cfg.Count

    local gui = Instance.new("ScreenGui")
    gui.Name = "LunaLightUI"
    gui.IgnoreGuiInset = true
    gui.ResetOnSpawn = false
    gui.Parent = player:WaitForChild("PlayerGui")

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 520, 0, 380)
    frame.Position = UDim2.new(0.5, -260, 0.5, -190)
    frame.BackgroundColor3 = Theme.Background
    frame.BorderSizePixel = 0
    frame.BackgroundTransparency = 0.15
    frame.Parent = gui
    glassify(frame)
    makeShadow(frame, 30, 0.22)

    -- Header (draggable)
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 64)
    header.BackgroundColor3 = Theme.Header
    header.BorderSizePixel = 0
    header.Parent = frame
    glassify(header)

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -60, 0, 30)
    titleLabel.Position = UDim2.new(0, 16, 0, 8)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = Title .. (Count and ("  —  " .. tostring(Count)) or "")
    titleLabel.TextColor3 = Theme.Text
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 20
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = header

    local subLabel = Instance.new("TextLabel")
    subLabel.Size = UDim2.new(1, -60, 0, 22)
    subLabel.Position = UDim2.new(0, 16, 0, 36)
    subLabel.BackgroundTransparency = 1
    subLabel.Text = Subtitle
    subLabel.TextColor3 = Theme.Accent
    subLabel.Font = Enum.Font.Gotham
    subLabel.TextSize = 16
    subLabel.TextXAlignment = Enum.TextXAlignment.Left
    subLabel.Parent = header

    -- Close button (icon)
    local closeBtn = Instance.new("ImageButton")
    closeBtn.Size = UDim2.new(0, 28, 0, 28)
    closeBtn.Position = UDim2.new(1, -36, 0, 18)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Image = "rbxassetid://3926305904"
    closeBtn.ImageRectOffset = Vector2.new(924, 724) -- X icon
    closeBtn.ImageRectSize = Vector2.new(36, 36)
    closeBtn.ImageColor3 = Theme.Text
    closeBtn.Parent = header

    closeBtn.MouseEnter:Connect(function()
        tween(closeBtn, 0.1, {ImageColor3 = Theme.Accent}):Play()
    end)
    closeBtn.MouseLeave:Connect(function()
        tween(closeBtn, 0.1, {ImageColor3 = Theme.Text}):Play()
    end)
    closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)

    -- Search
    local searchBox = Instance.new("TextBox")
    searchBox.Size = UDim2.new(1, -24, 0, 34)
    searchBox.Position = UDim2.new(0, 12, 0, 76)
    searchBox.PlaceholderText = "Search…"
    searchBox.Text = ""
    searchBox.ClearTextOnFocus = false
    searchBox.TextColor3 = Theme.Text
    searchBox.PlaceholderColor3 = Theme.SubText
    searchBox.Font = Enum.Font.Gotham
    searchBox.TextSize = 16
    searchBox.BackgroundColor3 = Theme.Button
    searchBox.BorderSizePixel = 0
    searchBox.Parent = frame
    glassify(searchBox)
    makeShadow(searchBox, 8, 0.12)

    -- List
    local list = Instance.new("ScrollingFrame")
    list.Size = UDim2.new(1, -24, 1, -136)
    list.Position = UDim2.new(0, 12, 0, 120)
    list.CanvasSize = UDim2.new(0,0,0,0)
    list.BackgroundTransparency = 1
    list.ScrollBarThickness = 6
    list.Parent = frame

    -- Footer (optional)
    local footer = Instance.new("TextLabel")
    footer.Size = UDim2.new(1, -24, 0, 18)
    footer.Position = UDim2.new(0, 12, 1, -22)
    footer.BackgroundTransparency = 1
    footer.Text = ""
    footer.TextColor3 = Theme.SubText
    footer.Font = Enum.Font.Gotham
    footer.TextSize = 13
    footer.TextXAlignment = Enum.TextXAlignment.Right
    footer.Parent = frame

    -- Animate window in
    frame.Position = UDim2.new(0.5, -260, 0.5, -180)
    frame.BackgroundTransparency = 0.4
    tween(frame, 0.35, {Position = UDim2.new(0.5, -260, 0.5, -190), BackgroundTransparency = 0.15}):Play()

    -- Make draggable via header
    do
        local dragging, dragStart, startPos
        header.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = frame.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then dragging = false end
                end)
            end
        end)
        header.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                if dragging then
                    local delta = input.Position - dragStart
                    frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
                end
            end
        end)
    end

    local self = setmetatable({
        _gui = gui,
        _frame = frame,
        _header = header,
        _list = list,
        _searchBox = searchBox,
        _footer = footer,
        _games = {},
    }, Luna)

    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        self:Filter(searchBox.Text)
    end)

    return self
end

-- ===== FOOTER TEXT =====
function Luna:SetFooter(text)
    if self._footer then self._footer.Text = text or "" end
end

-- ===== INTERNAL: confirm popup =====
function Luna:_confirm(gameName, onYes)
    local modal = Instance.new("Frame")
    modal.Size = UDim2.new(1,0,1,0)
    modal.BackgroundTransparency = 1
    modal.Parent = self._frame
    modal.ZIndex = 50

    local overlay = Instance.new("TextButton") -- catch clicks
    overlay.Size = UDim2.new(1,0,1,0)
    overlay.BackgroundColor3 = Theme.Background
    overlay.BackgroundTransparency = 0.35
    overlay.Text = ""
    overlay.BorderSizePixel = 0
    overlay.AutoButtonColor = false
    overlay.ZIndex = 50
    overlay.Parent = modal

    local box = Instance.new("Frame")
    box.AnchorPoint = Vector2.new(0.5,0.5)
    box.Position = UDim2.new(0.5,0,0.5,0)
    box.Size = UDim2.new(0, 300, 0, 150)
    box.BackgroundColor3 = Theme.Header
    box.BorderSizePixel = 0
    box.ZIndex = 51
    box.Parent = modal
    glassify(box)
    makeShadow(box, 18, 0.22)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -20, 0, 70)
    lbl.Position = UDim2.new(0, 10, 0, 12)
    lbl.BackgroundTransparency = 1
    lbl.Text = "Do you want to join\n“".. tostring(gameName) .. "”?"
    lbl.TextWrapped = true
    lbl.TextColor3 = Theme.Text
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 16
    lbl.ZIndex = 51
    lbl.Parent = box

    local yes = Instance.new("TextButton")
    yes.Size = UDim2.new(0.5, -15, 0, 34)
    yes.Position = UDim2.new(0, 10, 1, -44)
    yes.Text = "Join"
    yes.BackgroundColor3 = Theme.Accent
    yes.TextColor3 = Color3.new(1,1,1)
    yes.Font = Enum.Font.GothamBold
    yes.TextSize = 16
    yes.BorderSizePixel = 0
    yes.ZIndex = 51
    yes.Parent = box
    glassify(yes)

    local no = Instance.new("TextButton")
    no.Size = UDim2.new(0.5, -15, 0, 34)
    no.Position = UDim2.new(0.5, 5, 1, -44)
    no.Text = "Cancel"
    no.BackgroundColor3 = Theme.Button
    no.TextColor3 = Theme.Text
    no.Font = Enum.Font.Gotham
    no.TextSize = 16
    no.BorderSizePixel = 0
    no.ZIndex = 51
    no.Parent = box
    glassify(no)

    overlay.MouseButton1Click:Connect(function() modal:Destroy() end)
    no.MouseButton1Click:Connect(function() modal:Destroy() end)
    yes.MouseButton1Click:Connect(function()
        modal:Destroy()
        if onYes then onYes() end
    end)

    -- subtle appear animation
    box.Size = UDim2.new(0, 300, 0, 120)
    tween(box, 0.18, {Size = UDim2.new(0, 300, 0, 150)}):Play()
end

-- ===== ADD GAME =====
function Luna:AddGame(name, placeId, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -12, 0, 36)
    btn.Position = UDim2.new(0, 6, 0, 0) -- y is set in UpdateLayout
    btn.Text = name
    btn.BackgroundColor3 = Theme.Button
    btn.TextColor3 = Theme.Text
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 15
    btn.BorderSizePixel = 0
    btn.Parent = self._list
    glassify(btn)

    btn.MouseEnter:Connect(function()
        tween(btn, 0.12, {BackgroundColor3 = Theme.Hover}):Play()
    end)
    btn.MouseLeave:Connect(function()
        tween(btn, 0.12, {BackgroundColor3 = Theme.Button}):Play()
    end)

    btn.MouseButton1Click:Connect(function()
        self:_confirm(name, function()
            if placeId then
                pcall(function() TeleportService:Teleport(placeId, player) end)
            elseif callback then
                callback()
            end
        end)
    end)

    table.insert(self._games, {Name = name, Button = btn})
    self:UpdateLayout()
end

-- ===== UPDATE LAYOUT =====
function Luna:UpdateLayout()
    local y = 0
    for _, g in ipairs(self._games) do
        g.Button.Position = UDim2.new(0, 6, 0, y)
        y += 40
    end
    self._list.CanvasSize = UDim2.new(0,0,0,y)
end

-- ===== FILTER =====
function Luna:Filter(query)
    query = string.lower(query or "")
    local y = 0
    for _, g in ipairs(self._games) do
        local match = (query == "") or string.find(string.lower(g.Name), query, 1, true)
        g.Button.Visible = match
        if match then
            g.Button.Position = UDim2.new(0, 6, 0, y)
            y += 40
        end
    end
    self._list.CanvasSize = UDim2.new(0,0,0,y)
end

return setmetatable({}, Luna)
