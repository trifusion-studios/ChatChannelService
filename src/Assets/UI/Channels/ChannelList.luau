export type ChannelList = Frame

return function()
	local ChannelsFrame = Instance.new("Frame")
	ChannelsFrame.Name = "ChannelsFrame"
	ChannelsFrame.Active = true
	ChannelsFrame.BackgroundColor3 = Color3.fromRGB(25, 27, 29)
	ChannelsFrame.BackgroundTransparency = 1
	ChannelsFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
	ChannelsFrame.BorderSizePixel = 0
	ChannelsFrame.ClipsDescendants = false
	ChannelsFrame.Position = UDim2.fromOffset(10, 225)
	ChannelsFrame.Selectable = true
	ChannelsFrame.Size = UDim2.new(00, 450, 0, 30)
	ChannelsFrame.ZIndex = 2
	ChannelsFrame.SelectionGroup = true
	ChannelsFrame.LayoutOrder = 5

	local Padding = Instance.new("UIPadding")
	Padding.PaddingTop = UDim.new(0, 5)
	Padding.Parent = ChannelsFrame

	local Frame = Instance.new("ScrollingFrame")
	Frame.Name = "Frame"
	Frame.AutomaticCanvasSize = Enum.AutomaticSize.X
	Frame.CanvasSize = UDim2.new()
	Frame.HorizontalScrollBarInset = Enum.ScrollBarInset.ScrollBar
	Frame.ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0)
	Frame.ScrollBarImageTransparency = 1
	Frame.ScrollBarThickness = 0
	Frame.ScrollingDirection = Enum.ScrollingDirection.X
	Frame.Active = true
	Frame.BackgroundColor3 = Color3.fromRGB(25, 27, 29)
	Frame.BackgroundTransparency = 1
	Frame.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Frame.BorderSizePixel = 0
	Frame.ClipsDescendants = false
	Frame.Position = UDim2.fromOffset(8, 2)
	Frame.Size = UDim2.new(1, -8, 1, 0)
	Frame.ZIndex = 2

	local UIListLayout = Instance.new("UIListLayout")
	UIListLayout.Name = "UIListLayout"
	UIListLayout.Padding = UDim.new(0, 5)
	UIListLayout.FillDirection = Enum.FillDirection.Horizontal
	UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	UIListLayout.Parent = Frame

	Frame.Parent = ChannelsFrame

	return ChannelsFrame, Frame
end
