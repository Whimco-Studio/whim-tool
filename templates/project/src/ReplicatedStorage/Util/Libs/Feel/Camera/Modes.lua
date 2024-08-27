--// Services
local ContextActionService = game:GetService("ContextActionService")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

--// Dependencies
local Library = script.Parent.Parent

local Spring = require(Library.Spring)
local Lerp = require(Library.Lerp)

--// Functions
local function GetCharacter(Player: Player): Model
	return Player.Character or Player.CharacterAdded:Wait()
end

--// Modes
local Modes = {}

function Modes.LerpSpring(self)
	local Aim = CFrame.new()
	local Rot = CFrame.new()

	local Character = GetCharacter(self.Player)
	local Root = self.Subject or Character:WaitForChild("HumanoidRootPart", 3)

	if not Root then
		return
	end

	self.TargetCF = CFrame.new((CFrame.new(Root.CFrame.Position) * CFrame.new(0, 0, 12)).Position, Root.Position)
	self.Spring.target = self.TargetCF.Position

	Spring.Update(self.Spring)

	self.Binds["TrackZoom"] = UserInputService.InputChanged:Connect(function(...)
		self:trackZoom(self, ...)
	end)

	self.Binds["MouseMovement"] = ContextActionService:BindAction("MouseMovement", function(...)
		self:playerInput(...)
	end, false, Enum.UserInputType.MouseMovement, Enum.UserInputType.Touch)
	self.Binds["SwitchOffset"] = ContextActionService:BindAction("SwitchOffset", function(...)
		self:playerInput(...)
	end, false, Enum.KeyCode.Q, Enum.KeyCode.ButtonR1)
	-- self.Binds["LockSwitch"] = ContextActionService:BindAction("LockSwitch", function(...)
	-- 	self:playerInput(...)
	-- end, false, Enum.KeyCode.LeftShift)

	self.Connections["CameraConnnection"] = RunService.RenderStepped:Connect(function(dt)
		if self.Active == nil or self.Active == false then
			return
		end

		Character = GetCharacter(self.Player)
		Root = self.Subject or Character:WaitForChild("HumanoidRootPart", 3)

		if not Root then
			return
		end

		self.Camera.CameraType = Enum.CameraType.Scriptable

		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		raycastParams.FilterDescendantsInstances = {
			Character:GetDescendants(),
			self.Ignorables,
		}
		raycastParams.IgnoreWater = true

		-- Cast the ray
		local RX, RY, RZ

		Rot = CFrame.Angles(0, math.rad(self.cameraAngleX * UserInputService.MouseDeltaSensitivity), 0)
			* CFrame.Angles(math.rad(self.cameraAngleY * UserInputService.MouseDeltaSensitivity), 0, 0)

		local BaseCF = (CFrame.new(Root.CFrame.Position) * Rot) * (CFrame.new(0, 0, self.Zoom))
		local BlockedZoom = self.Zoom

		if not self.Following then
			BaseCF = self.Camera.CFrame
		end

		local raycastResult: RaycastResult = workspace:Raycast(
			Root.Position,
			CFrame.new(Root.Position, self.Camera.CFrame.Position).LookVector * (self.Zoom + 1),
			raycastParams
		)

		if raycastResult ~= nil then
			BlockedZoom = (self.Camera.CFrame.Position - raycastResult.Position).Magnitude
			BaseCF = (CFrame.new(Root.CFrame.Position) * Rot) * (CFrame.new(0, 0, BlockedZoom))
		end

		self.BlockedRay = false

		self.TargetCF = CFrame.new(BaseCF.Position, Root.Position)
		self.Spring.target = self.TargetCF.Position

		Spring.Update(self.Spring)

		Aim = CFrame.new((CFrame.new(self.Spring.position)).Position, Root.Position)
			* (CFrame.new(self.Offset.Value, 0, 0))
		Rot = CFrame.new(Aim.Position, (Aim * CFrame.new(0, 0, -20).Position))

		RX, RY, RZ = Rot:ToOrientation()

		if self.Mode == "Lerp" then
			self.Camera.CFrame = self.Camera.CFrame:Lerp(self.TargetCF, self.LerpRate)
		elseif self.Mode == "Spring" then
			self.Camera.CFrame = Aim
		elseif self.Mode == "LerpSpring" then
			self.Camera.CFrame = self.Camera.CFrame:Lerp(Aim, self.LerpRate)
		end
		self.bodyGyro.CFrame = CFrame.fromOrientation(0, RY, RZ)
	end)
end

function Modes.FreeCam(self)
	local Character = GetCharacter(self.Player)
	local Controls = self.PlayerModule:GetControls()
	local Humanoid: Humanoid = Character:FindFirstChild("Humanoid")

	game.StarterPlayer.EnableMouseLockOption = false
	self.Binds["MouseMovement"] = ContextActionService:BindAction("MouseMovement", function(...)
		self:playerInput(...)
	end, false, Enum.UserInputType.MouseMovement, Enum.UserInputType.Touch)
	self.Connections["CameraConnnection"] = RunService.RenderStepped:Connect(function(dt)
		if self.Active == nil or self.Active == false then
			return
		end

		local Movement = Controls:GetMoveVector()

		local HoldingShift = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)
		local Speed = HoldingShift and 5 or 1.5

		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		raycastParams.FilterDescendantsInstances = {
			self.Ignorables, --:GetDescendants(),
		}
		raycastParams.IgnoreWater = true

		local Rot = CFrame.Angles(0, math.rad(self.cameraAngleX * UserInputService.MouseDeltaSensitivity), 0)
			* CFrame.Angles(math.rad(self.cameraAngleY * UserInputService.MouseDeltaSensitivity), 0, 0)
		local BaseCF: CFrame = CFrame.new(self.Camera.CFrame.Position) * Rot
		local Desired = BaseCF + (BaseCF:VectorToWorldSpace(Movement) * Speed)

		local raycastResult = workspace:Raycast(BaseCF.Position, BaseCF:VectorToWorldSpace(Movement), raycastParams)

		if raycastResult == nil then
			self.BlockedRay = false
			self.Camera.CFrame = self.Camera.CFrame:Lerp(Desired, 0.1)
		end
	end)
end

return Modes
