local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
return {
	Pop = function(Root, Mini: boolean?)
		if Root ~= nil then
			local Poof = ReplicatedStorage.Assets.Particles:FindFirstChild(Mini and "MiniPoof" or "Poof"):Clone()

			Poof.Parent = game.Workspace
			Poof.CFrame = Root.CFrame

			local PopSound = game.SoundService.Pop:Clone()

			PopSound.Parent = Poof
			PopSound.TimePosition = 0.1
			PopSound:Play()
			Poof.Roblox.Enabled = true

			-- Root.Parent:Destroy()
			task.delay(0, function()
				task.wait(0.1)

				Poof.Roblox.Enabled = false
				task.wait(0.5)

				Poof:Destroy()
			end)
		end
	end,
	Collide = function(Root)
		if not Root then
			return
		end
		local Poof = ReplicatedStorage.Assets.Particles:FindFirstChild("Collision"):Clone()

		Poof.Parent = workspace
		Poof.CFrame = Root.CFrame

		Debris:AddItem(Poof, 2)

		for i, v in pairs(Poof:GetDescendants()) do
			if not v:IsA("ParticleEmitter") then
				continue
			end
			v.Enabled = true
			-- print(v.Enabled)
			task.delay(0.1, function()
				v.Enabled = false
			end)
		end
	end,
}
