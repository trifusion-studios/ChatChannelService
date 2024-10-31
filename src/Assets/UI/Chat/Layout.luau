return function()
	local Layout = Instance.new("Frame")
	Layout.Name = "appLayout"
	Layout.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	Layout.BackgroundTransparency = 1
	Layout.Position = UDim2.fromOffset(8, 4)
	Layout.Size = UDim2.fromScale(0.4, 0.25)

	local Border = Instance.new("ImageLabel")
	Border.Name = "topBorder"
	Border.Image = "rbxasset://textures/ui/TopRoundedRect8px.png"
	Border.ImageColor3 = Color3.fromRGB(25, 27, 29)
	Border.ImageTransparency = 0.3
	Border.ScaleType = Enum.ScaleType.Slice
	Border.SliceCenter = Rect.new(8, 8, 24, 32)
	Border.BackgroundTransparency = 1
	Border.LayoutOrder = 1
	Border.Size = UDim2.new(1, 0, 0, 8)

	local SizeConstraint = Instance.new("UISizeConstraint")
	SizeConstraint.Name = "uiSizeConstraint"
	SizeConstraint.MaxSize = Vector2.new(475, math.huge)
	SizeConstraint.Parent = Border

	Border.Parent = Layout

	local Layout1 = Instance.new("UIListLayout")
	Layout1.Name = "layout"
	Layout1.SortOrder = Enum.SortOrder.LayoutOrder
	Layout1.Parent = Layout

	local SizeConstraint1 = Instance.new("UISizeConstraint")
	SizeConstraint1.Name = "uiSizeConstraint"
	SizeConstraint1.MaxSize = Vector2.new(475, 200)
	SizeConstraint1.Parent = Layout

	local Border1 = Instance.new("ImageLabel")
	Border1.Name = "bottomBorder"
	Border1.Image = "rbxasset://textures/ui/BottomRoundedRect8px.png"
	Border1.ImageColor3 = Color3.fromRGB(25, 27, 29)
	Border1.ImageTransparency = 0.3
	Border1.ScaleType = Enum.ScaleType.Slice
	Border1.SliceCenter = Rect.new(8, 0, 24, 16)
	Border1.BackgroundTransparency = 1
	Border1.LayoutOrder = 4
	Border1.Size = UDim2.new(1, 0, 0, 8)

	local SizeConstraint2 = Instance.new("UISizeConstraint")
	SizeConstraint2.Name = "uiSizeConstraint"
	SizeConstraint2.MaxSize = Vector2.new(475, math.huge)
	SizeConstraint2.Parent = Border1

	Border1.Parent = Layout

	return Layout
end
