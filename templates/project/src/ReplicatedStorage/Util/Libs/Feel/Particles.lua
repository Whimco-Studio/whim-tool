--[[
Particles
    A short description of the module.
SYNOPSIS
    -- Lua code that showcases an overview of the API.
    local foobar = Particles.TopLevel('foo')
    print(foobar.Thing)
DESCRIPTION
    A detailed description of the module.
API
    -- Describes each API item using Luau type declarations.
    -- Top-level functions use the function declaration syntax.
    function ModuleName.TopLevel(thing: string): Foobar
    -- A description of Foobar.

    Particles.new(key: string | Instance, Humanoid: Humanoid, Mesh: MeshPart | {}, Offset): ParticleClass
        - ParticleClass Constructor

    Particles.CreateParticle(key: string | {})
        - Creates Singular Linear Particle Intended for Linear Direction
    
    Particles.CreateRadialParticle(key: string | {}, Destination)
        - Creates Singular Particle Intended for Radial Spread

    Particles.Landed(key: string | {})
        - Creates Particles in a radius
        - Called after ParticleClass.Humanoid.Landed has been fired

    Particles.Connect(key: string | {})
        - Creates Connections from Humanoid Events

    Particles.Disconnect(key: string | {})
        - Disconnects connections made and stored during Particles.Connect()

    Particles.Toggle(key: string | {}, Activate: boolean)
        - Toggles Particles

    type Connections = {[string]: RBXScriptConnection}
    
    type ParticleClass = {
        key: string,
        Active: boolean,
        CanCreateParticle: boolean,

        Mesh: MeshPart | BasePart,
        Base: BasePart,
        Humanoid: Humanoid,

        Connections: Connections
    }
]]

-- Implementation of Particles.

export type Connections = { [string]: RBXScriptConnection }

export type ParticleClass = {
	key: string,
	Active: boolean,
	CanCreateParticle: boolean,

	Mesh: MeshPart | BasePart,
	Base: BasePart,
	Humanoid: Humanoid,

	Connections: Connections,
}

--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

--// Dependencies
local Library = script.Parent

local Lerp = require(Library.Lerp)

--// module
local Particles = {}

local function Checker(ParticlesObject: table | string)
	if type(ParticlesObject) ~= "table" and type(ParticlesObject) ~= "string" then
		error("First arg needs to be a table or string")
	end

	if type(ParticlesObject) == "string" then
		ParticlesObject = Particles[ParticlesObject]
	end

	return ParticlesObject
end

local function MakeParticle(Mesh: BasePart | MeshPart, CF: CFrame)
	Mesh = Mesh[math.random(1, #Mesh)]:Clone()
	local MeshSize: Vector3 = Mesh.Size

	Mesh.Size = Vector3.new()
	Mesh.CanCollide = false

	Mesh.CFrame = CF
	Mesh.Anchored = true

	Mesh.Orientation = Vector3.new(math.random(-360, 360), math.random(-360, 360), math.random(-360, 360))

	Mesh.Parent = game.Workspace:FindFirstChild("Debris") or workspace

	return Mesh, MeshSize
end

function Particles.new(key: string | Instance, Humanoid: Humanoid, Mesh: MeshPart | {}, Offset): ParticleClass
	if Humanoid == nil then
		error("Humanoid needs to be provided as the 2nd arg")
	end
	if Mesh == nil then
		error("Mesh needs to be provided as the 3rd arg")
	end

	local self: ParticleClass = {
		key = key,
		Active = true,
		CanCreateParticle = true,

		Mesh = (Mesh:IsA("MeshPart") and not nil) and { Mesh } or Mesh,
		Base = Humanoid.Parent:FindFirstChild("HumanoidRootPart"),
		Humanoid = Humanoid,

		Connections = {},
	}

	self["Offset"] = Offset or CFrame.new(0, -self.Base.Size.Y / 2, self.Base.Size.Z / 2)

	Particles[key] = self

	return self
end

function Particles.CreateParticle(key: string | {})
	local self = Checker(key)

	local Speed = self.Base.AssemblyLinearVelocity.Magnitude
	local CurrentState = self.Humanoid:GetState()

	if self.Humanoid.Sit == true then
		return
	end
	if
		CurrentState == Enum.HumanoidStateType.Jumping
		or CurrentState == Enum.HumanoidStateType.Freefall
		or CurrentState == Enum.HumanoidStateType.FallingDown
	then
		return
	end

	local Mesh, MeshSize = MakeParticle(self.Mesh, self.Base.CFrame * self.Offset)

	Lerp.Size(Mesh, MeshSize * math.random(70, 100) / 100, 0.25, true)

	Mesh:Destroy()
end

function Particles.CreateRadialParticle(key: string | {}, Destination)
	local self = Checker(key)

	local Mesh: MeshPart | BasePart, MeshSize: Vector3 =
		MakeParticle(self.Mesh, self.Base.CFrame * CFrame.new(0, -self.Base.Size.Y / 2, 0))

	Mesh.Orientation = Vector3.new(math.random(-360, 360), math.random(-360, 360), math.random(-360, 360))

	Lerp.CFrameAndSize(Mesh, CFrame.new(Destination), MeshSize * math.random(70, 100) / 100, 0.25)

	Lerp.Size(Mesh, Vector3.new(), 0.25)

	Mesh:Destroy()
end

function Particles.Landed(key: string | {})
	local self = Checker(key)

	local radius: number = self.Base.Size.Magnitude * 0.5
	local totalAmountOfItems: number = math.random(3, 4)

	for myItemNumber = 1, totalAmountOfItems do
		local angle: number = myItemNumber * 2 * math.pi / totalAmountOfItems
		local positionOnCircle: Vector3 = Vector3.new(math.sin(angle), 0, math.cos(angle)) * radius

		task.spawn(function()
			Particles.CreateRadialParticle(
				self,
				(self.Base.CFrame.Position - Vector3.new(0, self.Base.Size.Y / 2, 0)) + positionOnCircle
			)
		end)
	end
end

function Particles.Connect(key: string | {})
	local self = Checker(key)

	local Humanoid: Humanoid = self.Humanoid

	local CurrentState: string = Enum.HumanoidStateType.None
	local MoveDirection: Vector3 = Vector3.new()
	local Active: boolean = false

	self.Connections["MoveDirection"] = Humanoid:GetPropertyChangedSignal("MoveDirection"):Connect(function()
		MoveDirection = Humanoid.MoveDirection

		if MoveDirection.Magnitude > 0 then
			if not Active then
				Active = true
				while Active and self.Connections and self.Connections["MoveDirection"] do
					if
						(CurrentState == Enum.HumanoidStateType.None and MoveDirection ~= Vector3.zero)
						or CurrentState == Enum.HumanoidStateType.Running
						or CurrentState == Enum.HumanoidStateType.RunningNoPhysics
					then
						task.spawn(function()
							Particles.CreateParticle(self)
						end)
					end

					task.wait(math.random(5, 10) / 50)
				end
			end
		else
			Active = false
		end
	end)

	self.Connections["HumanoidState"] = Humanoid.StateChanged:Connect(function(old, new)
		CurrentState = new

		if CurrentState == Enum.HumanoidStateType.Landed then
			Particles.Landed(self)
		end
	end)
end

function Particles.Disconnect(key: string | {}, Connection: string)
	local self = Checker(key)

	if Connection then
		self.Connections[Connection]:Disconnect()
	else
		for Index: string, _Connection: RBXScriptConnection in pairs(self.Connections) do
			_Connection:Disconnect()

			self.Connections[Index] = nil
		end
	end
end

function Particles.Destroy(key: string | {})
	local self = Checker(key)

	Particles.Disconnect(self)
	table.clear(self)
	table.freeze(self)
end

function Particles.Toggle(key: string | {}, Activate: boolean)
	local self = Checker(key)

	if Activate then
		Particles.Connect(self)
	else
		Particles.Disconnect(self)
	end
end

return Particles
