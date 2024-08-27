-- Implementation of Camera.

--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Module
local Camera = {}

function Camera.getCameraOffset(fov, extentsSize)
	local halfSize = extentsSize.Magnitude / 2
	local fovDivisor = math.tan(math.rad(fov / 2))
	return halfSize / fovDivisor
end

function Camera.zoomToExtents(camera, instance)
	local isModel = instance:IsA("Model")

	local instanceCFrame = isModel and instance:GetModelCFrame() or instance.CFrame
	local extentsSize = isModel and instance:GetExtentsSize() or instance.Size

	local cameraOffset = Camera.getCameraOffset(camera.FieldOfView, extentsSize)
	local cameraRotation = camera.CFrame - camera.CFrame.p

	local instancePosition = instanceCFrame.p
	camera.CFrame = cameraRotation + instancePosition + (-cameraRotation.LookVector * cameraOffset)
	camera.Focus = cameraRotation + instancePosition
end

return Camera
