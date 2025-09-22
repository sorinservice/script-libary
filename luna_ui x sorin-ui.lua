--[[                                                                                                                                                   

Main Credits

Hunter | Designing And Programming | Main Developer
JustHey | Configurations, Bug Fixing And More! | Co Developer
Throit | Color Picker
Wally | Dragging And Certain Functions
Sirius | PCall Parsing, Notifications, Slider And Home Tab
Original UI Base

Extra Credits / Provided Certain Elements

Pookie Pepelss | Bug Tester
Inori | Configuration Concept
Latte Softworks and qweery | Lucide Icons And Material Icons
kirill9655 | Loading Circle
Deity/dp4pv/x64x70 | Certain Scripting and Testing ig

Contributors
iPigTw | Typo Fixer, Fixed Key System!!
pushByAccident | Fixing Executor Lists
ImFloriz | Method Fixing

SorinServices UI
by SorinServices

]]

local Release = "Prerelease Beta 0.1"

local SorinUI = { 
	Folder = "SorinHub", 
	Options = {}, 
	ThemeGradient = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(117, 164, 206)), ColorSequenceKeypoint.new(0.50, Color3.fromRGB(123, 201, 201)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(224, 138, 175))} 
}

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Localization = game:GetService("LocalizationService")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local CoreGui = game:GetService("CoreGui")

local isStudio
local website = "https://scripts.sorinservice.online"

if RunService:IsStudio() then
	isStudio = true
end

-- Credits To Latte Softworks And qweery for Lucide And Material Icons Respectively.
local IconModule = {
	Lucide = nil,
	Material = {
		["perm_media"] = "http://www.roblox.com/asset/?id=6031215982";
		["baby_changing_station"] = "http://www.roblox.com/asset/?id=6035107930";
		["fire_extinguisher"] = "http://www.roblox.com/asset/?id=6035121913";
		["sparkle"] = "http://www.roblox.com/asset/?id=4483362748"
	}
}

-- Other Variables
local request = (syn and syn.request) or (http and http.request) or http_request or nil
local tweeninfo = TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
local PresetGradients = {
	["Nightlight (Classic)"] = {Color3.fromRGB(147, 255, 239), Color3.fromRGB(201,211,233), Color3.fromRGB(255, 167, 227)},
	["Nightlight (Neo)"] = {Color3.fromRGB(117, 164, 206), Color3.fromRGB(123, 201, 201), Color3.fromRGB(224, 138, 175)},
	Starlight = {Color3.fromRGB(147, 255, 239), Color3.fromRGB(181, 206, 241), Color3.fromRGB(214, 158, 243)},
	Solar = {Color3.fromRGB(242, 157, 76), Color3.fromRGB(240, 179, 81), Color3.fromRGB(238, 201, 86)},
	Sparkle = {Color3.fromRGB(199, 130, 242), Color3.fromRGB(221, 130, 238), Color3.fromRGB(243, 129, 233)},
	Lime = {Color3.fromRGB(170, 255, 127), Color3.fromRGB(163, 220, 138), Color3.fromRGB(155, 185, 149)},
	Vine = {Color3.fromRGB(0, 191, 143), Color3.fromRGB(0, 126, 94), Color3.fromRGB(0, 61, 46)},
	Cherry = {Color3.fromRGB(148, 54, 54), Color3.fromRGB(168, 67, 70), Color3.fromRGB(188, 80, 86)},
	Daylight = {Color3.fromRGB(51, 156, 255), Color3.fromRGB(89, 171, 237), Color3.fromRGB(127, 186, 218)},
	Blossom = {Color3.fromRGB(255, 165, 243), Color3.fromRGB(213, 129, 231), Color3.fromRGB(170, 92, 218)},
}

local function GetIcon(icon, source)
	if source == "Custom" then
		return "rbxassetid://" .. icon
	elseif source == "Lucide" then
		-- full credit to latte softworks :)
		local iconData = not isStudio and game:HttpGet("https://raw.githubusercontent.com/latte-soft/lucide-roblox/refs/heads/master/lib/Icons.luau")
		local icons = isStudio and IconModule.Lucide or loadstring(iconData)()
		if not isStudio then
			icon = string.match(string.lower(icon), "^%s*(.*)%s*$") :: string
			local sizedicons = icons['48px']

			local r = sizedicons[icon]
			if not r then
				error("Lucide Icons: Failed to find icon by the name of \"" .. icon .. "\.", 2)
			end

			local rirs = r[2]
			local riro = r[3]

			if type(r[1]) ~= "number" or type(rirs) ~= "table" or type(riro) ~= "table" then
				error("Lucide Icons: Internal error: Invalid auto-generated asset entry")
			end

			local irs = Vector2.new(rirs[1], rirs[2])
			local iro = Vector2.new(riro[1], riro[2])

			local asset = {
				id = r[1],
				imageRectSize = irs,
				imageRectOffset = iro,
			}

			return asset
		else
			return "rbxassetid://10723434557"
		end
	else	
		if icon ~= nil and IconModule[source] then
			local sourceicon = IconModule[source]
			return sourceicon[icon]
		else
			return nil
		end
	end
end

local function RemoveTable(tablre, value)
	for i,v in pairs(tablre) do
		if tostring(v) == tostring(value) then
			table.remove(tablre, i)
		end
	end
end

local function Kwargify(defaults, passed)
	for i, v in pairs(defaults) do
		if passed[i] == nil then
			passed[i] = v
		end
	end
	return passed
end

local function PackColor(Color)
	return {R = Color.R * 255, G = Color.G * 255, B = Color.B * 255}
end    

local function UnpackColor(Color)
	return Color3.fromRGB(Color.R, Color.G, Color.B)
end

function tween(object, goal, callback, tweenin)
	local tween = TweenService:Create(object,tweenin or tweeninfo, goal)
	tween.Completed:Connect(callback or function() end)
	tween:Play()
end

local function BlurModule(Frame)
	local RunService = game:GetService('RunService')
	local camera = workspace.CurrentCamera
	local MTREL = "Glass"
	local binds = {}
	local root = Instance.new('Folder', camera)
	root.Name = 'SorinBlur'

	local gTokenMH = 99999999
	local gToken = math.random(1, gTokenMH)

	local DepthOfField = Instance.new('DepthOfFieldEffect', game:GetService('Lighting'))
	DepthOfField.FarIntensity = 0
	DepthOfField.FocusDistance = 51.6
	DepthOfField.InFocusRadius = 50
	DepthOfField.NearIntensity = 6
	DepthOfField.Name = "DPT_"..gToken

	local frame = Instance.new('Frame')
	frame.Parent = Frame
	frame.Size = UDim2.new(0.95, 0, 0.95, 0)
	frame.Position = UDim2.new(0.5, 0, 0.5, 0)
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.BackgroundTransparency = 1

	local GenUid; do -- Generate unique names for RenderStepped bindings
		local id = 0
		function GenUid()
			id = id + 1
			return 'neon::'..tostring(id)
		end
	end

	do
		local function IsNotNaN(x)
			return x == x
		end
		local continue = IsNotNaN(camera:ScreenPointToRay(0,0).Origin.x)
		while not continue do
			RunService.RenderStepped:wait()
			continue = IsNotNaN(camera:ScreenPointToRay(0,0).Origin.x)
		end
	end

	local DrawQuad; do

		local acos, max, pi, sqrt = math.acos, math.max, math.pi, math.sqrt
		local sz = 0.22
		local function DrawTriangle(v1, v2, v3, p0, p1) -- I think Stravant wrote this function

			local s1 = (v1 - v2).magnitude
			local s2 = (v2 - v3).magnitude
			local s3 = (v3 - v1).magnitude
			local smax = max(s1, s2, s3)
			local A, B, C
			if s1 == smax then
				A, B, C = v1, v2, v3
			elseif s2 == smax then
				A, B, C = v2, v3, v1
			elseif s3 == smax then
				A, B, C = v3, v1, v2
			end

			local para = ( (B-A).x*(C-A).x + (B-A).y*(C-A).y + (B-A).z*(C-A).z ) / (A-B).magnitude
			local perp = sqrt((C-A).magnitude^2 - para*para)
			local dif_para = (A - B).magnitude - para

			local st = CFrame.new(B, A)
			local za = CFrame.Angles(pi/2,0,0)

			local cf0 = st

			local Top_Look = (cf0 * za).lookVector
			local Mid_Point = A + CFrame.new(A, B).lookVector * para
			local Needed_Look = CFrame.new(Mid_Point, C).lookVector
			local dot = Top_Look.x*Needed_Look.x + Top_Look.y*Needed_Look.y + Top_Look.z*Needed_Look.z

			local ac = CFrame.Angles(0, 0, acos(dot))

			cf0 = cf0 * ac
			if ((cf0 * za).lookVector - Needed_Look).magnitude > 0.01 then
				cf0 = cf0 * CFrame.Angles(0, 0, -2*acos(dot))
			end
			cf0 = cf0 * CFrame.new(0, perp/2, -(dif_para + para/2))

			local cf1 = st * ac * CFrame.Angles(0, pi, 0)
			if ((cf1 * za).lookVector - Needed_Look).magnitude > 0.01 then
				cf1 = cf1 * CFrame.Angles(0, 0, 2*acos(dot))
			end
			cf1 = cf1 * CFrame.new(0, perp/2, dif_para/2)

			if not p0 then
				p0 = Instance.new('Part')
				p0.FormFactor = 'Custom'
				p0.TopSurface = 0
				p0.BottomSurface = 0
				p0.Anchored = true
				p0.CanCollide = false
				p0.CastShadow = false
				p0.Material = MTREL
				p0.Size = Vector3.new(sz, sz, sz)
				local mesh = Instance.new('SpecialMesh', p0)
				mesh.MeshType = 2
				mesh.Name = 'WedgeMesh'
			end
			p0.WedgeMesh.Scale = Vector3.new(0, perp/sz, para/sz)
			p0.CFrame = cf0

			if not p1 then
				p1 = p0:clone()
			end
			p1.WedgeMesh.Scale = Vector3.new(0, perp/sz, dif_para/sz)
			p1.CFrame = cf1

			return p0, p1
		end

		function DrawQuad(v1, v2, v3, v4, parts)
			parts[1], parts[2] = DrawTriangle(v1, v2, v3, parts[1], parts[2])
			parts[3], parts[4] = DrawTriangle(v3, v2, v4, parts[3], parts[4])
		end
	end

	if binds[frame] then
		return binds[frame].parts
	end

	local uid = GenUid()
	local parts = {}
	local f = Instance.new('Folder', root)
	f.Name = frame.Name

	local parents = {}
	do
		local function add(child)
			if child:IsA'GuiObject' then
				parents[#parents + 1] = child
				add(child.Parent)
			end
		end
		add(frame)
	end

	local function UpdateOrientation(fetchProps)
		local properties = {
			Transparency = 0.98;
			BrickColor = BrickColor.new('Institutional white');
		}
		local zIndex = 1 - 0.05*frame.ZIndex

		local tl, br = frame.AbsolutePosition, frame.AbsolutePosition + frame.AbsoluteSize
		local tr, bl = Vector2.new(br.x, tl.y), Vector2.new(tl.x, br.y)
		do
			local rot = 0;
			for _, v in ipairs(parents) do
				rot = rot + v.Rotation
			end
			if rot ~= 0 and rot%180 ~= 0 then
				local mid = tl:lerp(br, 0.5)
				local s, c = math.sin(math.rad(rot)), math.cos(math.rad(rot))
				local vec = tl
				tl = Vector2.new(c*(tl.x - mid.x) - s*(tl.y - mid.y), s*(tl.x - mid.x) + c*(tl.y - mid.y)) + mid
				tr = Vector2.new(c*(tr.x - mid.x) - s*(tr.y - mid.y), s*(tr.x - mid.x) + c*(tr.y - mid.y)) + mid
				bl = Vector2.new(c*(bl.x - mid.x) - s*(bl.y - mid.y), s*(bl.x - mid.x) + c*(bl.y - mid.y)) + mid
				br = Vector2.new(c*(br.x - mid.x) - s*(br.y - mid.y), s*(br.x - mid.x) + c*(br.y - mid.y)) + mid
			end
		end
		DrawQuad(
			camera:ScreenPointToRay(tl.x, tl.y, zIndex).Origin, 
			camera:ScreenPointToRay(tr.x, tr.y, zIndex).Origin, 
			camera:ScreenPointToRay(bl.x, bl.y, zIndex).Origin, 
			camera:ScreenPointToRay(br.x, br.y, zIndex).Origin, 
			parts
		)
		if fetchProps then
			for _, pt in pairs(parts) do
				pt.Parent = f
			end
			for propName, propValue in pairs(properties) do
				for _, pt in pairs(parts) do
					pt[propName] = propValue
				end
			end
		end

	end

	UpdateOrientation(true)
	RunService:BindToRenderStep(uid, 2000, UpdateOrientation)
end

local function unpackt(array : table)

	local val = ""
	local i = 0
	for _,v in pairs(array) do
		if i < 3 then
			val = val .. v .. ", "
			i += 1
		else
			val = "Various"
			break
		end
	end

	return val
end

-- Interface Management
local SorinUI_Frame = isStudio and script.Parent:WaitForChild("Sorin UI") or game:GetObjects("rbxassetid://86467455075715")[1]

local SizeBleh = nil

local function Hide(Window, bind, notif)
	SizeBleh = Window.Size
	bind = string.split(tostring(bind), "Enum.KeyCode.")
	bind = bind[2]
	if notif then
		SorinUI:Notification({Title = "SorinServices UI Hidden", Content = "The interface has been hidden, you may reopen the interface by Pressing the UI Bind In Settings ("..tostring(bind)..")", Icon = "visibility_off"})
	end
	tween(Window, {BackgroundTransparency = 1})
	tween(Window.Elements, {BackgroundTransparency = 1})
	tween(Window.Line, {BackgroundTransparency = 1})
	tween(Window.Title.Title, {TextTransparency = 1})
	tween(Window.Title.subtitle, {TextTransparency = 1})
	tween(Window.Logo, {ImageTransparency = 1})
	tween(Window.Navigation.Line, {BackgroundTransparency = 1})

	for _, TopbarButton in ipairs(Window.Controls:GetChildren()) do
		if TopbarButton.ClassName == "Frame" then
			tween(TopbarButton, {BackgroundTransparency = 1})
			tween(TopbarButton.UIStroke, {Transparency = 1})
			tween(TopbarButton.ImageLabel, {ImageTransparency = 1})
			TopbarButton.Visible = false
		end
	end
	for _, tabbtn in ipairs(Window.Navigation.Tabs:GetChildren()) do
		if tabbtn.ClassName == "Frame" and tabbtn.Name ~= "InActive Template" then
			TweenService:Create(tabbtn, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {BackgroundTransparency = 1}):Play()
			TweenService:Create(tabbtn.ImageLabel, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {ImageTransparency = 1}):Play()
			TweenService:Create(tabbtn.DropShadowHolder.DropShadow, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {ImageTransparency = 1}):Play()
			TweenService:Create(tabbtn.UIStroke, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
		end
	end

	task.wait(0.28)
	Window.Size = UDim2.new(0,0,0,0)
	Window.Parent.ShadowHolder.Visible = false
	task.wait()
	Window.Elements.Parent.Visible = false
	Window.Visible = false
end

if gethui then
	SorinUI_Frame.Parent = gethui()
elseif syn and syn.protect_gui then 
	syn.protect_gui(SorinUI_Frame)
	SorinUI_Frame.Parent = CoreGui
elseif not isStudio and CoreGui:FindFirstChild("RobloxGui") then
	SorinUI_Frame.Parent = CoreGui:FindFirstChild("RobloxGui")
elseif not isStudio then
	SorinUI_Frame.Parent = CoreGui
end

if gethui then
	for _, Interface in ipairs(gethui():GetChildren()) do
		if Interface.Name == SorinUI_Frame.Name and Interface ~= SorinUI_Frame then
			Hide(Interface.SmartWindow)
			Interface.Enabled = false
			Interface.Name = "Sorin-Old"
		end
	end
elseif not isStudio then
	for _, Interface in ipairs(CoreGui:GetChildren()) do
		if Interface.Name == SorinUI_Frame.Name and Interface ~= SorinUI_Frame then
			Hide(Interface.SmartWindow)
			Interface.Enabled = false
			Interface.Name = "Sorin-Old"
		end
	end
end

SorinUI_Frame.Enabled = false
SorinUI_Frame.SmartWindow.Visible = false
SorinUI_Frame.Notifications.Template.Visible = false
SorinUI_Frame.DisplayOrder = 1000000000

local Main : Frame = SorinUI_Frame.SmartWindow
local Dragger = Main.Drag
local dragBar = SorinUI_Frame.Drag
local dragInteract = dragBar and dragBar.Interact or nil
local dragBarCosmetic = dragBar and dragBar.Drag or nil
local Elements = Main.Elements.Interactions
local LoadingFrame = Main.LoadingFrame
local Navigation = Main.Navigation
local Tabs = Navigation.Tabs
local Notifications = SorinUI_Frame.Notifications
local KeySystem : Frame = Main.KeySystem

local function Draggable(Bar, Window, enableTaptic, tapticOffset)
	pcall(function()
		local Dragging, DragInput, MousePos, FramePos

		local function connectFunctions()
			if dragBar and enableTaptic then
				dragBar.MouseEnter:Connect(function()
					if not Dragging then
						TweenService:Create(dragBarCosmetic, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {BackgroundTransparency = 0.5, Size = UDim2.new(0, 120, 0, 4)}):Play()
					end
				end)

				dragBar.MouseLeave:Connect(function()
					if not Dragging then
						TweenService:Create(dragBarCosmetic, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {BackgroundTransparency = 0.7, Size = UDim2.new(0, 100, 0, 4)}):Play()
					end
				end)
			end
		end

		connectFunctions()

		Bar.InputBegan:Connect(function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
				Dragging = true
				MousePos = Input.Position
				FramePos = Window.Position

				if enableTaptic then
					TweenService:Create(dragBarCosmetic, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 110, 0, 4), BackgroundTransparency = 0}):Play()
				end

				Input.Changed:Connect(function()
					if Input.UserInputState == Enum.UserInputState.End then
						Dragging = false
						connectFunctions()

						if enableTaptic then
							TweenService:Create(dragBarCosmetic, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 100, 0, 4), BackgroundTransparency = 0.7}):Play()
						end
					end
				end)
			end
		end)

		Bar.InputChanged:Connect(function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
				DragInput = Input
			end
		end)

		UserInputService.InputChanged:Connect(function(Input)
			if Input == DragInput and Dragging then
				local Delta = Input.Position - MousePos

				local newMainPosition = UDim2.new(FramePos.X.Scale, FramePos.X.Offset + Delta.X, FramePos.Y.Scale, FramePos.Y.Offset + Delta.Y)
				TweenService:Create(Window, TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Position = newMainPosition}):Play()

				if dragBar then
					local newDragBarPosition = UDim2.new(FramePos.X.Scale, FramePos.X.Offset + Delta.X, FramePos.Y.Scale, FramePos.Y.Offset + Delta.Y + 240)
					dragBar.Position = newDragBarPosition
				end
			end
		end)

	end)
end

function SorinUI:Notification(data)
	task.spawn(function()
		data = Kwargify({
			Title = "Missing Title",
			Content = "Missing or Unknown Content",
			Icon = "view_in_ar",
			ImageSource = "Material"
		}, data or {})

		-- Notification Object Creation
		local newNotification = Notifications.Template:Clone()
		newNotification.Name = data.Title
		newNotification.Parent = Notifications
		newNotification.LayoutOrder = #Notifications:GetChildren()
		newNotification.Visible = false
		BlurModule(newNotification)

		-- Set Data
		newNotification.Title.Text = data.Title
		newNotification.Description.Text = data.Content 
		newNotification.Icon.Image = GetIcon(data.Icon, data.ImageSource)

		-- Set initial transparency values
		newNotification.BackgroundTransparency = 1
		newNotification.Title.TextTransparency = 1
		newNotification.Description.TextTransparency = 1
		newNotification.UIStroke.Transparency = 1
		newNotification.Shadow.ImageTransparency = 1
		newNotification.Icon.ImageTransparency = 1
		newNotification.Icon.BackgroundTransparency = 1

		task.wait()

		-- Calculate textbounds and set initial values
		newNotification.Size = UDim2.new(1, 0, 0, -Notifications:FindFirstChild("UIListLayout").Padding.Offset)

		newNotification.Icon.Size = UDim2.new(0, 28, 0, 28)
		newNotification.Icon.Position = UDim2.new(0, 16, 0.5, -1)

		newNotification.Visible = true

		newNotification.Description.Size = UDim2.new(1, -65, 0, math.huge)
		local bounds = newNotification.Description.TextBounds.Y + 55
		newNotification.Description.Size = UDim2.new(1,-65,0, bounds - 35)
		newNotification.Size = UDim2.new(1, 0, 0, -Notifications:FindFirstChild("UIListLayout").Padding.Offset)
		TweenService:Create(newNotification, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Size = UDim2.new(1, 0, 0, bounds)}):Play()

		task.wait(0.15)
		TweenService:Create(newNotification, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0.45}):Play()
		TweenService:Create(newNotification.Title, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()
		TweenService:Create(newNotification.Description, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {TextTransparency = 0.5}):Play()
		TweenService:Create(newNotification.UIStroke, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {Transparency = 0.8}):Play()
		TweenService:Create(newNotification.Shadow, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {ImageTransparency = 0.9}):Play()
		TweenService:Create(newNotification.Icon, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {ImageTransparency = 0}):Play()
		TweenService:Create(newNotification.Icon, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0.8}):Play()
	end)
end

function SorinUI:CreateWindow(WindowSettings)
	WindowSettings = Kwargify({
		Name = "SorinServices UI",
		Subtitle = "by SorinServices",
		LogoID = "123795201100198",
		LoadingEnabled = true,
		LoadingTitle = "SorinServices UI",
		LoadingSubtitle = "Loading script...",
		KeySystem = true,
		KeySettings = {
			Title = "SorinServices | Key System",
			Subtitle = "Game Name",
			Note = "Please Enter Your Key To Use SorinServices",
			FileName = "Key",
			SaveKey = true,
			Key = {"Example Key"},
			SecondAction = {
				Enabled = true,
				Type = "Link",
				Parameter = ""
			}
		},
		ConfigSettings = {
			ConfigFolder = "SorinConfigs",
			RootFolder = nil
		}
	}, WindowSettings or {})

local Window = {
		Bind = Enum.KeyCode.RightControl,
		Size = false,
		State = false,
		CurrentTab = nil,
		Settings = nil
	}

	local function SafeCallback(func, ...)
		if type(func) == "function" then
			local suc, res = pcall(func, ...)
			if not suc then
				SorinUI:Notification({
					Title = "SorinServices UI",
					Icon = "warning",
					ImageSource = "Material",
					Content = "An error occurred: " .. res
				})
			end
		end
	end

	local function Unhide(Window, tab)
		Window.Size = SizeBleh
		Window.Parent.ShadowHolder.Visible = true
		Window.Visible = true
		Window.Elements.Parent.Visible = true
		tween(Window, {BackgroundTransparency = 0.1})
		tween(Window.Elements, {BackgroundTransparency = 0.1})
		tween(Window.Line, {BackgroundTransparency = 0})
		tween(Window.Title.Title, {TextTransparency = 0})
		tween(Window.Title.subtitle, {TextTransparency = 0})
		tween(Window.Logo, {ImageTransparency = 0})
		tween(Window.Navigation.Line, {BackgroundTransparency = 0})

		for _, TopbarButton in ipairs(Window.Controls:GetChildren()) do
			if TopbarButton.ClassName == "Frame" then
				TopbarButton.Visible = true
				tween(TopbarButton, {BackgroundTransparency = 0.25})
				tween(TopbarButton.UIStroke, {Transparency = 0.5})
				tween(TopbarButton.ImageLabel, {ImageTransparency = 0.25})
			end
		end
		for _, tabbtn in ipairs(Window.Navigation.Tabs:GetChildren()) do
			if tabbtn.ClassName == "Frame" and tabbtn.Name ~= "InActive Template" then
				TweenService:Create(tabbtn, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0.75}):Play()
				TweenService:Create(tabbtn.ImageLabel, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {ImageTransparency = 0}):Play()
				TweenService:Create(tabbtn.DropShadowHolder.DropShadow, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {ImageTransparency = 0.9}):Play()
				TweenService:Create(tabbtn.UIStroke, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {Transparency = 0.5}):Play()
			end
		end

		if tab then
			for _, v in ipairs(Tabs:GetChildren()) do
				if v.ClassName == "Frame" and v.Name ~= "InActive Template" then
					if v.Name == tab then
						v.BackgroundTransparency = 0
						v.ImageLabel.ImageTransparency = 0
						v.UIStroke.Transparency = 0
						v.DropShadowHolder.DropShadow.ImageTransparency = 0.6
						Window.CurrentTab = v.Name
					else
						v.BackgroundTransparency = 0.75
						v.ImageLabel.ImageTransparency = 0
						v.UIStroke.Transparency = 0.5
						v.DropShadowHolder.DropShadow.ImageTransparency = 0.9
					end
				end
			end
		end
	end

	local function Minimize(Window)
		tween(Window, {Size = UDim2.new(0, 200, 0, 40)})
		tween(Window.Elements.Parent, {Size = UDim2.new(0, 0, 0, 0)})
		Window.Title.Title.Text = WindowSettings.Name
		Window.Title.subtitle.Visible = false
	end

	local function Maximise(Window)
		tween(Window, {Size = SizeBleh})
		tween(Window.Elements.Parent, {Size = UDim2.new(1, -205, 1, -60)})
		Window.Title.Title.Text = WindowSettings.Name
		Window.Title.subtitle.Visible = true
	end

	function Window:SetVisible(bool)
		if bool then
			Unhide(Main, Window.CurrentTab)
			dragBar.Visible = true
			Window.State = true
			SorinUI_Frame.MobileSupport.Visible = false
		else
			Hide(Main, Window.Bind, true)
			dragBar.Visible = false
			Window.State = false
			if UserInputService.KeyboardEnabled == false then
				SorinUI_Frame.MobileSupport.Visible = true
			end
		end
	end

	function Window:SetMinimized(bool)
		if bool then
			Minimize(Main)
			dragBar.Visible = false
			Window.Size = true
		else
			Maximise(Main)
			dragBar.Visible = true
			Window.Size = false
		end
	end

	if WindowSettings.LoadingEnabled then
		LoadingFrame.Visible = true
		LoadingFrame.Title.Text = WindowSettings.LoadingTitle
		LoadingFrame.Subtitle.Text = WindowSettings.LoadingSubtitle
		tween(LoadingFrame, {BackgroundTransparency = 0.1})
		tween(LoadingFrame.Title, {TextTransparency = 0})
		tween(LoadingFrame.Subtitle, {TextTransparency = 0})
		tween(LoadingFrame.Logo, {ImageTransparency = 0})
		task.wait(2)
		tween(LoadingFrame, {BackgroundTransparency = 1})
		tween(LoadingFrame.Title, {TextTransparency = 1})
		tween(LoadingFrame.Subtitle, {TextTransparency = 1})
		tween(LoadingFrame.Logo, {ImageTransparency = 1})
		task.wait(0.3)
		LoadingFrame.Visible = false
	end

	if WindowSettings.KeySystem then
		KeySystem.Visible = true
		KeySystem.Title.Text = WindowSettings.KeySettings.Title
		KeySystem.Subtitle.Text = WindowSettings.KeySettings.Subtitle
		KeySystem.Description.Text = WindowSettings.KeySettings.Note
		KeySystem.Input.TextBox.PlaceholderText = "Enter Key"
		tween(KeySystem, {BackgroundTransparency = 0.1})
		tween(KeySystem.Title, {TextTransparency = 0})
		tween(KeySystem.Subtitle, {TextTransparency = 0})
		tween(KeySystem.Description, {TextTransparency = 0})
		tween(KeySystem.Input.TextBox, {TextTransparency = 0})
		tween(KeySystem.Input.UIStroke, {Transparency = 0})
		KeySystem.Input.TextBox.FocusLost:Connect(function()
			local input = KeySystem.Input.TextBox.Text
			for _, key in ipairs(WindowSettings.KeySettings.Key) do
				if input == key then
					if WindowSettings.KeySettings.SaveKey then
						if WindowSettings.KeySettings.SaveInRoot then
							writefile(WindowSettings.KeySettings.FileName .. ".key", input)
						else
							writefile(SorinUI.Folder .. "/" .. WindowSettings.KeySettings.FileName .. ".key", input)
						end
					end
					tween(KeySystem, {BackgroundTransparency = 1})
					tween(KeySystem.Title, {TextTransparency = 1})
					tween(KeySystem.Subtitle, {TextTransparency = 1})
					tween(KeySystem.Description, {TextTransparency = 1})
					tween(KeySystem.Input.TextBox, {TextTransparency = 1})
					tween(KeySystem.Input.UIStroke, {Transparency = 1})
					task.wait(0.3)
					KeySystem.Visible = false
					SorinUI_Frame.Enabled = true
					Main.Visible = true
					Unhide(Main)
					Window.State = true
					dragBar.Visible = true
					SorinUI:Notification({
						Title = "SorinServices UI",
						Icon = "sparkle",
						ImageSource = "Material",
						Content = "Key accepted! Welcome to SorinServices UI."
					})
					return
				end
			end
			SorinUI:Notification({
				Title = "SorinServices UI",
				Icon = "error",
				ImageSource = "Material",
				Content = "Invalid key entered."
			})
		end)
	end

	function Window:CreateTab(TabSettings)
		TabSettings = Kwargify({
			Name = "New Tab",
			Icon = "home",
			ImageSource = "Material",
			ShowTitle = true
		}, TabSettings or {})

		local Tab = {
			Name = TabSettings.Name,
			Icon = TabSettings.Icon,
			ImageSource = TabSettings.ImageSource
		}

		local TabPage = Elements.Template.Page:Clone()
		TabPage.Name = TabSettings.Name
		TabPage.Visible = false
		TabPage.Parent = Elements

		local TabButton = Tabs["InActive Template"]:Clone()
		TabButton.Name = TabSettings.Name
		TabButton.Visible = true
		TabButton.Parent = Tabs
		TabButton.ImageLabel.Image = GetIcon(TabSettings.Icon, TabSettings.ImageSource)
		TabButton.Title.Text = TabSettings.ShowTitle and TabSettings.Name or ""
		TabButton.BackgroundTransparency = 0.75
		TabButton.ImageLabel.ImageTransparency = 0
		TabButton.UIStroke.Transparency = 0.5
		TabButton.DropShadowHolder.DropShadow.ImageTransparency = 0.9

		TabButton.MouseButton1Click:Connect(function()
			for _, v in ipairs(Tabs:GetChildren()) do
				if v.ClassName == "Frame" and v.Name ~= "InActive Template" then
					if v.Name == TabSettings.Name then
						v.BackgroundTransparency = 0
						v.ImageLabel.ImageTransparency = 0
						v.UIStroke.Transparency = 0
						v.DropShadowHolder.DropShadow.ImageTransparency = 0.6
						Window.CurrentTab = v.Name
					else
						v.BackgroundTransparency = 0.75
						v.ImageLabel.ImageTransparency = 0
						v.UIStroke.Transparency = 0.5
						v.DropShadowHolder.DropShadow.ImageTransparency = 0.9
					end
				end
			end
			for _, v in ipairs(Elements:GetChildren()) do
				if v.ClassName == "ScrollingFrame" then
					v.Visible = v.Name == TabSettings.Name
				end
			end
		end)

		function Tab:Activate()
			for _, v in ipairs(Tabs:GetChildren()) do
				if v.ClassName == "Frame" and v.Name ~= "InActive Template" then
					if v.Name == TabSettings.Name then
						v.BackgroundTransparency = 0
						v.ImageLabel.ImageTransparency = 0
						v.UIStroke.Transparency = 0
						v.DropShadowHolder.DropShadow.ImageTransparency = 0.6
						Window.CurrentTab = v.Name
					else
						v.BackgroundTransparency = 0.75
						v.ImageLabel.ImageTransparency = 0
						v.UIStroke.Transparency = 0.5
						v.DropShadowHolder.DropShadow.ImageTransparency = 0.9
					end
				end
			end
			for _, v in ipairs(Elements:GetChildren()) do
				if v.ClassName == "ScrollingFrame" then
					v.Visible = v.Name == TabSettings.Name
				end
			end
		end

		function Tab:CreateSection(SectionName)
			local Section = Elements.Template.Section:Clone()
			Section.Name = SectionName
			Section.Title.Text = SectionName
			Section.Visible = true
			Section.Parent = TabPage
			Section.Title.TextTransparency = 1
			TweenService:Create(Section.Title, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
		end

		function Tab:CreateButton(ButtonSettings)
			ButtonSettings = Kwargify({
				Name = "Button",
				Description = "No Description",
				Callback = function() end
			}, ButtonSettings or {})

			local Button = Elements.Template.Button:Clone()
			Button.Name = ButtonSettings.Name
			Button.Title.Text = ButtonSettings.Name
			Button.Description.Text = ButtonSettings.Description
			Button.Visible = true
			Button.Parent = TabPage
			Button.BackgroundTransparency = 1
			Button.Title.TextTransparency = 1
			Button.Description.TextTransparency = 1
			TweenService:Create(Button, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0.35}):Play()
			TweenService:Create(Button.Title, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()
			TweenService:Create(Button.Description, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {TextTransparency = 0.5}):Play()

			Button.MouseButton1Click:Connect(function()
				SafeCallback(ButtonSettings.Callback)
			end)

			return Button
		end

		function Tab:CreateToggle(ToggleSettings, Flag)
			ToggleSettings = Kwargify({
				Name = "Toggle",
				Description = "No Description",
				CurrentValue = false,
				Callback = function() end
			}, ToggleSettings or {})

			local Toggle = Elements.Template.Toggle:Clone()
			Toggle.Name = ToggleSettings.Name
			Toggle.Title.Text = ToggleSettings.Name
			Toggle.Description.Text = ToggleSettings.Description
			Toggle.Visible = true
			Toggle.Parent = TabPage
			Toggle.BackgroundTransparency = 1
			Toggle.Title.TextTransparency = 1
			Toggle.Description.TextTransparency = 1
			Toggle.Switch.BackgroundTransparency = 1
			Toggle.Switch.Knob.BackgroundTransparency = 1
			Toggle.Switch.Knob.Position = ToggleSettings.CurrentValue and UDim2.new(0.5, 0, 0.5, 0) or UDim2.new(0, 0, 0.5, 0)
			TweenService:Create(Toggle, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0.35}):Play()
			TweenService:Create(Toggle.Title, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()
			TweenService:Create(Toggle.Description, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {TextTransparency = 0.5}):Play()
			TweenService:Create(Toggle.Switch, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0.8}):Play()
			TweenService:Create(Toggle.Switch.Knob, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0}):Play()

			local ToggleV = {
				CurrentValue = ToggleSettings.CurrentValue,
				Class = "Toggle"
			}

			Toggle.MouseButton1Click:Connect(function()
				ToggleV.CurrentValue = not ToggleV.CurrentValue
				TweenService:Create(Toggle.Switch.Knob, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {Position = ToggleV.CurrentValue and UDim2.new(0.5, 0, 0.5, 0) or UDim2.new(0, 0, 0.5, 0)}):Play()
				SafeCallback(ToggleSettings.Callback, ToggleV.CurrentValue)
			end)

			function ToggleV:Set(NewToggleSettings)
				NewToggleSettings = Kwargify(ToggleSettings, NewToggleSettings or {})
				ToggleSettings = NewToggleSettings
				ToggleV.CurrentValue = ToggleSettings.CurrentValue
				Toggle.Name = ToggleSettings.Name
				Toggle.Title.Text = ToggleSettings.Name
				Toggle.Description.Text = ToggleSettings.Description
				Toggle.Visible = true
				TweenService:Create(Toggle.Switch.Knob, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {Position = ToggleV.CurrentValue and UDim2.new(0.5, 0, 0.5, 0) or UDim2.new(0, 0, 0.5, 0)}):Play()
				SafeCallback(ToggleSettings.Callback, ToggleV.CurrentValue)
			end

			function ToggleV:Destroy()
				Toggle:Destroy()
			end

			if Flag then
				SorinUI.Options[Flag] = ToggleV
			end

			SafeCallback(ToggleSettings.Callback, ToggleV.CurrentValue)

			return ToggleV
		end

		function Tab:CreateSlider(SliderSettings, Flag)
			SliderSettings = Kwargify({
				Name = "Slider",
				Description = "No Description",
				Min = 0,
				Max = 100,
				Increment = 1,
				CurrentValue = 50,
				Callback = function() end
			}, SliderSettings or {})

			local Slider = Elements.Template.Slider:Clone()
			Slider.Name = SliderSettings.Name
			Slider.Title.Text = SliderSettings.Name
			Slider.Description.Text = SliderSettings.Description
			Slider.Visible = true
			Slider.Parent = TabPage
			Slider.BackgroundTransparency = 1
			Slider.Title.TextTransparency = 1
			Slider.Description.TextTransparency = 1
			Slider.SliderBar.BackgroundTransparency = 1
			Slider.SliderBar.SliderPoint.BackgroundTransparency = 1
			Slider.SliderBar.TextBox.Text = tostring(SliderSettings.CurrentValue)
			Slider.SliderBar.SliderPoint.Position = UDim2.new((SliderSettings.CurrentValue - SliderSettings.Min) / (SliderSettings.Max - SliderSettings.Min), 0, 0.5, 0)
			TweenService:Create(Slider, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0.35}):Play()
			TweenService:Create(Slider.Title, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()
			TweenService:Create(Slider.Description, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {TextTransparency = 0.5}):Play()
			TweenService:Create(Slider.SliderBar, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0.8}):Play()
			TweenService:Create(Slider.SliderBar.SliderPoint, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0}):Play()

			local SliderV = {
				CurrentValue = SliderSettings.CurrentValue,
				Class = "Slider"
			}

			local Dragging = false
			Slider.SliderBar.InputBegan:Connect(function(Input)
				if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
					Dragging = true
				end
			end)
			Slider.SliderBar.InputEnded:Connect(function(Input)
				if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
					Dragging = false
				end
			end)
			UserInputService.InputChanged:Connect(function(Input)
				if Dragging and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
					local localX = math.clamp(Input.Position.X - Slider.SliderBar.AbsolutePosition.X, 0, Slider.SliderBar.AbsoluteSize.X)
					local value = SliderSettings.Min + (localX / Slider.SliderBar.AbsoluteSize.X) * (SliderSettings.Max - SliderSettings.Min)
					value = math.floor(value / SliderSettings.Increment + 0.5) * SliderSettings.Increment
					SliderV.CurrentValue = value
					Slider.SliderBar.SliderPoint.Position = UDim2.new(localX / Slider.SliderBar.AbsoluteSize.X, 0, 0.5, 0)
					Slider.SliderBar.TextBox.Text = tostring(value)
					SafeCallback(SliderSettings.Callback, value)
				end
			end)
			Slider.SliderBar.TextBox.FocusLost:Connect(function()
				local value = tonumber(Slider.SliderBar.TextBox.Text)
				if value then
					value = math.clamp(math.floor(value / SliderSettings.Increment + 0.5) * SliderSettings.Increment, SliderSettings.Min, SliderSettings.Max)
					SliderV.CurrentValue = value
					Slider.SliderBar.SliderPoint.Position = UDim2.new((value - SliderSettings.Min) / (SliderSettings.Max - SliderSettings.Min), 0, 0.5, 0)
					Slider.SliderBar.TextBox.Text = tostring(value)
					SafeCallback(SliderSettings.Callback, value)
				else
					Slider.SliderBar.TextBox.Text = tostring(SliderV.CurrentValue)
				end
			end)

			function SliderV:Set(NewSliderSettings)
				NewSliderSettings = Kwargify(SliderSettings, NewSliderSettings or {})
				SliderSettings = NewSliderSettings
				SliderV.CurrentValue = SliderSettings.CurrentValue
				Slider.Name = SliderSettings.Name
				Slider.Title.Text = SliderSettings.Name
				Slider.Description.Text = SliderSettings.Description
				Slider.Visible = true
				Slider.SliderBar.SliderPoint.Position = UDim2.new((SliderSettings.CurrentValue - SliderSettings.Min) / (SliderSettings.Max - SliderSettings.Min), 0, 0.5, 0)
				Slider.SliderBar.TextBox.Text = tostring(SliderSettings.CurrentValue)
				SafeCallback(SliderSettings.Callback, SliderSettings.CurrentValue)
			end

			function SliderV:Destroy()
				Slider:Destroy()
			end

			if Flag then
				SorinUI.Options[Flag] = SliderV
			end

			SafeCallback(SliderSettings.Callback, SliderV.CurrentValue)

			return SliderV
		end

		function Tab:CreateInput(InputSettings, Flag)
			InputSettings = Kwargify({
				Name = "Input",
				Description = "No Description",
				PlaceholderText = "Enter Text",
				CurrentValue = "",
				Numeric = false,
				MaxCharacters = nil,
				Enter = false,
				Callback = function() end
			}, InputSettings or {})

			local Input = Elements.Template.Input:Clone()
			Input.Name = InputSettings.Name
			Input.Title.Text = InputSettings.Name
			Input.Description.Text = InputSettings.Description
			Input.InputBox.PlaceholderText = InputSettings.PlaceholderText
			Input.Visible = true
			Input.Parent = TabPage
			Input.BackgroundTransparency = 1
			Input.Title.TextTransparency = 1
			Input.Description.TextTransparency = 1
			Input.InputBox.TextTransparency = 1
			Input.InputBox.BackgroundTransparency = 1
			TweenService:Create(Input, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0.35}):Play()
			TweenService:Create(Input.Title, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()
			TweenService:Create(Input.Description, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {TextTransparency = 0.5}):Play()
			TweenService:Create(Input.InputBox, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()
			TweenService:Create(Input.InputBox, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0.8}):Play()

			local InputV = {
				CurrentValue = InputSettings.CurrentValue,
				Class = "Input"
			}

			Input.InputBox.FocusLost:Connect(function()
				local text = Input.InputBox.Text
				if InputSettings.Numeric then
					text = tonumber(text) or InputV.CurrentValue
				end
				if InputSettings.MaxCharacters and #text > InputSettings.MaxCharacters then
					text = text:sub(1, InputSettings.MaxCharacters)
				end
				InputV.CurrentValue = text
				Input.InputBox.Text = tostring(text)
				SafeCallback(InputSettings.Callback, text)
			end)

			function InputV:Set(NewInputSettings)
				NewInputSettings = Kwargify(InputSettings, NewInputSettings or {})
				InputSettings = NewInputSettings
				InputV.CurrentValue = InputSettings.CurrentValue
				Input.Name = InputSettings.Name
				Input.Title.Text = InputSettings.Name
				Input.Description.Text = InputSettings.Description
				Input.InputBox.PlaceholderText = InputSettings.PlaceholderText
				Input.Visible = true
				Input.InputBox.Text = tostring(InputSettings.CurrentValue)
				SafeCallback(InputSettings.Callback, InputSettings.CurrentValue)
			end

			function InputV:Destroy()
				Input:Destroy()
			end

			if Flag then
				SorinUI.Options[Flag] = InputV
			end

			SafeCallback(InputSettings.Callback, InputV.CurrentValue)

			return InputV
		end

		function Tab:CreateDropdown(DropdownSettings, Flag)
			DropdownSettings = Kwargify({
				Name = "Dropdown",
				Description = "No Description",
				Options = {},
				CurrentOption = {},
				MultipleOptions = false,
				SpecialType = nil,
				Callback = function() end
			}, DropdownSettings or {})

			local Dropdown = Elements.Template.Dropdown:Clone()
			Dropdown.Name = DropdownSettings.Name
			Dropdown.Title.Text = DropdownSettings.Name
			Dropdown.Description.Text = DropdownSettings.Description
			Dropdown.Visible = true
			Dropdown.Parent = TabPage
			Dropdown.BackgroundTransparency = 1
			Dropdown.Title.TextTransparency = 1
			Dropdown.Description.TextTransparency = 1
			Dropdown.DropdownFrame.BackgroundTransparency = 1
			TweenService:Create(Dropdown, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0.35}):Play()
			TweenService:Create(Dropdown.Title, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()
			TweenService:Create(Dropdown.Description, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {TextTransparency = 0.5}):Play()
			TweenService:Create(Dropdown.DropdownFrame, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0.8}):Play()

			local DropdownV = {
				CurrentOption = DropdownSettings.CurrentOption,
				Class = "Dropdown"
			}

			local function UpdateDropdown()
				Dropdown.DropdownFrame.TextLabel.Text = unpackt(DropdownV.CurrentOption)
				for _, option in ipairs(Dropdown.DropdownFrame.Options:GetChildren()) do
					if option.ClassName == "TextButton" then
						option:Destroy()
					end
				end
				for _, option in ipairs(DropdownSettings.Options) do
					local OptionButton = Elements.Template.Dropdown.Option:Clone()
					OptionButton.Text = tostring(option)
					OptionButton.Visible = true
					OptionButton.Parent = Dropdown.DropdownFrame.Options
					OptionButton.BackgroundTransparency = 1
					OptionButton.TextTransparency = 1
					TweenService:Create(OptionButton, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0.8}):Play()
					TweenService:Create(OptionButton, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()
					OptionButton.MouseButton1Click:Connect(function()
						if DropdownSettings.MultipleOptions then
							if table.find(DropdownV.CurrentOption, option) then
								RemoveTable(DropdownV.CurrentOption, option)
							else
								table.insert(DropdownV.CurrentOption, option)
							end
						else
							DropdownV.CurrentOption = {option}
						end
						UpdateDropdown()
						SafeCallback(DropdownSettings.Callback, DropdownV.CurrentOption)
					end)
				end
			end

			Dropdown.DropdownFrame.MouseButton1Click:Connect(function()
				Dropdown.DropdownFrame.Options.Visible = not Dropdown.DropdownFrame.Options.Visible
				TweenService:Create(Dropdown.DropdownFrame.Options, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {Size = Dropdown.DropdownFrame.Options.Visible and UDim2.new(1, 0, 0, #DropdownSettings.Options * 30) or UDim2.new(1, 0, 0, 0)}):Play()
			end)

			UpdateDropdown()

			function DropdownV:Set(NewDropdownSettings)
				NewDropdownSettings = Kwargify(DropdownSettings, NewDropdownSettings or {})
				DropdownSettings = NewDropdownSettings
				DropdownV.CurrentOption = DropdownSettings.CurrentOption
				Dropdown.Name = DropdownSettings.Name
				Dropdown.Title.Text = DropdownSettings.Name
				Dropdown.Description.Text = DropdownSettings.Description
				Dropdown.Visible = true
				UpdateDropdown()
				SafeCallback(DropdownSettings.Callback, DropdownV.CurrentOption)
			end

			function DropdownV:Destroy()
				Dropdown:Destroy()
			end

			if Flag then
				SorinUI.Options[Flag] = DropdownV
			end

			SafeCallback(DropdownSettings.Callback, DropdownV.CurrentOption)

			return DropdownV
		end

		function Tab:CreateColorPicker(ColorPickerSettings, Flag)
			ColorPickerSettings = Kwargify({
				Name = "Color Picker",
				Color = Color3.fromRGB(255, 255, 255),
				Alpha = 1,
				Callback = function() end
			}, ColorPickerSettings or {})

			local ColorPicker = Elements.Template.ColorPicker:Clone()
			ColorPicker.Name = ColorPickerSettings.Name
			ColorPicker.Title.Text = ColorPickerSettings.Name
			ColorPicker.Visible = true
			ColorPicker.Parent = TabPage
			ColorPicker.BackgroundTransparency = 1
			ColorPicker.Title.TextTransparency = 1
			TweenService:Create(ColorPicker, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0.35}):Play()
			TweenService:Create(ColorPicker.Title, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()

			local ColorPickerV = {
				Color = ColorPickerSettings.Color,
				Alpha = ColorPickerSettings.Alpha,
				Class = "Colorpicker"
			}

			local h, s, v = ColorPickerSettings.Color:ToHSV()
			local mainDragging, sliderDragging = false, false
			local mouse = Player:GetMouse()

			local function setDisplay(h, s, v)
				ColorPicker.HexInput.InputBox.Text = string.format("#%02X%02X%02X", ColorPickerSettings.Color.R * 255, ColorPickerSettings.Color.G * 255, ColorPickerSettings.Color.B * 255)
				ColorPicker.RInput.InputBox.Text = tostring(math.floor(ColorPickerSettings.Color.R * 255 + 0.5))
				ColorPicker.GInput.InputBox.Text = tostring(math.floor(ColorPickerSettings.Color.G * 255 + 0.5))
				ColorPicker.BInput.InputBox.Text = tostring(math.floor(ColorPickerSettings.Color.B * 255 + 0.5))
				ColorPicker.Main.BackgroundColor3 = Color3.fromHSV(h, s, v)
				ColorPicker.Main.MainPoint.Position = UDim2.new(s, 0, 1 - v, 0)
				ColorPicker.Slider.SliderPoint.Position = UDim2.new(h, 0, 0.5, 0)
			end

			ColorPicker.Main.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					mainDragging = true
				end
			end)
			ColorPicker.Main.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					mainDragging = false
				end
			end)
			ColorPicker.Slider.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					sliderDragging = true
				end
			end)
			ColorPicker.Slider.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					sliderDragging = false
				end
			end)
			ColorPicker.HexInput.InputBox.FocusLost:Connect(function()
				local hex = ColorPicker.HexInput.InputBox.Text
				if hex:match("^#?%x%x%x%x%x%x$") then
					local r, g, b = tonumber(hex:sub(2, 3), 16), tonumber(hex:sub(4, 5), 16), tonumber(hex:sub(6, 7), 16)
					h, s, v = Color3.fromRGB(r, g, b):ToHSV()
					setDisplay(h, s, v)
					ColorPickerSettings.Color = Color3.fromRGB(r, g, b)
					SafeCallback(ColorPickerSettings.Callback, Color3.fromRGB(r, g, b))
				end
			end)
			local function rgbBoxes(box, toChange)
				local value = tonumber(box.Text)
				local color = Color3.fromHSV(h, s, v)
				local oldR, oldG, oldB = math.floor((color.R * 255) + 0.5), math.floor((color.G * 255) + 0.5), math.floor((color.B * 255) + 0.5)
				local save
				if toChange == "R" then save = oldR; oldR = value elseif toChange == "G" then save = oldG; oldG = value else save = oldB; oldB = value end
				if value then
					value = math.clamp(value, 0, 255)
					h, s, v = Color3.fromRGB(oldR, oldG, oldB):ToHSV()
					setDisplay(h, s, v)
				else
					box.Text = tostring(save)
				end
				local r, g, b = math.floor((color.R * 255) + 0.5), math.floor((color.G * 255) + 0.5), math.floor((color.B * 255) + 0.5)
				ColorPickerSettings.Color = Color3.fromRGB(r, g, b)
			end
			ColorPicker.RInput.InputBox.FocusLost:Connect(function()
				rgbBoxes(ColorPicker.RInput.InputBox, "R")
				SafeCallback(ColorPickerSettings.Callback, Color3.fromRGB(r, g, b))
			end)
			ColorPicker.GInput.InputBox.FocusLost:Connect(function()
				rgbBoxes(ColorPicker.GInput.InputBox, "G")
				SafeCallback(ColorPickerSettings.Callback, Color3.fromRGB(r, g, b))
			end)
			ColorPicker.BInput.InputBox.FocusLost:Connect(function()
				rgbBoxes(ColorPicker.BInput.InputBox, "B")
				SafeCallback(ColorPickerSettings.Callback, Color3.fromRGB(r, g, b))
			end)
			RunService.RenderStepped:Connect(function()
				if mainDragging then
					local localX = math.clamp(mouse.X - ColorPicker.Main.AbsolutePosition.X, 0, ColorPicker.Main.AbsoluteSize.X)
					local localY = math.clamp(mouse.Y - ColorPicker.Main.AbsolutePosition.Y, 0, ColorPicker.Main.AbsoluteSize.Y)
					s = localX / ColorPicker.Main.AbsoluteSize.X
					v = 1 - (localY / ColorPicker.Main.AbsoluteSize.Y)
					ColorPicker.Main.BackgroundColor3 = Color3.fromHSV(h, s, v)
					ColorPicker.Main.MainPoint.Position = UDim2.new(s, 0, 1 - v, 0)
					local color = Color3.fromHSV(h, s, v)
					local r, g, b = math.floor((color.R * 255) + 0.5), math.floor((color.G * 255) + 0.5), math.floor((color.B * 255) + 0.5)
					ColorPicker.RInput.InputBox.Text = tostring(r)
					ColorPicker.GInput.InputBox.Text = tostring(g)
					ColorPicker.BInput.InputBox.Text = tostring(b)
					ColorPicker.HexInput.InputBox.Text = string.format("#%02X%02X%02X", color.R * 0xFF, color.G * 0xFF, color.B * 0xFF)
					SafeCallback(ColorPickerSettings.Callback, Color3.fromRGB(r, g, b))
					ColorPickerSettings.Color = Color3.fromRGB(r, g, b)
					ColorPickerV.Color = ColorPickerSettings.Color
				end
				if sliderDragging then
					local localX = math.clamp(mouse.X - ColorPicker.Slider.AbsolutePosition.X, 0, ColorPicker.Slider.AbsoluteSize.X)
					h = localX / ColorPicker.Slider.AbsoluteSize.X
					ColorPicker.Main.BackgroundColor3 = Color3.fromHSV(h, s, v)
					ColorPicker.Slider.SliderPoint.Position = UDim2.new(h, 0, 0.5, 0)
					local color = Color3.fromHSV(h, s, v)
					local r, g, b = math.floor((color.R * 255) + 0.5), math.floor((color.G * 255) + 0.5), math.floor((color.B * 255) + 0.5)
					ColorPicker.RInput.InputBox.Text = tostring(r)
					ColorPicker.GInput.InputBox.Text = tostring(g)
					ColorPicker.BInput.InputBox.Text = tostring(b)
					ColorPicker.HexInput.InputBox.Text = string.format("#%02X%02X%02X", color.R * 0xFF, color.G * 0xFF, color.B * 0xFF)
					SafeCallback(ColorPickerSettings.Callback, Color3.fromRGB(r, g, b))
					ColorPickerSettings.Color = Color3.fromRGB(r, g, b)
					ColorPickerV.Color = ColorPickerSettings.Color
				end
			end)

			function ColorPickerV:Set(NewColorPickerSettings)
				NewColorPickerSettings = Kwargify(ColorPickerSettings, NewColorPickerSettings or {})
				ColorPickerSettings = NewColorPickerSettings
				ColorPickerV.Color = ColorPickerSettings.Color
				ColorPicker.Name = ColorPickerSettings.Name
				ColorPicker.Title.Text = ColorPickerSettings.Name
				ColorPicker.Visible = true
				h, s, v = ColorPickerSettings.Color:ToHSV()
				setDisplay(h, s, v)
				SafeCallback(ColorPickerSettings.Callback, ColorPickerSettings.Color)
			end

			function ColorPickerV:Destroy()
				ColorPicker:Destroy()
			end

			if Flag then
				SorinUI.Options[Flag] = ColorPickerV
			end

			SafeCallback(ColorPickerSettings.Callback, ColorPickerSettings.Color)

			return ColorPickerV
		end

		function Tab:BuildConfigSection()
			if isStudio then
				Tab:CreateLabel({Text = "Config system unavailable. (Environment isStudio)", Style = 3})
				return "Config system unavailable."
			end

			local inputPath = nil
			local selectedConfig = nil

			local Title = Elements.Template.Title:Clone()
			Title.Text = "Configurations"
			Title.Visible = true
			Title.Parent = TabPage
			Title.TextTransparency = 1
			TweenService:Create(Title, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()

			Tab:CreateSection("Config Creator")

			Tab:CreateInput({
				Name = "Config Name",
				Description = "Insert a name for your to be created config.",
				PlaceholderText = "Name",
				CurrentValue = "",
				Numeric = false,
				MaxCharacters = nil,
				Enter = false,
				Callback = function(input)
					inputPath = input
				end,
			})

			local configSelection

			Tab:CreateButton({
				Name = "Create Config",
				Description = "Create a config with all of your current settings.",
				Callback = function()
					if not inputPath or string.gsub(inputPath, " ", "") == "" then
						SorinUI:Notification({
							Title = "SorinServices UI",
							Icon = "warning",
							ImageSource = "Material",
							Content = "Config name cannot be empty."
						})
						return
					end

					local success, returned = SorinUI:SaveConfig(inputPath)
					if not success then
						SorinUI:Notification({
							Title = "SorinServices UI",
							Icon = "error",
							ImageSource = "Material",
							Content = "Unable to save config, return error: " .. returned
						})
					end

					SorinUI:Notification({
						Title = "SorinServices UI",
						Icon = "info",
						ImageSource = "Material",
						Content = string.format("Created config %q", inputPath),
					})

					configSelection:Set({ Options = SorinUI:RefreshConfigList() })
				end
			})

			Tab:CreateSection("Config Load/Settings")

			configSelection = Tab:CreateDropdown({
				Name = "Select Config",
				Description = "Select a config to load your settings on.",
				Options = SorinUI:RefreshConfigList(),
				CurrentOption = {},
				MultipleOptions = false,
				SpecialType = nil,
				Callback = function(Value)
					selectedConfig = Value
				end,
			})

			Tab:CreateButton({
				Name = "Load Config",
				Description = "Load your saved config settings.",
				Callback = function()
					local success, returned = SorinUI:LoadConfig(selectedConfig)
					if not success then
						SorinUI:Notification({
							Title = "SorinServices UI",
							Icon = "error",
							ImageSource = "Material",
							Content = "Unable to load config, return error: " .. returned
						})
						return
					end

					SorinUI:Notification({
						Title = "SorinServices UI",
						Icon = "info",
						ImageSource = "Material",
						Content = string.format("Loaded config %q", selectedConfig),
					})
				end
			})

			Tab:CreateButton({
				Name = "Overwrite Config",
				Description = "Overwrite your current config settings.",
				Callback = function()
					local success, returned = SorinUI:SaveConfig(selectedConfig)
					if not success then
						SorinUI:Notification({
							Title = "SorinServices UI",
							Icon = "error",
							ImageSource = "Material",
							Content = "Unable to overwrite config, return error: " .. returned
						})
						return
					end

					SorinUI:Notification({
						Title = "SorinServices UI",
						Icon = "info",
						ImageSource = "Material",
						Content = string.format("Overwrote config %q", selectedConfig),
					})
				end
			})

			Tab:CreateButton({
				Name = "Refresh Config List",
				Description = "Refresh the current config list.",
				Callback = function()
					configSelection:Set({ Options = SorinUI:RefreshConfigList() })
				end,
			})

			local loadlabel
			Tab:CreateButton({
				Name = "Set as autoload",
				Description = "Set a config to auto load setting in your next session.",
				Callback = function()
					local name = selectedConfig
					writefile(SorinUI.Folder .. "/settings/autoload.txt", name)
					loadlabel:Set({ Text = "Current autoload config: " .. name })

					SorinUI:Notification({
						Title = "SorinServices UI",
						Icon = "info",
						ImageSource = "Material",
						Content = string.format("Set %q to auto load", name),
					})
				end,
			})

			loadlabel = Tab:CreateParagraph({
				Title = "Current Auto Load",
				Text = "None"
			})

			Tab:CreateButton({
				Name = "Delete Autoload",
				Description = "Delete The Autoload File",
				Callback = function()
					local name = selectedConfig
					delfile(SorinUI.Folder .. "/settings/autoload.txt")
					loadlabel:Set({ Text = "None" })

					SorinUI:Notification({
						Title = "SorinServices UI",
						Icon = "info",
						ImageSource = "Material",
						Content = "Deleted Autoload",
					})
				end,
			})

			if isfile(SorinUI.Folder .. "/settings/autoload.txt") then
				local name = readfile(SorinUI.Folder .. "/settings/autoload.txt")
				loadlabel:Set({ Text = "Current autoload config: " .. name })
			end
		end

		function Tab:BuildThemeSection()
			local Title = Elements.Template.Title:Clone()
			Title.Text = "Theming"
			Title.Visible = true
			Title.Parent = TabPage
			Title.TextTransparency = 1
			TweenService:Create(Title, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()

			Tab:CreateSection("Custom Editor")

			local c1cp = Tab:CreateColorPicker({
				Name = "Color 1",
				Color = Color3.fromRGB(117, 164, 206),
			}, "SorinUIInterfaceSuitePrebuiltCPC1")

			local c2cp = Tab:CreateColorPicker({
				Name = "Color 2",
				Color = Color3.fromRGB(123, 201, 201),
			}, "SorinUIInterfaceSuitePrebuiltCPC2")

			local c3cp = Tab:CreateColorPicker({
				Name = "Color 3",
				Color = Color3.fromRGB(224, 138, 184),
			}, "SorinUIInterfaceSuitePrebuiltCPC3")

			task.wait(1)

			c1cp:Set({
				Callback = function(Value)
					if c2cp and c3cp then
						SorinUI.ThemeGradient = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Value or Color3.fromRGB(255,255,255)), ColorSequenceKeypoint.new(0.50, c2cp.Color or Color3.fromRGB(255,255,255)), ColorSequenceKeypoint.new(1.00, c3cp.Color or Color3.fromRGB(255,255,255))}
						SorinUI_Frame.ThemeRemote.Value = not SorinUI_Frame.ThemeRemote.Value
					end
				end
			})

			c2cp:Set({
				Callback = function(Value)
					if c1cp and c3cp then
						SorinUI.ThemeGradient = ColorSequence.new{ColorSequenceKeypoint.new(0.00, c1cp.Color or Color3.fromRGB(255,255,255)), ColorSequenceKeypoint.new(0.50, Value or Color3.fromRGB(255,255,255)), ColorSequenceKeypoint.new(1.00, c3cp.Color or Color3.fromRGB(255,255,255))}
						SorinUI_Frame.ThemeRemote.Value = not SorinUI_Frame.ThemeRemote.Value
					end
				end
			})

			c3cp:Set({
				Callback = function(Value)
					if c1cp and c2cp then
						SorinUI.ThemeGradient = ColorSequence.new{ColorSequenceKeypoint.new(0.00, c1cp.Color or Color3.fromRGB(255,255,255)), ColorSequenceKeypoint.new(0.50, c2cp.Color or Color3.fromRGB(255,255,255)), ColorSequenceKeypoint.new(1.00, Value or Color3.fromRGB(255,255,255))}
						SorinUI_Frame.ThemeRemote.Value = not SorinUI_Frame.ThemeRemote.Value
					end
				end
			})

			Tab:CreateSection("Preset Gradients")

			for i, v in pairs(PresetGradients) do
				Tab:CreateButton({
					Name = tostring(i),
					Callback = function()
						c1cp:Set({ Color = v[1] })
						c2cp:Set({ Color = v[2] })
						c3cp:Set({ Color = v[3] })
					end,
				})
			end
		end

		local function BuildFolderTree()
			if isStudio then return "Config system unavailable." end
			local paths = {
				SorinUI.Folder,
				SorinUI.Folder .. "/settings"
			}

			for i = 1, #paths do
				local str = paths[i]
				if not isfolder(str) then
					makefolder(str)
				end
			end
		end

		local function SetFolder()
			if isStudio then return "Config system unavailable." end

			if WindowSettings.ConfigSettings.RootFolder ~= nil and WindowSettings.ConfigSettings.RootFolder ~= "" then
				SorinUI.Folder = WindowSettings.ConfigSettings.RootFolder .. "/" .. WindowSettings.ConfigSettings.ConfigFolder
			else
				SorinUI.Folder = WindowSettings.ConfigSettings.ConfigFolder
			end

			BuildFolderTree()
		end

		SetFolder()

		function SorinUI:SaveConfig(Path)
			if isStudio then return "Config system unavailable." end

			if (not Path) then
				return false, "Please select a config file."
			end

			local fullPath = SorinUI.Folder .. "/settings/" .. Path .. ".luna"

			local data = {
				objects = {}
			}

			for flag, option in next, SorinUI.Options do
				if not ClassParser[option.Class] then continue end
				if option.IgnoreConfig then continue end

				table.insert(data.objects, ClassParser[option.Class].Save(flag, option))
			end	

			local success, encoded = pcall(HttpService.JSONEncode, HttpService, data)
			if not success then
				return false, "Unable to encode into JSON data"
			end

			writefile(fullPath, encoded)
			return true
		end

		function SorinUI:LoadConfig(Path)
			if isStudio then return "Config system unavailable." end

			if (not Path) then
				return false, "Please select a config file."
			end

			local file = SorinUI.Folder .. "/settings/" .. Path .. ".luna"
			if not isfile(file) then return false, "Invalid file" end

			local success, decoded = pcall(HttpService.JSONDecode, HttpService, readfile(file))
			if not success then return false, "Unable to decode JSON data." end

			for _, option in next, decoded.objects do
				if ClassParser[option.type] then
					task.spawn(function() 
						ClassParser[option.type].Load(option.flag, option) 
					end)
				end
			end

			return true
		end

		function SorinUI:LoadAutoloadConfig()
			if isfile(SorinUI.Folder .. "/settings/autoload.txt") then
				if isStudio then return "Config system unavailable." end

				local name = readfile(SorinUI.Folder .. "/settings/autoload.txt")

				local success, err = SorinUI:LoadConfig(name)
				if not success then
					return SorinUI:Notification({
						Title = "SorinServices UI",
						Icon = "sparkle",
						ImageSource = "Material",
						Content = "Failed to load autoload config: " .. err,
					})
				end

				SorinUI:Notification({
					Title = "SorinServices UI",
					Icon = "sparkle",
					ImageSource = "Material",
					Content = string.format("Auto loaded config %q", name),
				})
			end 
		end

		function SorinUI:RefreshConfigList()
			if isStudio then return "Config system unavailable." end

			local list = listfiles(SorinUI.Folder .. "/settings")

			local out = {}
			for i = 1, #list do
				local file = list[i]
				if file:sub(-5) == ".luna" then
					local pos = file:find(".luna", 1, true)
					local start = pos

					local char = file:sub(pos, pos)
					while char ~= "/" and char ~= "\\" and char ~= "" do
						pos = pos - 1
						char = file:sub(pos, pos)
					end

					if char == "/" or char == "\\" then
						local name = file:sub(pos + 1, start - 1)
						if name ~= "options" then
							table.insert(out, name)
						end
					end
				end
			end

			return out
		end

		local ClassParser = {
			["Toggle"] = {
				Save = function(Flag, data)
					return {
						type = "Toggle", 
						flag = Flag, 
						state = data.CurrentValue or false
					}
				end,
				Load = function(Flag, data)
					if SorinUI.Options[Flag] then
						SorinUI.Options[Flag]:Set({ CurrentValue = data.state })
					end
				end
			},
			["Slider"] = {
				Save = function(Flag, data)
					return {
						type = "Slider", 
						flag = Flag, 
						value = (data.CurrentValue and tostring(data.CurrentValue)),
					}
				end,
				Load = function(Flag, data)
					if SorinUI.Options[Flag] and data.value then
						SorinUI.Options[Flag]:Set({ CurrentValue = data.value })
					end
				end
			},
			["Input"] = {
				Save = function(Flag, data)
					return {
						type = "Input", 
						flag = Flag, 
						text = data.CurrentValue
					}
				end,
				Load = function(Flag, data)
					if SorinUI.Options[Flag] and data.text and type(data.text) == "string" then
						SorinUI.Options[Flag]:Set({ CurrentValue = data.text })
					end
				end
			},
			["Dropdown"] = {
				Save = function(Flag, data)
					return {
						type = "Dropdown", 
						flag = Flag, 
						value = data.CurrentOption
					}
				end,
				Load = function(Flag, data)
					if SorinUI.Options[Flag] and data.value then
						SorinUI.Options[Flag]:Set({ CurrentOption = data.value })
					end
				end
			},
			["Colorpicker"] = {
				Save = function(Flag, data)
					local function Color3ToHex(color)
						return string.format("#%02X%02X%02X", math.floor(color.R * 255), math.floor(color.G * 255), math.floor(color.B * 255))
					end

					return {
						type = "Colorpicker", 
						flag = Flag, 
						color = Color3ToHex(data.Color) or nil,
						alpha = data.Alpha
					}
				end,
				Load = function(Flag, data)
					local function HexToColor3(hex)
						local r = tonumber(hex:sub(2, 3), 16) / 255
						local g = tonumber(hex:sub(4, 5), 16) / 255
						local b = tonumber(hex:sub(6, 7), 16) / 255
						return Color3.new(r, g, b)
					end

					if SorinUI.Options[Flag] and data.color then
						SorinUI.Options[Flag]:Set({Color = HexToColor3(data.color)})
					end
				end
			}
		}

		Elements.Parent.Visible = true
		tween(Elements.Parent, {BackgroundTransparency = 0.1})
		Navigation.Visible = true
		tween(Navigation.Line, {BackgroundTransparency = 0})

		for _, TopbarButton in ipairs(Main.Controls:GetChildren()) do
			if TopbarButton.ClassName == "Frame" and TopbarButton.Name ~= "Theme" then
				TopbarButton.Visible = true
				tween(TopbarButton, {BackgroundTransparency = 0.25})
				tween(TopbarButton.UIStroke, {Transparency = 0.5})
				tween(TopbarButton.ImageLabel, {ImageTransparency = 0.25})
			end
		end

		Main.Controls.Close.ImageLabel.MouseButton1Click:Connect(function()
			Hide(Main, Window.Bind, true)
			dragBar.Visible = false
			Window.State = false
			if UserInputService.KeyboardEnabled == false then
				SorinUI_Frame.MobileSupport.Visible = true
			end
		end)
		Main.Controls.Close.MouseEnter:Connect(function()
			tween(Main.Controls.Close.ImageLabel, {ImageColor3 = Color3.new(1,1,1)})
		end)
		Main.Controls.Close.MouseLeave:Connect(function()
			tween(Main.Controls.Close.ImageLabel, {ImageColor3 = Color3.fromRGB(195,195,195)})
		end)

		UserInputService.InputBegan:Connect(function(input, gpe)
			if gpe then return end
			if Window.State then return end
			if input.KeyCode == Window.Bind then
				Unhide(Main, Window.CurrentTab)
				SorinUI_Frame.MobileSupport.Visible = false
				dragBar.Visible = true
				Window.State = true
			end
		end)

		Main.Logo.MouseButton1Click:Connect(function()
			if Navigation.Size.X.Offset == 205 then
				tween(Elements.Parent, {Size = UDim2.new(1, -55, Elements.Parent.Size.Y.Scale, Elements.Parent.Size.Y.Offset)})
				tween(Navigation, {Size = UDim2.new(Navigation.Size.X.Scale, 55, Navigation.Size.Y.Scale, Navigation.Size.Y.Offset)})
			else
				tween(Elements.Parent, {Size = UDim2.new(1, -205, Elements.Parent.Size.Y.Scale, Elements.Parent.Size.Y.Offset)})
				tween(Navigation, {Size = UDim2.new(Navigation.Size.X.Scale, 205, Navigation.Size.Y.Scale, Navigation.Size.Y.Offset)})
			end
		end)

		Main.Controls.ToggleSize.ImageLabel.MouseButton1Click:Connect(function()
			Window.Size = not Window.Size
			if Window.Size then
				Minimize(Main)
				dragBar.Visible = false
			else
				Maximise(Main)
				dragBar.Visible = true
			end
		end)
		Main.Controls.ToggleSize.MouseEnter:Connect(function()
			tween(Main.Controls.ToggleSize.ImageLabel, {ImageColor3 = Color3.new(1,1,1)})
		end)
		Main.Controls.ToggleSize.MouseLeave:Connect(function()
			tween(Main.Controls.ToggleSize.ImageLabel, {ImageColor3 = Color3.fromRGB(195,195,195)})
		end)

		Main.Controls.Theme.ImageLabel.MouseButton1Click:Connect(function()
			if Window.Settings then
				Window.Settings:Activate()
				Elements.Settings.CanvasPosition = Vector2.new(0,698)
			end
		end)
		Main.Controls.Theme.MouseEnter:Connect(function()
			tween(Main.Controls.Theme.ImageLabel, {ImageColor3 = Color3.new(1,1,1)})
		end)
		Main.Controls.Theme.MouseLeave:Connect(function()
			tween(Main.Controls.Theme.ImageLabel, {ImageColor3 = Color3.fromRGB(195,195,195)})
		end)

		SorinUI_Frame.MobileSupport.Interact.MouseButton1Click:Connect(function()
			Unhide(Main, Window.CurrentTab)
			dragBar.Visible = true
			Window.State = true
			SorinUI_Frame.MobileSupport.Visible = false
		end)

		return Window
	end

	function SorinUI:Destroy()
		Main.Visible = false
		for _, Notification in ipairs(Notifications:GetChildren()) do
			if Notification.ClassName == "Frame" then
				Notification.Visible = false
				Notification:Destroy()
			end
		end
		SorinUI_Frame:Destroy()
	end

	-- Optionales Studio-Demo (nur im Studio)
	if isStudio then
		local Window = SorinUI:CreateWindow({
			Name = "SorinServices UI | Blade Ball",
			Subtitle = "by SorinServices",
			LogoID = "123795201100198",
			LoadingEnabled = true,
			LoadingTitle = "SorinServices UI",
			LoadingSubtitle = "Loading script for Blade Ball",
			KeySystem = true,
			KeySettings = {
				Title = "SorinServices | Key System",
				Subtitle = "Blade Ball",
				Note = "Please Enter Your Key To Use SorinServices",
				FileName = "Key",
				SaveKey = true,
				Key = {"Example Key"},
				SecondAction = {
					Enabled = true,
					Type = "Link",
					Parameter = ""
				}
			}
		})
	end

	return SorinUI
