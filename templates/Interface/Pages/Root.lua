--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

--// Interface
local Interface = ReplicatedStorage.Interface
local Handler_Interface = require(ReplicatedStorage.Config.Handlers.Handlers_Interface)
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
	Page = "Root",
}

--------------------------------------------------------------------------------
--// Child Components //--
--------------------------------------------------------------------------------
local Pages = Interface.Pages
local Components = Interface.Components
local BaseComponents = Components.Base
local LocalComponents = Components.Base

--------------------------------------------------------------------------------
--// Main Component //--
--------------------------------------------------------------------------------

type RootProps = {}

return function(props: RootProps)
	--// Value States
	local Active = Value(false)
	local TextRef = Value()

	--// Signals
	local Subscription = Handler_Interface:SubscribeToState("Page", function(NewPage: string)
		Active:set(NewPage == Settings.Page)
	end)

	--// Debugging
	if Interface_Settings.AutoActive == Settings.Page then
		task.delay(0, function()
			Active:set(true)
		end)
	end

	task.spawn(function()
		local TextLabel = TextRef:get() :: TextLabel

		repeat
			TextLabel = TextRef:get()
			task.wait()
		until TextLabel

		RunService:BindToRenderStep("CameraHeight", 0, function(delta: number)
			local Character = Players.LocalPlayer.Character
			if not Character then
				return
			end

			local Root = Character:FindFirstChild("HumanoidRootPart")
			if not Root then
				return
			end

			local HeightMeter = math.ceil(Root.Position.Y / 4)
			HeightMeter = HeightMeter >= 0 and math.abs(HeightMeter) or 0

			TextLabel.Text = `{HeightMeter} M`
		end)
	end)

	local Root = New("Frame")({
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		[Children] = {
			New("ImageLabel")({
				Name = "Height",
				Image = "rbxassetid://18671506233",
				AnchorPoint = Vector2.new(0.5, 0),
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				Position = UDim2.fromScale(0.5, 0),
				Size = UDim2.fromScale(0.15, 0.15),

				[Children] = {
					New("UIAspectRatioConstraint")({
						Name = "UIAspectRatioConstraint",
						AspectRatio = 1.68,
					}),

					New("TextLabel")({
						[Ref] = TextRef,
						Name = "TextLabel",
						FontFace = Font.new("rbxasset://fonts/families/FredokaOne.json"),
						Text = "100 M",
						TextColor3 = Color3.fromRGB(0, 0, 0),
						TextScaled = true,
						TextSize = 14,
						TextWrapped = true,
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BackgroundTransparency = 1,
						BorderColor3 = Color3.fromRGB(0, 0, 0),
						BorderSizePixel = 0,
						Position = UDim2.fromScale(0.5, 0.409),
						Size = UDim2.fromScale(0.4, 0.317),
					}),
				},
			}),
		},
	})

	return Root
end
