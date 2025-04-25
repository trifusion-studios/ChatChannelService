--!strict

local Types = require(script.Parent.Parent.Parent.Parent:WaitForChild("Utils"):WaitForChild("Types"))

return function(name: string, originalTextChannel: TextChannel): Types.Channel
	local self = {
		name = name,
		selected = false,
		unread = false,
		textChannel = originalTextChannel,
	} :: Types.Channel

	local Channel = Instance.new("ImageButton")
	Channel.Name = name
	Channel.Image = "rbxassetid://10791872163"
	Channel.ImageRectOffset = Vector2.new(922, 550)
	Channel.ImageRectSize = Vector2.new(78, 78)
	Channel.ScaleType = Enum.ScaleType.Slice
	Channel.SliceCenter = Rect.new(39, 39, 39, 39)
	Channel.AnchorPoint = Vector2.new(0.5, 0.5)
	Channel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Channel.BackgroundTransparency = 1
	Channel.Position = UDim2.fromScale(0.5, 0.5)
	Channel.Size = UDim2.fromScale(1, 1)

	local TextLabel = Instance.new("TextLabel")
	TextLabel.Name = "TextLabel"
	TextLabel.FontFace = Font.new("rbxasset://fonts/families/BuilderSans.json")
	TextLabel.Text = name
	TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	TextLabel.TextSize = 20
	TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	TextLabel.BackgroundTransparency = 1
	TextLabel.Size = UDim2.fromScale(1, 1)
	TextLabel.Parent = Channel

	local UIPadding = Instance.new("UIPadding")
	UIPadding.Name = "UIPadding"
	UIPadding.PaddingBottom = UDim.new(0.2, 0)
	UIPadding.PaddingLeft = UDim.new(0.1, 0)
	UIPadding.PaddingRight = UDim.new(0.1, 0)
	UIPadding.PaddingTop = UDim.new(0.2, 0)
	UIPadding.Parent = Channel

	-- Set instance variable and activated event
	self.uiInstance = Channel
	self.Activated = self.uiInstance.Activated

	self.TextLabelChanged = TextLabel.Changed:Connect(function(property: string)
		if self and self.uiInstance and property == "TextBounds" then
			self.uiInstance.Size = UDim2.new(0, (TextLabel.TextBounds.X + 10), 1, 0)
		end
	end)

	function self.SetSelected(selected: boolean)
		if self then
			self.selected = selected
		else
			return
		end

		if selected then
			Channel.Image = "rbxassetid://10791861382"
			Channel.ImageRectOffset = Vector2.new(904, 438)
			TextLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
		else
			Channel.Image = "rbxassetid://10791872163"
			Channel.ImageRectOffset = Vector2.new(922, 550)
			TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		end
	end

	function self.Destroy(): nil
		if not self then
			return nil
		end

		self.TextLabelChanged:Disconnect()

		self.uiInstance:Destroy()

		self = nil

		return self
	end

	return self :: Types.Channel
end
