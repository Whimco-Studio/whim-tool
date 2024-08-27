--[[
Sounds

    A short description of the module.

SYNOPSIS

    -- Lua code that showcases an overview of the API.
    local foobar = Sounds.TopLevel('foo')
   

DESCRIPTION

    A detailed description of the module.

API

    -- Describes each API item using Luau type declarations.

    -- Top-level functions use the function declaration syntax.
    function ModuleName.TopLevel(thing: string): Foobar

    -- A description of Foobar.
    type Foobar = {

        -- A description of the Thing member.
        Thing: string,

        -- Each distinct item in the API is separated by \n\n.
        Member: string,

    }
]]

-- Implementation of Sounds.

--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Packages
local Maid = require(ReplicatedStorage.Packages.Maid)

--// Class
local Sounds = {}
Sounds.__index = Sounds

function Sounds.new()
	local SoundDictionary = {
		Click = "rbxassetid://12313312",
		_maid = Maid.new(),
	}
	setmetatable(SoundDictionary, Sounds)
	return SoundDictionary
end

function Sounds:Play(SoundName: string)
	if true then
		return
	end
	local targetSound = self[SoundName]

	if not targetSound then
		return warn(SoundName .. " does not exist.")
	end

	local SoundEndedConnection
	local Sound = Instance.new("Sound")
	Sound.SoundId = targetSound

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

return Sounds
