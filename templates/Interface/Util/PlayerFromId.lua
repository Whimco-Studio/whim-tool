local Players = game:GetService("Players")

return function(Id: string)
	for i, p: Player in ipairs(Players:GetPlayers()) do
		if p.Name == Id then
			return p
		end
	end

	return false
end
