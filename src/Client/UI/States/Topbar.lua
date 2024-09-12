local RoRooms = require(script.Parent.Parent.Parent.Parent.Parent)
local States = require(script.Parent)
local OnyxUI = require(RoRooms.Packages.OnyxUI)
local Fusion = require(RoRooms.Packages.Fusion)

local Topbar = {
	NativeButtons = {
		Settings = {
			MenuName = "SettingsMenu",
			Icon = "rbxassetid://17273236509",
			IconFilled = "rbxassetid://17273236289",
			LayoutOrder = 5,
			IndicatorColor = Theme.Colors.Warning.Main,
			IndicatorEnabled = Scope:Computed(function(Use)
				return Use(States.RoRooms.UpToDate) == false
			end),
		},
		Emotes = {
			MenuName = "EmotesMenu",
			Icon = "rbxassetid://17273236115",
			IconFilled = "rbxassetid://17273235955",
			LayoutOrder = 3,
		},
		Friends = {
			MenuName = "FriendsMenu",
			Icon = "rbxassetid://17273235804",
			IconFilled = "rbxassetid://17273235655",
			LayoutOrder = 2,
		},
		Profile = {
			MenuName = "ProfileMenu",
			Icon = "rbxassetid://17273235245",
			IconFilled = "rbxassetid://17273235099",
			LayoutOrder = 1,
		},
		Worlds = {
			MenuName = "WorldsMenu",
			Icon = "rbxassetid://17273758646",
			IconFilled = "rbxassetid://17273758509",
			LayoutOrder = 4,
		},
	},
}

function Topbar:AddDefaultButtons()
	for Name, Button in pairs(self.NativeButtons) do
		self:AddTopbarButton(Name, Button)
	end
end

function Topbar:AddTopbarButton(
	Name: string,
	Button: {
		[string]: {
			MenuName: string,
			Icon: string,
			SizeMultiplier: number,
			LayoutOrder: number,
		},
	}
)
	local TopbarButtons = Use(States.TopbarButtons)

	TopbarButtons[Name] = Button

	States.TopbarButtons:set(TopbarButtons)
end

function Topbar:RemoveTopbarButton(Name: string)
	local TopbarButtons = Use(States.TopbarButtons)

	TopbarButtons[Name] = nil

	States.TopbarButtons:set(TopbarButtons)
end

return Topbar
