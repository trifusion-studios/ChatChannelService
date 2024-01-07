return function()
	local Window = Instance.new("Frame")
	Window.Name = "chatWindow"
	Window.BackgroundColor3 = Color3.fromRGB(25, 27, 29)
	Window.BackgroundTransparency = 0.3
	Window.BorderSizePixel = 0
	Window.LayoutOrder = 2
	Window.Size = UDim2.fromScale(1, 1)
	
	local SizeConstraint = Instance.new("UISizeConstraint")
	SizeConstraint.Name = "uiSizeConstraint"
	SizeConstraint.MaxSize = Vector2.new(475, 275)
	SizeConstraint.Parent = Window
	
	local View = Instance.new("ImageButton")
	View.Name = "scrollingView"
	View.BackgroundTransparency = 1
	View.Size = UDim2.fromScale(1, 1)
	
	local LockedScrollView = Instance.new("Frame")
	LockedScrollView.Name = "bottomLockedScrollView"
	LockedScrollView.BackgroundTransparency = 1
	LockedScrollView.Size = UDim2.fromScale(1, 1)
	
	local RCTScrollView = Instance.new("ScrollingFrame")
	RCTScrollView.Name = "RCTScrollView"
	RCTScrollView.AutomaticCanvasSize = Enum.AutomaticSize.XY
	RCTScrollView.CanvasSize = UDim2.new()
	RCTScrollView.ScrollBarImageTransparency = 1
	RCTScrollView.ScrollBarThickness = 8
	RCTScrollView.ScrollingDirection = Enum.ScrollingDirection.Y
	RCTScrollView.BackgroundTransparency = 1
	RCTScrollView.BorderSizePixel = 0
	RCTScrollView.Size = UDim2.fromScale(1, 1)
	
	local RCTScrollContentView = Instance.new("Frame")
	RCTScrollContentView.Name = "RCTScrollContentView"
	RCTScrollContentView.AutomaticSize = Enum.AutomaticSize.Y
	RCTScrollContentView.BackgroundTransparency = 1
	RCTScrollContentView.Size = UDim2.fromScale(1, 1)
	
	local VerticalLayout = Instance.new("UIListLayout")
	VerticalLayout.Name = "VerticalLayout"
	VerticalLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	VerticalLayout.SortOrder = Enum.SortOrder.LayoutOrder
	VerticalLayout.Parent = RCTScrollContentView
	
	local Layout = Instance.new("UIListLayout")
	Layout.Name = "$layout"
	Layout.Padding = UDim.new(0, 4)
	Layout.SortOrder = Enum.SortOrder.LayoutOrder
	Layout.Parent = RCTScrollContentView
	
	RCTScrollContentView.Parent = RCTScrollView
	
	RCTScrollView.Parent = LockedScrollView
	
	local Padding = Instance.new("UIPadding")
	Padding.Name = "padding"
	Padding.PaddingLeft = UDim.new(0, 8)
	Padding.PaddingRight = UDim.new(0, 8)
	Padding.Parent = LockedScrollView
	
	LockedScrollView.Parent = View
	
	View.Parent = Window

    return Window
end
