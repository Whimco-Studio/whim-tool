local Settings = {
	DefaultTransitionTime = 0.75,
	DefaultContentDelay = 0.3,
}

local Tweens = {

	DefaultTransitionTime = Settings.DefaultTransitionTime,
	DefaultContentDelay = Settings.DefaultContentDelay,
	Default = TweenInfo.new(
		Settings.DefaultTransitionTime,
		Enum.EasingStyle.Sine,
		Enum.EasingDirection.InOut,
		0,
		false,
		0
	),
	Toon = TweenInfo.new(
		Settings.DefaultTransitionTime,
		Enum.EasingStyle.Back,
		Enum.EasingDirection.InOut,
		0,
		false,
		0
	),
}

Tweens.Fast =
	TweenInfo.new(Settings.DefaultTransitionTime / 5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, false, 0)

Tweens.ToonMedium =
	TweenInfo.new(Settings.DefaultTransitionTime / 2.5, Enum.EasingStyle.Back, Enum.EasingDirection.InOut, 0, false, 0)

Tweens.ToonFast =
	TweenInfo.new(Settings.DefaultTransitionTime / 5, Enum.EasingStyle.Back, Enum.EasingDirection.InOut, 0, false, 0)

Tweens.RadialMenuTransitionTime = Settings.DefaultTransitionTime / 1.5

function Tweens.modifyTween(
	_BaseStyle: string,
	Changes: {
		Time: number?,
		EasingStyle: Enum.EasingStyle?,
		EasingDirection: Enum.EasingDirection?,
		RepeatCount: number?,
		Reverses: boolean?,
		DelayTime: number?,
	},
	SaveName: string?
)
	local BaseStyle = Tweens[_BaseStyle]

	local NewTween = TweenInfo.new(
		Changes.Time or BaseStyle.Time,
		Changes.EasingStyle or BaseStyle.EasingStyle,
		Changes.EasingDirection or BaseStyle.EasingDirection,
		Changes.RepeatCount or BaseStyle.RepeatCount,
		Changes.Reverses or BaseStyle.Reverses,
		Changes.DelayTime or BaseStyle.DelayTime
	)

	if SaveName then
		Tweens[SaveName] = NewTween
	end

	return NewTween
end

Tweens.WindowTime = Tweens.Toon.Time / 2.5

return Tweens
