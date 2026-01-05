local module = {}
module.IsReady = false
local Settings: SettingsType = require(script:WaitForChild("Settings"))
type SettingsType = {
	BaseRot: number,
	SetRot: number,
	BaseFreq: number,
	SetFreq: number,
	BaseMult: number,
	BaseNumLerp: number,
	SwayStrenght: number,
	BaseSway: number,
	SetSway: number,
	CustomSwayZVal: number,
	DriftMin: number,
	DriftMax: number,
	Rate: number,
	MaxBlur: number,
	BlurMult: number,
}
local MouseDelta: Vector2
local Vel, t: number

local sin = math.sin
local cos = math.cos
local rad = math.rad
local abs = math.abs
local sqrt = math.sqrt
local clamp = math.clamp
local round = math.round
local clock = os.clock

local CurrentVel = 0
local Drift = 0
local Limiter = 0

local RunServ = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local PlrServ = game:GetService("Players")
local LightingServ = game:GetService("Lighting")

local LocalPlr = PlrServ.LocalPlayer

local Cam: Camera = workspace.CurrentCamera
local BaseFov = Cam.FieldOfView

local char: Model = LocalPlr.Character or LocalPlr.CharacterAdded:Wait()
local HRP = char:WaitForChild("HumanoidRootPart") :: BasePart

function NumLerp(num1: number, num2: number, rate: number): number
	return num1 + (num2 - num1) * rate
end

function CalculateCurve(Base: number, Set: number): number
	return sin(clock() * Base) * Set
end

function GetVelMag(): number
	return round(
		Vector3.new(HRP.AssemblyLinearVelocity.X, HRP.AssemblyLinearVelocity.Y, HRP.AssemblyLinearVelocity.Z).Magnitude
	)
end

function GetMouseDrift(Drift: number, MouseDelta: Vector2, dt: number): number
	return NumLerp(Drift, clamp(MouseDelta.X, Settings.DriftMin, Settings.DriftMax), (Settings.BaseMult * dt))
end

local function setBlur(): BlurEffect
	local MotionBlur: BlurEffect = LightingServ:FindFirstChild("MotionBlur")

	if not MotionBlur then
		local newMotionBlur = Instance.new("BlurEffect")
		newMotionBlur.Size = 0
		newMotionBlur.Name = "MotionBlur"
		newMotionBlur.Enabled = true
		newMotionBlur.Parent = LightingServ

		MotionBlur = newMotionBlur
	end

	return MotionBlur
end

local MotionBlur = setBlur()

local function CameraUpdt(dt)
	Limiter += dt
	if Limiter >= 1 / Settings.Rate then
		t = clock()
		MouseDelta = UIS:GetMouseDelta()

		Vel = NumLerp(CurrentVel, GetVelMag(), Settings.BaseNumLerp)

		x = cos(t * Settings.BaseSway) * Settings.SetSway
		y = sin(t * Settings.BaseSway) * Settings.SetSway

		Drift = GetMouseDrift(Drift, MouseDelta, dt)

		Cam.FieldOfView = BaseFov + sqrt(Vel)

		MotionBlur.Size = clamp(abs(Drift * Settings.BlurMult), 0, Settings.MaxBlur)
		CurrentVel = Vel

		Cam.CFrame = Cam.CFrame
			* CFrame.new(0, CalculateCurve(Settings.BaseFreq, Settings.SetFreq) * Vel / Settings.BaseMult, 0)
			* CFrame.Angles(
				0,
				0,
				rad(CalculateCurve(Settings.BaseRot, Settings.SetRot) * Vel / Settings.BaseMult) + rad(Drift)
			)

		Limiter -= 1 / Settings.Rate
	end
end

function module.init()
	LocalPlr.CameraMode = Enum.CameraMode.LockFirstPerson
	RunServ:BindToRenderStep("CamEffect", Enum.RenderPriority.Camera.Value, CameraUpdt)
	module.IsReady = true
end

function module.Set()
	LocalPlr.CameraMode = Enum.CameraMode.LockFirstPerson
	RunServ:BindToRenderStep("CamEffect", Enum.RenderPriority.Camera.Value, CameraUpdt)
end

function module.Reset()
	LocalPlr.CameraMode = Enum.CameraMode.Classic
end

return module
