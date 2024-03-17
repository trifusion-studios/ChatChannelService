local TweenService = game:GetService("TweenService")

export type Channel = {
	name: string,
	selected: boolean,
	unread: boolean,
	unreadTween: Tween?,
	instance: TextButton,
	color: Color3?,
	channel: TextChannel,

	OnSelected: (selected: boolean) -> (),
	OnMessage: () -> (),
	Destroy: () -> nil,

	OnActivated: (callback: (inputObject: InputObject, clickCount: number) -> ()) -> RBXScriptConnection,
}

return function(name: string, color: Color3?, originalTextChannel: TextChannel)
	local self = {
		name = name,
		selected = false,
		unread = false,
		unreadTween = nil,
		instance = nil,
		color = color or nil,
		channel = originalTextChannel,
	} :: Channel

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
	self.instance = Channel

	function self.OnSelected(selected: boolean)
		self.selected = selected

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

	function self.OnActivated(callback: (inputObject: InputObject, clickCount: number) -> ()): RBXScriptConnection
		return self.instance.Activated:Connect(callback)
	end

	function self.Destroy(): nil
		self._instanceChangedConnection:Disconnect()

		self.instance:Destroy()

		self = nil

		return self
	end

	self._instanceChangedConnection = TextLabel.Changed:Connect(function(property: string)
		if property == "TextBounds" then
			self.instance.Size = UDim2.new(0, (TextLabel.TextBounds.X + 10), 1, 0)
		end
	end)

	originalTextChannel.OnIncomingMessage = function(message: TextChatMessage)
		if not self then
			-- Prevent when destroyed still changing colors
			return nil
		end

		if self.color then
			local newProperties = Instance.new("TextChatMessageProperties")

			newProperties.PrefixText = `<font color='#{self.color:ToHex():lower()}'>{message.PrefixText}</font>`

			return newProperties
		else
			return nil
		end
	end

	return self
end
