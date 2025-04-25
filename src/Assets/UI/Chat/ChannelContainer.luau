--!strict

return function(InputBarReference: ChatInputBarConfiguration)
	local ChannelContainer = Instance.new("Frame")
	ChannelContainer.Name = "appLayout"
	ChannelContainer.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	ChannelContainer.BackgroundTransparency = 1

	InputBarReference.Changed:Connect(function()
		if InputBarReference.AbsolutePosition ~= Vector2.zero and InputBarReference.AbsoluteSize ~= Vector2.zero then
			ChannelContainer.Position = UDim2.fromOffset(
				InputBarReference.AbsolutePosition.X,
				InputBarReference.AbsolutePosition.Y + InputBarReference.AbsoluteSize.Y + 5
			)
			ChannelContainer.Size = UDim2.fromOffset(InputBarReference.AbsoluteSize.X, 30)
		end
	end)

	ChannelContainer.Position = UDim2.fromOffset(
		InputBarReference.AbsolutePosition.X,
		InputBarReference.AbsolutePosition.Y + InputBarReference.AbsoluteSize.Y + 5
	)
	ChannelContainer.Size = UDim2.fromOffset(InputBarReference.AbsoluteSize.X, 30)

	return ChannelContainer
end
