--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Assets
local Particles = ReplicatedStorage.Assets.Particles

--// Module
local Particle = {}

Particle.ToggleEmitters = function(Parent, State)
	for _, Child in ipairs(Parent:GetDescendants()) do
		if Child:IsA("ParticleEmitter") then
			Child.Enabled = State
		end
	end
end

Particle.Create = function(ParticleName, Parent)
	if not Parent then
		return
	end

	local Effect = Particles:FindFirstChild(ParticleName):Clone()
	Effect.CFrame = Parent.CFrame
	Effect.Anchored = false
	Effect.Parent = Parent

	local CFrameOffset = Effect:GetAttribute("Offset") :: CFrame

	local Attachment = Instance.new("Attachment")
	Attachment.Parent = Effect

	if CFrameOffset then
		Attachment.CFrame = CFrameOffset
	end

	local RigidConstraint = Instance.new("RigidConstraint")
	RigidConstraint.Attachment0 = Attachment
	RigidConstraint.Attachment1 = Parent:WaitForChild("Particle")
	RigidConstraint.Parent = Effect

	Particle.ToggleEmitters(Effect, true)

	task.delay(Effect:GetAttribute("Duration"), function()
		Particle.ToggleEmitters(Effect, false)
		task.wait(1)
		Effect:Destroy()
	end)
end

return Particle
