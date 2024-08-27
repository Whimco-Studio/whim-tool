--[[
Animate

	A short description of the module.

SYNOPSIS

	-- Lua code that showcases an overview of the API.
	local foobar = Animate.TopLevel('foo')
	print(foobar.Thing)

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

-- Implementation of Animate.

--// Services
local ContentProvider = game:GetService("ContentProvider")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local KeyframeSequenceProvider = game:GetService("KeyframeSequenceProvider")

--// Class
local Animate = {}
Animate.__index = Animate

--// Variables
local AnimationPrefix = "rbxassetid://"
local Cache = {}

local function GetAnimationLength(Animation)
	local AssetId = Animation.AnimationId
	if Cache[AssetId] then
		return Cache[AssetId]
	end

	local Sequence = KeyframeSequenceProvider:GetKeyframeSequenceAsync(AssetId)
	local Keyframes = Sequence:GetKeyframes()

	local Length = 0
	for i = 1, #Keyframes do
		local Time = Keyframes[i].Time
		if Time > Length then
			Length = Time
		end
	end

	Sequence:Destroy()
	Cache[AssetId] = Length

	return Length
end

function Animate.new(Animator: Animator, Animation: Animation | string)
	local CurrentAnimation: Animation
	local CurrentAnimationTrack: AnimationTrack
	local Created = false

	local Connections = {}

	if typeof(Animation) == "Instance" and Animation:IsA("Animation") then
		CurrentAnimation = Animation
	elseif typeof(Animation) == "string" then
		Created = true
		if tonumber(CurrentAnimation) then
			CurrentAnimation = Instance.new("Animation")
			CurrentAnimation.AnimationId = AnimationPrefix .. CurrentAnimation
		else
			CurrentAnimation = Instance.new("Animation")
			CurrentAnimation.AnimationId = Animation
		end
	end

	ContentProvider:PreloadAsync({ CurrentAnimation })
	CurrentAnimationTrack = Animator:LoadAnimation(CurrentAnimation)

	Connections.Stopped = CurrentAnimationTrack.Stopped:Connect(function()
		CurrentAnimation:Destroy()
		Connections.Stopped:Disconnect()
	end)

	-- local Length, Keyframes = GetAnimationLength(CurrentAnimation)
	repeat
		task.wait()
	until CurrentAnimationTrack.Length ~= 0

	local Length = CurrentAnimationTrack

	local info = {
		Animation = CurrentAnimation,
		Track = CurrentAnimationTrack,
		Length = Length,
		-- Keyframes = Keyframes,
		Connections = Connections,
	}

	setmetatable(info, Animate)
	return info
end

function Animate:PlayOnce(fadeTime: number, weight: number, Speed: number)
	local Connections = self.Connections

	-- local Keyframes = self.Keyframes
	local Track: AnimationTrack = self.Track

	Track.Looped = false
	Track:Play(fadeTime or 0.100000001, weight or 1, Speed or 1)

	Track.Stopped:Connect(function()
		Track:AdjustSpeed(0)
		Track.TimePosition = GetAnimationLength(self.Animation)
	end)

	task.wait(Track.Length * 0.9)
	Track:AdjustSpeed(0)
end

function Animate:Disconnect()
	for _, c: RBXScriptConnection in pairs(self.Connections) do
		c:Disconnect()
	end
end

function Animate:Destroy()
	self:Disconnect()

	setmetatable(self, nil)
	table.clear(self)
	table.freeze(self)
end

return Animate
