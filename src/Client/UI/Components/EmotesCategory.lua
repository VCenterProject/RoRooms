local RoRooms = require(script.Parent.Parent.Parent.Parent.Parent)
local OnyxUI = require(RoRooms.Packages.OnyxUI)
local Fusion = require(RoRooms.Packages.Fusion)
local States = require(RoRooms.Client.UI.States)

local Children = Fusion.Children
local Util = OnyxUI.Util
local Themer = OnyxUI.Themer

local EmoteButton = require(RoRooms.Client.UI.Components.EmoteButton)

return function(Scope: Fusion.Scope<any>, Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Util, OnyxUI.Components)
	local Theme = Themer.Theme:now()

	local CategoryName = Util.Fallback(Props.CategoryName, "General")
	local Name = Util.Fallback(Props.Name, `{Use(Props.CategoryName)}EmotesCategory`)
	local Size = Util.Fallback(Props.Size, UDim2.fromScale(1, 0))
	local AutomaticSize = Util.Fallback(Props.AutomaticSize, Enum.AutomaticSize.Y)
	local LayoutOrder = Util.Fallback(Props.LayoutOrder, 0)

	local Category = Scope:Computed(function(Use)
		return RoRooms.Config.Systems.Emotes.Categories[Use(Props.CategoryName)]
	end)

	return Scope:Frame {
		Name = Props.Name,
		Size = Props.Size,
		AutomaticSize = Props.AutomaticSize,
		LayoutOrder = Props.LayoutOrder,
		ListEnabled = true,

		[Children] = {
			Scope:Frame {
				Name = "Title",
				ListEnabled = true,
				ListFillDirection = Enum.FillDirection.Horizontal,
				ListPadding = Scope:Computed(function(Use)
					return UDim.new(0, Use(Theme.Spacing["0.25"]))
				end),

				[Children] = {
					Scope:Icon {
						Image = Scope:Computed(function(Use)
							if Use(Category) and Use(Category).Icon then
								return Use(Category).Icon
							else
								return "rbxassetid://17266112920"
							end
						end),
						Size = Scope:Computed(function(Use)
							return UDim2.fromOffset(Use(Theme.TextSize["1"]), Use(Theme.TextSize["1"]))
						end),
					},
					Scope:Text {
						Text = Props.CategoryName,
					},
				},
			},
			Scope:Frame {
				Name = "Emotes",
				Size = UDim2.fromScale(1, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				ListEnabled = true,
				ListPadding = Scope:Computed(function(Use)
					return UDim.new(0, Use(Theme.Spacing["0.75"]))
				end),
				ListFillDirection = Enum.FillDirection.Horizontal,
				ListWraps = true,

				[Children] = {
					Scope:ForPairs(RoRooms.Config.Systems.Emotes.Emotes, function(EmoteId, Emote)
						local EmoteCategory = Emote.Category
						if EmoteCategory == nil then
							EmoteCategory = "General"
						end

						if EmoteCategory == Use(Props.CategoryName) then
							return EmoteId,
								Scope:EmoteButton {
									EmoteId = EmoteId,
									Emote = Emote,
									Color = Emote.TintColor,

									Callback = function()
										if Use(States.ScreenSize).Y <= 500 then
											States.CurrentMenu:set()
										end
									end,
								}
						else
							return EmoteId, nil
						end
					end),
				},
			},
		},
	}
end
