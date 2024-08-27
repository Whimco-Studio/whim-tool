-- Implementation of Sounds.

--// Services
local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Packages
local Maid = require(ReplicatedStorage.Packages.Maid)

--// Class
local Sounds = {}
Sounds.__index = Sounds

function Sounds.new()
	local SoundDictionary = {
		Bubbles = "rbxassetid://17184316404",
		WaterDeath = "rbxassetid://17184316187",
		_maid = Maid.new(),
	}
	setmetatable(SoundDictionary, Sounds)
	return SoundDictionary
end

function Sounds:Play(SoundName: string, Volume: number, Parent: Instance?)
	local targetSound = self[SoundName]

	if not targetSound then
		return warn(SoundName .. " does not exist.")
	end

	local SoundEndedConnection
	local Sound = Instance.new("Sound")
	Sound.SoundId = targetSound
	Sound.Volume = Volume
	Sound.Parent = Parent or SoundService

	Sound:Play()

	SoundEndedConnection = Sound.Ended:Connect(function()
		Sound:Destroy()
		SoundEndedConnection:Disconnect()
	end)
end

function Sounds:Disconnect()
	for _, c: RBXScriptConnection in pairs(self.Connections) do
		c:Disconnect()
	end
end

function Sounds:Destroy()
	self:Disconnect()

	setmetatable(self, nil)
	table.clear(self)
	table.freeze(self)
end

return Sounds.new()
