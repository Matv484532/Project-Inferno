return {
	--static
	BaseRot = 1.25, -- rotation speed
	SetRot = 0.4, -- rotation strenght
	BaseFreq = 15, -- view bobbing frequency
	SetFreq = 0.16, -- view bobbing strenght
	BaseMult = 12, -- base multiplier: less -> stronger effects
	BaseNumLerp = 0.25, -- lerp time value

	--sway settings
	SwayStrenght = 0.025, -- effect strenght
	BaseSway = 1, -- axis strenght
	SetSway = 0.5, -- axis multiplier
	CustomSwayZVal = -10, -- vector z value

	--drift min/max
	DriftMin = -1,
	DriftMax = 1,

	--fps
	Rate = 60,

	--blur
	MaxBlur = 3, -- max blur value
	BlurMult = 1.75, -- blur multiplier
}
