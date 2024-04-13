return {
	Channel = {
		Image = {
			Image = "rbxassetid://10791872163",
			ImageRectOffset = Vector2.new(922, 550),
			ImageRectSize = Vector2.new(78, 78),
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(39, 39, 39, 39),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(1, 1),

			Selected = {
				Image = "rbxassetid://10791872163",
				ImageRectOffset = Vector2.new(922, 550),
			},
		},

		Label = {
			FontFace = Font.new("rbxasset://fonts/families/BuilderSans.json"),
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextSize = 20,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),

			Selected = {
				TextColor3 = Color3.fromRGB(0, 0, 0),
			},
		},

		Padding = {
			PaddingBottom = UDim.new(0.2, 0),
			PaddingLeft = UDim.new(0.1, 0),
			PaddingRight = UDim.new(0.1, 0),
			PaddingTop = UDim.new(0.2, 0),
		},
	},

	ChannelList = {
		ChannelsFrame = {
			Active = true,
			BackgroundColor3 = Color3.fromRGB(25, 27, 29),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			ClipsDescendants = false,
			Position = UDim2.fromOffset(10, 225),
			Selectable = true,
			Size = UDim2.new(00, 450, 0, 30),
			ZIndex = 2,
			SelectionGroup = true,
			LayoutOrder = 5,
		},

		Padding = {
			PaddingTop = UDim.new(0, 5),
		},

		Scroller = {
			AutomaticCanvasSize = Enum.AutomaticSize.X,
			CanvasSize = UDim2.new(),
			HorizontalScrollBarInset = Enum.ScrollBarInset.ScrollBar,
			ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0),
			ScrollBarImageTransparency = 1,
			ScrollBarThickness = 0,
			ScrollingDirection = Enum.ScrollingDirection.X,
			Active = true,
			BackgroundColor3 = Color3.fromRGB(25, 27, 29),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			ClipsDescendants = false,
			Position = UDim2.fromOffset(8, 2),
			Size = UDim2.new(1, -8, 1, 0),
			ZIndex = 2,
		},

		Layout = {
			Padding = UDim.new(0, 5),
			FillDirection = Enum.FillDirection.Horizontal,
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Center,
		},
	},
}
