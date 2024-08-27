-- Implementation of Interface.

--// Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

--// Modules
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Feel = require(ReplicatedStorage.Util.Libs.Feel)
local Maid = require(ReplicatedStorage.Packages.Maid)

--// Types
type Connections = { [string]: RBXScriptConnection }

--// Class
local Interface = {}
Interface.__index = Interface
Interface.ClassName = "Interface"

--// Variables
local PagesFolder = script.Pages
local Handlers = ReplicatedStorage.Config.Handlers

local Handler_Interface = require(Handlers.Handlers_Interface)

local Pages = {
	["Root"] = require(PagesFolder.Root),
}

local function createScreenGui()
	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Parent = Players.LocalPlayer.PlayerGui
	ScreenGui.DisplayOrder = 5
	ScreenGui.IgnoreGuiInset = true
	ScreenGui.ResetOnSpawn = false
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	Handler_Interface:Set("ScreenGui", ScreenGui)

	return ScreenGui
end

function Interface.new()
	local info = {
		Handler = Handler_Interface,
		Connections = {},
	}

	setmetatable(info, Interface):Init()
	return info
end

function Interface:ToggleBlur(Blur: BlurEffect, Active: boolean)
	if Blur.Parent == nil then
		self.Blur = Instance.new("BlurEffect")
		self.Blur.Size = 0
		self.Blur.Parent = game.Lighting
		Blur = self.Blur
	end

	Feel.Tween
		.new(
			Blur,
			{
				Size = Active and 24 or 0,
			},
			0.2,
			{
				EasingStyle = Enum.EasingStyle.Linear,
			}
		)
		:Play()

	Feel.Tween
		.new(
			workspace.CurrentCamera,
			{
				FieldOfView = Active and 50 or 70,
			},
			0.2,
			{
				EasingStyle = Enum.EasingStyle.Linear,
			}
		)
		:Play()
end

function Interface:Init()
	self.Blur = Instance.new("BlurEffect")
	self.Blur.Size = 0
	self.Blur.Parent = game.Lighting

	self.Trees = {}
	self.ScreenGui = createScreenGui()
	self.Connections = Maid.new()

	self:signals()
	self:mountScreen("Root")
end

function Interface:signals()
	Handler_Interface:SubscribeToState("Page", function(Page: string, Active: boolean, ToggleBlur: boolean)
		if ToggleBlur then
			self:ToggleBlur(self.Blur, Active)
		end

		if Page == "Store" then
			StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, not Active)
		end
	end)
end

function Interface:connections()
	Handler_Interface.UnmountScreen.Event:Connect(function(ScreenName)
		self:unmountScreen(ScreenName)
	end)
	Handler_Interface.MountScreen.Event:Connect(function(ScreenName)
		self:mountScreen(ScreenName)
	end)
end

function Interface:unmountSafeGuard(ScreenName)
	local ActiveTree = self.Trees[ScreenName]
	if ActiveTree then
		return ActiveTree
	end
	return false
end

function Interface:mountSafeGuard(ScreenName)
	local Page = Pages[ScreenName]
	local ActiveTree = self.Trees[ScreenName]
	if Page and not ActiveTree then
		return true
	end
	return false
end

function Interface:mountScreen(ScreenName, props, Cleanup)
	if self:mountSafeGuard(ScreenName) then
		self.Trees[ScreenName] = Pages[ScreenName](props or {}, Cleanup or function()
			print("Cleaning up " .. ScreenName)
		end)
		self.Trees[ScreenName].Parent = self.ScreenGui
	end
end

function Interface:unmountScreen(ScreenName)
	local ActiveTree = self.Trees[ScreenName]
	if self:unmountSafeGuard(ScreenName) then
		ActiveTree:Destroy()
		self.Trees[ScreenName] = nil
	end
end

function Interface:disconnect()
	local Connections: typeof(Maid.new()) = self.Connections
end

function Interface:destroy()
	self:Disconnect()

	setmetatable(self, nil)
	table.clear(self)
	table.freeze(self)
end

return Interface.new()
