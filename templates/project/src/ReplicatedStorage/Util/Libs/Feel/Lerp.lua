--[[
Lerp

    A short description of the module.

SYNOPSIS

    -- Lua code that showcases an overview of the API.
    local foobar = Lerp.TopLevel('foo')
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

-- Implementation of Lerp.

--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

--// module
local Lerp = {}

-- Track active lerps
local activeLerps = {}

function DefaultLerpLerp(a, b, t)
	return a + (b - a) * t
end

local function cancelActiveLerp(key)
	if activeLerps[key] then
		activeLerps[key].active = false
		activeLerps[key] = nil
	end
end

function Lerp.KeyValue(array, key, goal: number, t: number)
	cancelActiveLerp(key)
	local lerpData = { active = true }
	activeLerps[key] = lerpData

	local timepassed: number = 0
	while timepassed <= t and lerpData.active do
		timepassed = timepassed + RunService.RenderStepped:Wait()
		array[key] = DefaultLerpLerp(array[key], goal, timepassed / t)
	end

	activeLerps[key] = nil
end

function Lerp.CFrame(part: BasePart | MeshPart | Camera, goal: CFrame, t: number)
	cancelActiveLerp(part)
	local lerpData = { active = true }
	activeLerps[part] = lerpData

	local timepassed: number = 0
	local start: CFrame = part.CFrame
	while timepassed <= t and lerpData.active do
		timepassed = timepassed + RunService.RenderStepped:Wait()
		part.CFrame = start:Lerp(goal, timepassed / t)
	end

	activeLerps[part] = nil
end

function Lerp.Size(part: BasePart | MeshPart, goal: Vector3, t: number, reversing: boolean)
	cancelActiveLerp(part)
	local lerpData = { active = true }
	activeLerps[part] = lerpData

	local timepassed: number = 0
	local start: Vector3 = part.Size
	while timepassed <= t and lerpData.active do
		timepassed = timepassed + RunService.RenderStepped:Wait()
		part.Size = start:Lerp(goal, timepassed / t)
	end

	if reversing and lerpData.active then
		timepassed = 0
		while timepassed <= t and lerpData.active do
			timepassed = timepassed + RunService.RenderStepped:Wait()
			part.Size = part.Size:Lerp(start, timepassed / t)
		end
	end

	activeLerps[part] = nil
end

function Lerp.CFrameAndSize(part: BasePart | MeshPart, goalCF: CFrame, goalV3: Vector3, t: number)
	cancelActiveLerp(part)
	local lerpData = { active = true }
	activeLerps[part] = lerpData

	local timepassed: number = 0
	local startV3: Vector3 = part.Size
	local startCF: CFrame = part.CFrame
	while timepassed <= t and lerpData.active do
		timepassed = timepassed + RunService.RenderStepped:Wait()
		part.CFrame = startCF:Lerp(goalCF, timepassed / t)
		part.Size = startV3:Lerp(goalV3, timepassed / t)
	end

	activeLerps[part] = nil
end

function Lerp.new(...)
	Lerp.CFrame(...)
end

return Lerp
