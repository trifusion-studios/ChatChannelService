return function(command: string, layoutOrder: number, clickCallback: () -> ()): (Frame, TextButton)
	local CommandFrame = Instance.new("Frame")
	CommandFrame.Name = command
	CommandFrame.AutomaticSize = Enum.AutomaticSize.Y
	CommandFrame.BackgroundTransparency = 1
	CommandFrame.LayoutOrder = layoutOrder
	CommandFrame.Size = UDim2.new(1, 0, 0, 30)
	CommandFrame.ZIndex = 2

	local Divider = Instance.new("Frame")
	Divider.Name = "Divider"
	Divider.AnchorPoint = Vector2.new(0, 1)
	Divider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Divider.BackgroundTransparency = 0.8
	Divider.BorderSizePixel = 0
	Divider.Position = UDim2.fromScale(0, 1)
	Divider.Size = UDim2.new(1, 0, 0, 1)
	Divider.ZIndex = 2
	Divider.Parent = CommandFrame

	local TextLabelButton = Instance.new("TextButton")
	TextLabelButton.Name = "TextLabelButton"
	TextLabelButton.Text = ""
	TextLabelButton.BackgroundColor3 = Color3.fromRGB(163, 162, 165)
	TextLabelButton.BackgroundTransparency = 1
	TextLabelButton.Size = UDim2.new(1, 0, 1, -1)
	TextLabelButton.ZIndex = 3

	TextLabelButton.Activated:Connect(clickCallback)

	local UIPadding = Instance.new("UIPadding")
	UIPadding.Name = "UIPadding"
	UIPadding.PaddingBottom = UDim.new(0, 8)
	UIPadding.PaddingLeft = UDim.new(0, 15)
	UIPadding.PaddingRight = UDim.new(0, 30)
	UIPadding.PaddingTop = UDim.new(0, 8)
	UIPadding.Parent = TextLabelButton

	local UIListLayout = Instance.new("UIListLayout")
	UIListLayout.Name = "UIListLayout"
	UIListLayout.FillDirection = Enum.FillDirection.Horizontal
	UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	UIListLayout.Parent = TextLabelButton

	local TextLabel = Instance.new("TextLabel")
	TextLabel.Name = "TextLabel"
	TextLabel.FontFace =
		Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
	TextLabel.RichText = true
	TextLabel.Text = command
	TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	TextLabel.TextSize = 14
	TextLabel.TextWrapped = true
	TextLabel.TextXAlignment = Enum.TextXAlignment.Left
	TextLabel.TextYAlignment = Enum.TextYAlignment.Top
	TextLabel.AutomaticSize = Enum.AutomaticSize.XY
	TextLabel.BackgroundTransparency = 1
	TextLabel.LayoutOrder = 3
	TextLabel.ZIndex = 2
	TextLabel.Parent = TextLabelButton

	TextLabelButton.Parent = CommandFrame

	return CommandFrame, TextLabelButton
end
