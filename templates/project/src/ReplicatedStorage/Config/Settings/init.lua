local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local module = {
	QuirkyVersion = not Players.CharacterAutoLoads,
}

return module
