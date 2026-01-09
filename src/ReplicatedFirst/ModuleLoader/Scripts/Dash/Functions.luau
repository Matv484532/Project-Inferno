local module = {}

-- === Services === --
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

-- === Player References === --
local plr = game:GetService("Players").LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local humanoid = char:FindFirstChildOfClass("Humanoid")

-- === Animation === --
local dashAnim = Instance.new("Animation")
dashAnim.AnimationId = "rbxassetid://115738916764023"
dashAnim.Name = "Dash"
dashAnim.Parent = script

-- === Settings === --
local key = Enum.KeyCode.LeftShift
local velocity = 20000
local debounce = false
local cd = 0.2
local duration = 0.2

-- === UI === --
local charge: NumberValue = plr:WaitForChild("DashCharges")
local UI = plr:WaitForChild("PlayerGui"):WaitForChild("Dashes")

local AvailableColor = Color3.fromRGB(4, 167, 226)
local UnavailableColor = Color3.fromRGB(155, 23, 0)

-- === Functions === --

local function SetGravityEnabled(enabled)
	local primaryPart = char.PrimaryPart
	local forceName = "AntiGravityForce"

	-- Destroy an existing force if it is still created
	local existing = primaryPart:FindFirstChild(forceName)
	if existing then
		existing:Destroy()
	end

	if not enabled then
		-- Calculate the mass of the player's character
		local totalMass = 0
		for _, part in ipairs(char:GetDescendants()) do
			if part:IsA("BasePart") then
				totalMass += part:GetMass()
			end
		end

		-- 2. Create the Force
		local attachment = Instance.new("Attachment")
		attachment.Parent = primaryPart
		local vf = Instance.new("VectorForce")
		vf.Parent = primaryPart

		vf.Name = forceName
		vf.Attachment0 = attachment
		vf.RelativeTo = Enum.ActuatorRelativeTo.World

		-- Create a force to cancel out the gravity
		vf.Force = Vector3.new(0, totalMass * workspace.Gravity, 0)
	end
end

function module.Dash()
	if debounce then
		return
	end

	if charge.Value <= 0 then
		charge.Value = 0
		return
	end

	if charge.Value < 1 then
		return
	end

	debounce = true
	if humanoid.FloorMaterial == Enum.Material.Air then
		velocity = 20000
	elseif humanoid.FloorMaterial ~= Enum.Material.Air then
		velocity = 30000
	else
		return warn("Unknown humanoid floor material state, canceled dash")
	end

	SetGravityEnabled(false)

	if char then
		local hrp = char:FindFirstChild("HumanoidRootPart")

		local animTrack = humanoid:LoadAnimation(dashAnim)
		animTrack:Play()
		local dashDir = nil
		local MoveDirection = humanoid.MoveDirection
		local lookVector = hrp.CFrame.LookVector

		local minusVelocity = -velocity

		if MoveDirection == Vector3.new(0, 0, 0) then
			dashDir = hrp.Position + Vector3.new(lookVector.X, 0, lookVector.Z)
		else
			dashDir = hrp.Position + Vector3.new(MoveDirection.X, 0, MoveDirection.Z)
		end

		humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)

		UI:FindFirstChild("Bar" .. math.floor(charge.Value)).BackgroundColor3 = UnavailableColor

		charge.Value -= 1

		local bodyGyro = Instance.new("BodyGyro")
		bodyGyro.Parent = hrp
		bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
		bodyGyro.D = 0
		bodyGyro.P = 50000
		bodyGyro.CFrame = CFrame.lookAt(hrp.Position, dashDir)

		local Att = Instance.new("Attachment")
		Att.Parent = hrp

		local vectorForce = Instance.new("VectorForce")
		vectorForce.Parent = hrp
		vectorForce.Attachment0 = Att
		vectorForce.Force = Vector3.new(0, 0, minusVelocity)
		animTrack:Play()
		humanoid.AutoRotate = false

		task.wait(duration)

		humanoid.AutoRotate = true
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)

		vectorForce:Destroy()
		bodyGyro:Destroy()
		Att:Destroy()
		task.wait(0.05)
		SetGravityEnabled(true)
		animTrack:Stop()
	end
	velocity = 20000
	task.wait(cd)
	debounce = false
end

function module.JumpDash()
	if debounce then
		return
	end

	if charge.Value <= 0 then
		charge.Value = 0
		return
	end

	if charge.Value < 2 then
		return
	end

	debounce = true
	velocity = 20000

	if char then
		humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		local hrp = char:FindFirstChild("HumanoidRootPart")
		local animTrack = humanoid:LoadAnimation(dashAnim)
		animTrack:Play()
		local dashDir = nil
		local MoveDirection = humanoid.MoveDirection
		local lookVector = hrp.CFrame.LookVector
		local minusVelocity = -velocity

		if MoveDirection == Vector3.new(0, 0, 0) then
			dashDir = hrp.Position + Vector3.new(lookVector.X, 0, lookVector.Z)
		else
			dashDir = hrp.Position + Vector3.new(MoveDirection.X, 0, MoveDirection.Z)
		end
		UI:FindFirstChild("Bar" .. math.floor(charge.Value)).BackgroundColor3 = UnavailableColor
		UI:FindFirstChild("Bar" .. math.floor(charge.Value - 1)).BackgroundColor3 = UnavailableColor
		charge.Value -= 2

		local bodyGyro = Instance.new("BodyGyro")
		bodyGyro.Parent = hrp
		bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
		bodyGyro.D = 0
		bodyGyro.P = 50000
		bodyGyro.CFrame = CFrame.lookAt(hrp.Position, dashDir)

		local Att = Instance.new("Attachment")
		Att.Parent = hrp

		local vectorForce = Instance.new("VectorForce")
		vectorForce.Parent = hrp
		vectorForce.Attachment0 = Att
		vectorForce.Force = Vector3.new(0, 0, minusVelocity)
		animTrack:Play()
		humanoid.AutoRotate = false
		task.wait(duration)

		humanoid.AutoRotate = true

		vectorForce:Destroy()
		bodyGyro:Destroy()
		Att:Destroy()
		animTrack:Stop()
	end
	velocity = 20000
	task.wait(cd)
	debounce = false
end

function module.UpdateUI()
	if charge.Value <= 0 then
		for _, bar in pairs(UI:GetChildren()) do
			bar.BackgroundColor3 = UnavailableColor
		end
	end
	if charge.Value >= 3 then
		for _, bar in pairs(UI:GetChildren()) do
			bar.BackgroundColor3 = AvailableColor
		end
	end
	if charge.Value >= 1 then
		UI.Bar1.BackgroundColor3 = AvailableColor
	end
	if charge.Value >= 2 then
		UI.Bar2.BackgroundColor3 = AvailableColor
	end
end

function module.ApplyDashes()
	UIS.InputBegan:Connect(function(input, gpe)
		if gpe then
			return
		end

		if input.KeyCode == key then
			local dashTriggered = false
			local checkTime = 0.1
			local start = tick()

			repeat
				local holdingSpace = UIS:IsKeyDown(Enum.KeyCode.Space)
				local isGrounded = (humanoid.FloorMaterial ~= Enum.Material.Air)
				local justStartedJump = (humanoid:GetState() == Enum.HumanoidStateType.Jumping)

				if holdingSpace and (isGrounded or justStartedJump) then
					module.JumpDash()
					dashTriggered = true
					break
				end
				task.wait()
			until tick() - start > checkTime

			if not dashTriggered then
				module.Dash()
			end
		end
	end)
end

function module.StaminaRegen()
	RunService.Heartbeat:Connect(function(dt)
		charge.Value += 0.7 * dt
		if charge.Value > 3 then
			charge.Value = 3
		end
		module.UpdateUI()
	end)
end

return module
