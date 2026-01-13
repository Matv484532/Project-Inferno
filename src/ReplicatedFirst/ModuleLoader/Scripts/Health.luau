local Players = game:GetService("Players")
local TS = game:GetService("TweenService")

local plr = Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local plrGui = plr:WaitForChild("PlayerGui")
local Gui = plrGui:WaitForChild("Health").HealthBar
local Filling = Gui.Fill
local hum = char:WaitForChild("Humanoid")

local Text = Gui.HealthLabel
local BaseFillingX = Filling.Size.X.Offset
local BaseFillingY = Filling.Size.Y.Offset

local Siza

local module = {}

function module.HealthBarUpdate()
	hum.HealthChanged:Connect(function()
		local Health = hum.Health
		local MaxHealth = hum.MaxHealth

		if Health >= 100 then
			Siza = UDim2.fromOffset(BaseFillingX, BaseFillingY)
		else
			Siza = UDim2.fromOffset((Health / 100) * BaseFillingX, BaseFillingY)
		end

		local HealthTween =
			TS:Create(Filling, TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), { Size = Siza })

		HealthTween:Play()
		Text.Text = "+  " .. tostring(Health) .. "/100"
	end)
end

function module.init()
	module.HealthBarUpdate()
end

return module
