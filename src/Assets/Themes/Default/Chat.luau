return {
	Command = {
		CommandFrame = {
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 30),
			ZIndex = 2,
		},

		CommandLabel = {
			FontFace = Font.new(
				"rbxasset://fonts/families/GothamSSm.json",
				Enum.FontWeight.Medium,
				Enum.FontStyle.Normal
			),
			RichText = true,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextSize = 14,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundTransparency = 1,
			LayoutOrder = 3,
			ZIndex = 2,
		},

		Divider = {
			AnchorPoint = Vector2.new(0, 1),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 0.8,
			BorderSizePixel = 0,
			Position = UDim2.fromScale(0, 1),
			Size = UDim2.new(1, 0, 0, 1),
			ZIndex = 2,
		},

		Button = {
			BackgroundColor3 = Color3.fromRGB(163, 162, 165),
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 1, -1),
			ZIndex = 3,
		},

		Padding = {
			PaddingBottom = UDim.new(0, 8),
			PaddingLeft = UDim.new(0, 15),
			PaddingRight = UDim.new(0, 30),
			PaddingTop = UDim.new(0, 8),
		},

		Layout = {
			FillDirection = Enum.FillDirection.Horizontal,
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Center,
		},
	},

	Layout = {
		Frame = {
			BackgroundColor3 = Color3.fromRGB(0, 0, 0),
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(8, 4),
			Size = UDim2.fromScale(0.4, 0.25),
		},

		FrameConstraint = {
			MaxSize = Vector2.new(475, 200),
		},

		FrameLayout = {
			SortOrder = Enum.SortOrder.LayoutOrder,
		},

		TopBorderImage = {
			Image = "rbxasset://textures/ui/TopRoundedRect8px.png",
			ImageColor3 = Color3.fromRGB(25, 27, 29),
			ImageTransparency = 0.3,
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(8, 8, 24, 32),
			BackgroundTransparency = 1,
			LayoutOrder = 1,
			Size = UDim2.new(1, 0, 0, 8),
		},

		BorderConstraint = {
			MaxSize = Vector2.new(475, math.huge),
		},

		BottomBorderImage = {
			Image = "rbxasset://textures/ui/BottomRoundedRect8px.png",
			ImageColor3 = Color3.fromRGB(25, 27, 29),
			ImageTransparency = 0.3,
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(8, 0, 24, 16),
			BackgroundTransparency = 1,
			LayoutOrder = 4,
		},

		BottomBorderConstraint = {
			MaxSize = Vector2.new(475, math.huge),
		},
	},

	InputBar = {
		Bar = {
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundColor3 = Color3.fromRGB(25, 27, 29),
			BackgroundTransparency = 0.3,
			BorderSizePixel = 0,
			LayoutOrder = 3,
			Size = UDim2.fromScale(1, 0),
		},

		Background = {
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundColor3 = Color3.fromRGB(25, 27, 29),
			BackgroundTransparency = 0.2,
			Size = UDim2.fromScale(1, 0),
		},

		BackgroundCorner = {
			CornerRadius = UDim.new(0, 3),
		},

		BackgroundBorder = {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Color = Color3.fromRGB(255, 255, 255),
			Transparency = 0.8,
		},

		Container = {
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
		},

		TextContainer = {
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, -30, 0, 0),
		},

		TextContainerPadding = {
			PaddingBottom = UDim.new(0, 10),
			PaddingLeft = UDim.new(0, 10),
			PaddingRight = UDim.new(0, 10),
			PaddingTop = UDim.new(0, 10),
		},

		TextBoxContainer = {
			AnchorPoint = Vector2.new(1, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(1, 0),
			Size = UDim2.new(1, -8, 0, 0),
		},

		TextBox = {
			ClearTextOnFocus = false,
			FontFace = Font.new(
				"rbxasset://fonts/families/BuilderSans.json",
				Enum.FontWeight.Medium,
				Enum.FontStyle.Normal
			),
			PlaceholderColor3 = Color3.fromRGB(178, 178, 178),
			PlaceholderText = "To chat click here or press / key",
			Text = "",
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextSize = 14,
			TextStrokeTransparency = 0.5,
			TextTransparency = 0.5,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 0),
		},

		TargetChannelChip = {
			FontFace = Font.new(
				"rbxasset://fonts/families/GothamSSm.json",
				Enum.FontWeight.Medium,
				Enum.FontStyle.Normal
			),
			Text = "",
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextSize = 14,
			TextWrapped = true,
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(0, 1),
			Visible = false,
		},

		SendButton = {
			Text = "",
			AnchorPoint = Vector2.new(1, 0),
			BackgroundTransparency = 1,
			LayoutOrder = 2,
			Position = UDim2.fromScale(1, 0),
			Size = UDim2.new(0, 30, 1, 0),
		},

		SendIcon = {
			Image = "rbxasset://LuaPackages/Packages/_Index/UIBlox/UIBlox/AppImageAtlas/img_set_1x_5.png",
			ImageColor3 = Color3.fromRGB(178, 178, 178),
			ImageRectOffset = Vector2.new(233, 454),
			ImageRectSize = Vector2.new(36, 36),
			ImageTransparency = 0.5,
			BackgroundTransparency = 1,
			Size = UDim2.fromOffset(30, 30),
		},

		SendButtonLayout = {
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
		},

		AutocompleteDropdown = {
			AnchorPoint = Vector2.new(0, 1),
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(0.95, 0),
			Visible = true,
			ZIndex = 2,
		},

		DropdownConstraint = {
			MaxSize = Vector2.new(475, 120),
		},

		ScrollbarFrame = {
			BackgroundColor3 = Color3.fromRGB(25, 27, 29),
			Size = UDim2.fromScale(1, 1),
		},

		ScrollbarCorner = {
			CornerRadius = UDim.new(0, 3),
		},

		ScrollbarBorder = {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Color = Color3.fromRGB(255, 255, 255),
			Transparency = 0.8,
		},

		ScrollviewFrame = {
			BackgroundTransparency = 1,
			ClipsDescendants = true,
			Size = UDim2.fromScale(1, 1),
			ZIndex = 2,
		},

		Scrollview = {
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			CanvasSize = UDim2.new(),
			ScrollBarThickness = 4,
			VerticalScrollBarInset = Enum.ScrollBarInset.Always,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ClipsDescendants = false,
			Size = UDim2.new(1, -4, 1, 0),
			ZIndex = 2,
		},

		Offset = {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 8, 1, 0),
		},

		OffsetLayout = {
			SortOrder = Enum.SortOrder.LayoutOrder,
		},

		Constraint = {
			MaxSize = Vector2.new(475, math.huge),
		},

		Padding = {
			PaddingBottom = UDim.new(0, 1),
			PaddingLeft = UDim.new(0, 8),
			PaddingRight = UDim.new(0, 8),
			PaddingTop = UDim.new(0, 8),
		},
	},

	List = {
		Window = {
			BackgroundColor3 = Color3.fromRGB(25, 27, 29),
			BackgroundTransparency = 0.3,
			BorderSizePixel = 0,
			LayoutOrder = 2,
		},

		WindowConstraint = {
			MaxSize = Vector2.new(475, 275),
		},

		ScrollViewer = {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
		},

		BottomScrollViewer = {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
		},

		BottomScrollPadding = {
			PaddingLeft = UDim.new(0, 8),
			PaddingRight = UDim.new(0, 8),
		},

		RCTScrollView = {
			AutomaticCanvasSize = Enum.AutomaticSize.XY,
			CanvasSize = UDim2.new(),
			ScrollBarImageTransparency = 1,
			ScrollBarThickness = 8,
			ScrollingDirection = Enum.ScrollingDirection.Y,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.fromScale(1, 1),
		},

		RCTScrollContentView = {
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
		},

		ScrollContentLayout = {
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
		},

		Layout = {
			Padding = UDim.new(0, 4),
			SortOrder = Enum.SortOrder.LayoutOrder,
		},
	},
}
