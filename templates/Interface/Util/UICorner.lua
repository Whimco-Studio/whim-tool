--[[
UICorner

    A short description of the module.

SYNOPSIS

    -- Lua code that showcases an overview of the API.
    local foobar = UICorner.TopLevel('foo')
   

DESCRIPTION

    A module for creating relatively scaled ui strokes

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

-- Implementation of UICorner.

--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Private Functions
local function GetAverage(vector: Vector2): number
	return (vector.X + vector.Y) / 2
end

--// Variables
local STUDIO_SCREEN_SIZE = Vector2.new(1366, 767) -- change 0, 0 to your studio resolution
local camera: Camera = workspace.Camera

local studioAverage = GetAverage(STUDIO_SCREEN_SIZE)
local currentScreenAverage = GetAverage(camera.ViewportSize)

--// Variable-reliant Private Functions
local function AdjustCornerRadius(OriginalCornerRadius: number)
	local ratio = OriginalCornerRadius / studioAverage
	return currentScreenAverage * ratio
end

local function ModifyUICorners(args: any)
	currentScreenAverage = GetAverage(camera.ViewportSize) -- re-calculate the screen average as it could've changed
	return AdjustCornerRadius(args)
end

--// Module
local UICorner = function(_CornerRadius: number)
	local ratio = (_CornerRadius or 1) / studioAverage
	local CornerRadius = currentScreenAverage * ratio

	return CornerRadius
end

return UICorner
