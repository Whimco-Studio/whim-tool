local BoundingBoxUtility = {}

local function cleanup(assets)
	for _, v in pairs(assets) do
		if typeof(v) == "Instance" then
			v:Destroy()
		elseif typeof(v) == "RBXScriptConnection" then
			v:Disconnect()
		end
	end
end

function BoundingBoxUtility.CreateBoundingBox(model)
	local assets = {}

	if not model or not model:IsA("Model") then
		return nil, "Invalid model"
	end

	-- Ensure the model has parts
	local testPart = model:FindFirstChildWhichIsA("BasePart", true)
	if not testPart then
		return nil, "Model has no parts"
	end

	local orientation, size = model:GetBoundingBox()

	-- Create the bounding box
	local boundingBox = Instance.new("Part")
	boundingBox.Size = size
	boundingBox.Transparency = 1
	boundingBox.Anchored = true
	boundingBox.CanCollide = false
	boundingBox.CanTouch = false
	boundingBox.CanQuery = true
	boundingBox.Name = "BoundingBox"
	boundingBox.CFrame = orientation
	boundingBox.Parent = model

	model.PrimaryPart = boundingBox

	-- Cleanup any temporary assets
	cleanup(assets)

	return boundingBox
end

return BoundingBoxUtility
