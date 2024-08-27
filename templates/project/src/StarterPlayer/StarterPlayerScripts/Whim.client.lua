--@localscript
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

-- Load core module:
local Whim = require(ReplicatedStorage.Packages.Whim)

Whim.Player = Players.LocalPlayer

--// Adding Conrollers
Whim:AddControllers(ReplicatedStorage.Controllers)

-- Start Whim:
Whim:Start():catch(warn)
