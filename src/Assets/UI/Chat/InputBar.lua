return function(): (Frame, TextBox, TextButton, Frame, Frame)
	local InputBar = Instance.new("Frame")
	InputBar.Name = "chatInputBar"
	InputBar.AutomaticSize = Enum.AutomaticSize.Y
	InputBar.BackgroundColor3 = Color3.fromRGB(25, 27, 29)
	InputBar.BackgroundTransparency = 0.3
	InputBar.BorderSizePixel = 0
	InputBar.LayoutOrder = 3
	InputBar.Size = UDim2.fromScale(1, 0)

	local Background = Instance.new("Frame")
	Background.Name = "Background"
	Background.AutomaticSize = Enum.AutomaticSize.XY
	Background.BackgroundColor3 = Color3.fromRGB(25, 27, 29)
	Background.BackgroundTransparency = 0.2
	Background.Size = UDim2.fromScale(1, 0)

	local Corner = Instance.new("UICorner")
	Corner.Name = "Corner"
	Corner.CornerRadius = UDim.new(0, 3)
	Corner.Parent = Background

	local Border = Instance.new("UIStroke")
	Border.Name = "Border"
	Border.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	Border.Color = Color3.fromRGB(255, 255, 255)
	Border.Transparency = 0.8
	Border.Parent = Background

	local Container = Instance.new("Frame")
	Container.Name = "Container"
	Container.AutomaticSize = Enum.AutomaticSize.Y
	Container.BackgroundTransparency = 1
	Container.Size = UDim2.fromScale(1, 0)

	local TextContainer = Instance.new("Frame")
	TextContainer.Name = "TextContainer"
	TextContainer.AutomaticSize = Enum.AutomaticSize.Y
	TextContainer.BackgroundTransparency = 1
	TextContainer.Size = UDim2.new(1, -30, 0, 0)

	local UIPadding = Instance.new("UIPadding")
	UIPadding.Name = "UIPadding"
	UIPadding.PaddingBottom = UDim.new(0, 10)
	UIPadding.PaddingLeft = UDim.new(0, 10)
	UIPadding.PaddingRight = UDim.new(0, 10)
	UIPadding.PaddingTop = UDim.new(0, 10)
	UIPadding.Parent = TextContainer

	local TextBoxContainer = Instance.new("Frame")
	TextBoxContainer.Name = "TextBoxContainer"
	TextBoxContainer.AnchorPoint = Vector2.new(1, 0)
	TextBoxContainer.AutomaticSize = Enum.AutomaticSize.Y
	TextBoxContainer.BackgroundTransparency = 1
	TextBoxContainer.Position = UDim2.fromScale(1, 0)
	TextBoxContainer.Size = UDim2.new(1, -8, 0, 0)

	local TextBox = Instance.new("TextBox")
	TextBox.Name = "TextBox"
	TextBox.ClearTextOnFocus = false
	TextBox.FontFace =
		Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
	TextBox.PlaceholderColor3 = Color3.fromRGB(178, 178, 178)
	TextBox.PlaceholderText = "To chat click here or press / key"
	TextBox.Text = ""
	TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
	TextBox.TextSize = 14
	TextBox.TextStrokeTransparency = 0.5
	TextBox.TextTransparency = 0.5
	TextBox.TextWrapped = true
	TextBox.TextXAlignment = Enum.TextXAlignment.Left
	TextBox.TextYAlignment = Enum.TextYAlignment.Top
	TextBox.AutomaticSize = Enum.AutomaticSize.XY
	TextBox.BackgroundTransparency = 1
	TextBox.Size = UDim2.fromScale(1, 0)
	TextBox.Parent = TextBoxContainer

	TextBoxContainer.Parent = TextContainer

	local TargetChannelChip = Instance.new("TextButton")
	TargetChannelChip.Name = "TargetChannelChip"
	TargetChannelChip.FontFace =
		Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
	TargetChannelChip.Text = ""
	TargetChannelChip.TextColor3 = Color3.fromRGB(255, 255, 255)
	TargetChannelChip.TextSize = 14
	TargetChannelChip.TextWrapped = true
	TargetChannelChip.AutomaticSize = Enum.AutomaticSize.XY
	TargetChannelChip.BackgroundTransparency = 1
	TargetChannelChip.Size = UDim2.fromScale(0, 1)
	TargetChannelChip.Visible = false
	TargetChannelChip.Parent = TextContainer

	TextContainer.Parent = Container

	local SendButton = Instance.new("TextButton")
	SendButton.Name = "SendButton"
	SendButton.Text = ""
	SendButton.AnchorPoint = Vector2.new(1, 0)
	SendButton.BackgroundTransparency = 1
	SendButton.LayoutOrder = 2
	SendButton.Position = UDim2.fromScale(1, 0)
	SendButton.Size = UDim2.new(0, 30, 1, 0)

	local SendIcon = Instance.new("ImageLabel")
	SendIcon.Name = "SendIcon"
	SendIcon.Image = "rbxasset://LuaPackages/Packages/_Index/UIBlox/UIBlox/AppImageAtlas/img_set_1x_5.png"
	SendIcon.ImageColor3 = Color3.fromRGB(178, 178, 178)
	SendIcon.ImageRectOffset = Vector2.new(233, 454)
	SendIcon.ImageRectSize = Vector2.new(36, 36)
	SendIcon.ImageTransparency = 0.5
	SendIcon.BackgroundTransparency = 1
	SendIcon.Size = UDim2.fromOffset(30, 30)
	SendIcon.Parent = SendButton

	local Layout = Instance.new("UIListLayout")
	Layout.Name = "Layout"
	Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	Layout.VerticalAlignment = Enum.VerticalAlignment.Center
	Layout.Parent = SendButton

	SendButton.Parent = Container

	Container.Parent = Background

	Background.Parent = InputBar

	local AutocompleteDropdown = Instance.new("Frame")
	AutocompleteDropdown.Name = "AutocompleteDropdown"
	AutocompleteDropdown.AnchorPoint = Vector2.new(0, 1)
	AutocompleteDropdown.BackgroundTransparency = 1
	AutocompleteDropdown.Size = UDim2.fromScale(0.95, 0)
	AutocompleteDropdown.Visible = true
	AutocompleteDropdown.ZIndex = 2

	local UISizeConstraint = Instance.new("UISizeConstraint")
	UISizeConstraint.Name = "UISizeConstraint"
	UISizeConstraint.MaxSize = Vector2.new(475, 120)
	UISizeConstraint.Parent = AutocompleteDropdown

	local ScrollBarFrame = Instance.new("Frame")
	ScrollBarFrame.Name = "ScrollBarFrame"
	ScrollBarFrame.BackgroundColor3 = Color3.fromRGB(25, 27, 29)
	ScrollBarFrame.Size = UDim2.fromScale(1, 1)
	ScrollBarFrame.ZIndex = 2

	local Corner1 = Instance.new("UICorner")
	Corner1.Name = "Corner"
	Corner1.CornerRadius = UDim.new(0, 3)
	Corner1.Parent = ScrollBarFrame

	local Border1 = Instance.new("UIStroke")
	Border1.Name = "Border"
	Border1.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	Border1.Color = Color3.fromRGB(255, 255, 255)
	Border1.Transparency = 0.8
	Border1.Parent = ScrollBarFrame

	local ScrollViewFrame = Instance.new("Frame")
	ScrollViewFrame.Name = "ScrollViewFrame"
	ScrollViewFrame.BackgroundTransparency = 1
	ScrollViewFrame.ClipsDescendants = true
	ScrollViewFrame.Size = UDim2.fromScale(1, 1)
	ScrollViewFrame.ZIndex = 2

	local ScrollView = Instance.new("ScrollingFrame")
	ScrollView.Name = "ScrollView"
	ScrollView.AutomaticCanvasSize = Enum.AutomaticSize.Y
	ScrollView.CanvasSize = UDim2.new()
	ScrollView.ScrollBarThickness = 4
	ScrollView.VerticalScrollBarInset = Enum.ScrollBarInset.Always
	ScrollView.BackgroundTransparency = 1
	ScrollView.BorderSizePixel = 0
	ScrollView.ClipsDescendants = false
	ScrollView.Size = UDim2.new(1, -4, 1, 0)
	ScrollView.ZIndex = 2

	local OffsetFrame = Instance.new("Frame")
	OffsetFrame.Name = "OffsetFrame"
	OffsetFrame.BackgroundTransparency = 1
	OffsetFrame.Size = UDim2.new(1, 8, 1, 0)

	local Layout1 = Instance.new("UIListLayout")
	Layout1.Name = "$layout"
	Layout1.SortOrder = Enum.SortOrder.LayoutOrder
	Layout1.Parent = OffsetFrame

	OffsetFrame.Parent = ScrollView

	ScrollView.Parent = ScrollViewFrame

	ScrollViewFrame.Parent = ScrollBarFrame

	ScrollBarFrame.Parent = AutocompleteDropdown

	AutocompleteDropdown.Parent = InputBar

	local UISizeConstraint1 = Instance.new("UISizeConstraint")
	UISizeConstraint1.Name = "UISizeConstraint"
	UISizeConstraint1.MaxSize = Vector2.new(475, math.huge)
	UISizeConstraint1.Parent = InputBar

	local UIPadding1 = Instance.new("UIPadding")
	UIPadding1.Name = "UIPadding"
	UIPadding1.PaddingBottom = UDim.new(0, 1)
	UIPadding1.PaddingLeft = UDim.new(0, 8)
	UIPadding1.PaddingRight = UDim.new(0, 8)
	UIPadding1.PaddingTop = UDim.new(0, 8)
	UIPadding1.Parent = InputBar

	Layout1:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		ScrollView.CanvasSize = UDim2.new(0, 0, 0, Layout1.AbsoluteContentSize.Y)
		AutocompleteDropdown.Size = UDim2.new(0.95, 0, 0, Layout1.AbsoluteContentSize.Y)
	end)

	return InputBar, TextBox, SendButton, OffsetFrame, AutocompleteDropdown, ScrollView
end
