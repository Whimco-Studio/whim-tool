--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Pages
local Components = ReplicatedStorage.Interface.Components
local Pages = ReplicatedStorage.Interface.Pages

local RootFrame = require(Pages.Root)()

return function(target: Frame)
	RootFrame.Parent = target
	return function()
		RootFrame:Destroy()
	end
end
