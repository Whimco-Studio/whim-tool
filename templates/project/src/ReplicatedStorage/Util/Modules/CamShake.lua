--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Modules
local CameraShaker = require(ReplicatedStorage.Util.CameraShake)

--// CamShake
local Camera = workspace.CurrentCamera

local camShake = CameraShaker.new(Enum.RenderPriority.Camera.Value, function(shakeCf)
	Camera.CFrame = Camera.CFrame * shakeCf
end)

camShake:Start()

return camShake
