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

type ImageButtonProps = {
	Active: any?,
	Name: string?,
	Image: string?,
	ZIndex: number?,
	Visible: boolean?,
	GrowthSize: number?,
	FrameZIndex: number?,
	AspectRatio: number?,
	AnimationSpeed: number?,

	Size: UDim2,
	Position: UDim2?,
	ImageColor3: Color3?,
	AnchorPoint: Vector2?,
	BackgroundColor3: Color3?,
	FrameLayoutOrder: number?,
	BackgroundTransparency: number?,
	RootBackgroundTransparency: number?,

	OnClick: () -> any?,
	Children: {}?,
}

return function(props: ImageButtonProps)
	--// Value States
	local Active = props.Active or Value(false)
	local Hovering = Value(false)
	local Clicking = Value(false)

	--// Debugging
	if Interface_Settings.BaseDebug then
		task.delay(0, function()
			Active:set(true)
		end)
	end

	local ImageButton = New("Frame")({
		[Cleanup] = {},

		ZIndex = props["FrameZIndex"] or 1,
		LayoutOrder = props["FrameLayoutOrder"] or 1,
		BackgroundTransparency = props["RootBackgroundTransparency"] or 1,
		BackgroundColor3 = props.BackgroundColor3 or Color3.new(1, 1, 1),
		Size = props.Size,
		AnchorPoint = props.AnchorPoint or Vector2.new(0, 0),
		Position = props.Position or UDim2.fromScale(0.5, 0.5),
		Visible = props["Visible"] and props["Visible"] or true,
		[Children] = {
			Computed(function()
				if props["AspectRatio"] then
					return New("UIAspectRatioConstraint")({
						AspectRatio = props["AspectRatio"] or 1,
					})
				end

				return {}
			end, function(a0: Instance)
				-- a0:Destroy()
			end),
			New("ImageButton")({
				[OnEvent("MouseButton1Click")] = function()
					Sounds:Play("Click")

					if props.OnClick then
						props.OnClick()
					end

					Clicking:set(true)
					task.delay(0.25, function()
						Hovering:set(false)
						Clicking:set(false)
					end)
				end,
				[OnEvent("MouseEnter")] = function()
					Hovering:set(true)
				end,
				[OnEvent("MouseLeave")] = function()
					Hovering:set(false)
				end,

				ZIndex = props["ZIndex"] or 1,
				Name = props.Name or "Button",
				Image = props.Image or "rbxassetid://13190836263",
				ImageColor3 = props.ImageColor3 or Color3.new(1, 1, 1),
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = props.BackgroundTransparency or 1,
				BackgroundColor3 = props.BackgroundColor3 or Color3.new(1, 1, 1),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = Tween(
					Computed(function()
						if Clicking:get() then
							return UDim2.fromScale(0.75, 0.75)
						end
						if Hovering:get() then
							return UDim2.fromScale(props["GrowthSize"] or 1.25, props["GrowthSize"] or 1.25)
						end
						return Active:get() and UDim2.fromScale(1, 1) or UDim2.fromScale(0, 0)
					end),
					Tweens.modifyTween("Toon", {
						EasingDirection = Enum.EasingDirection.Out,
						Time = props["AnimationSpeed"] or Tweens.Toon.Time,
					})
				),

				ImageTransparency = Tween(
					Computed(function()
						return Active:get() and 0 or 1
					end),
					Tweens.modifyTween("Toon", {
						EasingDirection = Enum.EasingDirection.Out,
						Time = props["AnimationSpeed"] or Tweens.Toon.Time,
					})
				),

				[Children] = {
					props["Children"],
				},
			}),
		},
	})

	return ImageButton
end
