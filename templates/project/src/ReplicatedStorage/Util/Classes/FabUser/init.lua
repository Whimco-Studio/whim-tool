-- Implementation of Test_User.

--// Services
local _HttpService = game:GetService("HttpService")
local _ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Util
local Util = script.Util
local Usernames = require(Util.Usernames)

--// Class
local Test_User = {}
Test_User.__index = Test_User

function Test_User.new(Character: Model, ID: string?)
	ID = ID or _HttpService:GenerateGUID(false)

	local info = {
		UserId = ID,
		Name = Usernames[math.random(1, #Usernames)],
		FabricatedUser = true,
		ClassName = "FabricatedPlayer",

		Character = Character,
		FabPlayerInstance = Instance.new("DepthOfFieldEffect"),

		Attributes = {
			UserId = ID,
			FabricatedUser = true,
		},
		Connections = {},
	}

	info.Character.Name = ID

	info.ChatEvent = Instance.new("BindableEvent")
	info.Chatted = info.ChatEvent.Event

	info.CharacterAddedEvent = Instance.new("BindableEvent")
	info.CharacterAdded = info.CharacterAddedEvent.Event

	info.Character.Parent = workspace.Players

	setmetatable(info, Test_User):Init()
	return info
end

function Test_User:Kick()
	print(`Kicking {self.UserId}`)
	self:Destroy()
end

function Test_User:PrepChat() end

function Test_User:ListenForNewCharacter()
	workspace.DescendantAdded:Connect(function(NewCharacter: Instance)
		if NewCharacter.Name == tostring(self.UserId) then
			self.CharacterAddedEvent:Fire(NewCharacter)
		end
	end)
end

function Test_User:SetAttribute(Attribute: string, Value: any)
	self.Attributes[Attribute] = Value
end

function Test_User:GetAttribute(Attribute: string)
	return self.Attributes[Attribute]
end

function Test_User:Init()
	self:ListenForNewCharacter()
end

function Test_User:IsDescendantOf(Parent: Instance)
	return true
end

function Test_User:Disconnect()
	for _, c: RBXScriptConnection in pairs(self.Connections) do
		c:Disconnect()
	end
end

function Test_User:Destroy()
	self:Disconnect()

	setmetatable(self, nil)
	table.clear(self)
	table.freeze(self)
end

export type User = typeof(Test_User.new(Instance.new("Model"), nil))

return Test_User
