-- SorinUI.lua
-- Lightweight UI helper for SorinSoftware scripts

local SorinUI = {}
SorinUI.__index = SorinUI

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local THEME = {
    Background = Color3.fromRGB(25, 24, 36),
    Accent = Color3.fromRGB(140, 120, 255),
    AccentDark = Color3.fromRGB(95, 82, 170),
    AccentLight = Color3.fromRGB(180, 170, 255),
    Text = Color3.fromRGB(235, 235, 245),
    SubText = Color3.fromRGB(170, 170, 190),
    Stroke = Color3.fromRGB(45, 45, 65)
}

local function getGuiParent()
    if gethui then
        local ui = gethui()
        if typeof(ui) == "Instance" then
            return ui
        end
    end

    local coreGuiSuccess, coreGui = pcall(function()
        return game:GetService("CoreGui")
    end)

    if coreGuiSuccess and coreGui then
        return coreGui
    end

    return LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui")
end

local function protectGui(gui)
    if syn and syn.protect_gui then
        syn.protect_gui(gui)
    elseif protectgui then
        protectgui(gui)
    elseif get_hidden_gui then
        gui.Parent = get_hidden_gui()
        return
    end

    gui.Parent = getGuiParent()
end

local function makeDraggable(frame, dragHandle)
    local dragging = false
    local dragStart, startPos

    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)

    dragHandle.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

local function createShadow(parent)
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://5028857084"
    shadow.ImageTransparency = 0.25
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(24, 24, 276, 276)
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.Position = UDim2.fromScale(0.5, 0.5)
    shadow.Size = parent.Size + UDim2.new(0, 40, 0, 40)
    shadow.ZIndex = parent.ZIndex - 1
    shadow.Parent = parent
end

local function round(number, step)
    step = step or 1
    return math.round(number / step) * step
end

local function createRow(container, height)
    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = THEME.Background
    frame.BorderSizePixel = 0
    frame.Size = UDim2.new(1, 0, 0, height or 36)
    frame.Parent = container

    local stroke = Instance.new("UIStroke")
    stroke.Color = THEME.Stroke
    stroke.Thickness = 1
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = frame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = frame

    return frame
end

local function createLabel(parent, text)
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamSemibold
    label.TextColor3 = THEME.Text
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.Text = text
    label.Parent = parent
    return label
end

function SorinUI.new(options)
    options = options or {}
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = options.Name or "SorinUI"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    protectGui(screenGui)

    local main = Instance.new("Frame")
    main.Name = "Window"
    main.BackgroundColor3 = THEME.Background
    main.BorderSizePixel = 0
    main.Position = options.Position or UDim2.new(0.06, 0, 0.1, 0)
    main.Size = options.Size or UDim2.new(0, 260, 0, 320)
    main.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = main

    createShadow(main)

    local header = Instance.new("Frame")
    header.Name = "Header"
    header.BackgroundColor3 = THEME.Accent
    header.BorderSizePixel = 0
    header.Size = UDim2.new(1, 0, 0, 40)
    header.Parent = main

    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 10)
    headerCorner.Parent = header

    local headerLabel = createLabel(header, options.Title or "Sorin UI")
    headerLabel.Size = UDim2.new(1, -16, 1, 0)
    headerLabel.Position = UDim2.new(0, 8, 0, 0)
    headerLabel.TextColor3 = THEME.Text
    headerLabel.TextSize = 16

    local closeButton = Instance.new("TextButton")
    closeButton.Name = "Close"
    closeButton.BackgroundTransparency = 1
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Text = "×"
    closeButton.TextSize = 20
    closeButton.TextColor3 = THEME.Text
    closeButton.Size = UDim2.new(0, 34, 0, 34)
    closeButton.Position = UDim2.new(1, -36, 0, 3)
    closeButton.Parent = header

    local content = Instance.new("Frame")
    content.Name = "Content"
    content.BackgroundTransparency = 1
    content.Position = UDim2.new(0, 10, 0, 50)
    content.Size = UDim2.new(1, -20, 1, -60)
    content.Parent = main

    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.VerticalAlignment = Enum.VerticalAlignment.Begin
    layout.Padding = UDim.new(0, 8)
    layout.Parent = content

    makeDraggable(main, header)

    local self = setmetatable({
        _gui = screenGui,
        _main = main,
        _content = content,
        _connections = {},
        _destroyed = false
    }, SorinUI)

    closeButton.MouseButton1Click:Connect(function()
        self:Destroy()
    end)

    return self
end

function SorinUI:AddLabel(text)
    assert(not self._destroyed, "Window destroyed")
    local row = createRow(self._content, 30)
    row.BackgroundTransparency = 1
    row:FindFirstChildOfClass("UIStroke").Enabled = false
    local label = createLabel(row, text or "")
    label.Size = UDim2.new(1, -12, 1, 0)
    label.Position = UDim2.new(0, 6, 0, 0)
    label.TextColor3 = THEME.SubText
    label.TextWrapped = true
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextSize = 13
    return label
end

function SorinUI:AddToggle(config)
    assert(not self._destroyed, "Window destroyed")
    config = config or {}
    local row = createRow(self._content)

    local label = createLabel(row, config.Label or "Toggle")
    label.Size = UDim2.new(1, -80, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)

    local button = Instance.new("TextButton")
    button.Name = "ToggleButton"
    button.AnchorPoint = Vector2.new(1, 0.5)
    button.Position = UDim2.new(1, -18, 0.5, 0)
    button.Size = UDim2.new(0, 56, 0, 24)
    button.BackgroundColor3 = THEME.Stroke
    button.BorderSizePixel = 0
    button.Text = ""
    button.Parent = row

    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(1, 0)
    buttonCorner.Parent = button

    local knob = Instance.new("Frame")
    knob.Name = "Knob"
    knob.BackgroundColor3 = THEME.Background
    knob.BorderSizePixel = 0
    knob.Size = UDim2.new(0, 24, 0, 24)
    knob.Position = UDim2.new(0, 0, 0, 0)
    knob.Parent = button

    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob

    local state = config.Default == true

    local function apply(value)
        knob:TweenPosition(UDim2.new(value and 1 or 0, value and -24 or 0, 0, 0), "Out", "Quad", 0.15, true)
        button.BackgroundColor3 = value and THEME.Accent or THEME.Stroke
    end

    apply(state)

    local toggle = {}

    function toggle:Get()
        return state
    end

    function toggle:Set(value, suppressCallback)
        value = value == true
        if state == value then
            return
        end
        state = value
        apply(state)
        if config.Callback and not suppressCallback then
            task.spawn(config.Callback, state)
        end
    end

    button.MouseButton1Click:Connect(function()
        toggle:Set(not state)
    end)

    return toggle
end

function SorinUI:AddButton(config)
    assert(not self._destroyed, "Window destroyed")
    config = config or {}
    local row = createRow(self._content)

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -20, 1, -10)
    button.Position = UDim2.new(0, 10, 0, 5)
    button.BackgroundColor3 = THEME.AccentDark
    button.TextColor3 = THEME.Text
    button.TextSize = 14
    button.Text = config.Label or "Button"
    button.Font = Enum.Font.GothamSemibold
    button.Parent = row

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button

    button.MouseButton1Click:Connect(function()
        if config.Callback then
            task.spawn(config.Callback)
        end
    end)

    return button
end

function SorinUI:AddSlider(config)
    assert(not self._destroyed, "Window destroyed")
    config = config or {}
    local min = config.Min or 0
    local max = config.Max or 100
    local step = config.Step or 1
    if step <= 0 then
        step = 1
    end

    local default = config.Default or min
    default = math.clamp(default, min, max)
    default = round(default - min, step) + min

    local row = createRow(self._content, 52)

    local label = createLabel(row, config.Label or "Slider")
    label.Size = UDim2.new(1, -12, 0, 24)
    label.Position = UDim2.new(0, 12, 0, 4)
    label.TextYAlignment = Enum.TextYAlignment.Top

    local valueLabel = Instance.new("TextLabel")
    valueLabel.BackgroundTransparency = 1
    valueLabel.Font = Enum.Font.Gotham
    valueLabel.TextSize = 12
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.TextColor3 = THEME.SubText
    valueLabel.Size = UDim2.new(1, -20, 0, 14)
    valueLabel.Position = UDim2.new(0, 10, 0, 24)
    valueLabel.Parent = row

    local track = Instance.new("Frame")
    track.Name = "Track"
    track.BackgroundColor3 = THEME.Stroke
    track.BorderSizePixel = 0
    track.Size = UDim2.new(1, -20, 0, 6)
    track.Position = UDim2.new(0, 10, 0, 38)
    track.Parent = row

    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(1, 0)
    trackCorner.Parent = track

    local fill = Instance.new("Frame")
    fill.Name = "Fill"
    fill.BackgroundColor3 = THEME.Accent
    fill.BorderSizePixel = 0
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.Parent = track

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill

    local dragging = false
    local value = default

    local function format(num)
        if config.ShowDecimal then
            return string.format("%.2f", num)
        end
        return tostring(num)
    end

    local function updateVisual()
        local alpha = (value - min) / (max - min)
        if max == min then
            alpha = 0
        end
        fill.Size = UDim2.new(alpha, 0, 1, 0)
        valueLabel.Text = string.format("%s (%s)", config.Label or "Slider", format(value))
    end

    local function setValue(newValue, suppressCallback)
        newValue = math.clamp(newValue, min, max)
        newValue = round(newValue - min, step) + min
        if newValue == value then
            updateVisual()
            return
        end
        value = newValue
        updateVisual()
        if config.Callback and not suppressCallback then
            task.spawn(config.Callback, value)
        end
    end

    updateVisual()

    local function valueFromX(x)
        local absPos = track.AbsolutePosition.X
        local absSize = track.AbsoluteSize.X
        local ratio = math.clamp((x - absPos) / absSize, 0, 1)
        return min + (max - min) * ratio
    end

    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            setValue(valueFromX(input.Position.X))
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            setValue(valueFromX(input.Position.X))
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    local slider = {}

    function slider:Get()
        return value
    end

    function slider:Set(newValue, suppressCallback)
        setValue(newValue, suppressCallback)
    end

    return slider
end

function SorinUI:Destroy()
    if self._destroyed then
        return
    end
    self._destroyed = true
    for _, conn in ipairs(self._connections) do
        conn:Disconnect()
    end
    if self._gui then
        self._gui:Destroy()
    end
end

return setmetatable({
    new = SorinUI.new,
    Theme = THEME
}, SorinUI)
