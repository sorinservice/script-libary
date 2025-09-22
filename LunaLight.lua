-- LunaLight.lua
-- A lightweight stylish game list UI library (inspired by Luna UI)

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local player = Players.LocalPlayer

local Luna = {}
Luna.__index = Luna

-- Color scheme
local Theme = {
    Background = Color3.fromRGB(25, 25, 30),
    Accent = Color3.fromRGB(120, 80, 255),
    Button = Color3.fromRGB(40, 40, 50),
    Hover = Color3.fromRGB(80, 80, 120),
    Text = Color3.fromRGB(230, 230, 240),
    Header = Color3.fromRGB(35, 35, 45),
}

-- Create main window
function Luna:CreateWindow(title, total)
    local screen = Instance.new("ScreenGui")
    screen.Name = "LunaLightUI"
    screen.ResetOnSpawn = false
    screen.Parent = player:WaitForChild("PlayerGui")

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 420, 0, 320)
    frame.Position = UDim2.new(0.5, -210, 0.5, -160)
    frame.BackgroundColor3 = Theme.Background
    frame.BorderSizePixel = 0
    frame.BackgroundTransparency = 1 -- start invisible
    frame.Parent = screen

    -- Header
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 40)
    header.BackgroundColor3 = Theme.Header
    header.BorderSizePixel = 0
    header.Parent = frame

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -50, 1, 0)
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.Text = title .. " - " .. tostring(total)
    titleLabel.TextColor3 = Theme.Text
    titleLabel.BackgroundTransparency = 1
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 18
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = header

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0.5, -15)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Theme.Text
    closeBtn.BackgroundTransparency = 1
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 18
    closeBtn.Parent = header

    closeBtn.MouseButton1Click:Connect(function()
        screen:Destroy()
    end)

    -- Search box
    local searchBox = Instance.new("TextBox")
    searchBox.Size = UDim2.new(1, -20, 0, 30)
    searchBox.Position = UDim2.new(0, 10, 0, 50)
    searchBox.PlaceholderText = "Search..."
    searchBox.Text = ""
    searchBox.ClearTextOnFocus = false
    searchBox.TextColor3 = Theme.Text
    searchBox.BackgroundColor3 = Theme.Button
    searchBox.BorderSizePixel = 0
    searchBox.Font = Enum.Font.Gotham
    searchBox.TextSize = 16
    searchBox.Parent = frame

    -- List container
    local list = Instance.new("ScrollingFrame")
    list.Size = UDim2.new(1, -20, 1, -100)
    list.Position = UDim2.new(0, 10, 0, 90)
    list.CanvasSize = UDim2.new(0, 0, 0, 0)
    list.ScrollBarThickness = 6
    list.BackgroundTransparency = 1
    list.BorderSizePixel = 0
    list.Parent = frame

    local games = {}

    self._frame = frame
    self._list = list
    self._searchBox = searchBox
    self._games = games

    -- Animate window in
    TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0,
        Position = UDim2.new(0.5, -210, 0.5, -160)
    }):Play()

    -- Search filter
    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        self:Filter(searchBox.Text)
    end)

    return self
end

-- Add a game entry
function Luna:AddGame(name, placeId, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 32)
    btn.BackgroundColor3 = Theme.Button
    btn.TextColor3 = Theme.Text
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 15
    btn.Text = name
    btn.BorderSizePixel = 0
    btn.Parent = self._list

    -- Hover effect
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Theme.Hover}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Theme.Button}):Play()
    end)

    btn.MouseButton1Click:Connect(function()
        if placeId then
            pcall(function()
                TeleportService:Teleport(placeId, player)
            end)
        elseif callback then
            callback()
        end
    end)

    table.insert(self._games, {Name = name, Button = btn})
    self:UpdateLayout()
end

-- Layout updater
function Luna:UpdateLayout()
    local y = 0
    for _, g in ipairs(self._games) do
        g.Button.Position = UDim2.new(0, 5, 0, y)
        y = y + 36
    end
    self._list.CanvasSize = UDim2.new(0, 0, 0, y)
end

-- Search filter
function Luna:Filter(query)
    query = string.lower(query)
    local y = 0
    for _, g in ipairs(self._games) do
        if query == "" or string.find(string.lower(g.Name), query) then
            g.Button.Visible = true
            g.Button.Position = UDim2.new(0, 5, 0, y)
            y = y + 36
        else
            g.Button.Visible = false
        end
    end
    self._list.CanvasSize = UDim2.new(0, 0, 0, y)
end

return setmetatable({}, Luna)
