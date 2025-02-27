local HttpService = game:GetService("HttpService")

local RoRooms = script.Parent.Parent.Parent.Parent
local Future = require(RoRooms.Parent.Future)
local Signal = require(RoRooms.Parent.Signal)
local t = require(RoRooms.Parent.t)
local Fetch = require(RoRooms.Parent.Fetch)
local Config = require(RoRooms.Config).Config
local DeepCopy = require(RoRooms.SourceCode.Shared.ExtPackages.DeepCopy)
local Knit = require(RoRooms.Parent.Knit)

local REGISTRY_UPDATE_DELAY = 10 * 60

local WorldRegistryService = {
	Name = "WorldRegistryService",
	Client = {
		Registered = Knit.CreateProperty(false),
	},

	WorldRegistry = {},
	WorldRegistryLastUpdated = 0,

	RegistryUpdated = Signal.new(),
}

function WorldRegistryService.Client:IsWorldRegistered(Player: Player, PlaceId: number)
	assert(t.tuple(t.instanceOf("Player")(Player), t.number(PlaceId)))

	return WorldRegistryService:IsWorldRegistered(PlaceId)
end

function WorldRegistryService.Client:GetWorldDetails(Player: Player, PlaceId: number)
	assert(t.tuple(t.instanceOf("Player")(Player), t.number(PlaceId)))

	return WorldRegistryService:GetWorldDetails(PlaceId)
end

function WorldRegistryService:IsWorldRegistered(PlaceId: number)
	return self:GetWorldDetails(PlaceId) ~= nil
end

function WorldRegistryService:GetWorldDetails(PlaceId: number)
	local WorldEntry = self.WorldRegistry[tostring(PlaceId)]

	if WorldEntry ~= nil then
		return DeepCopy(WorldEntry)
	else
		return nil
	end
end

function WorldRegistryService:UpdateRegistry()
	Future.Try(function()
		local Success, Response =
			Fetch(`https://api.github.com/repos/{Config.Systems.Worlds.RegistryRepository}/releases/latest`):Await()
		if Success then
			local Body = HttpService:JSONDecode(Response.Body)
			if Body then
				return Body["published_at"]
			end
		end
	end):After(function(Success, PublishedAt)
		if Success and PublishedAt then
			if PublishedAt ~= self.WorldRegistryLastUpdated then
				self:_FetchLatestRegistry():After(function(Success2, Response2)
					if Success2 then
						self.WorldRegistry = Response2
						self.WorldRegistryLastUpdated = PublishedAt

						self:_RemoveDelistedWorlds()

						self.RegistryUpdated:Fire(Response2)
					else
						warn(Response2)
					end
				end)
			end
		end
	end)
end

function WorldRegistryService:_FetchLatestRegistry()
	return Future.Try(function()
		local Success, Response = Fetch(
			`https://github.com/{Config.Systems.Worlds.RegistryRepository}/releases/latest/download/worlds.json`
		):Await()

		if Success then
			local Worlds = HttpService:JSONDecode(Response.Body)

			if typeof(Worlds) == "table" then
				return Worlds
			else
				warn("Latest world registry version does not decode to JSON. Report this ASAP.")
			end
		else
			warn("Latest world registry version is not a string. Report this ASAP.")

			return {}
		end
	end)
end

function WorldRegistryService:_RemoveDelistedWorlds()
	for PlaceId, World in pairs(self.WorldRegistry) do
		if World.delisted or World.forceDelisted then
			self.WorldRegistry[PlaceId] = nil
		end
	end
end

function WorldRegistryService:_SpawnRegistryUpdateLoop()
	return task.spawn(function()
		while true do
			self:UpdateRegistry()

			task.wait(REGISTRY_UPDATE_DELAY)
		end
	end)
end

function WorldRegistryService:KnitStart()
	self.RegistryUpdated:Connect(function(Worlds)
		local World = Worlds[tostring(game.PlaceId)]

		self.Client.Registered:Set(World ~= nil)
	end)

	self:_SpawnRegistryUpdateLoop()
end

return WorldRegistryService
