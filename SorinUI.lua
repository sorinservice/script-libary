-- SorinUI.lua
-- Modern SorinSoftware UI library with window management, scrolling layout and notifications

local SorinUI = {}
SorinUI.__index = SorinUI
SorinUI._VERSION = 20241006

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local THEME = {
    Background = Color3.fromRGB(24, 25, 35),
    Accent = Color3.fromRGB(125, 105, 255),
    AccentDark = Color3.fromRGB(88, 75, 185),
    AccentLight = Color3.fromRGB(170, 160, 255),
    Surface = Color3.fromRGB(32, 33, 45),
    Card = Color3.fromRGB(36, 38, 50),
    Text = Color3.fromRGB(235, 236, 245),
    SubText = Color3.fromRGB(170, 173, 190),
    Stroke = Color3.fromRGB(48, 50, 70),
    Notification = Color3.fromRGB(30, 31, 43),
    Shadow = Color3.fromRGB(18, 18, 26)
}

local HEADER_HEIGHT = 42
local WINDOW_MIN_HEIGHT = HEADER_HEIGHT + 12

---------------------------------------------------------------------
-- Utility
---------------------------------------------------------------------
local function getGuiParent()
    if gethui then
        local ui = gethui()
        if typeof(ui) == "Instance" then
            return ui
        end
    end

    local ok, coreGui = pcall(function()
        return game:GetService("CoreGui")
    end)

    if ok and coreGui then
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

local function tween(object, goal, time, style, direction)
    local info = TweenInfo.new(time or 0.2, style or Enum.EasingStyle.Quad, direction or Enum.EasingDirection.Out)
    local animation = TweenService:Create(object, info, goal)
    animation:Play()
    return animation
end

local function createIconButton(parent, icon)
    local btn = Instance.new("TextButton")
    btn.BackgroundTransparency = 1
    btn.Size = UDim2.new(0, 26, 0, 26)
    btn.Text = icon
    btn.TextSize = 20
    btn.Font = Enum.Font.GothamBold
    btn.TextColor3 = THEME.Text
    btn.Parent = parent
    return btn
end

local function createStroke(parent, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = THEME.Stroke
    stroke.Thickness = thickness or 1
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = parent
    return stroke
end

local function createCard(parent)
    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = THEME.Card
    frame.BorderSizePixel = 0
    frame.Parent = parent
    createStroke(frame, 1)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    return frame
end

local function createLabel(parent, text, size, font)
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Text = text or ""
    label.TextColor3 = THEME.Text
    label.Font = font or Enum.Font.GothamSemibold
    label.TextSize = size or 16
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.Parent = parent
    return label
end

local function createShadow(parent)
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.Position = UDim2.fromScale(0.5, 0.5)
    shadow.Size = UDim2.new(1, 40, 1, 40)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://6014261993"
    shadow.ImageColor3 = THEME.Shadow
    shadow.ImageTransparency = 0.72
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(49, 49, 450, 450)
    shadow.ZIndex = parent.ZIndex - 1
    shadow.Parent = parent
    return shadow
end

local function round(number, step)
    step = step or 1
    return math.round(number / step) * step
end

---------------------------------------------------------------------
-- SorinUI window
---------------------------------------------------------------------
function SorinUI.new(options)
    options = options or {}

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = options.Name or "SorinUI"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    protectGui(screenGui)

    local main = Instance.new("Frame")
    main.Name = "Window"
    main.BackgroundColor3 = THEME.Surface
    main.BorderSizePixel = 0
    main.Size = options.Size or UDim2.new(0, 320, 0, 360)
    main.Position = options.Position or UDim2.new(0.12, 0, 0.14, 0)
    main.ClipsDescendants = true
    main.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = main

    createStroke(main, 1.25)
    local shadow = createShadow(main)

    local header = Instance.new("Frame")
    header.Name = "Header"
    header.BackgroundColor3 = THEME.Surface:Lerp(THEME.Accent, 0.08)
    header.BorderSizePixel = 0
    header.Size = UDim2.new(1, 0, 0, HEADER_HEIGHT)
    header.Parent = main

    local headerStroke = createStroke(header, 1)
    headerStroke.Color = THEME.Surface:Lerp(THEME.Stroke, 0.5)

    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 10)
    headerCorner.Parent = header

    local titleLabel = createLabel(header, options.Title or "Sorin Window", 17, Enum.Font.GothamSemibold)
    titleLabel.Position = UDim2.new(0, 16, 0, 0)
    titleLabel.Size = UDim2.new(1, -120, 1, 0)
    titleLabel.TextColor3 = THEME.Text
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left

    local iconBar = Instance.new("Frame")
    iconBar.BackgroundTransparency = 1
    iconBar.Position = UDim2.new(1, -46, 0, 0)
    iconBar.Size = UDim2.new(0, 46, 1, 0)
    iconBar.Parent = header

    local iconLayout = Instance.new("UIListLayout")
    iconLayout.FillDirection = Enum.FillDirection.Horizontal
    iconLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    iconLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    iconLayout.Padding = UDim.new(0, 6)
    iconLayout.Parent = iconBar

    local minimizeButton = createIconButton(iconBar, "-")
    minimizeButton.TextSize = 24

    local body = Instance.new("Frame")
    body.Name = "Body"
    body.BackgroundTransparency = 1
    body.Position = UDim2.new(0, 14, 0, HEADER_HEIGHT + 6)
    body.Size = UDim2.new(1, -28, 1, -(HEADER_HEIGHT + 20))
    body.Parent = main

    local scroll = Instance.new("ScrollingFrame")
    scroll.Name = "Scroll"
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.Size = UDim2.new(1, 0, 1, 0)
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.ScrollBarThickness = 4
    scroll.ScrollBarImageColor3 = THEME.Accent
    scroll.ClipsDescendants = false
    scroll.Parent = body

    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 8)
    padding.PaddingLeft = UDim.new(0, 12)
    padding.PaddingRight = UDim.new(0, 12)
    padding.PaddingBottom = UDim.new(0, 12)
    padding.Parent = scroll

    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    layout.VerticalAlignment = Enum.VerticalAlignment.Top
    layout.Padding = UDim.new(0, 10)
    layout.Parent = scroll

    local notificationHost = Instance.new("Frame")
    notificationHost.Name = "Notifications"
    notificationHost.BackgroundTransparency = 1
    notificationHost.Size = UDim2.new(0, 280, 1, 0)
    notificationHost.AnchorPoint = Vector2.new(1, 0)
    notificationHost.Position = UDim2.new(1, -10, 0, 10)
    notificationHost.ZIndex = 100
    notificationHost.ClipsDescendants = false
    notificationHost.Parent = screenGui

    local notificationLayout = Instance.new("UIListLayout")
    notificationLayout.FillDirection = Enum.FillDirection.Vertical
    notificationLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    notificationLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    notificationLayout.Padding = UDim.new(0, 8)
    notificationLayout.Parent = notificationHost

    local connections = {}
    local function connect(signal, fn)
        local conn = signal:Connect(fn)
        table.insert(connections, conn)
        return conn
    end

    makeDraggable(main, header)

    local self = setmetatable({
        _gui = screenGui,
        _main = main,
        _shadow = shadow,
        _header = header,
        _body = body,
        _scroll = scroll,
        _layout = layout,
        _connections = connections,
        _destroyed = false,
        _minimized = false,
        _originalSize = main.Size,
        _notificationHost = notificationHost,
        _headerButtons = {
            Minimize = minimizeButton
        }
    }, SorinUI)

    minimizeButton.MouseButton1Click:Connect(function()
        self:ToggleMinimize()
    end)

    return self
end

---------------------------------------------------------------------
-- Public API
---------------------------------------------------------------------
function SorinUI:ToggleMinimize(state)
    if self._destroyed then
        return
    end

    if state == nil then
        state = not self._minimized
    end

    local targetMinimized = state == true
    if targetMinimized == self._minimized then
        return
    end

    self._minimized = targetMinimized

    if targetMinimized then
        tween(self._main, {Size = UDim2.new(self._originalSize.X.Scale, self._originalSize.X.Offset, 0, WINDOW_MIN_HEIGHT)}, 0.18)
    else
        tween(self._main, {Size = self._originalSize}, 0.18)
    end

    self._body.Visible = not targetMinimized
    if self._shadow then
        self._shadow.Visible = not targetMinimized
    end
end

function SorinUI:AddSection(title)
    assert(not self._destroyed, "Window destroyed")
    local card = createCard(self._scroll)
    card.AutomaticSize = Enum.AutomaticSize.Y
    card.Size = UDim2.new(1, -24, 0, 48)

    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 12)
    padding.PaddingBottom = UDim.new(0, 12)
    padding.PaddingLeft = UDim.new(0, 14)
    padding.PaddingRight = UDim.new(0, 14)
    padding.Parent = card

    local label = createLabel(card, title or "Section", 16, Enum.Font.GothamBold)
    label.Size = UDim2.new(1, 0, 0, 20)
    label.TextColor3 = THEME.AccentLight
    label.TextXAlignment = Enum.TextXAlignment.Left

    return card
end

function SorinUI:AddLabel(text)
    assert(not self._destroyed, "Window destroyed")
    local card = createCard(self._scroll)
    card.AutomaticSize = Enum.AutomaticSize.Y
    card.Size = UDim2.new(1, -24, 0, 48)

    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 10)
    padding.PaddingBottom = UDim.new(0, 10)
    padding.PaddingLeft = UDim.new(0, 14)
    padding.PaddingRight = UDim.new(0, 14)
    padding.Parent = card

    local label = createLabel(card, text or "", 14, Enum.Font.Gotham)
    label.TextWrapped = true
    label.TextColor3 = THEME.SubText
    label.Size = UDim2.new(1, 0, 0, 18)
    label.AutomaticSize = Enum.AutomaticSize.Y

    return label
end

function SorinUI:AddToggle(config)
    assert(not self._destroyed, "Window destroyed")
    config = config or {}

    local card = createCard(self._scroll)
    card.Size = UDim2.new(1, -24, 0, 58)

    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 16)
    padding.PaddingRight = UDim.new(0, 16)
    padding.Parent = card

    local label = createLabel(card, config.Label or "Toggle")
    label.Size = UDim2.new(1, -80, 1, 0)
    label.TextColor3 = THEME.Text
    label.TextXAlignment = Enum.TextXAlignment.Left

    local button = Instance.new("Frame")
    button.Name = "ToggleTrack"
    button.AnchorPoint = Vector2.new(1, 0.5)
    button.Position = UDim2.new(1, -4, 0.5, 0)
    button.Size = UDim2.new(0, 54, 0, 26)
    button.BackgroundColor3 = THEME.Stroke
    button.BorderSizePixel = 0
    button.Parent = card

    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(1, 0)
    trackCorner.Parent = button

    local knob = Instance.new("Frame")
    knob.Name = "Knob"
    knob.Size = UDim2.new(0, 24, 0, 24)
    knob.Position = UDim2.new(0, 1, 0.5, -12)
    knob.BackgroundColor3 = THEME.Surface
    knob.BorderSizePixel = 0
    knob.Parent = button

    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob

    local overlayButton = Instance.new("TextButton")
    overlayButton.BackgroundTransparency = 1
    overlayButton.Size = UDim2.new(1, 0, 1, 0)
    overlayButton.Text = ""
    overlayButton.Parent = button

    local state = config.Default == true

    local function apply(value, instant)
        value = value == true
        local goalPosition = value and UDim2.new(1, -25, 0.5, -12) or UDim2.new(0, 1, 0.5, -12)
        local colorGoal = value and THEME.Accent or THEME.Stroke
        if instant then
            knob.Position = goalPosition
            button.BackgroundColor3 = colorGoal
        else
            tween(knob, {Position = goalPosition}, 0.16)
            tween(button, {BackgroundColor3 = colorGoal}, 0.16)
        end
    end

    apply(state, true)

    local toggle = {}

    function toggle:Get()
        return state
    end

    function toggle:Set(value, suppress)
        value = value == true
        if state == value then
            apply(state, true)
            return
        end
        state = value
        apply(state)
        if config.Callback and not suppress then
            task.spawn(config.Callback, state)
        end
    end

    overlayButton.MouseButton1Click:Connect(function()
        toggle:Set(not state)
    end)

    return toggle
end

function SorinUI:AddButton(config)
    assert(not self._destroyed, "Window destroyed")
    config = config or {}

    local card = createCard(self._scroll)
    card.Size = UDim2.new(1, -24, 0, 56)

    local button = Instance.new("TextButton")
    button.BackgroundColor3 = config.Color or THEME.AccentDark
    button.TextColor3 = THEME.Text
    button.TextSize = 15
    button.Font = Enum.Font.GothamSemibold
    button.Text = config.Label or "Button"
    button.Size = UDim2.new(1, -24, 1, -16)
    button.Position = UDim2.new(0, 12, 0, 8)
    button.Parent = card

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button

    createStroke(button, 1).Color = (config.Color or THEME.AccentDark):Lerp(THEME.Text, 0.1)

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

    local card = createCard(self._scroll)
    card.Size = UDim2.new(1, -24, 0, 96)

    local title = createLabel(card, config.Label or "Slider", 15)
    title.Position = UDim2.new(0, 16, 0, 14)
    title.Size = UDim2.new(1, -32, 0, 20)

    local valueLabel = createLabel(card, "", 13, Enum.Font.Gotham)
    valueLabel.TextColor3 = THEME.SubText
    valueLabel.Position = UDim2.new(0, 16, 0, 36)
    valueLabel.Size = UDim2.new(1, -32, 0, 18)

    local track = Instance.new("Frame")
    track.Name = "SliderTrack"
    track.BackgroundColor3 = THEME.Stroke
    track.BorderSizePixel = 0
    track.Size = UDim2.new(1, -32, 0, 6)
    track.Position = UDim2.new(0, 16, 0, 64)
    track.Parent = card

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

    local knob = Instance.new("Frame")
    knob.Name = "Knob"
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.Position = UDim2.new(0, 0, 0.5, 0)
    knob.BackgroundColor3 = THEME.Surface
    knob.BorderSizePixel = 0
    knob.Parent = track

    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob

    local dragging = false
    local value = default

    local function formatValue(v)
        if config.ShowDecimal then
            return string.format("%.2f", v)
        end
        return tostring(v)
    end

    local function updateVisual()
        local alpha = (value - min) / (max - min)
        if max == min then
            alpha = 0
        end
        fill.Size = UDim2.new(alpha, 0, 1, 0)
        knob.Position = UDim2.new(alpha, 0, 0.5, 0)
        valueLabel.Text = formatValue(value)
    end

    local function setValue(newValue, suppress)
        newValue = math.clamp(newValue, min, max)
        newValue = round(newValue - min, step) + min
        if newValue == value then
            updateVisual()
            return
        end
        value = newValue
        updateVisual()
        if config.Callback and not suppress then
            task.spawn(config.Callback, value)
        end
    end

    local function valueFromX(x)
        local absPos = track.AbsolutePosition.X
        local absSize = track.AbsoluteSize.X
        if absSize == 0 then return min end
        local ratio = math.clamp((x - absPos) / absSize, 0, 1)
        return min + (max - min) * ratio
    end

    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            setValue(valueFromX(input.Position.X))
        end
    end)

    local inputChangedConn
    inputChangedConn = UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            setValue(valueFromX(input.Position.X))
        end
    end)

    local inputEndedConn
    inputEndedConn = UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    table.insert(self._connections, inputChangedConn)
    table.insert(self._connections, inputEndedConn)

    updateVisual()

    local slider = {}
    function slider:Get()
        return value
    end
    function slider:Set(newValue, suppress)
        setValue(newValue, suppress)
    end

    return slider
end

function SorinUI:Notify(config)
    assert(not self._destroyed, "Window destroyed")
    config = config or {}
    local duration = config.Duration or 4

    local container = Instance.new("Frame")
    container.BackgroundTransparency = 1
    container.Size = UDim2.new(1, 0, 0, 0)
    container.Parent = self._notificationHost

    local card = createCard(container)
    card.AutomaticSize = Enum.AutomaticSize.Y
    card.Size = UDim2.new(1, -6, 0, 0)

    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 10)
    padding.PaddingBottom = UDim.new(0, 10)
    padding.PaddingLeft = UDim.new(0, 14)
    padding.PaddingRight = UDim.new(0, 14)
    padding.Parent = card

    local titleLabel = createLabel(card, config.Title or "Sorin Notification", 15, Enum.Font.GothamSemibold)
    titleLabel.Size = UDim2.new(1, -26, 0, 20)

    local bodyLabel = createLabel(card, config.Text or "", 13, Enum.Font.Gotham)
    bodyLabel.TextColor3 = THEME.SubText
    bodyLabel.TextWrapped = true
    bodyLabel.AutomaticSize = Enum.AutomaticSize.Y
    bodyLabel.Size = UDim2.new(1, 0, 0, 18)
    bodyLabel.Position = UDim2.new(0, 0, 0, 22)

    local closeButton = createIconButton(card, "X")
    closeButton.TextSize = 18
    closeButton.AnchorPoint = Vector2.new(1, 0)
    closeButton.Position = UDim2.new(1, 0, 0, 0)

    card.ClipsDescendants = true
    card.Position = UDim2.new(0, -20, 0, 0)
    card.BackgroundTransparency = 1
    titleLabel.TextTransparency = 1
    bodyLabel.TextTransparency = 1

    tween(card, {Position = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 0}, 0.18, Enum.EasingStyle.Quart)
    tween(titleLabel, {TextTransparency = 0}, 0.2)
    tween(bodyLabel, {TextTransparency = 0}, 0.2)

    local dismissed = false
    local function dismiss()
        if dismissed then
            return
        end
        dismissed = true
        tween(titleLabel, {TextTransparency = 1}, 0.15)
        tween(bodyLabel, {TextTransparency = 1}, 0.15)
        local anim = tween(card, {Position = UDim2.new(0, 0, 0, -10), BackgroundTransparency = 1}, 0.15)
        anim.Completed:Wait()
        container:Destroy()
    end

    closeButton.MouseButton1Click:Connect(dismiss)
    if duration > 0 then
        task.delay(duration, function()
            if not dismissed then
                dismiss()
            end
        end)
    end

    return {
        Dismiss = dismiss
    }
end

function SorinUI:GetHeaderButtons()
    return self._headerButtons
end

function SorinUI:GetMainFrame()
    return self._main
end

function SorinUI:GetGui()
    return self._gui
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
    Theme = THEME,
    _VERSION = SorinUI._VERSION
}, SorinUI)
