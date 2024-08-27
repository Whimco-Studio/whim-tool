--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local _Players = game:GetService("Players")
local _RunService = game:GetService("RunService")

--// Interface
local Interface = ReplicatedStorage.Interface
local Interface_Handler = require(ReplicatedStorage.Config.Handlers.Handlers_Interface)
local Interface_Settings = require(Interface.Config.InterfaceSettings)

--// Util
local Util = Interface.Util
local Tweens = require(Util.Tweens)
local _Sounds = require(Util.Sounds)
local _Images = require(Util.Images)
local UIStroke = require(Util.UIStroke)

--// Packages
local Packages = ReplicatedStorage.Packages

--// Fusion
local Fusion = require(Packages.Fusion)

--// Fusion Imports
local New = Fusion.New
local Ref = Fusion.Ref
local Out = Fusion.Out
local Value = Fusion.Value
local Tween = Fusion.Tween
local OnEvent = Fusion.OnEvent
local Cleanup = Fusion.Cleanup
local Computed = Fusion.Computed
local Observer = Fusion.Observer
local Children = Fusion.Children

--// Configuration
local Settings = {
	Debug = true,
	Page = "CharacterCreation",
}

--------------------------------------------------------------------------------
--// Main Component //--
--------------------------------------------------------------------------------

type InputLabelProps = {
	LabelName: string,

	Size: UDim2?,
	Position: UDim2?,
	AnchorPoint: Vector2?,
	TextXAlignment: Enum.TextXAlignment?,
}

return function(props: InputLabelProps)
	--// Value States
	local Active = Value(false)
	local HasText = Value(false)
	local InputFocused = Value(false)

	--// Ref
	local TextBoxRef = Value()

	--// Signals
	local ToggleAnimationConnection = Interface_Handler.ToggleAnimation.Event:Connect(
		function(Page: string, Animate: boolean)
			if Page == Settings.Page then
				Active:set(Animate or false)
			end
		end
	)

	--// Debugging
	if Interface_Settings.AutoActive == Settings.Page then
		task.delay(0, function()
			Active:set(true)
		end)
	end

	local InputLabel = New("Frame")({
		[Cleanup] = { ToggleAnimationConnection },
		BackgroundTransparency = 1,
		Size = props["Size"] or UDim2.fromScale(0.25, 0.25),
		AnchorPoint = props["AnchorPoint"] or Vector2.new(0.5, 0.5),
		Position = props["Position"] or UDim2.fromScale(0.5, 0.5),
		TextXAlignment = props["TextXAlignment"] or Enum.TextXAlignment.Left,
		[Children] = {
			New("ImageLabel")({
				Name = "InputLabel",
				Image = "rbxassetid://13190703913",
				BackgroundTransparency = 1,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = Tween(
					Computed(function()
						return Active:get() and UDim2.fromScale(1, 1) or UDim2.fromScale(0, 0)
					end),
					Tweens.modifyTween("Toon", {
						EasingDirection = Enum.EasingDirection.Out,
					})
				),

				[Children] = {
					New("UIAspectRatioConstraint")({
						Name = "1",
						AspectRatio = 2.55,
					}),

					New("TextBox")({
						[Ref] = TextBoxRef,
						Name = "Input",
						-- CursorPosition = -1,
						FontFace = Font.new("rbxasset://fonts/families/FredokaOne.json"),
						Text = "",
						TextColor3 = Color3.fromRGB(70, 70, 70),
						TextScaled = true,
						TextSize = 14,
						TextWrapped = true,
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundTransparency = 1,
						Position = UDim2.fromScale(0.5, 0.5),
						Size = UDim2.fromScale(0.742, 0.35),
						TextXAlignment = Enum.TextXAlignment.Left,
						[OnEvent("Focused")] = function()
							InputFocused:set(true)
						end,
						[OnEvent("FocusLost")] = function()
							InputFocused:set(false)
							HasText:set(#TextBoxRef:get().Text > 0)
						end,
					}),

					Computed(function()
						if props.LabelName then
							return New("TextLabel")({
								Name = props.LabelName .. "Label",
								FontFace = Font.new("rbxasset://fonts/families/FredokaOne.json"),
								Text = props.LabelName,
								TextColor3 = Tween(
									Computed(function()
										local ActiveStateSize = Color3.new(1, 1, 1)
										if HasText:get() then
											return ActiveStateSize
										end

										return InputFocused:get() and ActiveStateSize or Color3.new(0.85, 0.85, 0.85)
									end),
									Tweens.modifyTween("Toon", {
										EasingDirection = Enum.EasingDirection.Out,
									})
								),
								TextScaled = true,
								TextSize = Tween(
									Computed(function()
										local ActiveStateSize = 5
										if HasText:get() then
											return ActiveStateSize
										end
										return InputFocused:get() and ActiveStateSize or 14
									end),
									Tweens.Default
								),
								TextWrapped = true,
								TextXAlignment = Enum.TextXAlignment.Left,
								BackgroundTransparency = 1,
								AnchorPoint = Vector2.new(1, 0.5),
								Position = Tween(
									Computed(function()
										local ActiveStateSize = UDim2.fromScale(0.3, -0.2)
										if HasText:get() then
											return ActiveStateSize
										end

										return InputFocused:get() and ActiveStateSize or UDim2.fromScale(0.65, 0.5)
									end),
									Tweens.modifyTween("Toon", {
										EasingDirection = Enum.EasingDirection.Out,
									})
								),
								Size = Tween(
									Computed(function()
										local ActiveStateSize = UDim2.fromScale(0.25, 0.25)
										if HasText:get() then
											return ActiveStateSize
										end

										return InputFocused:get() and ActiveStateSize or UDim2.fromScale(0.5, 0.5)
									end),
									Tweens.modifyTween("Toon", {
										EasingDirection = Enum.EasingDirection.Out,
									})
								),

								[Children] = {
									New("UIStroke")({
										Name = "1",
										Color = Color3.fromRGB(84, 175, 255),
										LineJoinMode = Enum.LineJoinMode.Miter,
										Transparency = Tween(
											Computed(function()
												if HasText:get() then
													return 0
												end

												return InputFocused:get() and 0 or 1
											end),
											Tweens.Default
										),
										Thickness = Tween(
											Computed(function()
												if HasText:get() then
													return UIStroke(1)
												end

												return InputFocused:get() and UIStroke(3) or 0
											end),
											Tweens.Default
										),
									}),
								},
							})
						end

						return {}
					end, function()
						return {}
					end),
				},
			}),
		},
	})

	return InputLabel
end
