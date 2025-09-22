-- GameLibrary.lua
-- Simple game list UI library for loaders

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local TeleportService = game:GetService("TeleportService")

local Library = {}
Library.__index = Library

function Library:CreateWindow(title, total)
    local screen = Instance.new("ScreenGui")
    screen.Name = "GameLibraryUI"
    screen.ResetOnSpawn = false
    screen.Parent = player:WaitForChild("PlayerGui")

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 400, 0, 300)
    frame.Position = UDim2.new(0.5, -200, 0.5, -150)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.BorderSizePixel = 0
    frame.Parent = screen

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -10, 0, 30)
    titleLabel.Position = UDim2.new(0, 5, 0, 5)
    titleLabel.Text = title .. " - " .. tostring(total)
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.TextSize = 18
    titleLabel.Parent = frame

    local searchBox = Instance.new("TextBox")
    searchBox.Size = UDim2.new(1, -10, 0, 25)
    searchBox.Position = UDim2.new(0, 5, 0, 40)
    searchBox.PlaceholderText = "Search..."
    searchBox.Text = ""
    searchBox.ClearTextOnFocus = false
    searchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    searchBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    searchBox.BorderSizePixel = 0
    searchBox.Parent = frame

    local scrollingFrame = Instance.new("ScrollingFrame")
    scrollingFrame.Size = UDim2.new(1, -10, 1, -100)
    scrollingFrame.Position = UDim2.new(0, 5, 0, 70)
    scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollingFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    scrollingFrame.BorderSizePixel = 0
    scrollingFrame.ScrollBarThickness = 6
    scrollingFrame.Parent = frame

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 80, 0, 30)
    closeBtn.Position = UDim2.new(1, -90, 1, -40)
    closeBtn.Text = "Close"
    closeBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.Parent = frame
    closeBtn.MouseButton1Click:Connect(function()
        screen:Destroy()
    end)

    self._scrollingFrame = scrollingFrame
    self._searchBox = searchBox
    self._games = {}

    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        self:Filter(searchBox.Text)
    end)

    return self
end

function Library:AddGame(name, placeId, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -10, 0, 30)
    button.Text = name
    button.TextColor3 = Color3.new(1, 1, 1)
    button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    button.BorderSizePixel = 0
    button.Parent = self._scrollingFrame

    button.MouseButton1Click:Connect(function()
        if placeId then
            -- teleport if executor supports it
            pcall(function()
                TeleportService:Teleport(placeId, player)
            end)
        elseif callback then
            callback()
        end
    end)

    table.insert(self._games, {Name = name, Button = button})
    self:UpdateLayout()
end

function Library:UpdateLayout()
    local y = 0
    for _, g in ipairs(self._games) do
        g.Button.Position = UDim2.new(0, 5, 0, y)
        y = y + 35
    end
    self._scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, y)
end

function Library:Filter(query)
    query = string.lower(query)
    local y = 0
    for _, g in ipairs(self._games) do
        if query == "" or string.find(string.lower(g.Name), query) then
            g.Button.Visible = true
            g.Button.Position = UDim2.new(0, 5, 0, y)
            y = y + 35
        else
            g.Button.Visible = false
        end
    end
    self._scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, y)
end

return setmetatable({}, Library)
