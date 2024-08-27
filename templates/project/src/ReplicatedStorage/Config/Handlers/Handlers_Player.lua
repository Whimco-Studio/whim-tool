---@diagnostic disable: undefined-type

-- Implementation of Interface.

--// Types
export type FabricatedUser = Player & { FabricatedUser: boolean? }

export type UserTradeContent = {
	Coins: number,
	Gems: number,
	Items: {
		{
			Slot: number,
			ItemId: number,
		}
	},
}

export type TradeInfo = {
	Id: string,
	Key: FabricatedUser,
	Host: FabricatedUser,
	HostInfo: UserTradeContent,
	Recipient: FabricatedUser,
	RecipientInfo: UserTradeContent,
}

--// Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Plugin
local Plugin = ReplicatedStorage

--// Fusion
local Fusion = require(Plugin.Packages.Fusion)
local Value = Fusion.Value
local Observer = Fusion.Observer

--// Maid
local Maid = require(Plugin.Packages.Maid)

--// Class
local Interface = {}
Interface.__index = Interface

--// Private Function
local function FlattenStates(states, prefix)
	local flatStates = {}
	for key, value in pairs(states) do
		-- Construct a new key using the prefix and the current key
		local newKey = key

		if typeof(value) == "table" and not getmetatable(value) then
			-- If the value is a table and not a Fusion Value object, recursively flatten it
			local nestedStates = FlattenStates(value, newKey)
			for nestedKey, nestedValue in pairs(nestedStates) do
				flatStates[nestedKey] = nestedValue
			end
		else
			-- If the value is not a table or is a Fusion Value object, add it directly
			flatStates[newKey] = value
		end
	end
	return flatStates
end

---
-- @description Constructs a new Interface object.
-- @return Interface - The newly created Interface instance.
--
function Interface.new()
	local Event = function()
		return Instance.new("BindableEvent")
	end

	local Function = function()
		return Instance.new("BindableFunction")
	end

	local info = {
		--// External
		Events = {
			General = {},
		},

		--// Internal

		--// States
		States = {

			Root = {
				Character = Value(false),
				SpeedBoost = Value(false),
			},
		},

		--// State Subscriptions
		StateSubscriptions = {},

		--// CleanUp
		_maid = Maid.new(),
	}

	setmetatable(info, Interface):Init()

	return info
end

---
-- @description Removes Layers from self.Event
--
function Interface:CondensedSelf()
	local function RecursiveLoop(A, _Tbl)
		local Tbl = _Tbl or {}
		for i, v in pairs(A) do
			if typeof(v) == "table" and not v["_value"] then
				-- Removed 'return' to allow continuation of the loop
				RecursiveLoop(v, Tbl)
			else
				if Tbl[i] then
					warn(i .. " already exists!")
				end

				Tbl[i] = v
			end
		end
		return Tbl
	end

	self.Events = RecursiveLoop(self.Events, {})
	self.States = FlattenStates(self.States, "")
end

---
-- @description Adds Observers for the States in the Interface.
--
function Interface:InitializeSubscriptionArrays()
	for StateName: string, State in pairs(self.States) do
		local CurrentStateSubscriptionArray = self.StateSubscriptions[StateName]
		self.StateSubscriptions[StateName] = CurrentStateSubscriptionArray or {}
	end
end

---
-- @description Initializes the Interface.
--
function Interface:Init()
	self:CondensedSelf()
	self:InitializeSubscriptionArrays()
	self:ListenToStates()

	Players.LocalPlayer.CharacterAdded:Connect(function(Character)
		self:SetState("Character", Character)
		workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
	end)

	task.spawn(function()
		local Character = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
		self:SetState("Character", Character)
	end)
end

---
-- @description Adds Observers for the States in the Interface.
--
function Interface:ListenToStates()
	-- Adding Observers
	for StateName, State in pairs(self.States) do
		--// LocalStateSubscriptions
		local StateSubscriptions = self.StateSubscriptions[StateName]

		local observer = Observer(State)
		self._maid:GiveTask(observer:onChange(function()
			for _, Callback: () -> nil in pairs(StateSubscriptions) do
				Callback(State:get())
			end
		end))
	end
end

---
-- @description Fetches a desired BindableEvent from the Interface.
-- @param SignalName string - The name of the BindableEvent to fetch.
-- @return BindableEvent - The fetched BindableEvent.
--
function Interface:GetEvent(SignalName: string): BindableEvent
	local DesiredSignal: BindableEvent = self.Events[SignalName]
	assert(DesiredSignal, "Bindable Event `" .. SignalName .. "` does not exist")

	return DesiredSignal
end

---
-- @description Fetches a desired State from the Interface.
-- @param StateName string - The name of the State to fetch.
-- @return Fusion.Value<any> - The fetched State.
--

function Interface:GetState(StateName: string)
	local DesiredState = self.States[StateName]
	assert(DesiredState, "State `" .. StateName .. "` does not exist")

	return DesiredState
end

---
-- @description Fetches a desired State value from the Interface.
-- @param StateName string - The name of the State to fetch.
-- @return Fusion.Value<any> - The fetched State.
--
function Interface:Get(StateName: string)
	local DesiredState = self.States[StateName]
	assert(DesiredState, "State `" .. StateName .. "` does not exist")

	return DesiredState:get()
end

---
-- @description Sets a state value in the Interface.
-- @param StateName string - The name of the State to set.
-- @param Value any - The value to set the state to.
--
function Interface:SetState(StateName: string, _Value)
	local DesiredState = self:GetState(StateName)
	DesiredState:set(_Value)
end

---
-- @description Sets a state value in the Interface.
-- @param StateName string - The name of the State to set.
-- @param Value any - The value to set the state to.
--
function Interface:Set(StateName: string, _Value)
	local DesiredState = self:GetState(StateName)
	DesiredState:set(_Value)
end

---
-- @description Hooks an event listener to a desired State.
-- @param StateName string - The name of the State to hook.
-- @param callback function - The function to execute when the event is triggered.
--
function Interface:SubscribeToState(State: string, callback: () -> nil)
	local DesiredState = self:GetState(State)
	local StateSubscriptions = self.StateSubscriptions[State] or {}

	table.insert(StateSubscriptions, callback)
end

---
-- @description Hooks an event listener to a desired BindableEvent.
-- @param SignalName string - The name of the BindableEvent to hook.
-- @param callback function - The function to execute when the event is triggered.
--
function Interface:Subscribe(SignalName: string, callback: () -> nil)
	local DesiredSignal: BindableEvent | BindableFunction = self:GetEvent(SignalName)

	if DesiredSignal.ClassName == "BindableEvent" then
		self._maid:GiveTask(DesiredSignal.Event:Connect(callback))
	else
		DesiredSignal.OnInvoke = function()
			return callback()
		end
	end
end

---
-- @description Fires a BindableEvent with the provided arguments.
-- @param SignalName string - The name of the BindableEvent to fire.
-- @param ... any - The arguments to pass when firing the event.
--
function Interface:Fire(SignalName: string, ...)
	local DesiredSignal: BindableEvent | BindableFunction = self:GetEvent(SignalName)
	local IsRemoteFunction = DesiredSignal:IsA("RemoteFunction")

	if not IsRemoteFunction then
		DesiredSignal:Fire(...)
	else
		return DesiredSignal:Invoke(...)
	end
end

---
-- @description Cleans up all tasks and listeners associated with the Interface.
--
function Interface:DoCleaning()
	self._maid:Cleanup()
end

return Interface.new()
