--:: 90% of this was coded while sleep deprived

--:: Variables
local Library = {
	Settings = {
		ConfigWindow = {
			MinSize = Vector2.new(200, 0);
			MaxSize = Vector2.new(200, 240);
		};
		Tab = {
			MinSize = Vector2.new(200, 0);
			MaxSize = Vector2.new(200, 400);
		}
	};

	UI = {
		Objects = game:GetObjects("https://assetdelivery.roblox.com/v1/asset/?id=10400859799")[1];
	};

	AnimationSettings = {
		["ButtonObject"] = {
			MouseEnter = {
				Transparency = {
					Info   = TweenInfo.new(0.15, Enum.EasingStyle.Quad);
					Change = { BackgroundTransparency = 0.65 };
				};
			};

			MouseLeave = {
				Transparency = {
					Info   = TweenInfo.new(0.15, Enum.EasingStyle.Quad);
					Change = { BackgroundTransparency = 1 };
				};
			};

			MouseButton1Click = {
				State1 = {
					Info   = TweenInfo.new(0.15, Enum.EasingStyle.Quad);
					Change = { Size = UDim2.new(1, -20, 0, 28)};
				};
				State2 = {
					Info   = TweenInfo.new(0.15, Enum.EasingStyle.Quad);
					Change = { Size = UDim2.new(1, -10, 0, 28)};
				};
				[true] = {
					Info   = TweenInfo.new(0.15, Enum.EasingStyle.Quad);
					Change = { TextColor3 = Color3.fromRGB(111, 183, 102) };
				};
				[false] = {
					Info   = TweenInfo.new(0.15, Enum.EasingStyle.Quad);
					Change = { TextColor3 = Color3.fromRGB(255, 255, 255) };
				};
			};
		};
		["ToggleObject"] = {
			MouseEnter = {
				Transparency = {
					Info   = TweenInfo.new(0.15, Enum.EasingStyle.Quad);
					Change = { BackgroundTransparency = 0.65 };
				};
			};

			MouseLeave = {
				Transparency = {
					Info   = TweenInfo.new(0.15, Enum.EasingStyle.Quad);
					Change = { BackgroundTransparency = 1 };
				};
			};

			MouseButton1Click = {
				["Ball-true"] = {
					Info   = TweenInfo.new(0.15, Enum.EasingStyle.Quad);
					Change = { Position = UDim2.new(1, -5, 0.5, 0) };
				};
				["Ball-false"] = {
					Info   = TweenInfo.new(0.15, Enum.EasingStyle.Quad);
					Change = { Position = UDim2.new(0, -5, 0.5, 0) };
				};
				["Indicator-true"] = {
					Info   = TweenInfo.new(0.15, Enum.EasingStyle.Quad);
					Change = { BackgroundColor3 = Color3.fromRGB(111, 183, 102) };
				};
				["Indicator-false"] = {
					Info   = TweenInfo.new(0.15, Enum.EasingStyle.Quad);
					Change = { BackgroundColor3 = Color3.fromRGB(226, 53, 56) };
				};

			};
		};
		["BoxObject"] = {
			MouseEnter = {
				Transparency = {
					Info   = TweenInfo.new(0.15, Enum.EasingStyle.Quad);
					Change = { BackgroundTransparency = 0.65 };
				};
			};

			MouseLeave = {
				Transparency = {
					Info   = TweenInfo.new(0.15, Enum.EasingStyle.Quad);
					Change = { BackgroundTransparency = 1 };
				};
			};

			Focus = {
				Focused = {
					Info   = TweenInfo.new(0.15, Enum.EasingStyle.Quad);
					Change = { Transparency = 0 };
				};
				FocusLost = {
					Info   = TweenInfo.new(0.15, Enum.EasingStyle.Quad);
					Change = { Transparency = 1 };
				};
			};
		};
	};

	Icons  = {
		Combat   = "rbxassetid://10401329089";
		Movement = "rbxassetid://10403468113";
		Visuals  = "rbxassetid://10403490626";
		Settings = "rbxassetid://10403508076";
		Others   = "rbxassetid://10403543022";
	};
	Flags  = {};

	Shown  = true;
	Count  = 0;

	--:: this is unused (might re-add being able to resize tabs)
	Sizing = { 
		Dragging        = false;
		StartPosition   = nil;
		StartSize       = nil;
		Input           = nil;
	};
}

local Game				= game
local GetService 		= Game.GetService
local GetChangedSignal 	= Game.GetPropertyChangedSignal
local FindFirstChild	= Game.FindFirstChild
local IsDescendantOf	= Game.IsDescendantOf

local Connect, Disconnect do 
	local RBXScriptSignal 		= Game.Loaded; Connect = RBXScriptSignal.Connect
	local RBXScriptConnection 	= Connect(RBXScriptSignal, function() end); Disconnect = RBXScriptConnection.Disconnect

	Disconnect(RBXScriptConnection)
end

local TweenService  	= GetService(Game, "TweenService")
local UserInputService 	= GetService(Game, "UserInputService")
local GuiService 		= GetService(Game, "GuiService")
local HttpService 		= GetService(Game, "HttpService")
local RunService        = GetService(Game, "RunService")
local CoreGui    		= GetService(Game, "CoreGui")
local Players    		= GetService(Game, "Players")

local GuiInset			= GuiService.GetGuiInset(GuiService)

local ScreenGUIs        = { Popouts = Instance.new("ScreenGui"); Tabs = Instance.new("ScreenGui"); } do
	for i,v in next, ScreenGUIs do
		syn.protect_gui(v)
		v.Parent = CoreGui
	end
end

--:: Local Tables
local ConnectionManager = {Connections = {}; Paused = {}; } do
	function ConnectionManager:Clear()
		local index_count = 0
		for i,v in next, self.Connections do
			index_count = index_count + 1

			Disconnect(v.Connection)

			table.remove(self.Connections, index_count)
		end
	end
	function ConnectionManager:Add(ObjectA, SignalA, FunctionA)
		local Object, Signal, Function = ObjectA, SignalA, FunctionA

		if type(SignalA) == "string" then
			Signal = Object[SignalA]

			local Connection; Connection = Signal.Connect(Signal, function(...)
				if self.Paused[Connection] == true then 
					return 
				end
				Function(...)
			end)

			self.Connections[#self.Connections + 1] = { Object = ObjectA; Connection = Connection; }

			return Connection
		else
			Function = SignalA
			Signal   = ObjectA

			local Connection; Connection = Signal.Connect(Signal, function(...)
				if self.Paused[Connection] == true then 
					return 
				end
				Function(...)
			end)

			self.Connections[#self.Connections + 1] = { Connection = Connection; }

			return Connection
		end
	end
	function ConnectionManager:Stop(Check)
		for i,v in next, self.Connections do
			if Check(v.Object) then
				self.Paused[v.Connection] = true
			end
		end
	end
	function ConnectionManager:Start()
		for i,v in next, self.Connections do
			if self.Paused[v.Connection] then
				self.Paused[v.Connection] = false
			end
		end
	end
end


--:: Local Functions
local function GetMouseLocation()
	return (UserInputService.GetMouseLocation(UserInputService) - GuiInset)
end

local function IsMouseButtonDown(Button)
	return UserInputService.IsMouseButtonPressed(UserInputService, Enum.UserInputType[Button])
end


local function AddDragger(Object)
	local Success, _ = pcall(function()
		return Object.MouseEnter
	end)

	if Success then
		ConnectionManager:Add(Object, "MouseEnter", function()
			local InputBeganConn = Connect(Object.InputBegan, function(Input)
				if Input.UserInputType == Enum.UserInputType.MouseButton1 then
					local StartPosition = Vector2.new(Input.Position.X, Input.Position.Y) - Object.AbsolutePosition
 
					while IsMouseButtonDown("MouseButton1") do
						local NewPosition = GetMouseLocation() - StartPosition

						Object:TweenPosition(UDim2.new(0, NewPosition.X, 0, NewPosition.Y), "Out", "Linear", 0.01, true)

						task.wait()
					end
				end
			end)

			local MouseLeaveConn
			MouseLeaveConn = Connect(Object.MouseLeave, function()
				Disconnect(InputBeganConn)
				Disconnect(MouseLeaveConn)
			end)
		end)
	end
end

local function CreateTween(Object, Event, Setting, CustomClass)
	local Table = Library.AnimationSettings[CustomClass or Object.ClassName][Event][Setting]

	return TweenService.Create(TweenService, Object, Table.Info, Table.Change)
end

local function UpdateSlider(SliderFrame, Position, Properties)
	local SliderLimit  	= SliderFrame.SliderLimit
	local SliderObject 	= SliderLimit.SliderObject
	local SliderText 	= FindFirstChild(SliderFrame, "Text")

	if Position == "Init" then
		local NewSize = SliderLimit.AbsoluteSize.X / (Properties.Min + (Properties.Max - Properties.Min)) * Properties.Default --// this sucks and imk too lazy to fix

		SliderText.Text = string.format("%s <i>%s</i>", Properties.Title, Properties.Default)

		Library.Flags[Properties.Flag] = Properties.Default
	
		pcall(Properties.Callback, Properties.Default)

		SliderObject.Size 	= UDim2.new(SliderObject.Size.X.Scale, NewSize, SliderObject.Size.Y.Scale, SliderObject.Size.Y.Offset)
		return
	end

	local MaxSizeX 		= SliderLimit.AbsoluteSize.X
	local DeltaX 		= Position.X - SliderLimit.AbsolutePosition.X

	SliderObject.Size 	= UDim2.new(SliderObject.Size.X.Scale, math.clamp(DeltaX, 0, MaxSizeX), SliderObject.Size.Y.Scale, SliderObject.Size.Y.Offset)

	local Value 		= math.floor( Properties.Min + ( ( ( Properties.Max - Properties.Min ) / MaxSizeX ) * SliderObject.AbsoluteSize.X ) )
	SliderText.Text 	= string.format("%s <i>%s</i>", Properties.Title, Value)

	Library.Flags[Properties.Flag] = Value

	pcall(Properties.Callback, Value)
end

local function IsHoveringObject(Object)
	local Location = GetMouseLocation()

	local tx = Object.AbsolutePosition.X
	local ty = Object.AbsolutePosition.Y
	local bx = tx + Object.AbsoluteSize.X
	local by = ty + Object.AbsoluteSize.Y
	if Location.X >= tx and Location.Y >= ty and Location.X <= bx and Location.Y <= by then
		return true
	end
	return false
end

local function ToggleConfigWindow(Visible, __self, Window)
	if Visible then
		ConnectionManager:Stop(function(Object)
			if (Object == nil) or (Object == UserInputService) or (IsDescendantOf(Object, Window)) then return false end

			return true
		end)
	else
		ConnectionManager:Start()
	end

	local Mouse = GetMouseLocation()

	local NewSize = Visible and __self:Resize() or Library.Settings.ConfigWindow.MinSize do
		NewSize = Vector2.new(NewSize.X, math.clamp(NewSize.Y, Library.Settings.ConfigWindow.MinSize.Y, Library.Settings.ConfigWindow.MaxSize.Y) )

		NewSize = UDim2.new(0, NewSize.X, 0, NewSize.Y)
	end

	local NewPosition     = Visible and UDim2.new(0, Mouse.X, 0, Mouse.Y) or Window.Position
	local NewTransparency = Visible and 0.5 or 1


	Window.Position = NewPosition
	TweenService.Create(TweenService, Window.UIStroke, TweenInfo.new(0.15, Enum.EasingStyle.Quad), { Transparency = NewTransparency }):Play()
	TweenService.Create(TweenService, Window, 		   TweenInfo.new(0.15, Enum.EasingStyle.Quad), { Size 		  = NewSize }):Play()
end

--:: Start Functions Table
local Functions = { 
	ConfigWindow 	= nil; 
	Objects 		= {}; 
	Internal 		= {}; 
	ConfigPages 	= {}; 
	StoredToolTips 	= {};
	CurrentSlider 	= { 
		Sliding = false; 
		Input 	= nil; 
		Frame 	= nil; 
		Props   = nil; 
	}; 
}
Functions.__index = Functions

--:: Internal Functions
function Functions.Internal:AddToolTip(Object, Text)
	local MouseOnObject = true

	local ToolTip  = Functions.StoredToolTips[Object] or Library.UI.Objects.ToolTip:Clone()
	ToolTip.Parent = ScreenGUIs.Popouts
	Functions.StoredToolTips[Object] = ToolTip

	local TitleLabel = ToolTip.TitleLabel
	local DropShadow = TitleLabel.DropShadow
	local UIStroke   = ToolTip.UIStroke

	TitleLabel.Text = Text
	DropShadow.Text = Text

	--:: Connections
	ConnectionManager:Add(Object, "MouseEnter", function()
		local MousePos   = UserInputService.GetMouseLocation(UserInputService)
		ToolTip.Position = UDim2.new(0, MousePos.X, 0, (MousePos.Y - GuiInset.Y) - 20 )

		TweenService.Create(TweenService, ToolTip, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {Size = UDim2.new(0, TitleLabel.TextBounds.X + 10, 0, 20)}):Play()
		TweenService.Create(TweenService, UIStroke, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {Transparency = 0}):Play()

		MouseOnObject = true
	end)

	ConnectionManager:Add(Object, "MouseLeave", function()
		TweenService.Create(TweenService, ToolTip, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 0, 0, 20)}):Play()
		TweenService.Create(TweenService, UIStroke, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Transparency = 1}):Play()

		MouseOnObject = false
	end)

	ConnectionManager:Add(Object, "MouseMoved", function()
		if MouseOnObject then
			local MousePos   = UserInputService.GetMouseLocation(UserInputService)
			ToolTip.Position = UDim2.new(0, MousePos.X, 0, (MousePos.Y - GuiInset.Y) - 20 )
		end
	end)
end

function Functions.Internal:InitConfigPage(Object, Properties, Callback)
	if (not Functions.ConfigPages[Object]) then
		local ClonedWindow  = Library.UI.Objects.ConfigWindow:Clone() 
		ClonedWindow.Parent = ScreenGUIs.Popouts
		Functions.ConfigPages[Object] = ClonedWindow

		self:InitScrollBar(ClonedWindow.ScrollBar, ClonedWindow.ScrollingFrame, 8)
	end

	local ConfigWindow 	= Functions.ConfigPages[Object]
    ConfigWindow.Size   = UDim2.new(0,200,0,0)
	local __self   		= Functions:InitItemHolder({ Parent = ConfigWindow.ScrollingFrame })

	ConnectionManager:Add(Object, "MouseButton2Click", function()
		local Visible = not (Functions.ConfigWindow ~= nil)

		if Functions.ConfigWindow then
			ToggleConfigWindow(false, nil, Functions.ConfigWindow)
			Functions.ConfigWindow = nil
		end

		Functions.ConfigWindow = ConfigWindow
		ToggleConfigWindow(Visible, __self, ConfigWindow)

		task.spawn(Callback)
	end)


	local UI_Elements = {} do
		for i, v in next, Properties do
			UI_Elements[i] = __self[v.Type](__self, v.Args)
		end
	end

	ToggleConfigWindow(false, nil, ConfigWindow)

	return {
		Close = function(self)
			ToggleConfigWindow(false, nil, Functions.ConfigWindow)
			Functions.ConfigWindow = nil
		end
	}, UI_Elements
end

function Functions.Internal:InitScrollBar(ScrollBarObject, ScrollFrame, ScrollBarSize)
	local ScrollingParent = ScrollFrame.Parent

	ScrollFrame.ScrollBarThickness = ScrollBarSize
	ScrollBarObject.Size = UDim2.new(0, ScrollBarSize, ScrollingParent.AbsoluteSize.Y / ScrollFrame.AbsoluteCanvasSize.Y , 0)

	--:: Changed Connections
	ConnectionManager:Add( GetChangedSignal(ScrollFrame, "CanvasPosition"), function()
		ScrollBarObject.Position = UDim2.new( ScrollBarObject.Position.X.Scale, ScrollBarObject.Position.X.Offset, (ScrollFrame.CanvasPosition.Y / ScrollFrame.AbsoluteCanvasSize.Y), 0)
	end)
	ConnectionManager:Add( GetChangedSignal(ScrollFrame, "AbsoluteCanvasSize"), function()
		ScrollBarObject.Size = UDim2.new(0, ScrollBarSize, ScrollingParent.AbsoluteSize.Y / ScrollFrame.AbsoluteCanvasSize.Y , 0)
	end)

	ConnectionManager:Add( GetChangedSignal(ScrollingParent, "AbsoluteSize"), function()
		ScrollBarObject.Size = UDim2.new(0, ScrollBarSize,  ScrollingParent.AbsoluteSize.Y / ScrollFrame.AbsoluteCanvasSize.Y , 0)
	end)
end

function Functions.Internal:InitButton(ButtonObject, Properties)
	local IsToggleable  = Properties.Toggleable or false
	local Default		= Properties.Default 	or false
	local Title			= Properties.Title 		or "No title set."
	local Callback		= Properties.Callback 	or (function(...) print("No callback set.", ...) end)

	local Flag			= Properties.Flag 	or tostring(math.random())
	Properties.Flag		= Flag

	local Toggled       = Default

	local TextObject 	= FindFirstChild(ButtonObject, "Text")
	local DropShadow 	= TextObject.DropShadow

	--:: Sync Connection
	ConnectionManager:Add(GetChangedSignal(TextObject, "Text"), function()
		DropShadow.Text = TextObject.Text
	end)

	--:: Tween Connections
	ConnectionManager:Add(ButtonObject, "MouseEnter", function()
		CreateTween(ButtonObject, "MouseEnter", "Transparency", "ButtonObject"):Play()
	end)

	ConnectionManager:Add(ButtonObject, "MouseLeave", function()
		CreateTween(ButtonObject, "MouseLeave", "Transparency", "ButtonObject"):Play()
	end)

	ConnectionManager:Add(ButtonObject, "MouseButton1Down", function()
		CreateTween(TextObject, "MouseButton1Click", "State1", "ButtonObject"):Play()
	end)

	ConnectionManager:Add(ButtonObject, "MouseButton1Up", function()
		CreateTween(TextObject, "MouseButton1Click", "State2", "ButtonObject"):Play()
	end)


	--:: Click Connection
	ConnectionManager:Add(ButtonObject, "MouseButton1Click", function()
		if IsToggleable then
			Toggled = not Toggled

			Library.Flags[Flag] = Toggled

			pcall(Callback, Toggled)

			CreateTween(TextObject, "MouseButton1Click", Toggled, "ButtonObject"):Play()
		else
			pcall(Callback)
		end
	end)

	--:: End Init

	if IsToggleable then
		pcall(Callback, Toggled)
		CreateTween(TextObject, "MouseButton1Click", Toggled, "ButtonObject"):Play()
	end

	TextObject.Text = Title

	return ButtonObject
end

function Functions.Internal:InitSlider(SliderObject, Properties)
	Properties.Min		= Properties.Min 		or 0
	Properties.Max 		= Properties.Max		or 10
	Properties.Default	= Properties.Default    or Properties.Max / 2

	local Title			= Properties.Title 		or "No title set."
	local Callback		= Properties.Callback 	or (function(...) print("No callback set.", ...) end)

	local Flag		= Properties.Flag 	or tostring(math.random())
	Properties.Flag = Flag

	local TextObject 	= FindFirstChild(SliderObject, "Text")
	local DropShadow 	= TextObject.DropShadow

	--:: Sync Connection
	ConnectionManager:Add(GetChangedSignal(TextObject, "Text"), function()
		DropShadow.Text = TextObject.Text
	end)

	--:: Tween Connections
	ConnectionManager:Add(SliderObject, "MouseEnter", function()
		CreateTween(SliderObject, "MouseEnter", "Transparency", "ButtonObject"):Play()
	end)

	ConnectionManager:Add(SliderObject, "MouseLeave", function()
		CreateTween(SliderObject, "MouseLeave", "Transparency", "ButtonObject"):Play()
	end)

	--:: Sliding Connections
	ConnectionManager:Add(SliderObject, "InputBegan", function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 then
			Functions.CurrentSlider.Sliding		= true
			Functions.CurrentSlider.Frame   	= SliderObject
			Functions.CurrentSlider.Props 		= Properties

			local InputChangedConnection
			InputChangedConnection =  ConnectionManager:Add(Input, "Changed", function()
				if Input.UserInputState == Enum.UserInputState.End then
					Functions.CurrentSlider.Sliding		= false
					Functions.CurrentSlider.Input		= nil
					Functions.CurrentSlider.Frame   	= nil
					Functions.CurrentSlider.Props 		= nil

					InputChangedConnection.Disconnect(InputChangedConnection)
				end
			end)
		end
	end)

	ConnectionManager:Add(SliderObject, "InputChanged", function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseMovement then
			Functions.CurrentSlider.Input = Input
		end
	end)

	--:: End Init

	UpdateSlider(SliderObject, "Init", Properties)

	return SliderObject
end

function Functions.Internal:InitToggle(ToggleObject, Properties)
	local Default			= Properties.Default 	or false
	local Title				= Properties.Title 		or "No title set."
	local Callback			= Properties.Callback 	or (function(...) print("No callback set.", ...) end)
	local CallbackOnStart	= Properties.CallbackOnStart or false

	local Flag				= Properties.Flag 	or tostring(math.random())
	Properties.Flag 		= Flag

	local Value				= Default or false

	local ToggleIndicator 	= ToggleObject.ToggleIndicator
	local ToggleBall 		= ToggleIndicator.ToggleBall

	local TextObject 		= FindFirstChild(ToggleObject, "Text")
	local DropShadow 		= TextObject.DropShadow

	--:: Sync Connection
	ConnectionManager:Add(GetChangedSignal(TextObject, "Text"), function()
		DropShadow.Text = TextObject.Text
	end)

	--:: Tween Connections
	ConnectionManager:Add(ToggleObject, "MouseEnter", function()
		CreateTween(ToggleObject, "MouseEnter", "Transparency", "ToggleObject"):Play()
	end)

	ConnectionManager:Add(ToggleObject, "MouseLeave", function()
		CreateTween(ToggleObject, "MouseLeave", "Transparency", "ToggleObject"):Play()
	end)

	--:: Toggle	 Connection
	ConnectionManager:Add(ToggleObject, "MouseButton1Click", function()
		Value = not Value
		Library.Flags[Flag] = Value

		pcall(Callback, Value)

		CreateTween(ToggleBall, "MouseButton1Click", "Ball-" .. tostring(Value), "ToggleObject"):Play()
		CreateTween(ToggleIndicator, "MouseButton1Click", "Indicator-" .. tostring(Value),  "ToggleObject"):Play()
	end)

	--:: Init End
	if CallbackOnStart then
		Library.Flags[Flag] = Value
		pcall(Callback, Value)
	end

	CreateTween(ToggleBall, "MouseButton1Click", "Ball-" .. tostring(Value), "ToggleObject"):Play()
	CreateTween(ToggleIndicator, "MouseButton1Click", "Indicator-" .. tostring(Value),  "ToggleObject"):Play()

	TextObject.Text = Title

	return { 
		Set = function(Value)
			Library.Flags[Flag] = Value
			Value = not Value

			CreateTween(ToggleBall, "MouseButton1Click", "Ball-" .. tostring(Value), "ToggleObject"):Play()
			CreateTween(ToggleIndicator, "MouseButton1Click", "Indicator-" .. tostring(Value),  "ToggleObject"):Play()
		end;
		Get = function()
			return Value
		end;
		Type = "Toggle";
	}
end

function Functions.Internal:InitTextBox(BoxObject, Properties)
	local Title			= Properties.Title 		or "No title set."
	local Callback		= Properties.Callback 	or (function(...) print("No callback set.", ...) end)

	local TextBox		= BoxObject.TextBox
	local UIStroke		= TextBox.UIStroke

	--:: Tween Connections
	ConnectionManager:Add(BoxObject, "MouseEnter", function()
		CreateTween(BoxObject, "MouseEnter", "Transparency", "BoxObject"):Play()
	end)

	ConnectionManager:Add(BoxObject, "MouseLeave", function()
		CreateTween(BoxObject, "MouseLeave", "Transparency", "BoxObject"):Play()
	end)

	--:: Focus Connection
	ConnectionManager:Add(TextBox, "Focused", function()
		CreateTween(UIStroke, "Focus", "Focused", "BoxObject"):Play()
	end)

	ConnectionManager:Add(TextBox, "FocusLost", function()
		CreateTween(UIStroke, "Focus", "FocusLost", "BoxObject"):Play()
		pcall(Callback, TextBox.Text)
	end)

	--:: End Init
	TextBox.PlaceholderText = Title

	return BoxObject
end

--:: Exposed Functions
--[[function Functions:InitResizer(Object)
	ConnectionManager:Add(Object, "InputBegan", function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 then
			Library.Sizing.Dragging      = true
			Library.Sizing.StartPosition = Vector2.new(Input.Position.X, Input.Position.Y)
			Library.Sizing.StartSize     = Object.Parent.AbsoluteSize
			Library.Sizing.Object        = Object.Parent.ScrollingFrame

			local InputChangedConnection
			InputChangedConnection = ConnectionManager:Add(Input, "Changed", function()
				if Input.UserInputState == Enum.UserInputState.End then

					Library.Sizing.Dragging      = false
					Library.Sizing.StartPosition = nil
					Library.Sizing.StartSize     = nil
					Library.Sizing.Input         = nil

					InputChangedConnection.Disconnect(InputChangedConnection)
				end
			end)
		end
	end)

	ConnectionManager:Add(Object, "InputChanged", function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseMovement then
			Library.Sizing.Input = Input
		end
	end)
end]]

function Functions:Resize()
	local ScrollingFrame = self.Parent

	local MainFrame      = ScrollingFrame.Parent

	local CanvasSizeY = self.Count * 40
	ScrollingFrame.CanvasSize = UDim2.new(ScrollingFrame.CanvasSize.X.Scale, ScrollingFrame.CanvasSize.X.Offset, 0, CanvasSizeY)
	table.foreach(self, warn)
	MainFrame:TweenSize(
		(
			self.Visible and UDim2.new(MainFrame.Size.X.Scale, MainFrame.Size.X.Offset, 0, math.clamp(CanvasSizeY, 0, Library.Settings.Tab.MaxSize.Y) ) or UDim2.new(MainFrame.Size.X.Scale, MainFrame.Size.X.Offset, 0,  0)
		), 
		self.Visible and "Out" or "In", 
		"Linear", 
		0.15, 
		true
	)
	
	return ScrollingFrame.AbsoluteCanvasSize
end

function Functions:GetOrder() 
	return #self.Parent:GetChildren() - 1
end

function Functions:InitItemHolder(Properties)
	local ItemHolder = Properties.Parent

	self.Internal:InitScrollBar(ItemHolder.Parent.ScrollBar, ItemHolder, 8)

	return setmetatable({
		Parent = ItemHolder;
		Count  = 0;
	}, Functions)
end

function Functions:AddButton(Properties)
	local NewButton = Library.UI.Objects.Button:Clone() do
		NewButton.Parent 	  = self.Parent
		NewButton.LayoutOrder = self:GetOrder() 
	end
	self.Count = self.Count + 1
	self:Resize()


	self.Internal:InitButton(NewButton, Properties)

	return {
		AddConfiguration = function(_, Config)
			return self.Internal:InitConfigPage(NewButton, Config, function()
				CreateTween(NewButton, "MouseLeave", "Transparency", "ButtonObject"):Play()
			end)
		end;
        ChangeText = function(_, text)
            local Label = FindFirstChild(NewButton, "Text")
            Label.Text              = text
            Label.DropShadow.Text   = text
        end;
	}
end

function Functions:AddLabel(Properties)
	local NewButton = Library.UI.Objects.Button:Clone() do
		NewButton.Parent 	  = self.Parent
		NewButton.LayoutOrder = self:GetOrder() 
        NewButton.Active      = false
	end

    local Label = FindFirstChild(NewButton, "Text")
    Label.RichText              = true
    Label.DropShadow.RichText   = true

    Label.Text              = Properties.Text or Properties.Title or "None"
    Label.DropShadow.Text   = Label.Text

	self.Count = self.Count + 1
	self:Resize()

	return {
        ChangeText = function(_, text)
            Label.Text              = text
            Label.DropShadow.Text   = text
        end;
        ChangeColor = function(_, color)
            Label.TextColor3              = color
            Label.DropShadow.TextColor3   = color
        end;
	}
end

function Functions:AddToggle(Properties)
	local NewToggle = Library.UI.Objects.Toggle:Clone() do
		NewToggle.Parent 	  = self.Parent
		NewToggle.LayoutOrder = self:GetOrder() 
	end
	self.Count = self.Count + 1
	self:Resize()


	return self.Internal:InitToggle(NewToggle, Properties)
end

function Functions:AddSlider(Properties)
	local NewSlider = Library.UI.Objects.Slider:Clone() do
		NewSlider.Parent 	  = self.Parent
		NewSlider.LayoutOrder = self:GetOrder() 
	end
	self.Count = self.Count + 1
	self:Resize()


	return self.Internal:InitSlider(NewSlider, Properties)
end

function Functions:AddTextBox(Properties)
	local NewTextBox = Library.UI.Objects.Box:Clone() do
		NewTextBox.Parent 	   = self.Parent
		NewTextBox.LayoutOrder = self:GetOrder() 
	end
	self.Count = self.Count + 1
	self:Resize()

	return self.Internal:InitTextBox(NewTextBox, Properties)
end

--:: UserInputService Connections
ConnectionManager:Add(UserInputService, "InputChanged", function(Input)
	if Input == Functions.CurrentSlider.Input then
		if Functions.CurrentSlider.Sliding and Input.UserInputType == Enum.UserInputType.MouseMovement then
			UpdateSlider(
				Functions.CurrentSlider.Frame,
				Functions.CurrentSlider.Input.Position,
				Functions.CurrentSlider.Props
			)
		end
	end
	--[[elseif Input == Library.Sizing.Input then
		if Library.Sizing.Dragging and Input.UserInputType == Enum.UserInputType.MouseMovement then
			local ItemCount = #Library.Sizing.Object:GetChildren() - 1
			local MaxSizeY = ItemCount * 40

			MaxSizeY = math.clamp(MaxSizeY, 0, Library.Settings.Tab.MaxSize.Y)

			local DeltaY = Input.Position.Y - Library.Sizing.StartPosition.Y

			DeltaY = Library.Sizing.StartSize.Y + DeltaY
			DeltaY = math.clamp(DeltaY, 40, MaxSizeY)

			Library.Sizing.Object.Parent.Size = UDim2.new(0, Library.Sizing.StartSize.X, 0, DeltaY)
		end
	end]]
end)


ConnectionManager:Add(UserInputService, "InputBegan", function(Input)
	if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.MouseButton2 then
		local ConfigWindow = Functions.ConfigWindow
		if ConfigWindow then
			if IsHoveringObject( ConfigWindow ) == false then
				ToggleConfigWindow(false, nil, ConfigWindow)
				Functions.ConfigWindow = nil
			end
		end
	end

	if Input.UserInputType == Enum.UserInputType.Keyboard then
		if Input.KeyCode == Enum.KeyCode.RightShift then
			Library.Shown = not Library.Shown

			for i,v in next, ScreenGUIs do 
				v.Enabled = Library.Shown
			end
		end
	end
end)


function Library:NewTab(Properties)
	local TabTitle  = Properties.Title or "None"
	local TabIcon   = Properties.Icon  or ""

	self.Count   = self.Count + 1
	self.Visible = true

	local NewTab, MainFrame = Library.UI.Objects.Tab:Clone() do
		NewTab.Parent 		= ScreenGUIs.Tabs

		MainFrame			= NewTab.Underline.MainFrame
		MainFrame.ClipsDescendants = true

		NewTab.Position 	= (not self.LastTab) and UDim2.new(0, 25, 0, 25) or UDim2.new(0, self.LastTab.Position.X.Offset + NewTab.AbsoluteSize.X + 25, 0, 25 )
		self.LastTab		= NewTab
	end

	local __selfFuncs = Functions:InitItemHolder({ 
		Parent = MainFrame.ScrollingFrame;
	})

	__selfFuncs.Visible = true
	local ToggleButton = Instance.new("TextButton", NewTab.Title.Icon) do
		ToggleButton.Size 					= UDim2.new(1, 0, 1, 0)
		ToggleButton.Position 				= UDim2.new(1, 0, 1, 0)
		ToggleButton.AnchorPoint 			= Vector2.new(1, 1)
		ToggleButton.BackgroundTransparency = 1
		ToggleButton.Text					= ""
		ToggleButton.ZIndex					= 200

		ConnectionManager:Add(ToggleButton, "MouseButton1Click", function()
			__selfFuncs.Visible = not __selfFuncs.Visible
			__selfFuncs:Resize()
		end)
	end

	local TitleObject = NewTab.Title do
		TitleObject.Text 			= TabTitle
		TitleObject.DropShadow.Text = TabTitle

		TitleObject.Icon.Image 		= TabIcon
	end
	
	AddDragger(NewTab)

	return __selfFuncs
end

return Library


