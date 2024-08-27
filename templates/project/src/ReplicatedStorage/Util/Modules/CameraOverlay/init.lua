--[[

Example Script:

Example Script 2:
local CamOverlay = require(game.ReplicatedStorage.CameraOverlay)
CamOverlay:Start( game.ReplicatedStorage.Burn[Particle] , 2[DURATION] )

]]
--
local RunService = game:GetService("RunService")
local module = {}

function Remove(P_Name)
	local Overlay = workspace.CurrentCamera:FindFirstChild(P_Name)
	if Overlay then
		for i, v in pairs(Overlay:GetChildren()) do
			v:FindFirstChild(P_Name).Enabled = false
		end
		game.Debris:AddItem(Overlay, 1.5)
	end
end

function Update(Overlay: typeof(require(script.Overlay)))
	local Xe = game.Workspace.Camera.ViewportSize.X
	local DistFromCam = 1.3
	local Ye = game.Workspace.Camera.ViewportSize.Y
	Overlay.Size = Vector3.new(Xe / 257, Ye / 226.71, 0.506)
	Overlay.CFrame = workspace.CurrentCamera.CFrame * CFrame.new(0, 0, 0)
	Overlay.X.WorldCFrame = Overlay.CFrame * CFrame.new(Overlay.Size.X / 2.3, -Overlay.Size.Y / 9.2, -DistFromCam)
	Overlay.Xi.WorldCFrame = Overlay.CFrame * CFrame.new(-Overlay.Size.X / 2.3, -Overlay.Size.Y / 9.2, -DistFromCam)
	Overlay.Xsi.WorldCFrame = Overlay.CFrame * CFrame.new(-Overlay.Size.X / 4.6, -Overlay.Size.Y / 2.3, -DistFromCam)
	Overlay.Xsii.WorldCFrame = Overlay.CFrame * CFrame.new(-Overlay.Size.X / 2.3, -Overlay.Size.Y / 2.3, -DistFromCam)
	Overlay.Xsiii.WorldCFrame = Overlay.CFrame * CFrame.new(Overlay.Size.X / 4.6, -Overlay.Size.Y / 2.3, -DistFromCam)
	Overlay.Xs.WorldCFrame = Overlay.CFrame * CFrame.new(Overlay.Size.X / 2, Overlay.Size.Y / 2.3, -DistFromCam)
	Overlay.Y.WorldCFrame = Overlay.CFrame * CFrame.new(0, Overlay.Size.Y / 2.3, -DistFromCam)
	Overlay.Yi.WorldCFrame = Overlay.CFrame * CFrame.new(0, -Overlay.Size.Y / 2.3, -DistFromCam)
	Overlay.Ys.WorldCFrame = Overlay.CFrame * CFrame.new(-Overlay.Size.X / 2.3, Overlay.Size.Y / 2.3, -DistFromCam)
	Overlay.Ysi.WorldCFrame = Overlay.CFrame * CFrame.new(Overlay.Size.X / 2.3, -Overlay.Size.Y / 2.3, -DistFromCam)
	Overlay.Ysii.WorldCFrame = Overlay.CFrame * CFrame.new(Overlay.Size.X / 4.6, Overlay.Size.Y / 2.3, -DistFromCam)
	Overlay.Ysiii.WorldCFrame = Overlay.CFrame * CFrame.new(-Overlay.Size.X / 4.6, Overlay.Size.Y / 2.3, -DistFromCam)
	Overlay.Ysiiii.WorldCFrame = Overlay.CFrame * CFrame.new(Overlay.Size.X / 2.3, Overlay.Size.Y / 9.2, -DistFromCam)
	Overlay.Ysiiiii.WorldCFrame = Overlay.CFrame * CFrame.new(-Overlay.Size.X / 2.3, Overlay.Size.Y / 9.2, -DistFromCam)
end

function module:Start(Particle: ParticleEmitter, Duration: number)
	if Particle and Particle:IsA("ParticleEmitter") then
		local P_Code = game.HttpService:GenerateGUID(false)
		local Overlay = script.Overlay:Clone()
		Overlay.Parent = workspace.CurrentCamera
		Overlay.Name = P_Code

		for i, v in pairs(Overlay:GetChildren()) do
			local Particle_C = Particle:Clone()
			Particle_C.Name = P_Code
			Particle_C.Parent = v
			Particle_C.Enabled = true
			Particle_C.LockedToPart = true
		end

		if Duration then
			task.delay(Duration, function()
				Remove(P_Code)
				task.wait(1.35)
				RunService:UnbindFromRenderStep(P_Code)
			end)
		end

		RunService:BindToRenderStep(P_Code, 10000, function()
			Update(Overlay)
		end)
	else
		warn("Invalid input for Particle [Particle does not exist / not a particle]")
	end
end

return module
