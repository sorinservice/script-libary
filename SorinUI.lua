-- SorinUI.lua
-- Lightweight UI + notifications for SorinSoftware scripts

local SorinUI = {}
SorinUI.__index = SorinUI
SorinUI._VERSION = 20241005

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local THEME = {
    Background = Color3.fromRGB(25, 24, 36),
    Accent = Color3.fromRGB(140, 120, 255),
    AccentDark = Color3.fromRGB(95, 82, 170),
    AccentLight = Color3.fromRGB(180, 170, 255),
    Text = Color3.fromRGB(235, 235, 245),
    SubText = Color3.fromRGB(170, 170, 190),
    Stroke = Color3.fromRGB(45, 45, 65),
    Notification = Color3.fromRGB(30, 28, 44)
}

local HEADER_HEIGHT = 40

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

local function createShadow(parent)
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.Position = UDim2.fromScale(0.5, 0.5)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://5028857084"
    shadow.ImageTransparency = 0.25
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(24, 24, 276, 276)
    shadow.Size = parent.Size + UDim2.new(0, 40, 0, 40)
    shadow.ZIndex = parent.ZIndex - 1
    shadow.Visible = parent.Visible
    shadow.Parent = parent
    return shadow
end

local function createStroke(parent)
    local stroke = Instance.new("UIStroke")
    stroke.Color = THEME.Stroke
    stroke.Thickness = 1
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = parent
    return stroke
end

local function createRow(container, height)
    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = THEME.Background
    frame.BorderSizePixel = 0
    frame.Size = UDim2.new(1, 0, 0, height or 36)
    frame.Parent = container

    createStroke(frame)

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
    label.Text = text or ""
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.Parent = parent
    return label
end

local function round(number, step)
    step = step or 1
    return math.round(number / step) * step
end

local function createSpinner(parent)
    local spinner = Instance.new("Frame")
    spinner.Name = "Spinner"
    spinner.AnchorPoint = Vector2.new(0.5, 0.5)
    spinner.Position = UDim2.fromScale(0.5, 0.5)
    spinner.Size = UDim2.new(0, 32, 0, 32)
    spinner.BackgroundTransparency = 1
    spinner.Parent = parent

    local circle = Instance.new("ImageLabel")
    circle.BackgroundTransparency = 1
    circle.Image = "rbxassetid://4483345878"
    circle.ImageColor3 = THEME.Accent
    circle.Size = UDim2.fromScale(1, 1)
    circle.Parent = spinner

    return spinner, circle
end

local function tween(object, goal, time, style, direction)
    local info = TweenInfo.new(time or 0.2, style or Enum.EasingStyle.Quad, direction or Enum.EasingDirection.Out)
    return TweenService:Create(object, info, goal)
end

---------------------------------------------------------------------
-- SorinUI window
---------------------------------------------------------------------
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
    main.Size = options.Size or UDim2.new(0, 260, 0, 320)
    main.Position = options.Position or UDim2.new(0.06, 0, 0.12, 0)
    main.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = main

    local shadow = createShadow(main)

    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, HEADER_HEIGHT)
    header.BackgroundColor3 = THEME.Accent
    header.BorderSizePixel = 0
    header.Parent = main

    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 10)
    headerCorner.Parent = header

    local headerLabel = createLabel(header, options.Title or "Sorin UI")
    headerLabel.Size = UDim2.new(1, -70, 1, 0)
    headerLabel.Position = UDim2.new(0, 12, 0, 0)
    headerLabel.TextColor3 = THEME.Text
    headerLabel.TextSize = 16

    local buttonContainer = Instance.new("Frame")
    buttonContainer.BackgroundTransparency = 1
    buttonContainer.Size = UDim2.new(0, 64, 1, 0)
    buttonContainer.Position = UDim2.new(1, -66, 0, 0)
    buttonContainer.Parent = header

    local buttonLayout = Instance.new("UIListLayout")
    buttonLayout.FillDirection = Enum.FillDirection.Horizontal
    buttonLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    buttonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    buttonLayout.Padding = UDim.new(0, 6)
    buttonLayout.Parent = buttonContainer

    local function createHeaderButton(text)
        local btn = Instance.new("TextButton")
        btn.BackgroundTransparency = 1
        btn.Size = UDim2.new(0, 24, 0, 24)
        btn.Text = text
        btn.TextSize = 20
        btn.Font = Enum.Font.GothamBold
        btn.TextColor3 = THEME.Text
        btn.Parent = buttonContainer
        return btn
    end

    local minimizeButton = createHeaderButton("-")
    minimizeButton.TextSize = 22
    local closeButton = createHeaderButton("X")

    local body = Instance.new("Frame")
    body.Name = "Body"
    body.BackgroundTransparency = 1
    body.Position = UDim2.new(0, 12, 0, HEADER_HEIGHT + 8)
    body.Size = UDim2.new(1, -24, 1, -(HEADER_HEIGHT + 20))
    body.Parent = main

    local contentContainer = Instance.new("Frame")
    contentContainer.Name = "Content"
    contentContainer.BackgroundTransparency = 1
    contentContainer.Size = UDim2.new(1, 0, 1, 0)
    contentContainer.Parent = body

    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.VerticalAlignment = Enum.VerticalAlignment.Top
    layout.Padding = UDim.new(0, 8)
    layout.Parent = contentContainer

    local notificationHost = Instance.new("Frame")
    notificationHost.Name = "Notifications"
    notificationHost.BackgroundTransparency = 1
    notificationHost.Size = UDim2.new(0, 260, 1, 0)
    notificationHost.AnchorPoint = Vector2.new(1, 0)
    notificationHost.Position = UDim2.new(1, -10, 0, 10)
    notificationHost.ZIndex = 50
    notificationHost.Parent = screenGui

    local notificationLayout = Instance.new("UIListLayout")
    notificationLayout.FillDirection = Enum.FillDirection.Vertical
    notificationLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    notificationLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    notificationLayout.Padding = UDim.new(0, 8)
    notificationLayout.Parent = notificationHost

    local loaderOverlay = Instance.new("Frame")
    loaderOverlay.Name = "Loader"
    loaderOverlay.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
    loaderOverlay.BackgroundTransparency = 0.15
    loaderOverlay.Visible = options.LoaderEnabled ~= false
    loaderOverlay.Size = UDim2.fromScale(1, 1)
    loaderOverlay.Parent = body

    local loaderCorner = Instance.new("UICorner")
    loaderCorner.CornerRadius = UDim.new(0, 8)
    loaderCorner.Parent = loaderOverlay

    local spinnerFrame, spinnerImage = createSpinner(loaderOverlay)
    spinnerImage.ImageTransparency = 0.1

    local loaderLabel = createLabel(loaderOverlay, options.LoaderText or "Loading Sorin UI...")
    loaderLabel.TextSize = 15
    loaderLabel.TextColor3 = THEME.SubText
    loaderLabel.Size = UDim2.new(1, 0, 0, 24)
    loaderLabel.Position = UDim2.new(0, 0, 0.5, 24)
    loaderLabel.TextXAlignment = Enum.TextXAlignment.Center

    local connections = {}
    local function connect(signal, fn)
        local conn = signal:Connect(fn)
        table.insert(connections, conn)
        return conn
    end

    local self = setmetatable({
        _gui = screenGui,
        _main = main,
        _shadow = shadow,
        _header = header,
        _body = body,
        _content = contentContainer,
        _layout = layout,
        _loader = loaderOverlay,
        _loaderLabel = loaderLabel,
        _spinnerImage = spinnerImage,
        _spinnerConnection = nil,
        _connections = connections,
        _destroyed = false,
        _minimized = false,
        _originalSize = main.Size,
        _notificationHost = notificationHost
    }, SorinUI)

    if loaderOverlay.Visible then
        self._spinnerConnection = connect(RunService.RenderStepped, function(dt)
            if self._spinnerImage then
                self._spinnerImage.Rotation = (self._spinnerImage.Rotation + 200 * dt) % 360
            end
        end)
    end

    makeDraggable(main, header)

    closeButton.MouseButton1Click:Connect(function()
        self:Destroy()
    end)

    minimizeButton.MouseButton1Click:Connect(function()
        self:ToggleMinimize()
    end)

    if loaderOverlay.Visible and options.AutoHideLoader ~= false then
        task.delay(options.LoaderDuration or 1.0, function()
            if not self._destroyed then
                self:SetLoading(false)
            end
        end)
    end

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

    state = state == true
    if self._minimized == state then
        return
    end

    self._minimized = state
    local targetSize = state and UDim2.new(self._originalSize.X.Scale, self._originalSize.X.Offset, 0, HEADER_HEIGHT + 12)
        or self._originalSize

    local contentVisible = not state

    if self._body.Visible ~= contentVisible then
        self._body.Visible = contentVisible
    end

    if self._shadow then
        self._shadow.Visible = not state
    end

    tween(self._main, {Size = targetSize}, 0.2):Play()
end

function SorinUI:AddSection(title)
    assert(not self._destroyed, "Window destroyed")
    local row = createRow(self._content, 34)
    row.BackgroundTransparency = 0.2
    row:FindFirstChildOfClass("UIStroke").Enabled = false

    local label = createLabel(row, title or "")
    label.Size = UDim2.new(1, -12, 1, 0)
    label.Position = UDim2.new(0, 6, 0, 0)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.TextSize = 15
    label.Font = Enum.Font.GothamBold

    return row
end

function SorinUI:AddLabel(text)
    assert(not self._destroyed, "Window destroyed")
    local row = createRow(self._content, 30)
    row.BackgroundTransparency = 1
    local stroke = row:FindFirstChildOfClass("UIStroke")
    if stroke then
        stroke.Enabled = false
    end
    local label = createLabel(row, text or "")
    label.Size = UDim2.new(1, -12, 1, 0)
    label.Position = UDim2.new(0, 6, 0, 0)
    label.TextColor3 = THEME.SubText
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextWrapped = true
    label.TextSize = 13
    return label
end

function SorinUI:AddToggle(config)
    assert(not self._destroyed, "Window destroyed")
    config = config or {}
    local row = createRow(self._content, 40)

    local label = createLabel(row, config.Label or "Toggle")
    label.Size = UDim2.new(1, -90, 1, 0)
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
        value = value == true
        local goal = value and UDim2.new(1, -24, 0, 0) or UDim2.new(0, 0, 0, 0)
        tween(knob, {Position = goal}, 0.12):Play()
        tween(button, {BackgroundColor3 = value and THEME.Accent or THEME.Stroke}, 0.12):Play()
    end

    apply(state)

    local toggle = {}

    function toggle:Get()
        return state
    end

    function toggle:Set(value, suppressCallback)
        value = value == true
        if state == value then
            apply(state)
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
    local row = createRow(self._content, 42)

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -20, 1, -10)
    button.Position = UDim2.new(0, 10, 0, 5)
    button.BackgroundColor3 = config.Color or THEME.AccentDark
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

    local row = createRow(self._content, 56)

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
    track.Position = UDim2.new(0, 10, 0, 40)
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

    local function formatValue(num)
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
        valueLabel.Text = string.format("%s (%s)", config.Label or "Slider", formatValue(value))
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

    function slider:Set(newValue, suppressCallback)
        setValue(newValue, suppressCallback)
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

    local holder = Instance.new("Frame")
    holder.AutomaticSize = Enum.AutomaticSize.Y
    holder.Size = UDim2.new(1, -8, 0, 0)
    holder.Position = UDim2.new(0, 8, 0, 0)
    holder.BackgroundColor3 = THEME.Notification
    holder.BorderSizePixel = 0
    holder.Parent = container

    createStroke(holder)

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = holder

    local titleLabel = createLabel(holder, config.Title or "Sorin Notification")
    titleLabel.TextSize = 15
    titleLabel.Position = UDim2.new(0, 10, 0, 6)
    titleLabel.Size = UDim2.new(1, -40, 0, 20)

    local messageLabel = Instance.new("TextLabel")
    messageLabel.BackgroundTransparency = 1
    messageLabel.Font = Enum.Font.Gotham
    messageLabel.TextColor3 = THEME.SubText
    messageLabel.TextSize = 13
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.TextYAlignment = Enum.TextYAlignment.Top
    messageLabel.TextWrapped = true
    messageLabel.AutomaticSize = Enum.AutomaticSize.Y
    messageLabel.Position = UDim2.new(0, 10, 0, 28)
    messageLabel.Size = UDim2.new(1, -20, 0, 0)
    messageLabel.Text = config.Text or ""
    messageLabel.Parent = holder

    local closeButton = Instance.new("TextButton")
    closeButton.BackgroundTransparency = 1
    closeButton.Text = "X"
    closeButton.TextSize = 18
    closeButton.Font = Enum.Font.GothamBold
    closeButton.TextColor3 = THEME.SubText
    closeButton.Size = UDim2.new(0, 24, 0, 24)
    closeButton.Position = UDim2.new(1, -30, 0, 2)
    closeButton.Parent = holder

    holder.ClipsDescendants = true
    holder.Size = UDim2.new(1, -8, 0, 0)
    holder.Position = UDim2.new(0, 8, 0, -10)
    holder.BackgroundTransparency = 1
    messageLabel.TextTransparency = 1
    titleLabel.TextTransparency = 1

    tween(holder, {Position = UDim2.new(0, 8, 0, 0), BackgroundTransparency = 0}, 0.18, Enum.EasingStyle.Quart):Play()
    tween(titleLabel, {TextTransparency = 0}, 0.18):Play()
    tween(messageLabel, {TextTransparency = 0}, 0.18):Play()

    local dismissed = false

    local function dismiss()
        if dismissed then
            return
        end
        dismissed = true
        local fade = tween(holder, {Position = UDim2.new(0, 8, 0, -10), BackgroundTransparency = 1}, 0.15)
        tween(titleLabel, {TextTransparency = 1}, 0.15):Play()
        tween(messageLabel, {TextTransparency = 1}, 0.15):Play()
        fade.Completed:Wait()
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

function SorinUI:SetLoading(state, text)
    if self._destroyed or not self._loader then
        return
    end
    local shouldShow = state == true
    if text and self._loaderLabel then
        self._loaderLabel.Text = text
    end

    self._loader.Visible = shouldShow

    if self._spinnerConnection then
        self._spinnerConnection:Disconnect()
        self._spinnerConnection = nil
    end

    if shouldShow and self._spinnerImage then
        self._spinnerImage.Rotation = 0
        self._spinnerConnection = RunService.RenderStepped:Connect(function(dt)
            if self._spinnerImage then
                self._spinnerImage.Rotation = (self._spinnerImage.Rotation + 200 * dt) % 360
            end
        end)
    end
end

function SorinUI:Destroy()
    if self._destroyed then
        return
    end
    self._destroyed = true
    if self._spinnerConnection then
        self._spinnerConnection:Disconnect()
        self._spinnerConnection = nil
    end
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
