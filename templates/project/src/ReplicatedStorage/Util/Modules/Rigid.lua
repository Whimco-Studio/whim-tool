-- RigidConstraint Function
return function(Host: Instance, Target: Instance)
	local Attachment0 = Instance.new("Attachment")
	local Attachment1 = Instance.new("Attachment")

	Attachment0.Parent = Host
	Attachment1.Parent = Target

	local RigidConstraint = Instance.new("RigidConstraint")
	RigidConstraint.Attachment0 = Attachment0
	RigidConstraint.Attachment1 = Attachment1
	RigidConstraint.Parent = Host

	Host.Destroying:Once(function(...: any)
		Host:Destroy()
	end)

	return RigidConstraint
end
