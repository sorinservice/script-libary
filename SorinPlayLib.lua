-- lib/SorinPlaysLib.lua
-- SorinPlaysForYou UI Library (v1)
-- Glassy, draggable window with sidebar tabs, elements, song modal, persistence and a simple player adapter.
-- Author: EndOfCircuit for Wyatt (SorinSoftware Services)

local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting         = game:GetService("Lighting")
local HttpService      = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

local SorinUI = {}
SorinUI.__index = SorinUI

-- =========================
-- Theme
-- =========================
local Theme = {
  Background   = Color3.fromRGB(22, 22, 28),
  Header       = Color3.fromRGB(28, 28, 36),
  Accent       = Color3.fromRGB(145, 105, 255),
  Button       = Color3.fromRGB(44, 44, 56),
  Hover        = Color3.fromRGB(80, 80, 120),
  Text         = Color3.fromRGB(235, 235, 245),
  SubText      = Color3.fromRGB(170, 170, 200),
  Stroke       = Color3.fromRGB(255, 255, 255),
  Shadow       = Color3.fromRGB(0, 0, 0),
  Content      = Color3.fromRGB(16, 16, 22),
}

-- =========================
-- Utils
-- =========================
local function tween(i, t, props, style, dir)
  return TweenService:Create(i, TweenInfo.new(t or 0.22, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props)
end

local function makeShadow(parent, radius, opacity)
  local shadow = Instance.new("ImageLabel")
  shadow.Name = "Shadow"
  shadow.BackgroundTransparency = 1
  shadow.Image = "rbxassetid://5028857084"
  shadow.ScaleType = Enum.ScaleType.Slice
  shadow.SliceCenter = Rect.new(24,24,276,276)
  shadow.ImageColor3 = Theme.Shadow
  shadow.ImageTransparency = 1 - (opacity or 0.22)
  shadow.Size = UDim2.new(1, radius or 24, 1, radius or 24)
  shadow.Position = UDim2.new(0, -((radius or 24)/2), 0, -((radius or 24)/2))
  shadow.ZIndex = 0
  shadow.Parent = parent
  return shadow
end

local function glassify(frame, cornerRadius)
  local stroke = Instance.new("UIStroke")
  stroke.Color = Theme.Stroke
  stroke.Thickness = 1
  stroke.Transparency = 0.75
  stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
  stroke.Parent = frame

  local uiCorner = Instance.new("UICorner")
  uiCorner.CornerRadius = UDim.new(0, cornerRadius or 10)
  uiCorner.Parent = frame

  frame.BackgroundTransparency = 0.18
end

local function create(class, props, parent)
  local obj = Instance.new(class)
  for k,v in pairs(props) do obj[k] = v end
  if parent then obj.Parent = parent end
  return obj
end

-- FS helpers for persistence (favourites)
local function safe_readfile(path)
  local ok, data = pcall(function()
    if isfile and isfile(path) then return readfile(path) end
  end)
  if ok and type(data) == "string" then return data end
  return nil
end

local function safe_writefile(path, data)
  pcall(function()
    if writefile then writefile(path, data) end
  end)
end

-- =========================
-- Public: setup/override theme
-- =========================
function SorinUI:Setup(overrides)
  if typeof(overrides) ~= "table" then return end
  for k,v in pairs(overrides) do if Theme[k] ~= nil then Theme[k] = v end end
end

-- =========================
-- Intro / Loading overlay (optional)
-- =========================
function SorinUI:Intro(text, duration)
  duration = duration or 1.6
  text = text or "Loading SorinPlaysForYou…"

  local gui = create("ScreenGui", {Name="SorinIntro", IgnoreGuiInset=true, ResetOnSpawn=false}, LocalPlayer:WaitForChild("PlayerGui"))

  local overlay = create("Frame", {
    Size = UDim2.new(1,0,1,0),
    BackgroundColor3 = Theme.Background,
    BackgroundTransparency = 0.3,
    BorderSizePixel = 0
  }, gui)
  makeShadow(overlay, 80, 0.18)

  local blur = Instance.new("BlurEffect")
  blur.Name = "SorinIntroBlur"
  blur.Size = 0
  blur.Parent = Lighting
  tween(blur, 0.28, {Size = 12}):Play()

  local box = create("Frame", {
    AnchorPoint = Vector2.new(0.5,0.5),
    Position = UDim2.new(0.5,0,0.5,0),
    Size = UDim2.new(0, 520, 0, 110),
    BackgroundColor3 = Theme.Header,
    BorderSizePixel = 0
  }, overlay)
  glassify(box); makeShadow(box, 36, 0.23)

  local spinner = create("ImageLabel", {
    AnchorPoint = Vector2.new(0,0.5),
    Position = UDim2.new(0, 20, 0.5, 0),
    Size = UDim2.new(0, 42, 0, 42),
    BackgroundTransparency = 1,
    Image = "rbxassetid://3926307971",
    ImageRectOffset = Vector2.new(628, 420),
    ImageRectSize = Vector2.new(36, 36),
    ImageColor3 = Theme.Accent
  }, box)

  local title = create("TextLabel", {
    AnchorPoint = Vector2.new(0,0.5),
    Position = UDim2.new(0, 80, 0.5, -10),
    Size = UDim2.new(1, -100, 0, 30),
    BackgroundTransparency = 1,
    Text = text,
    TextColor3 = Theme.Text,
    Font = Enum.Font.GothamBold,
    TextScaled = true
  }, box)

  local sub = create("TextLabel", {
    AnchorPoint = Vector2.new(0,0.5),
    Position = UDim2.new(0, 80, 0.5, 18),
    Size = UDim2.new(1, -100, 0, 20),
    BackgroundTransparency = 1,
    Text = "Please wait…",
    TextColor3 = Theme.SubText,
    Font = Enum.Font.Gotham,
    TextScaled = true
  }, box)

  -- simple rotator
  task.spawn(function()
    while spinner.Parent do
      spinner.Rotation += 10
      task.wait(0.03)
    end
  end)

  task.wait(duration)

  tween(box, 0.22, {BackgroundTransparency = 1}):Play()
  tween(title, 0.22, {TextTransparency = 1}):Play()
  tween(sub, 0.22, {TextTransparency = 1}):Play()
  tween(overlay, 0.22, {BackgroundTransparency = 1}):Play()
  task.wait(0.24)
  pcall(function() if blur.Parent == Lighting then blur:Destroy() end end)
  gui:Destroy()
end

-- =========================
-- Window / Tabs
-- =========================
function SorinUI:CreateWindow(cfg)
  cfg = cfg or {}
  local Title    = cfg.Title    or "SorinPlaysForYou"
  local Subtitle = cfg.Subtitle or "made by EndOfCircuit"

  -- enforce single instance
  local prior = game.CoreGui:FindFirstChild("SorinPlaysUI")
  if prior then prior:Destroy() end

  local gui = create("ScreenGui", {
    Name = "SorinPlaysUI",
    IgnoreGuiInset = true,
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling
  }, LocalPlayer:WaitForChild("PlayerGui"))

  local frame = create("Frame", {
    Size = UDim2.new(0, 820, 0, 480),
    Position = UDim2.new(0.5, -410, 0.5, -240),
    BackgroundColor3 = Theme.Background,
    BorderSizePixel = 0,
    BackgroundTransparency = 0.14,
    Active = true,
  }, gui)
  glassify(frame); makeShadow(frame, 30, 0.22)

  -- Topbar (draggable)
  local top = create("Frame", {
    Size = UDim2.new(1, 0, 0, 64),
    BackgroundColor3 = Theme.Header,
    BorderSizePixel = 0
  }, frame)
  glassify(top)

  local titleLbl = create("TextLabel", {
    Size = UDim2.new(1, -60, 0, 30),
    Position = UDim2.new(0, 16, 0, 8),
    BackgroundTransparency = 1,
    Text = Title,
    TextColor3 = Theme.Text,
    Font = Enum.Font.GothamBold,
    TextSize = 20,
    TextXAlignment = Enum.TextXAlignment.Left
  }, top)

  local subLbl = create("TextLabel", {
    Size = UDim2.new(1, -60, 0, 22),
    Position = UDim2.new(0, 16, 0, 36),
    BackgroundTransparency = 1,
    Text = Subtitle,
    TextColor3 = Theme.Accent,
    Font = Enum.Font.Gotham,
    TextSize = 16,
    TextXAlignment = Enum.TextXAlignment.Left
  }, top)

  local closeBtn = create("ImageButton", {
    Size = UDim2.new(0, 28, 0, 28),
    Position = UDim2.new(1, -36, 0, 18),
    BackgroundTransparency = 1,
    Image = "rbxassetid://3926305904",
    ImageRectOffset = Vector2.new(924, 724),
    ImageRectSize = Vector2.new(36, 36),
    ImageColor3 = Theme.Text
  }, top)
  closeBtn.MouseEnter:Connect(function() tween(closeBtn, 0.1, {ImageColor3 = Theme.Accent}):Play() end)
  closeBtn.MouseLeave:Connect(function() tween(closeBtn, 0.1, {ImageColor3 = Theme.Text}):Play() end)
  closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)

  -- Sidebar
  local sidebar = create("Frame", {
    Size = UDim2.new(0, 180, 1, -64),
    Position = UDim2.new(0, 0, 0, 64),
    BackgroundColor3 = Theme.Header,
    BorderSizePixel = 0
  }, frame)
  glassify(sidebar)

  local tabList = create("ScrollingFrame", {
    Size = UDim2.new(1, 0, 1, 0),
    CanvasSize = UDim2.new(0,0,0,0),
    BackgroundTransparency = 1,
    ScrollBarThickness = 6
  }, sidebar)
  local tabLayout = create("UIListLayout", {
    SortOrder = Enum.SortOrder.LayoutOrder,
    Padding = UDim.new(0, 6)
  }, tabList)

  -- Content area
  local content = create("Frame", {
    Size = UDim2.new(1, -180, 1, -64),
    Position = UDim2.new(0, 180, 0, 64),
    BackgroundColor3 = Theme.Content,
    BorderSizePixel = 0
  }, frame)
  glassify(content)

  local pages = create("Folder", {Name = "Pages"}, content)

  -- Make header draggable (robust, no Draggable property)
  do
    local dragging, dragStart, startPos
    top.InputBegan:Connect(function(input)
      if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
        input.Changed:Connect(function()
          if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
      end
    end)
    top.InputChanged:Connect(function(input)
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
    _top = top,
    _sidebar = sidebar,
    _tabList = tabList,
    _tabLayout = tabLayout,
    _content = content,
    _pages = pages,
    _tabs = {},
    _currentPage = nil,
    _favPath = "spfavourites.json",
  }, SorinUI)

  return self
end

-- =========================
-- Tabs
-- =========================
function SorinUI:CreateTab(name)
  local btn = create("TextButton", {
    Size = UDim2.new(1, -12, 0, 36),
    BackgroundColor3 = Theme.Button,
    TextColor3 = Theme.Text,
    Font = Enum.Font.GothamBold,
    TextSize = 15,
    Text = name,
    BorderSizePixel = 0
  }, self._tabList)
  glassify(btn)

  btn.MouseEnter:Connect(function() tween(btn, 0.12, {BackgroundColor3 = Theme.Hover}):Play() end)
  btn.MouseLeave:Connect(function() tween(btn, 0.12, {BackgroundColor3 = Theme.Button}):Play() end)

  local page = create("Frame", {
    Size = UDim2.new(1, -16, 1, -16),
    Position = UDim2.new(0, 8, 0, 8),
    BackgroundTransparency = 1,
    Visible = false,
    ClipsDescendants = false
  }, self._content)

  btn.MouseButton1Click:Connect(function()
    if self._currentPage then self._currentPage.Visible = false end
    page.Visible = true
    self._currentPage = page
  end)

  -- auto-layout inside page
  local layout = create("UIListLayout", {
    SortOrder = Enum.SortOrder.LayoutOrder,
    Padding = UDim.new(0, 8)
  }, page)

  self._tabs[name] = { Button = btn, Page = page, Layout = layout }
  -- show first tab by default
  if not self._currentPage then btn:MouseButton1Click() end

  -- adjust canvas size
  task.defer(function()
    local y = 0
    for _,child in ipairs(self._tabList:GetChildren()) do
      if child:IsA("GuiObject") and child.Visible then y = y + child.AbsoluteSize.Y + 6 end
    end
    self._tabList.CanvasSize = UDim2.new(0,0,0, y)
  end)

  return page
end

-- =========================
-- Element API
-- =========================
function SorinUI:AddSection(page, title)
  local holder = create("Frame", {Size = UDim2.new(1, 0, 0, 34), BackgroundColor3 = Theme.Header, BorderSizePixel = 0}, page)
  glassify(holder)
  create("TextLabel", {
    Size = UDim2.new(1, -12, 1, 0),
    Position = UDim2.new(0, 12, 0, 0),
    BackgroundTransparency = 1,
    Text = title or "",
    TextColor3 = Theme.Text,
    Font = Enum.Font.GothamBold,
    TextSize = 16,
    TextXAlignment = Enum.TextXAlignment.Left
  }, holder)
  return holder
end

function SorinUI:AddLabel(page, text)
  return create("TextLabel", {
    Size = UDim2.new(1, 0, 0, 24),
    BackgroundTransparency = 1,
    Text = text or "",
    TextColor3 = Theme.SubText,
    Font = Enum.Font.Gotham,
    TextSize = 14,
    TextXAlignment = Enum.TextXAlignment.Left
  }, page)
end

function SorinUI:AddButton(page, text, callback)
  local btn = create("TextButton", {
    Size = UDim2.new(1, 0, 0, 34),
    BackgroundColor3 = Theme.Button,
    TextColor3 = Theme.Text,
    Font = Enum.Font.GothamBold,
    TextSize = 15,
    Text = text or "Button",
    BorderSizePixel = 0
  }, page)
  glassify(btn)
  btn.MouseEnter:Connect(function() tween(btn, 0.12, {BackgroundColor3 = Theme.Hover}):Play() end)
  btn.MouseLeave:Connect(function() tween(btn, 0.12, {BackgroundColor3 = Theme.Button}):Play() end)
  if typeof(callback) == "function" then btn.MouseButton1Click:Connect(callback) end
  return btn
end

function SorinUI:AddInput(page, placeholder, onSubmit, defaultText)
  local box = create("TextBox", {
    Size = UDim2.new(1, 0, 0, 34),
    PlaceholderText = placeholder or "Enter text…",
    Text = defaultText or "",
    ClearTextOnFocus = false,
    TextColor3 = Theme.Text,
    PlaceholderColor3 = Theme.SubText,
    Font = Enum.Font.Gotham,
    TextSize = 14,
    BackgroundColor3 = Theme.Button,
    BorderSizePixel = 0
  }, page)
  glassify(box); makeShadow(box, 8, 0.12)
  if typeof(onSubmit) == "function" then
    box.FocusLost:Connect(function(enterPressed)
      if enterPressed then onSubmit(box.Text) end
    end)
  end
  return box
end

function SorinUI:AddToggle(page, label, default, onToggle)
  local holder = create("Frame", {Size = UDim2.new(1, 0, 0, 34), BackgroundColor3 = Theme.Button, BorderSizePixel = 0}, page)
  glassify(holder)
  local txt = create("TextLabel", {
    Size = UDim2.new(1, -60, 1, 0), Position = UDim2.new(0, 12, 0, 0),
    BackgroundTransparency = 1, Text = label or "Toggle",
    TextColor3 = Theme.Text, Font = Enum.Font.Gotham, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left
  }, holder)
  local btn = create("TextButton", {
    Size = UDim2.new(0, 46, 0, 22), Position = UDim2.new(1, -58, 0.5, -11),
    BackgroundColor3 = default and Theme.Accent or Theme.Hover, Text="", BorderSizePixel=0
  }, holder)
  glassify(btn, 11)
  local state = not not default
  btn.MouseButton1Click:Connect(function()
    state = not state
    tween(btn, 0.12, {BackgroundColor3 = state and Theme.Accent or Theme.Hover}):Play()
    if typeof(onToggle) == "function" then onToggle(state) end
  end)
  return {Frame = holder, State = function() return state end}
end

function SorinUI:AddSlider(page, label, min, max, default, onChange)
  min, max = tonumber(min) or 0, tonumber(max) or 100
  local value = math.clamp(tonumber(default or min) or min, min, max)
  local holder = create("Frame", {Size = UDim2.new(1, 0, 0, 48), BackgroundTransparency=1}, page)
  local title = self:AddLabel(holder, (label or "Slider") .. "  ("..tostring(value)..")")
  title.Size = UDim2.new(1, 0, 0, 20)
  local bar = create("Frame", {Size=UDim2.new(1, 0, 0, 18), BackgroundColor3=Theme.Button, BorderSizePixel=0}, holder)
  glassify(bar, 9)
  local fill = create("Frame", {Size=UDim2.new((value-min)/(max-min), 0, 1, 0), BackgroundColor3=Theme.Accent, BorderSizePixel=0}, bar)
  glassify(fill, 9)

  local function setValue(v)
    value = math.clamp(math.floor(v + 0.5), min, max)
    fill.Size = UDim2.new((value-min)/(max-min), 0, 1, 0)
    title.Text = (label or "Slider") .. "  ("..tostring(value)..")"
    if typeof(onChange) == "function" then onChange(value) end
  end

  bar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
      local conn; conn = UserInputService.InputChanged:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseMovement then
          local rel = math.clamp((i.Position.X - bar.AbsolutePosition.X)/bar.AbsoluteSize.X, 0, 1)
          setValue(min + rel*(max-min))
        end
      end)
      local endConn; endConn = UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
          if conn then conn:Disconnect() end
          if endConn then endConn:Disconnect() end
        end
      end)
    end
  end)

  setValue(value)
  return {Frame = holder, Get = function() return value end, Set = setValue}
end

-- =========================
-- Persistence: Favourites
-- =========================
function SorinUI:LoadFavourites()
  local raw = safe_readfile(self._favPath)
  if not raw then return {} end
  local ok, data = pcall(function() return HttpService:JSONDecode(raw) end)
  if ok and typeof(data)=="table" then return data end
  return {}
end

function SorinUI:SaveFavourites(tbl)
  safe_writefile(self._favPath, HttpService:JSONEncode(tbl or {}))
end

-- =========================
-- Song Modal (Name, BPM, Error, Play/Pause/Stop, Fav)
-- =========================
-- playHandler signature: function(action, ctx)
--  action: "play"|"pause"|"stop"|"fav"
--  ctx: { name=..., bpm=..., error=..., file=..., fav=true/false }
function SorinUI:ShowSongModal(songCtx, playHandler)
  songCtx = songCtx or {}
  local name  = songCtx.name or "Unknown Song"
  local bpm   = tonumber(songCtx.bpm) or 120
  local err   = tonumber(songCtx.error or 0) or 0
  local fav   = not not songCtx.fav

  local modal = create("Frame", {Size=UDim2.new(1,0,1,0), BackgroundTransparency=1}, self._frame)
  modal.ZIndex = 70
  local overlay = create("TextButton", {
    Size=UDim2.new(1,0,1,0), BackgroundColor3=Theme.Background, BackgroundTransparency=0.35,
    Text="", BorderSizePixel=0, AutoButtonColor=false, ZIndex=70
  }, modal)

  local box = create("Frame", {
    AnchorPoint = Vector2.new(0.5,0.5), Position = UDim2.new(0.5,0,0.5,0),
    Size = UDim2.new(0, 420, 0, 240),
    BackgroundColor3 = Theme.Header, BorderSizePixel=0, ZIndex=71
  }, modal)
  glassify(box); makeShadow(box, 22, 0.22)

  local title = create("TextLabel", {
    Size=UDim2.new(1,-20,0,32), Position=UDim2.new(0,10,0,10),
    BackgroundTransparency=1, Text=name, TextColor3=Theme.Text, Font=Enum.Font.GothamBold, TextSize=18,
    TextXAlignment = Enum.TextXAlignment.Left, ZIndex=71
  }, box)

  -- BPM slider
  local bpmSlider = self:AddSlider(box, "BPM", 40, 240, bpm, function(v) bpm = v end)
  bpmSlider.Frame.ZIndex = 71
  -- Error slider (in milliseconds +/- jitter)
  local errSlider = self:AddSlider(box, "Error Margin (ms)", 0, 200, err, function(v) err = v end)
  errSlider.Frame.ZIndex = 71

  -- Buttons row
  local row = create("Frame", {Size=UDim2.new(1,-20,0,40), Position=UDim2.new(0,10,1,-50), BackgroundTransparency=1, ZIndex=71}, box)
  local layout = create("UIListLayout", {FillDirection=Enum.FillDirection.Horizontal, Padding=UDim.new(0,8)}, row)

  local function addSmall(text)
    local b = create("TextButton", {
      Size = UDim2.new(0.25, -6, 1, 0),
      BackgroundColor3=Theme.Button, TextColor3=Theme.Text, Font=Enum.Font.GothamBold, TextSize=14, Text=text, BorderSizePixel=0, ZIndex=71
    }, row)
    glassify(b)
    b.MouseEnter:Connect(function() tween(b,0.12,{BackgroundColor3=Theme.Hover}):Play() end)
    b.MouseLeave:Connect(function() tween(b,0.12,{BackgroundColor3=Theme.Button}):Play() end)
    return b
  end

  local playBtn  = addSmall("▶ Play")
  local pauseBtn = addSmall("⏸ Pause")
  local stopBtn  = addSmall("⏹ Stop")
  local favBtn   = addSmall(fav and "❤️ Unfavourite" or "♡ Favourite")

  playBtn.MouseButton1Click:Connect(function()
    if playHandler then playHandler("play", {name=name, bpm=bpm, error=err, file=songCtx.file, fav=fav}) end
  end)
  pauseBtn.MouseButton1Click:Connect(function()
    if playHandler then playHandler("pause", {name=name, bpm=bpm, error=err, file=songCtx.file, fav=fav}) end
  end)
  stopBtn.MouseButton1Click:Connect(function()
    if playHandler then playHandler("stop", {name=name, bpm=bpm, error=err, file=songCtx.file, fav=fav}) end
  end)
  favBtn.MouseButton1Click:Connect(function()
    fav = not fav
    favBtn.Text = fav and "❤️ Unfavourite" or "♡ Favourite"
    if playHandler then playHandler("fav", {name=name, bpm=bpm, error=err, file=songCtx.file, fav=fav}) end
  end)

  overlay.MouseButton1Click:Connect(function() modal:Destroy() end)

  -- small pop animation
  box.Size = UDim2.new(0, 420, 0, 200)
  tween(box, 0.18, {Size = UDim2.new(0, 420, 0, 240)}):Play()

  return {
    Close = function() modal:Destroy() end,
    SetBPM = function(v) bpmSlider.Set(v) end,
    SetError = function(v) errSlider.Set(v) end,
    GetCtx = function() return {name=name, bpm=bpm, error=err, fav=fav, file=songCtx.file} end
  }
end

-- =========================
-- Player Adapter
-- =========================
-- Runs a song file (string code) that expects keypress(key, x, bpm) & rest(t, bpm) & finishedSong()
-- We map bpm + jitter (error ms) by tweaking task.wait durations.
function SorinUI:CreatePlayer()
  local currentThread = nil
  local paused = false
  local stopFlag = false

  local function ms_to_wait(ms) return math.max(0, (ms or 0) / 1000) end

  local api = {}

  function api:Play(songCode, bpm, errorMs, onFinished, onStep)
    self:Stop()
    paused, stopFlag = false, false

    currentThread = task.spawn(function()
      local env = {}
      setmetatable(env, {__index = getfenv()})

      local function waitBeat(seconds)
        -- seconds is from rest() or derived; add jitter
        local jitter = 0
        if errorMs and errorMs > 0 then
          local r = (math.random() * (errorMs*2)) - errorMs -- -err .. +err
          jitter = ms_to_wait(r)
        end
        local total = (seconds or 0) + jitter
        local t0 = os.clock()
        while os.clock() - t0 < total do
          if stopFlag then return false end
          while paused do task.wait(0.05) end
          task.wait(0.01)
        end
        return true
      end

      env.keypress = function(key, x, bpmArg)
        if stopFlag then return end
        if typeof(onStep)=="function" then
          pcall(onStep, "keypress", key, x, bpmArg)
        end
        -- NOTE: Hier würdest du deine tatsächliche Key-Emit-Logik einhängen (Virtual Input / Executor API)
        -- Placeholder: kleine wait, damit es nicht „instant“ durchrennt.
        task.wait(0.0)
      end

      env.rest = function(beatsOrSeconds, bpmArg)
        if stopFlag then return end
        local beats = tonumber(beatsOrSeconds) or 0
        local bpmUse = tonumber(bpm or bpmArg or 120)
        local seconds = (beats > 0 and (beats * 60 / bpmUse)) or tonumber(beatsOrSeconds) or 0
        return waitBeat(seconds)
      end

      env.finishedSong = function()
        if typeof(onFinished)=="function" then pcall(onFinished) end
      end

      local fn, err = loadstring(songCode)
      if not fn then warn("Song compile error: ", err) return end
      setfenv(fn, env)

      local ok, runErr = pcall(fn)
      if not ok then warn("Song runtime error: ", runErr) end
    end)
  end

  function api:Pause() paused = true end
  function api:Resume() paused = false end
  function api:Stop() stopFlag = true end

  return api
end

return SorinUI
