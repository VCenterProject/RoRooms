local RoRooms = require(script.Parent.Parent.Parent.Parent.Parent)

local Shared = RoRooms.Shared
local Client = RoRooms.Client
local Config = RoRooms.Config

local OnyxUI = require(Shared.ExtPackages.OnyxUI)
local Fusion = require(OnyxUI._Packages.Fusion)

local New = Fusion.New
local Children = Fusion.Children
local Computed = Fusion.Computed

local ScrollingFrame = require(OnyxUI.Components.ScrollingFrame)
local ItemCategoryButton = require(Client.UI.Components.ItemCategoryButton)

return function(Props: { [any]: any })
	return ScrollingFrame {
		Name = "ItemCategoriesSidebar",
		Size = Props.Size,

		[Children] = {
			New "UIListLayout" {
				Padding = UDim.new(0, 10),
				FillDirection = Enum.FillDirection.Vertical,
				SortOrder = Enum.SortOrder.LayoutOrder,
			},
			New "UIPadding" {
				PaddingLeft = UDim.new(0, 2),
				PaddingBottom = UDim.new(0, 2),
				PaddingTop = UDim.new(0, 2),
				PaddingRight = UDim.new(0, 2),
			},
			Computed(function()
				local Categories = {}
				for CategoryName, _ in Config.ItemsSystem.Categories do
					table.insert(
						Categories,
						ItemCategoryButton {
							CategoryName = CategoryName,
						}
					)
				end
				return Categories
			end),
		},
	}
end
