-- SorinCoreInterface.lua
-- Simple UI framework for "Sorin Core Hub"
-- Provides: CreateWindow, tabs, buttons, toggles, notifications

local SorinCoreInterface = {}
SorinCoreInterface.__index = SorinCoreInterface

---------------------------------------------------------------------
-- Services
---------------------------------------------------------------------

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer

---------------------------------------------------------------------
-- Utility
---------------------------------------------------------------------

local function safeParentGui(gui)
    local ok, coreGui = pcall(function()
        return game:GetService("CoreGui")
    end)
    if ok and coreGui then
        gui.Parent = coreGui
        return
    end

    if LocalPlayer and LocalPlayer:FindFirstChildOfClass("PlayerGui") then
        gui.Parent = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    end
end

local function createRound(instance, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 6)
    corner.Parent = instance
    return corner
end

local function tween(instance, info, props)
    local ok, tw = pcall(TweenService.Create, TweenService, instance, info, props)
    if ok and tw then
        tw:Play()
    else
        for k, v in pairs(props) do
            instance[k] = v
        end
    end
end

---------------------------------------------------------------------
-- Theme
---------------------------------------------------------------------

local Theme = {
    Background = Color3.fromRGB(20, 20, 24),
    Accent = Color3.fromRGB(85, 170, 255),
    AccentSoft = Color3.fromRGB(40, 80, 120),
    Border = Color3.fromRGB(40, 40, 48),
    Text = Color3.fromRGB(235, 235, 240),
    TextDim = Color3.fromRGB(170, 170, 180),
    Section = Color3.fromRGB(28, 28, 34),
    Button = Color3.fromRGB(36, 36, 44),
    ButtonHover = Color3.fromRGB(50, 50, 60),
    ToggleOn = Color3.fromRGB(90, 190, 120),
    ToggleOff = Color3.fromRGB(80, 80, 90),
    NotificationInfo = Color3.fromRGB(60, 130, 200),
    NotificationSuccess = Color3.fromRGB(70, 180, 120),
    NotificationWarning = Color3.fromRGB(200, 160, 60),
    NotificationError = Color3.fromRGB(200, 70, 70),
}

---------------------------------------------------------------------
-- Core GUI bootstrap
---------------------------------------------------------------------

local screenGui
local notificationHolder

local function ensureScreenGui()
    if screenGui and screenGui.Parent then
        return screenGui, notificationHolder
    end

    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SorinCoreInterface"
    screenGui.IgnoreGuiInset = true
    screenGui.ResetOnSpawn = false

    safeParentGui(screenGui)

    notificationHolder = Instance.new("Frame")
    notificationHolder.Name = "Notifications"
    notificationHolder.AnchorPoint = Vector2.new(1, 0)
    notificationHolder.Position = UDim2.new(1, -16, 0, 16)
    notificationHolder.Size = UDim2.new(0, 280, 1, -32)
    notificationHolder.BackgroundTransparency = 1
    notificationHolder.ClipsDescendants = false
    notificationHolder.Parent = screenGui

    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    layout.VerticalAlignment = Enum.VerticalAlignment.Top
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 6)
    layout.Parent = notificationHolder

    return screenGui, notificationHolder
end

---------------------------------------------------------------------
-- Notifications
---------------------------------------------------------------------

local function pickNotificationColor(kind)
    kind = string.lower(kind or "info")
    if kind == "success" or kind == "ok" or kind == "check" then
        return Theme.NotificationSuccess
    elseif kind == "warn" or kind == "warning" or kind == "alert" then
        return Theme.NotificationWarning
    elseif kind == "error" or kind == "fail" or kind == "danger" then
        return Theme.NotificationError
    else
        return Theme.NotificationInfo
    end
end

function SorinCoreInterface:Notify(opts)
    local _, holder = ensureScreenGui()
    if not holder then
        return
    end

    opts = opts or {}
    local title = tostring(opts.Title or "Notification")
    local content = tostring(opts.Content or "")
    local kind = opts.Type or opts.Kind or "info"
    local duration = tonumber(opts.Duration) or 3

    local frame = Instance.new("Frame")
    frame.Name = "Toast"
    frame.BackgroundColor3 = Theme.Section
    frame.BorderSizePixel = 0
    frame.Size = UDim2.new(1, 0, 0, content ~= "" and 70 or 40)
    frame.BackgroundTransparency = 0.1
    frame.ClipsDescendants = true
    frame.Parent = holder
    createRound(frame, 6)

    local accent = Instance.new("Frame")
    accent.Name = "Accent"
    accent.BackgroundColor3 = pickNotificationColor(kind)
    accent.BorderSizePixel = 0
    accent.Size = UDim2.new(0, 3, 1, 0)
    accent.Position = UDim2.new(0, 0, 0, 0)
    accent.Parent = frame

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.BackgroundTransparency = 1
    titleLabel.Position = UDim2.new(0, 10, 0, 6)
    titleLabel.Size = UDim2.new(1, -20, 0, 18)
    titleLabel.Font = Enum.Font.GothamSemibold
    titleLabel.TextSize = 14
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.TextColor3 = Theme.Text
    titleLabel.Text = title
    titleLabel.Parent = frame

    if content ~= "" then
        local bodyLabel = Instance.new("TextLabel")
        bodyLabel.Name = "Body"
        bodyLabel.BackgroundTransparency = 1
        bodyLabel.Position = UDim2.new(0, 10, 0, 24)
        bodyLabel.Size = UDim2.new(1, -20, 1, -30)
        bodyLabel.Font = Enum.Font.Gotham
        bodyLabel.TextSize = 13
        bodyLabel.TextXAlignment = Enum.TextXAlignment.Left
        bodyLabel.TextYAlignment = Enum.TextYAlignment.Top
        bodyLabel.TextWrapped = true
        bodyLabel.TextColor3 = Theme.TextDim
        bodyLabel.Text = content
        bodyLabel.Parent = frame
    end

    frame.BackgroundTransparency = 1
    frame.Position = UDim2.new(1, 20, 0, 0)

    tween(frame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0.1,
        Position = UDim2.new(0, 0, 0, 0),
    })

    task.delay(duration, function()
        if not frame.Parent then
            return
        end
        tween(frame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            BackgroundTransparency = 1,
            Position = UDim2.new(1, 20, 0, 0),
        })
        task.delay(0.25, function()
            pcall(function()
                frame:Destroy()
            end)
        end)
    end)
end

---------------------------------------------------------------------
-- Window / Tab classes
---------------------------------------------------------------------

local WindowClass = {}
WindowClass.__index = WindowClass

local TabClass = {}
TabClass.__index = TabClass

---------------------------------------------------------------------
-- Window: constructor
---------------------------------------------------------------------

function SorinCoreInterface:CreateWindow(opts)
    ensureScreenGui()

    opts = opts or {}
    local name = tostring(opts.Name or "Sorin Core Hub")
    local subtitle = tostring(opts.Subtitle or "SorinSoftware Services")
    local toggleKey = opts.ToggleKey or Enum.KeyCode.K

    -- root window frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainWindow"
    mainFrame.Size = UDim2.new(0, 620, 0, 360)
    mainFrame.Position = UDim2.new(0.5, -310, 0.5, -180)
    mainFrame.BackgroundColor3 = Theme.Background
    mainFrame.BorderColor3 = Theme.Border
    mainFrame.BorderSizePixel = 1
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Parent = screenGui
    createRound(mainFrame, 8)

    -- top bar
    local topBar = Instance.new("Frame")
    topBar.Name = "TopBar"
    topBar.BackgroundColor3 = Theme.Section
    topBar.BorderSizePixel = 0
    topBar.Size = UDim2.new(1, 0, 0, 32)
    topBar.Parent = mainFrame
    createRound(topBar, 8)

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.BackgroundTransparency = 1
    titleLabel.Position = UDim2.new(0, 12, 0, 0)
    titleLabel.Size = UDim2.new(1, -120, 1, 0)
    titleLabel.Font = Enum.Font.GothamSemibold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.TextSize = 15
    titleLabel.TextColor3 = Theme.Text
    titleLabel.Text = name
    titleLabel.Parent = topBar

    local subtitleLabel = Instance.new("TextLabel")
    subtitleLabel.Name = "Subtitle"
    subtitleLabel.BackgroundTransparency = 1
    subtitleLabel.Position = UDim2.new(0, 12, 0, 16)
    subtitleLabel.Size = UDim2.new(1, -120, 0, 14)
    subtitleLabel.Font = Enum.Font.Gotham
    subtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    subtitleLabel.TextSize = 12
    subtitleLabel.TextColor3 = Theme.TextDim
    subtitleLabel.Text = subtitle
    subtitleLabel.Parent = topBar

    -- close button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "Close"
    closeButton.BackgroundTransparency = 1
    closeButton.Position = UDim2.new(1, -28, 0, 0)
    closeButton.Size = UDim2.new(0, 28, 1, 0)
    closeButton.Font = Enum.Font.GothamSemibold
    closeButton.TextSize = 16
    closeButton.TextColor3 = Theme.TextDim
    closeButton.Text = "×"
    closeButton.Parent = topBar

    -- left tab bar
    local tabBar = Instance.new("Frame")
    tabBar.Name = "TabBar"
    tabBar.BackgroundColor3 = Theme.Section
    tabBar.BorderSizePixel = 0
    tabBar.Position = UDim2.new(0, 0, 0, 32)
    tabBar.Size = UDim2.new(0, 160, 1, -32)
    tabBar.Parent = mainFrame

    local tabList = Instance.new("UIListLayout")
    tabList.FillDirection = Enum.FillDirection.Vertical
    tabList.SortOrder = Enum.SortOrder.LayoutOrder
    tabList.Padding = UDim.new(0, 4)
    tabList.Parent = tabBar

    local tabPadding = Instance.new("UIPadding")
    tabPadding.PaddingTop = UDim.new(0, 8)
    tabPadding.PaddingLeft = UDim.new(0, 8)
    tabPadding.PaddingRight = UDim.new(0, 8)
    tabPadding.Parent = tabBar

    -- content container
    local contentFrame = Instance.new("Frame")
    contentFrame.Name = "Content"
    contentFrame.BackgroundColor3 = Theme.Background
    contentFrame.BorderSizePixel = 0
    contentFrame.Position = UDim2.new(0, 160, 0, 32)
    contentFrame.Size = UDim2.new(1, -160, 1, -32)
    contentFrame.Parent = mainFrame

    createRound(contentFrame, 8)

    local window = setmetatable({
        _frame = mainFrame,
        _tabBar = tabBar,
        _content = contentFrame,
        _tabs = {},
        _activeTab = nil,
        _toggleConnection = nil,
        _toggleKey = toggleKey,
    }, WindowClass)

    -- visibility toggle via key
    if toggleKey then
        window._toggleConnection = UserInputService.InputBegan:Connect(function(input, gp)
            if gp then
                return
            end
            if input.KeyCode == toggleKey then
                window:SetVisible(not window:GetVisible())
            end
        end)
    end

    closeButton.MouseButton1Click:Connect(function()
        window:SetVisible(false)
    end)

    return window
end

---------------------------------------------------------------------
-- Window methods
---------------------------------------------------------------------

function WindowClass:SetVisible(state)
    state = state and true or false
    if not self._frame then
        return
    end
    self._frame.Visible = state
end

function WindowClass:GetVisible()
    return self._frame and self._frame.Visible or false
end

function WindowClass:Destroy()
    if self._toggleConnection then
        self._toggleConnection:Disconnect()
        self._toggleConnection = nil
    end
    if self._frame then
        self._frame:Destroy()
        self._frame = nil
    end
end

function WindowClass:CreateTab(opts)
    opts = opts or {}
    local name = tostring(opts.Name or "Tab")

    local tabButton = Instance.new("TextButton")
    tabButton.Name = "TabButton_" .. name
    tabButton.BackgroundColor3 = Theme.Button
    tabButton.BorderSizePixel = 0
    tabButton.Size = UDim2.new(1, 0, 0, 28)
    tabButton.AutoButtonColor = false
    tabButton.Font = Enum.Font.Gotham
    tabButton.TextSize = 13
    tabButton.TextColor3 = Theme.TextDim
    tabButton.TextXAlignment = Enum.TextXAlignment.Left
    tabButton.Text = "  " .. name
    tabButton.Parent = self._tabBar
    createRound(tabButton, 6)

    local content = Instance.new("ScrollingFrame")
    content.Name = "TabContent_" .. name
    content.BackgroundColor3 = Theme.Background
    content.BorderSizePixel = 0
    content.Position = UDim2.new(0, 8, 0, 8)
    content.Size = UDim2.new(1, -16, 1, -16)
    content.ScrollBarThickness = 4
    content.CanvasSize = UDim2.new(0, 0, 0, 0)
    content.ScrollBarImageColor3 = Theme.AccentSoft
    content.Visible = false
    content.Parent = self._content

    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 6)
    layout.Parent = content

    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 6)
    padding.PaddingLeft = UDim.new(0, 6)
    padding.PaddingRight = UDim.new(0, 6)
    padding.Parent = content

    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        content.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 8)
    end)

    local tab = setmetatable({
        _window = self,
        _button = tabButton,
        _content = content,
        _name = name,
    }, TabClass)

    table.insert(self._tabs, tab)

    local function activate()
        for _, t in ipairs(self._tabs) do
            local isActive = (t == tab)
            t._content.Visible = isActive
            if isActive then
                t._button.BackgroundColor3 = Theme.AccentSoft
                t._button.TextColor3 = Theme.Text
            else
                t._button.BackgroundColor3 = Theme.Button
                t._button.TextColor3 = Theme.TextDim
            end
        end
        self._activeTab = tab
    end

    tabButton.MouseEnter:Connect(function()
        if self._activeTab ~= tab then
            tween(tabButton, TweenInfo.new(0.15), { BackgroundColor3 = Theme.ButtonHover })
        end
    end)

    tabButton.MouseLeave:Connect(function()
        if self._activeTab ~= tab then
            tween(tabButton, TweenInfo.new(0.15), { BackgroundColor3 = Theme.Button })
        end
    end)

    tabButton.MouseButton1Click:Connect(activate)

    if not self._activeTab then
        activate()
    end

    return tab
end

---------------------------------------------------------------------
-- Tab methods: sections / controls
---------------------------------------------------------------------

function TabClass:CreateSection(title)
    title = tostring(title or "")

    local frame = Instance.new("Frame")
    frame.Name = "Section_" .. title
    frame.BackgroundColor3 = Theme.Section
    frame.BorderSizePixel = 0
    frame.Size = UDim2.new(1, 0, 0, 30)
    frame.Parent = self._content
    createRound(frame, 6)

    local label = Instance.new("TextLabel")
    label.Name = "Title"
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, 10, 0, 0)
    label.Size = UDim2.new(1, -20, 1, 0)
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextColor3 = Theme.Text
    label.Text = title
    label.Parent = frame

    return frame
end

function TabClass:CreateButton(opts)
    opts = opts or {}
    local name = tostring(opts.Name or "Button")
    local description = opts.Description and tostring(opts.Description) or ""
    local callback = typeof(opts.Callback) == "function" and opts.Callback or nil

    local height = description ~= "" and 54 or 32

    local frame = Instance.new("Frame")
    frame.Name = "Button_" .. name
    frame.BackgroundColor3 = Theme.Button
    frame.BorderSizePixel = 0
    frame.Size = UDim2.new(1, 0, 0, height)
    frame.Parent = self._content
    createRound(frame, 6)

    local button = Instance.new("TextButton")
    button.Name = "Hitbox"
    button.BackgroundTransparency = 1
    button.Size = UDim2.new(1, 0, 1, 0)
    button.Font = Enum.Font.Gotham
    button.Text = ""
    button.Parent = frame

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.BackgroundTransparency = 1
    titleLabel.Position = UDim2.new(0, 10, 0, 4)
    titleLabel.Size = UDim2.new(1, -20, 0, 18)
    titleLabel.Font = Enum.Font.GothamSemibold
    titleLabel.TextSize = 14
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.TextColor3 = Theme.Text
    titleLabel.Text = name
    titleLabel.Parent = frame

    if description ~= "" then
        local descLabel = Instance.new("TextLabel")
        descLabel.Name = "Description"
        descLabel.BackgroundTransparency = 1
        descLabel.Position = UDim2.new(0, 10, 0, 22)
        descLabel.Size = UDim2.new(1, -20, 0, 18)
        descLabel.Font = Enum.Font.Gotham
        descLabel.TextSize = 12
        descLabel.TextXAlignment = Enum.TextXAlignment.Left
        descLabel.TextColor3 = Theme.TextDim
        descLabel.Text = description
        descLabel.Parent = frame
    end

    button.MouseEnter:Connect(function()
        tween(frame, TweenInfo.new(0.12), { BackgroundColor3 = Theme.ButtonHover })
    end)

    button.MouseLeave:Connect(function()
        tween(frame, TweenInfo.new(0.12), { BackgroundColor3 = Theme.Button })
    end)

    button.MouseButton1Click:Connect(function()
        if callback then
            task.spawn(function()
                local ok, err = pcall(callback)
                if not ok then
                    SorinCoreInterface:Notify({
                        Title = name,
                        Content = "Callback error: " .. tostring(err),
                        Type = "error",
                    })
                end
            end)
        end
    end)

    return frame
end

function TabClass:CreateToggle(opts)
    opts = opts or {}
    local name = tostring(opts.Name or "Toggle")
    local description = opts.Description and tostring(opts.Description) or ""
    local callback = typeof(opts.Callback) == "function" and opts.Callback or nil
    local state = opts.CurrentValue == true or opts.Default == true

    local height = description ~= "" and 54 or 32

    local frame = Instance.new("Frame")
    frame.Name = "Toggle_" .. name
    frame.BackgroundColor3 = Theme.Button
    frame.BorderSizePixel = 0
    frame.Size = UDim2.new(1, 0, 0, height)
    frame.Parent = self._content
    createRound(frame, 6)

    local hitbox = Instance.new("TextButton")
    hitbox.Name = "Hitbox"
    hitbox.BackgroundTransparency = 1
    hitbox.Size = UDim2.new(1, 0, 1, 0)
    hitbox.Font = Enum.Font.Gotham
    hitbox.Text = ""
    hitbox.Parent = frame

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.BackgroundTransparency = 1
    titleLabel.Position = UDim2.new(0, 10, 0, 4)
    titleLabel.Size = UDim2.new(1, -80, 0, 18)
    titleLabel.Font = Enum.Font.GothamSemibold
    titleLabel.TextSize = 14
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.TextColor3 = Theme.Text
    titleLabel.Text = name
    titleLabel.Parent = frame

    if description ~= "" then
        local descLabel = Instance.new("TextLabel")
        descLabel.Name = "Description"
        descLabel.BackgroundTransparency = 1
        descLabel.Position = UDim2.new(0, 10, 0, 22)
        descLabel.Size = UDim2.new(1, -80, 0, 18)
        descLabel.Font = Enum.Font.Gotham
        descLabel.TextSize = 12
        descLabel.TextXAlignment = Enum.TextXAlignment.Left
        descLabel.TextColor3 = Theme.TextDim
        descLabel.Text = description
        descLabel.Parent = frame
    end

    local toggleFrame = Instance.new("Frame")
    toggleFrame.Name = "Switch"
    toggleFrame.BackgroundColor3 = Theme.ToggleOff
    toggleFrame.BorderSizePixel = 0
    toggleFrame.Size = UDim2.new(0, 40, 0, 18)
    toggleFrame.AnchorPoint = Vector2.new(1, 0.5)
    toggleFrame.Position = UDim2.new(1, -10, 0.5, 0)
    toggleFrame.Parent = frame
    createRound(toggleFrame, 9)

    local knob = Instance.new("Frame")
    knob.Name = "Knob"
    knob.BackgroundColor3 = Color3.new(1, 1, 1)
    knob.BorderSizePixel = 0
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.Position = UDim2.new(0, 9, 0.5, 0)
    knob.Parent = toggleFrame
    createRound(knob, 7)

    local function applyState(instant)
        local bgColor = state and Theme.ToggleOn or Theme.ToggleOff
        local xOffset = state and 31 or 9
        if instant then
            toggleFrame.BackgroundColor3 = bgColor
            knob.Position = UDim2.new(0, xOffset, 0.5, 0)
        else
            tween(toggleFrame, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                BackgroundColor3 = bgColor,
            })
            tween(knob, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Position = UDim2.new(0, xOffset, 0.5, 0),
            })
        end
    end

    applyState(true)

    local function setState(newState, fromUser)
        if state == newState then
            return
        end
        state = newState and true or false
        applyState(false)
        if callback and fromUser then
            task.spawn(function()
                local ok, err = pcall(callback, state)
                if not ok then
                    SorinCoreInterface:Notify({
                        Title = name,
                        Content = "Toggle error: " .. tostring(err),
                        Type = "error",
                    })
                end
            end)
        end
    end

    hitbox.MouseEnter:Connect(function()
        tween(frame, TweenInfo.new(0.12), { BackgroundColor3 = Theme.ButtonHover })
    end)

    hitbox.MouseLeave:Connect(function()
        tween(frame, TweenInfo.new(0.12), { BackgroundColor3 = Theme.Button })
    end)

    hitbox.MouseButton1Click:Connect(function()
        setState(not state, true)
    end)

    return {
        Frame = frame,
        Set = function(_, options)
            if options and typeof(options.CurrentValue) == "boolean" then
                setState(options.CurrentValue, false)
            end
        end,
        Get = function()
            return state
        end,
    }
end

---------------------------------------------------------------------
-- Public export
---------------------------------------------------------------------

return setmetatable(SorinCoreInterface, SorinCoreInterface)
