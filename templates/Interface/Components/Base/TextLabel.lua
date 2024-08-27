--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

--// Interface
local Interface = ReplicatedStorage.Interface
local Interface_Handler = require(ReplicatedStorage.Config.Handlers.Handlers_Interface)
local Interface_Settings = require(Interface.Config.InterfaceSettings)

--// Util
local Util = Interface.Util
local Tweens = require(Util.Tweens)
local Sounds = require(Util.Sounds)
local Images = require(Util.Images)

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
	Page = "Base",
}

--------------------------------------------------------------------------------
--// Main Component //--
--------------------------------------------------------------------------------

type TextLabelProps = {
	Active: any?,
	Name: string?,
	Text: string?,

	Size: UDim2,
	Position: UDim2?,
	AnchorPoint: Vector2?,

	Children: {},
}

return function(props: TextLabelProps)
	--// Value States
	local Active = props["Active"] or Value(false)
	local Hovering = Value(false)
	local Clicking = Value(false)

	--// Signals
	local ToggleAnimationConnection = Interface_Handler.ToggleAnimation.Event:Connect(
		function(Page: string, Animate: boolean)
			if Page == Settings.Page then
				Active:set(Animate or false)
			end
		end
	)

	--// Debugging
	if Interface_Settings.BaseDebug:get() == true then
		task.delay(0, function()
			Active:set(true)
		end)
	end

	local TextLabel = New("Frame")({
		[Cleanup] = { ToggleAnimationConnection },
		BackgroundTransparency = 1,
		Size = props.Size,
		AnchorPoint = props["AnchorPoint"] or Vector2.new(0, 0),
		Position = props["Position"] or UDim2.fromScale(0.5, 0.5),
		[Children] = {
			New("ImageLabel")({
				Name = "NameLabelQCS",
				Image = "rbxassetid://14962576335",
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = Tween(
					Computed(function()
						if Clicking:get() then
							return UDim2.fromScale(0.75, 0.75)
						end
						if Hovering:get() then
							return UDim2.fromScale(1.25, 1.25)
						end
						return Active:get() and UDim2.fromScale(1, 1) or UDim2.fromScale(0, 0)
					end),
					Tweens.modifyTween("Toon", {
						EasingDirection = Enum.EasingDirection.Out,
					})
				),

				[Children] = {
					New("UIAspectRatioConstraint")({
						Name = "UIAspectRatioConstraint",
						AspectRatio = 2.26,
					}),

					New("TextLabel")({
						Name = "Label",
						FontFace = Font.new("rbxasset://fonts/families/FredokaOne.json"),
						Text = props["Text"] or "Empty",
						TextColor3 = Color3.fromRGB(0, 0, 0),
						TextScaled = true,
						TextSize = 14,
						TextWrapped = true,
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BackgroundTransparency = 1,
						BorderColor3 = Color3.fromRGB(0, 0, 0),
						BorderSizePixel = 0,
						Position = UDim2.fromScale(0.115, 0.24),
						Size = UDim2.fromScale(0.779, 0.38),
					}),
				},
			}),
		},
	})

	return TextLabel
end
