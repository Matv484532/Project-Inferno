local module = {}
module.IsReady = false

function module.init()
	game:GetService("Players").PlayerAdded:Connect(function(plr)
		local Charges = Instance.new("NumberValue")
		Charges.Name = "DashCharges"
		Charges.Value = 3
		Charges.Parent = plr
	end)
	module.IsReady = true
end

return module
