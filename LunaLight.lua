-- LunaLite.lua
-- Stylish Loader + Game Library UI (inspired by Luna/NebulaSoftworks)

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local player = Players.LocalPlayer

local Luna = {}
Luna.__index = Luna

local Theme = {
    Background = Color3.fromRGB(20, 20, 25),
    Accent = Color3.fromRGB(140, 100, 255),
    Button = Color3.fromRGB(40, 40, 50),
    Hover = Color3.fromRGB(80, 80, 120),
    Text = Color3.fromRGB(235, 235, 245),
    Header = Color3.fromRGB(30, 30, 40),
}

-- Create intro loading text
function Luna:Intro(text)
    local screen = Instance.new("ScreenGui")
    screen.Name = "LunaIntro"
    screen.ResetOnSpawn = false
    screen.Parent = player:WaitForChild("PlayerGui")

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text or "Loading..."
    label.TextColor3 = Theme.Accent
    label.Font = Enum.Font.GothamBold
    label.TextScaled = true
    label.Parent = screen

    -- fade in/out
    label.TextTransparency = 1
    TweenService:Create(label, TweenInfo.new(0.5), {TextTransparency = 0}):Play()
    wait(1.5)
    TweenService:Create(label, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
    wait(0.6)
    screen:Destroy()
end

-- Main window
function Luna:CreateWindow(config)
    -- config = {Title = "Supported Games", Subtitle = "Sorin Loader", Count = 0}
    local screen = Instance.new("ScreenGui")
    screen.Name = "LunaLiteUI"
    screen.ResetOnSpawn = false
    screen.Parent = player:WaitForChild("PlayerGui")

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 460, 0, 340)
    frame.Position = UDim2.new(0.5, -230, 0.5, -170)
    frame.BackgroundColor3 = Theme.Background
    frame.BorderSizePixel = 0
    frame.BackgroundTransparency = 1
    frame.Parent = screen

    -- Header
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 60)
    header.BackgroundColor3 = Theme.Header
    header.BorderSizePixel = 0
    header.Parent = frame

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -20, 0, 30)
    titleLabel.Position = UDim2.new(0, 10, 0, 5)
    titleLabel.Text = config.Title or "Loader"
    titleLabel.TextColor3 = Theme.Text
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 20
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.BackgroundTransparency = 1
    titleLabel.Parent = header

    local subLabel = Instance.new("TextLabel")
    subLabel.Size = UDim2.new(1, -20, 0, 20)
    subLabel.Position = UDim2.new(0, 10, 0, 30)
    subLabel.Text = config.Subtitle or ""
    subLabel.TextColor3 = Theme.Accent
    subLabel.Font = Enum.Font.Gotham
    subLabel.TextSize = 16
    subLabel.TextXAlignment = Enum.TextXAlignment.Left
    subLabel.BackgroundTransparency = 1
    subLabel.Parent = header

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0, 15)
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
    searchBox.Position = UDim2.new(0, 10, 0, 70)
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
    list.Size = UDim2.new(1, -20, 1, -110)
    list.Position = UDim2.new(0, 10, 0, 110)
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

    -- animate window fade in
    TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0
    }):Play()

    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        self:Filter(searchBox.Text)
    end)

    return self
end

-- Add game entry
function Luna:AddGame(name, placeId, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 34)
    btn.BackgroundColor3 = Theme.Button
    btn.TextColor3 = Theme.Text
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 15
    btn.Text = name
    btn.BorderSizePixel = 0
    btn.Parent = self._list

    -- hover animation
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

function Luna:UpdateLayout()
    local y = 0
    for _, g in ipairs(self._games) do
        g.Button.Position = UDim2.new(0, 5, 0, y)
        y = y + 38
    end
    self._list.CanvasSize = UDim2.new(0, 0, 0, y)
end

function Luna:Filter(query)
    query = string.lower(query)
    local y = 0
    for _, g in ipairs(self._games) do
        if query == "" or string.find(string.lower(g.Name), query) then
            g.Button.Visible = true
            g.Button.Position = UDim2.new(0, 5, 0, y)
            y = y + 38
        else
            g.Button.Visible = false
        end
    end
    self._list.CanvasSize = UDim2.new(0, 0, 0, y)
end

return setmetatable({}, Luna)
