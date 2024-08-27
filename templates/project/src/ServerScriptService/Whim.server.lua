--@script
--// Services
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

--// Core Modules
local Whim = require(ReplicatedStorage.Packages.Whim)

--// Whim Stuff
local Services = ServerScriptService.Services

Whim:AddServices(Services)
Whim:Start():catch(warn)
-- Whim:Start({ ServicePromises = false }):catch(warn)
