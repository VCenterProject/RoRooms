local RoRooms = require(script.Parent.Parent.Parent.Parent.Parent)

local Shared = RoRooms.Shared
local Client = RoRooms.Client
local Config = RoRooms.Config

local Fusion = require(Shared.ExtPackages.NekaUI.Packages.Fusion)
local NekaUI = require(Shared.ExtPackages.NekaUI)
local States = require(Client.UI.States)

local Children = Fusion.Children
local Computed = Fusion.Computed
local ForValues = Fusion.ForValues
local New = Fusion.New
local Observer = Fusion.Observer
local Spring = Fusion.Spring
local Value = Fusion.Value
local Cleanup = Fusion.Cleanup

local Components = Client.UI.Components
local TopbarButton = require(Components.TopbarButton)
local AutoScaleFrame = require(NekaUI.Components.AutoScaleFrame)
local Frame = require(NekaUI.Components.Frame)
local BaseButton = require(NekaUI.Components.BaseButton)

local TOPBAR_BUTTONS = {
	{
		MenuName = "ProfileMenu",
		IconImage = "rbxassetid://15091717235",
	},
	{
		MenuName = "FriendsMenu",
		IconImage = "rbxassetid://16037713145",
	},
	{
		MenuName = "EmotesMenu",
		IconImage = "rbxassetid://15091717452",
	},
	{
		MenuName = "WorldsMenu",
		IconImage = "rbxassetid://15091717321",
	},
	{
		MenuName = "SettingsMenu",
		IconImage = "rbxassetid://15091717549",
	},
}
local FEATURE_MENU_MAP = {
	WorldsSystem = "WorldsMenu",
	ProfilesSystem = "ProfileMenu",
	EmotesSystem = "EmotesMenu",
	SettingsSystem = "SettingsMenu",
	FriendsSystem = "FriendsMenu",
}

return function(Props)
	local EnabledTopbarButtons = Computed(function()
		local EnabledButtons = {}
		for FeatureName, MenuName in pairs(FEATURE_MENU_MAP) do
			if Config[FeatureName].Enabled then
				table.insert(EnabledButtons, MenuName)
			end
		end
		return EnabledButtons
	end)
	local TopbarButtonsHeight = Value(0)
	local IsUnibarOpen = Computed(function()
		return States.TopbarInset:get().Min.X > 250
	end)

	local Observers = {}

	local TopbarInstance = New "ScreenGui" {
		Name = "Topbar",
		Parent = Props.Parent,
		ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets,
		ResetOnSpawn = false,

		[Cleanup] = {
			Observers,
		},

		[Children] = {
			AutoScaleFrame {
				AnchorPoint = Vector2.new(0.5, 0),
				Position = Spring(
					Computed(function()
						if States.TopbarVisible:get() then
							return UDim2.new(UDim.new(0.5, 0), UDim.new(0, 14))
						else
							return UDim2.new(UDim.new(0.5, 0), UDim.new(0, (-TopbarButtonsHeight:get()) - 2))
						end
					end),
					40,
					1
				),
				BaseResolution = Vector2.new(883, 893),
				ScaleClamps = { Min = 0.75, Max = math.huge },

				[Children] = {
					New "UIListLayout" {
						SortOrder = Enum.SortOrder.LayoutOrder,
						Padding = UDim.new(0, 15),
						HorizontalAlignment = Enum.HorizontalAlignment.Center,
					},
					Frame {
						Name = "TopbarButtons",
						-- Visible = States.TopbarVisible,

						[Children] = {
							New "UIListLayout" {
								SortOrder = Enum.SortOrder.LayoutOrder,
								Padding = UDim.new(0, 13),
								FillDirection = Enum.FillDirection.Horizontal,
								VerticalAlignment = Enum.VerticalAlignment.Center,
							},
							ForValues(TOPBAR_BUTTONS, function(Button)
								return Computed(function()
									if table.find(EnabledTopbarButtons:get(), Button.MenuName) then
										return TopbarButton {
											MenuName = Button.MenuName,
											IconImage = Button.IconImage,
											SizeMultiplier = Button.SizeMultiplier,
										}
									end
								end, Fusion.cleanup)
							end, Fusion.cleanup),
						},
					},
					BaseButton {
						Name = "PullButton",
						BackgroundTransparency = 0,
						BackgroundColor3 = Color3.fromRGB(26, 26, 26),
						Visible = Computed(function()
							return (typeof(States.CurrentMenu:get()) == "string") == false
						end),

						OnActivated = function()
							States.TopbarVisible:set(not States.TopbarVisible:get())
							States.CurrentMenu:set(nil)
							-- States.UserSettings.HideUI:set(false)
						end,

						[Children] = {
							New "UICorner" {
								CornerRadius = UDim.new(0, 25),
							},
							New "UIStroke" {
								ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
								Thickness = 3,
								Color = Color3.fromRGB(56, 56, 56),
							},
							New "UIPadding" {
								PaddingLeft = UDim.new(0, 16),
								PaddingBottom = UDim.new(0, 8),
								PaddingTop = UDim.new(0, 8),
								PaddingRight = UDim.new(0, 16),
							},
							New "Frame" {
								Size = UDim2.fromOffset(120, 3),
								AutomaticSize = Enum.AutomaticSize.None,
								BackgroundTransparency = 0,
								BackgroundColor3 = Color3.fromRGB(255, 255, 255),
							},
						},
					},
				},
			},
		},
	}

	local TopbarButtons = TopbarInstance.AutoScaleFrame.TopbarButtons
	local TopbarPully = TopbarInstance.AutoScaleFrame.PullButton

	local function UpdateTopbarBottomPos()
		States.TopbarBottomPos:set(TopbarPully.AbsolutePosition.Y)
	end

	table.insert(Observers, TopbarPully:GetPropertyChangedSignal("AbsoluteSize"):Connect(UpdateTopbarBottomPos))
	table.insert(Observers, TopbarPully:GetPropertyChangedSignal("AbsolutePosition"):Connect(UpdateTopbarBottomPos))
	UpdateTopbarBottomPos()

	local function UpdateTopbarButtonsHeight()
		TopbarButtonsHeight:set(TopbarButtons.AbsoluteSize.Y)
	end

	table.insert(Observers, TopbarButtons:GetPropertyChangedSignal("AbsoluteSize"):Connect(UpdateTopbarButtonsHeight))
	UpdateTopbarButtonsHeight()

	table.insert(
		Observers,
		Observer(IsUnibarOpen):onChange(function()
			States.TopbarVisible:set(not IsUnibarOpen:get())
			if IsUnibarOpen:get() then
				States.CurrentMenu:set(nil)
			end
		end)
	)
	table.insert(
		Observers,
		Observer(States.RobloxMenuOpen):onChange(function()
			States.TopbarVisible:set(not States.RobloxMenuOpen:get())
		end)
	)

	return TopbarInstance
end
