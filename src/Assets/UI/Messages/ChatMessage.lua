return function(originalMessage: TextChatMessage): Frame
	local Message = Instance.new("Frame")
	Message.Name = originalMessage.MessageId
	Message.AutomaticSize = Enum.AutomaticSize.XY
	Message.BackgroundTransparency = 1
	Message.Size = UDim2.fromScale(1, 0)
	-- Message.LayoutOrder = originalMessage.Timestamp

	local TextLabel = Instance.new("Frame")
	TextLabel.Name = "TextLabel"
	TextLabel.AutomaticSize = Enum.AutomaticSize.XY
	TextLabel.BackgroundTransparency = 1
	TextLabel.LayoutOrder = 1

	local TextMessage = Instance.new("TextLabel")
	TextMessage.Name = "TextMessage"
	TextMessage.FontFace =
		Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
	TextMessage.RichText = true
	TextMessage.Text = `{originalMessage.PrefixText} {originalMessage.Text}`
	TextMessage.TextColor3 = Color3.fromRGB(255, 255, 255)
	TextMessage.TextSize = 14
	TextMessage.TextStrokeTransparency = 0.5
	TextMessage.TextWrapped = true
	TextMessage.TextXAlignment = Enum.TextXAlignment.Left
	TextMessage.TextYAlignment = Enum.TextYAlignment.Top
	TextMessage.AutomaticSize = Enum.AutomaticSize.XY
	TextMessage.BackgroundTransparency = 1
	TextMessage.Size = UDim2.fromScale(1, 0)

	local TextMessageButton = Instance.new("Frame")
	TextMessageButton.Name = "TextMessageButton"
	TextMessageButton.AutomaticSize = Enum.AutomaticSize.XY
	TextMessageButton.BackgroundTransparency = 1
	TextMessageButton.Size = UDim2.fromScale(1, 0)

	local TextButton = Instance.new("TextButton")
	TextButton.Name = "TextButton"
	TextButton.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
	TextButton.RichText = true
	TextButton.Text = originalMessage.PrefixText
	TextButton.TextSize = 14
	TextButton.TextTransparency = 1
	TextButton.TextWrapped = true
	TextButton.TextXAlignment = Enum.TextXAlignment.Left
	TextButton.TextYAlignment = Enum.TextYAlignment.Top
	TextButton.AutomaticSize = Enum.AutomaticSize.XY
	TextButton.BackgroundTransparency = 1
	TextButton.LayoutOrder = 1
	TextButton.Parent = TextMessageButton

	local Layout = Instance.new("UIListLayout")
	Layout.Name = "Layout"
	Layout.Padding = UDim.new(0, 4)
	Layout.FillDirection = Enum.FillDirection.Horizontal
	Layout.SortOrder = Enum.SortOrder.LayoutOrder
	Layout.Parent = TextMessageButton

	TextMessageButton.Parent = TextMessage

	TextMessage.Parent = TextLabel

	TextLabel.Parent = Message

	return Message
end
