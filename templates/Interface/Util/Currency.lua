--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")

--// Interface
local Interface = ReplicatedStorage.Interface
local ImageButton = require(Interface.Components.Base.ImageButton)

--// Packages
local Packages = ReplicatedStorage.Packages

--// Fusion
local Fusion = require(Packages.Fusion)

--// Fusion Imports
local New = Fusion.New
local Value = Fusion.Value
local Computed = Fusion.Computed
local Children = Fusion.Children

local Active = Value(true)
local GrowthSize = 1.1
local AnimationSpeed = 0.25

local function BaseElementCurrencyAmount(Icon: string, CoinValue: number)
	return {
		New("ImageLabel")({
			Name = "CoinsIcon",
			Image = "rbxassetid://17267367760",
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			Position = UDim2.fromScale(0.136, 0.113),
			Size = UDim2.fromScale(0.276, 0.363),
			ZIndex = 5,
		}),

		New("TextLabel")({
			Name = "CoinsValue",
			FontFace = Font.new("rbxasset://fonts/families/LuckiestGuy.json"),
			Text = `+{CoinValue}`,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextScaled = true,
			TextSize = 14,
			TextWrapped = true,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			Position = UDim2.fromScale(0.48, 0.193),
			Size = UDim2.fromScale(0.434, 0.28),
			ZIndex = 4,

			[Children] = {
				New("UIStroke")({
					Name = "UIStroke",
					Thickness = 3,
				}),
			},
		}),
	}
end

return {
	Base = function(props: {
		ID: number,
		Index: number,
		Reward: number,
		Section: string,
		CallBack: () -> nil,
	})
		local Pricing = Value("...")

		task.spawn(function()
			local ProductInfo =
				MarketplaceService:GetProductInfo(props.ID, Enum.InfoType[props.Section]) :: Enum.InfoType

			if ProductInfo then
				Pricing:set(ProductInfo["PriceInRobux"])
			end
		end)

		return New("ImageLabel")({
			Name = "0" .. props.Index,
			Image = "rbxassetid://17343261719",
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			LayoutOrder = props.Index,
			Size = UDim2.fromScale(0.269, 1),

			[Children] = {
				BaseElementCurrencyAmount("rbxassetid://17267367760", props.Reward or 500),
				ImageButton({
					Active = Active,
					GrowthSize = GrowthSize,
					AnimationSpeed = AnimationSpeed,
					Name = "PurchaseButton",
					Image = "rbxassetid://17343262322",
					AnchorPoint = Vector2.new(0.5, 1),
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 1,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Position = UDim2.fromScale(0.5, 0.925),
					Size = UDim2.fromScale(0.833, 0.345),
					FrameZIndex = 3,
					OnClick = props.CallBack,

					Children = {
						New("ImageLabel")({
							Name = "RobuxIcon",
							Image = "rbxassetid://17343261881",
							BackgroundColor3 = Color3.fromRGB(255, 255, 255),
							BackgroundTransparency = 1,
							BorderColor3 = Color3.fromRGB(0, 0, 0),
							BorderSizePixel = 0,
							Position = UDim2.fromScale(0.245, 0.259),
							Size = UDim2.fromScale(0.152, 0.483),
							ZIndex = 4,

							[Children] = {
								New("UIAspectRatioConstraint")({
									Name = "UIAspectRatioConstraint",
								}),
							},
						}),

						New("UIListLayout")({
							Name = "UIListLayout",
							Padding = UDim.new(0.025, 0),
							FillDirection = Enum.FillDirection.Horizontal,
							HorizontalAlignment = Enum.HorizontalAlignment.Center,
							SortOrder = Enum.SortOrder.LayoutOrder,
						}),

						New("UIPadding")({
							Name = "UIPadding",
							PaddingTop = UDim.new(0.2, 0),
						}),

						New("TextLabel")({
							Name = "Price",
							FontFace = Font.new("rbxasset://fonts/families/LuckiestGuy.json"),
							Text = Computed(function()
								return Pricing:get()
							end),
							TextColor3 = Color3.fromRGB(255, 255, 255),
							TextScaled = true,
							TextSize = 50,
							TextWrapped = true,
							BackgroundColor3 = Color3.fromRGB(255, 255, 255),
							BackgroundTransparency = 1,
							BorderColor3 = Color3.fromRGB(0, 0, 0),
							BorderSizePixel = 0,
							Position = UDim2.fromScale(0.42, 1.23e-07),
							Size = UDim2.fromScale(0.337, 0.655),

							[Children] = {
								New("UIStroke")({
									Name = "UIStroke",
									LineJoinMode = Enum.LineJoinMode.Round,
									Thickness = 3,
								}),
							},
						}),
					},
				}),
			},
		})
	end,
	LongFirst = function(props: {
		ID: number,
		Index: number,
		Section: string,
		CallBack: () -> nil,
	})
		local Pricing = Value("Loading...")

		task.spawn(function()
			local ProductInfo =
				MarketplaceService:GetProductInfo(props.ID, Enum.InfoType[props.Section]) :: Enum.InfoType

			if ProductInfo then
				Pricing:set(ProductInfo["PriceInRobux"])
			end
		end)

		return New("ImageLabel")({
			Name = "0" .. props.Index,
			Image = "rbxassetid://17343262015",
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			LayoutOrder = props.Index,
			Size = UDim2.fromScale(0.378, 1),

			[Children] = {
				ImageButton({
					Active = Active,
					GrowthSize = GrowthSize,
					AnimationSpeed = AnimationSpeed,
					Name = "PurchaseButton",
					Image = "rbxassetid://17343261569",
					AnchorPoint = Vector2.new(1, 0),
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 1,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Position = UDim2.fromScale(0.96, 0.075),
					Size = UDim2.fromScale(0.412, 0.345),
					ZIndex = 3,
					OnClick = props.CallBack,

					Children = {
						New("ImageLabel")({
							Name = "RobuxIcon",
							Image = "rbxassetid://17343261881",
							BackgroundColor3 = Color3.fromRGB(255, 255, 255),
							BackgroundTransparency = 1,
							BorderColor3 = Color3.fromRGB(0, 0, 0),
							BorderSizePixel = 0,
							Position = UDim2.fromScale(0.158, 1.44e-06),
							Size = UDim2.fromScale(0.219, 0.603),
							ZIndex = 4,

							[Children] = {
								New("UIAspectRatioConstraint")({
									Name = "UIAspectRatioConstraint",
								}),
							},
						}),

						New("UIListLayout")({
							Name = "UIListLayout",
							Padding = UDim.new(0.025, 0),
							FillDirection = Enum.FillDirection.Horizontal,
							HorizontalAlignment = Enum.HorizontalAlignment.Center,
							SortOrder = Enum.SortOrder.LayoutOrder,
						}),

						New("UIPadding")({
							Name = "UIPadding",
							PaddingTop = UDim.new(0.2, 0),
						}),

						New("TextLabel")({
							Name = "Price",
							FontFace = Font.new("rbxasset://fonts/families/LuckiestGuy.json"),
							Text = Computed(function()
								return Pricing:get() or "..."
							end),
							TextColor3 = Color3.fromRGB(255, 255, 255),
							TextScaled = true,
							TextSize = 50,
							TextWrapped = true,
							BackgroundColor3 = Color3.fromRGB(255, 255, 255),
							BackgroundTransparency = 1,
							BorderColor3 = Color3.fromRGB(0, 0, 0),
							BorderSizePixel = 0,
							Position = UDim2.fromScale(0.408, 1.44e-06),
							Size = UDim2.fromScale(0.605, 0.819),

							[Children] = {
								New("UIStroke")({
									Name = "UIStroke",
									LineJoinMode = Enum.LineJoinMode.Miter,
									Thickness = 3,
								}),
							},
						}),
					},
				}),
				New("TextLabel")({
					Name = "Deal",
					FontFace = Font.new("rbxasset://fonts/families/LuckiestGuy.json"),
					RichText = true,
					Text = '<stroke color="#202020" joins="miter" thickness="3" transparency="0"><font color="#9fff8a"></font> NINETAILS!</stroke>',
					TextColor3 = Color3.fromRGB(255, 255, 255),
					TextScaled = true,
					TextSize = 50,
					TextWrapped = true,
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 1,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Position = UDim2.fromScale(0.785, 0.794),
					Rotation = -29,
					Size = UDim2.fromScale(0.605, 0.293),
					ZIndex = 4,

					[Children] = {
						New("UIStroke")({
							Name = "UIStroke",
							LineJoinMode = Enum.LineJoinMode.Miter,
							Thickness = 3,
						}),
					},
				}),

				New("ImageLabel")({
					Name = "ImageLabel",
					Image = "rbxassetid://17560951920",
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 1,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Position = UDim2.fromScale(0.0965, 0.0654),
					Size = UDim2.fromScale(0.405, 0.923),
					ZIndex = 3,
				}),

				New("TextLabel")({
					Name = "Info",
					FontFace = Font.new("rbxasset://fonts/families/LuckiestGuy.json"),
					-- RichText = true,
					Text = "LIMITED",
					TextColor3 = Color3.fromRGB(255, 74, 55),
					TextScaled = true,
					TextSize = 50,
					TextWrapped = true,
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 1,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Position = UDim2.fromScale(0.3, 0.179),
					Rotation = 11,
					Size = UDim2.fromScale(0.473, 0.224),
					ZIndex = 4,

					[Children] = {
						New("UIStroke")({
							Name = "UIStroke",
							LineJoinMode = Enum.LineJoinMode.Miter,
							Thickness = 3,
						}),
					},
				}),
			},
		})
	end,
	LongSecond = function(props: {
		ID: number,
		Index: number,
		Section: string,
		CallBack: () -> nil,
	})
		local Pricing = Value("Loading...")

		task.spawn(function()
			local ProductInfo =
				MarketplaceService:GetProductInfo(props.ID, Enum.InfoType[props.Section]) :: Enum.InfoType

			if ProductInfo then
				Pricing:set(ProductInfo["PriceInRobux"])
			end
		end)
		return New("ImageLabel")({
			Name = "04",
			Image = "rbxassetid://17343262015",
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			LayoutOrder = props.Index,
			Size = UDim2.fromScale(0.378, 1),

			[Children] = {
				ImageButton({
					Active = Active,
					GrowthSize = GrowthSize,
					AnimationSpeed = AnimationSpeed,
					Name = "PurchaseButton",
					Image = "rbxassetid://17343261569",
					AnchorPoint = Vector2.new(0, 1),
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 1,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Position = UDim2.fromScale(0.04, 0.925),
					Size = UDim2.fromScale(0.412, 0.345),
					ZIndex = 3,
					OnClick = props.CallBack,

					Children = {
						New("ImageLabel")({
							Name = "RobuxIcon",
							Image = "rbxassetid://17343261881",
							BackgroundColor3 = Color3.fromRGB(255, 255, 255),
							BackgroundTransparency = 1,
							BorderColor3 = Color3.fromRGB(0, 0, 0),
							BorderSizePixel = 0,
							Position = UDim2.fromScale(0.158, 1.44e-06),
							Size = UDim2.fromScale(0.219, 0.603),
							ZIndex = 4,

							[Children] = {
								New("UIAspectRatioConstraint")({
									Name = "UIAspectRatioConstraint",
								}),
							},
						}),

						New("UIListLayout")({
							Name = "UIListLayout",
							Padding = UDim.new(0.025, 0),
							FillDirection = Enum.FillDirection.Horizontal,
							HorizontalAlignment = Enum.HorizontalAlignment.Center,
							SortOrder = Enum.SortOrder.LayoutOrder,
						}),

						New("UIPadding")({
							Name = "UIPadding",
							PaddingTop = UDim.new(0.2, 0),
						}),

						New("TextLabel")({
							Name = "Price",
							FontFace = Font.new("rbxasset://fonts/families/LuckiestGuy.json"),
							Text = Computed(function()
								return Pricing:get() or "..."
							end),
							TextColor3 = Color3.fromRGB(255, 255, 255),
							TextScaled = true,
							TextSize = 50,
							TextWrapped = true,
							BackgroundColor3 = Color3.fromRGB(255, 255, 255),
							BackgroundTransparency = 1,
							BorderColor3 = Color3.fromRGB(0, 0, 0),
							BorderSizePixel = 0,
							Position = UDim2.fromScale(0.408, 1.44e-06),
							Size = UDim2.fromScale(0.605, 0.819),

							[Children] = {
								New("UIStroke")({
									Name = "UIStroke",
									LineJoinMode = Enum.LineJoinMode.Bevel,
									Thickness = 3,
								}),
							},
						}),
					},
				}),

				New("TextLabel")({
					Name = "Deal",
					FontFace = Font.new("rbxasset://fonts/families/LuckiestGuy.json"),
					Text = "SALE!!!",
					TextColor3 = Color3.fromRGB(255, 74, 55),
					TextScaled = true,
					TextSize = 50,
					TextWrapped = true,
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 1,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Position = UDim2.fromScale(0.849, 0.973),
					Rotation = -25,
					Size = UDim2.fromScale(0.605, 0.293),
					ZIndex = 4,

					[Children] = {
						New("UIStroke")({
							Name = "UIStroke",
							LineJoinMode = Enum.LineJoinMode.Bevel,
							Thickness = 3,
						}),
					},
				}),

				New("TextLabel")({
					Name = "Name",
					FontFace = Font.new("rbxasset://fonts/families/LuckiestGuy.json"),
					Text = "DRAGON",
					TextColor3 = Color3.fromRGB(255, 255, 255),
					TextScaled = true,
					TextSize = 50,
					TextWrapped = true,
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 1,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Position = UDim2.fromScale(0.225, 0.3),
					Rotation = 345,
					Size = UDim2.fromScale(0.605, 0.293),
					ZIndex = 4,

					[Children] = {
						New("UIStroke")({
							Name = "UIStroke",
							LineJoinMode = Enum.LineJoinMode.Bevel,
							Thickness = 3,
						}),
					},
				}),

				New("ImageLabel")({
					Name = "ImageLabel",
					Image = "rbxassetid://17369824160",
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 1,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Position = UDim2.fromScale(0.465, -0.161),
					Size = UDim2.fromScale(0.534, 1.16),
					ZIndex = 3,
				}),
			},
		})
	end,
}
