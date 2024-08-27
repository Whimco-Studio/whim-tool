--[[
Camera

    A short description of the module.

SYNOPSIS

    -- Lua code that showcases an overview of the API.
    local foobar = Camera.TopLevel('foo')
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

-- Implementation of Camera.

--// Services
local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

--// Dependencies
local Library = script.Parent
local Modes = require(script.Modes)

local Spring = require(Library.Spring)
local Lerp = require(Library.Lerp)

--// Camera Variables
local MouseBehavior = {
	Default = Enum.MouseBehavior.Default,
	LockCenter = Enum.MouseBehavior.LockCenter,
	LockCurrentPosition = Enum.MouseBehavior.LockCurrentPosition,
}

--// Camera Functions
local function PrepareBodyGyro(): BodyGyro
	local bodyGyro = Instance.new("BodyGyro")
	bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
	bodyGyro.P = 10000

	return bodyGyro
end

local function GetCharacter(Player: Player): Model
	return Player.Character or Player.CharacterAdded:Wait()
end

--// Class
local Camera = {}
Camera.__index = Camera

local Cameras = {}

function Camera.new(Ignorables)
	local Player = Players.LocalPlayer
	local CurrentCamera = workspace.CurrentCamera
	local PlayerModule = require(game.Players.LocalPlayer.PlayerScripts:WaitForChild("PlayerModule"))

	local self = {
		Player = Player,
		Camera = CurrentCamera,
		PlayerModule = PlayerModule,

		Mode = "Custom",
		Subject = false,
		Enabled = false,
		Rotating = false,
		Following = true,
		ShiftLock = false,
		BlockedRay = false,
		OffsetRight = false,
		CameraCFrame = CFrame.new(),
		CameraMoveVector = Vector3.zero,

		Binds = {},
		Connections = {},
		Ignorables = Ignorables or {},

		LerpRate = 0.5,
		TargetCF = CFrame.new(),
		Spring = Spring.new(CurrentCamera.CFrame.Position, Vector3.new(), Vector3.new()),
	}

	self.cameraAngleX = 365
	self.cameraAngleY = -14

	self.Zoom = 10
	self.MaxZoom = Player.CameraMaxZoomDistance
	self.MinZoom = Player.CameraMinZoomDistance
	self.bodyGyro = PrepareBodyGyro()
	self.Offset = Instance.new("NumberValue")

	setmetatable(self, Camera)

	Cameras[Player] = self
	return self
end

function Camera:GetMode() end

function Camera:Set(Mode: string)
	self.Mode = Mode or "Default"

	self:Disconnect()

	if Mode == "Default" or Mode == "Custom" or Mode == nil then
		self.Camera.CameraType = Enum.CameraType.Custom
		return self:Disconnect()
	end

	self.Active = true

	self:Enable()
end

function Camera:TrackRotation(inputObject)
	-- Calculate camera/player rotation on input change
	self.cameraAngleX = self.cameraAngleX
		- (inputObject.Delta.X * (string.find(self.Mode, "Spring") and (self.Spring.rate * 2) or 1))
	self.cameraAngleY = self.cameraAngleY
		- (inputObject.Delta.Y * (string.find(self.Mode, "Spring") and (self.Spring.rate * 2) or 1))

	local Upperbound = 70
	local Lowerbound = 70

	if self.cameraAngleY > Lowerbound then
		self.cameraAngleY = Lowerbound
	elseif self.cameraAngleY < -Upperbound then
		self.cameraAngleY = -Upperbound
	end
end

--------- Mobile Movement Tracking ----------
function Camera:isInDynamicThumbstickArea(input)
	local playerGui = self.Player:FindFirstChildOfClass("PlayerGui")
	local touchGui = playerGui and playerGui:FindFirstChild("TouchGui")
	local touchFrame = touchGui and touchGui:FindFirstChild("TouchControlFrame")
	local thumbstickFrame = touchFrame and touchFrame:FindFirstChild("DynamicThumbstickFrame")

	if not thumbstickFrame then
		return false
	end

	local frameCornerTopLeft = thumbstickFrame.AbsolutePosition
	local frameCornerBottomRight = frameCornerTopLeft + thumbstickFrame.AbsoluteSize
	if input.Position.X >= frameCornerTopLeft.X and input.Position.Y >= frameCornerTopLeft.Y then
		if input.Position.X <= frameCornerBottomRight.X and input.Position.Y <= frameCornerBottomRight.Y then
			return true
		end
	end

	return false
end

function Camera:trackZoom(inputObject)
	if inputObject.UserInputType == Enum.UserInputType.MouseWheel then
		if self.Zoom >= 1 and self.Zoom <= self.MaxZoom then
			self.Zoom -= inputObject.Position.Z * 5
			if self.Zoom > self.MaxZoom then
				self.Zoom = self.MaxZoom
			elseif self.Zoom < self.MinZoom and not self.BlockedRay then
				self.Zoom = self.MinZoom * 2
			elseif self.Zoom < self.MinZoom and self.BlockedRay then
				self.cameraAngleY -= 1
				self.Zoom = self.MinZoom * 2
			end
		end
	end
end

--------- --------------------- ----------

function Camera:playerInput(actionName, inputState, inputObject)
	if not self.Active then
		return
	end
	if actionName == "MouseMovement" then
		if inputState == Enum.UserInputState.Change then
			if inputObject.UserInputType == Enum.UserInputType.MouseMovement then
				if
					UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
					or inputState == Enum.UserInputState.Change and self.ShiftLock
				then
					UserInputService.MouseBehavior = MouseBehavior.LockCurrentPosition
					self:TrackRotation(inputObject)
				else
					UserInputService.MouseBehavior = not self.ShiftLock and MouseBehavior.Default
						or MouseBehavior.LockCenter
				end
			else
				if not self:isInDynamicThumbstickArea(inputObject) then
					self:TrackRotation(self, inputObject)
				end
			end
		end
	elseif actionName == "LockSwitch" then
		if inputState == Enum.UserInputState.Begin then
			local Character = GetCharacter(self.Player)

			self.ShiftLock = not self.ShiftLock
			UserInputService.MouseBehavior = self.ShiftLock and MouseBehavior.LockCenter or MouseBehavior.Default

			if not self.Spectating then
				self.bodyGyro.Parent = self.ShiftLock and Character.HumanoidRootPart or nil
			end
		end
	elseif actionName == "SwitchOffset" then
		if inputState == Enum.UserInputState.Begin then
			self.OffsetRight = not self.OffsetRight
			-- tween.new(Offset, {Value = OffsetCount * (OffsetRight and 1 or -1)}, .5):Play()
		end
		-- elseif actionName == "MobileZoom" then
	end
end

function Camera:Connect()
	local CurrentMode: string = string.lower(self.Mode)
	if CurrentMode:find("lerp") or CurrentMode:find("spring") then
		Modes["LerpSpring"](self)
	else
		if Modes[self.Mode] ~= nil then
			Modes[self.Mode](self)
		end
	end
end

function Camera:Enable()
	local UserCamera: Camera = self.Camera

	game.StarterPlayer.EnableMouseLockOption = true

	if self.Active then
		UserCamera.CameraType = Enum.CameraType.Scriptable
		self:Connect()
	else
		self:Disconnect()
		UserCamera.CameraType = "Custom"
	end
end

function Camera:Disconnect()
	for index, Connection in pairs(self.Connections) do
		Connection:Disconnect()
	end
	for Bind, BindValue in pairs(self.Binds) do
		ContextActionService:UnbindAction(Bind)
	end
end

return Camera
