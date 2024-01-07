local TweenService = game:GetService("TweenService")

export type Channel = {
    selected: boolean,
    unread: boolean,
    unreadTween: Tween?,
    instance: TextButton,
    color: Color3?,
    channel: TextChannel,

    OnSelected: (selected: boolean) -> (),
    OnMessage: () -> (),
    OnActivated: (callback: (inputObject: InputObject, clickCount: number) -> ()) -> RBXScriptConnection
}

return function(name: string, color: Color3?, originalTextChannel: TextChannel)
    local self = {
        selected = false,
        unread = false,
        unreadTween = nil,
        instance = nil,
        color = color or nil,
        channel = originalTextChannel
    } :: Channel

	local Channel = Instance.new("TextButton")
	Channel.Name = name
	Channel.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json")
	Channel.Text = name
	Channel.TextColor3 = Color3.fromRGB(255, 255, 255)
	Channel.TextSize = 14
	Channel.TextStrokeColor3 = Color3.fromRGB(255, 255, 255)
	Channel.BackgroundColor3 = Color3.fromRGB(43, 47, 50)
	Channel.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Channel.BorderSizePixel = 0
	Channel.Size = UDim2.new(0, 200, 0.9, 0)
	Channel.ZIndex = 2

	local Corner = Instance.new("UICorner")
	Corner.Name = "Corner"
	Corner.CornerRadius = UDim.new(0, 10)
	Corner.Parent = Channel

	local UIStroke = Instance.new("UIStroke")
	UIStroke.Name = "UIStroke"
	UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	UIStroke.Color = Color3.fromRGB(255, 255, 255)
	UIStroke.Thickness = 2
	UIStroke.Transparency = 0.3
    UIStroke.Enabled = false
	UIStroke.Parent = Channel

    -- Set instance variable and activated event
    self.instance = Channel

    function self.OnSelected(selected: boolean)
        self.selected = selected

        if selected then
            UIStroke.Enabled = true

            -- Cancel tween as channel has been selected
            if self.unreadTween then
                self.unreadTween:Cancel()
            end
        else
            UIStroke.Enabled = false
        end
    end

    function self.OnMessage()
        if self.selected == false and type(self.unreadTween) == "nil" then
            -- Setup UIStroke
            UIStroke.Transparency = 0
            UIStroke.Enabled = true

            local tween = TweenService:Create(
                UIStroke, 
                TweenInfo.new(
                    1,
                    Enum.EasingStyle.Quad,
                    Enum.EasingDirection.InOut,
                    -1,
                    true,
                    0
                ), 
                {
                    ["Transparency"] = 1
                }
            )

            -- Revert transparency and clean up tween once finished
            tween.Completed:Once(function()
                UIStroke.Transparency = 0.3

                tween:Destroy()
                self.unreadTween = nil
            end)

            -- Save tween and play it
            self.unreadTween = tween

            tween:Play()
        end
    end

    function self.OnActivated(callback: (inputObject: InputObject, clickCount: number) -> ()): RBXScriptConnection
        return self.instance.Activated:Connect(callback)
    end

    self.instance.Changed:Connect(function(property: string)
        if property == "TextBounds" then
            self.instance.Size = UDim2.new(0, (self.instance.TextBounds.X + 10), 0.9, 0)
        end
    end)

    originalTextChannel.OnIncomingMessage = function(message: TextChatMessage)
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
