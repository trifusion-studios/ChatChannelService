--[[
    Adds channels to the roblox chat.
]]

local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local TextChatService = game:GetService("TextChatService")
local UserInputService = game:GetService("UserInputService")

local Loaded = script:WaitForChild("Loaded") :: BoolValue
local Assets = script:WaitForChild("Assets")
local Utils = Assets:WaitForChild("Utils")
local UI = Assets:WaitForChild("UI")
local Channels = UI:WaitForChild("Channels")
local Chat = UI:WaitForChild("Chat")
local Messages = UI:WaitForChild("Messages")


local Channel = require(Channels:WaitForChild("Channel"))
local ChannelList = require(Channels:WaitForChild("ChannelList"))
local SafePcall = require(Utils:WaitForChild("SafePcall"))
local History = require(Utils:WaitForChild("History"))

local InputBar = require(Chat:WaitForChild("InputBar"))
local Layout = require(Chat:WaitForChild("Layout"))
local List = require(Chat:WaitForChild("List"))
local ChatMessage = require(Messages:WaitForChild("ChatMessage"))
local Icon = require(UI:WaitForChild("Icon"))


local ChatChannelService = {
    Debug = false,
    Channels = {} :: {[string]: Channel.Channel},
    ChannelHistory = History.new()
}

local BlockChatMessageStatus = {"Unknown", "Sending", "TextFilterFailed", "Floodchecked", "InvalidPrivacySettings", "InvalidTextChannelPermissions", "MessageTooLong"}

local function DebugPrint(...: any)
    if ChatChannelService.Debug == true then
        local finalString = "[ChatChannelService]"
        for _, object in {...} do
            finalString = `{finalString} {tostring(object)}`
        end
        finalString = `{finalString}\n{debug.traceback()}`
        print(finalString)
        finalString = nil
    end
end

local function CountArray(array: {[any]: any}): number
    local count = 0
    for _ in array do
        count += 1
    end
    return count
end

local function FindTextChannelInChannels(textChannel: TextChannel): (string?, Channel.Channel?)
    for name, channel in ChatChannelService.Channels do
        if channel.channel == textChannel then
            return name, channel
        end
    end

    return nil, nil
end

function ChatChannelService:SetupUI()
    if RunService:IsServer() == true then
        -- Prevent server making icons
        DebugPrint("Tried to setup UI on server")
        return false
    end

    -- Disable chat on console
    if GuiService:IsTenFootInterface() == true then
        return false
    end

    -- try to disable the chat gui
    local disabledChat = SafePcall(15, 5, function()
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false)
    end)

    if disabledChat == false then
        error("[ChatChannelService] Failed to disable the default chat, channels are now disabled on this client.")
    end

    -- Added a small wait to prevent settings from being changed too early
	-- TODO: Fix Icon overriding theme on already active icons
    task.wait(3)
    self.icon = Icon.new()
    self.icon:setEnabled(false)
    self.icon:set("iconImage", "rbxasset://textures/ui/TopBar/chatOff.png", "deselected")
    self.icon:set("iconImage", "rbxasset://textures/ui/TopBar/chatOn.png", "selected")
    self.icon:set("iconBackgroundColor", Color3.fromRGB(0, 0, 0), "selected")
    self.icon:set("iconBackgroundTransparency", 0.5, "selected")
    self.icon:set("iconImageColor", Color3.fromRGB(255,255,255), "selected")
    self.icon:set("iconTextColor", Color3.fromRGB(255,255,255), "selected")

    self.ui = Instance.new("ScreenGui")
    self.ui.Name = "ChatChannelService_UI"
    self.ui.Enabled = false

    self.root = Layout()
    self.window, self.list = List()
    self.input, self.textbox, self.send = InputBar()

    self.root.Parent = self.ui
    self.input.Parent = self.root
    self.window.Parent = self.root

    self.currentChannel = nil :: TextChannel?
    self.currentChannelChanged = Instance.new("BindableEvent")
    self.canSend = false

    self.channelList, self.channelScroll = ChannelList()
    self.channelList.Parent = self.root

    self.ui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

    local sending = false
    local function SendCurrentText()
        if sending == true or self.canSend == false then
            return
        else
            sending = false
        end

        -- Send message to current channel
        DebugPrint("Sending message!")

        -- Run send async in seperate thread as it can stop the current thread
        task.spawn(
            self.currentChannel.channel.SendAsync,
            self.currentChannel.channel,
            self.textbox.Text
        )

        -- Reset UI
        self.textbox.PlaceholderText = "To chat click here or press / key"
        self.textbox.TextTransparency = 0.5
        self.textbox.Text = ""
    end

    -- Connect events
    self.icon:bindEvent("selected", function()
        self.ui.Enabled = true
    end)
    self.icon:bindEvent("deselected", function()
        self.ui.Enabled = false
    end)

    TextChatService.MessageReceived:Connect(function(textChatMessage: TextChatMessage)
        if table.find(BlockChatMessageStatus, textChatMessage.Status.Name) then
            -- Block message there 
            return
        end

        if self.icon:getToggleState() == "deselected" then
            self.icon:notify()
        end

        DebugPrint(`Received message! Current status: {textChatMessage.Status}`)
        local _, channel = FindTextChannelInChannels(textChatMessage.TextChannel)
        if channel then
            channel.OnMessage()
            ChatChannelService.ChannelHistory:AddEntry(textChatMessage)
        end
    end)

    UserInputService.InputEnded:Connect(function(input: InputObject, gameProcessedEvent: boolean)
        if gameProcessedEvent or input.KeyCode ~= Enum.KeyCode.Slash or self.canSend == false then
            -- Prevent accidental activate when typing or wrong input
            return
        end
        
        self.icon:select()
        self.textbox:CaptureFocus()
    end)
    
    self.textbox.FocusLost:Connect(function(enterPressed: boolean)
        if enterPressed and #self.textbox.Text > 0 then
            -- Send the text to server
            SendCurrentText()
        end
    end)

    self.textbox.Changed:Connect(function(property)
        if property == "Text" then
            if self.textbox.Text:len() > 0 then
                self.send.SendIcon.ImageColor3 = Color3.new(1, 1, 1)
                self.send.SendIcon.ImageTransparency = 0
                self.textbox.TextTransparency = 0
            else
                self.send.SendIcon.ImageColor3 = Color3.fromRGB(178, 178, 178)
                self.send.SendIcon.ImageTransparency = 0.5
                self.textbox.TextTransparency = 0.5
            end
        end
    end)

    self.send.Activated:Connect(function()
        SendCurrentText()
    end)

    self.currentChannelChanged.Event:Connect(function(newChannel: Channel.Channel)
		local source = newChannel.channel:FindFirstChild(Players.LocalPlayer.Name) or {CanSend = false} :: TextSource | {CanSend: boolean}

        if source.CanSend == false then
            self.canSend = false
            self.textbox.TextEditable = false
            self.textbox.PlaceholderText = "You cannot send message in this channel"
            self.textbox.Text = ""
            self.textbox:ReleaseFocus()
        else
            self.canSend = true
            self.textbox.TextEditable = true
            self.textbox.PlaceholderText = "To chat click here or press / key"
            self.textbox.Text = ""
        end
	end)

    return true
end

function ChatChannelService:AddChannel(channel: TextChannel, customName: string?): Channel.Channel
    local name = customName or channel.Name

    DebugPrint(`Adding channel: {name}`)

    if ChatChannelService.Channels[name] then
        error(`[ChatChannelService] Duplicate channel name! Name: {name}`)
    end

    -- Setup channel
    local color = channel:GetAttribute("ChatColor")
    if typeof(color) ~= "Color3" and typeof(color) ~= "nil" then
        error(`[ChatChannelService] Inccorrect color type, expected Color3 or nil! Channel name: {name}`)
    end

    local newChannel = Channel(name, color, channel)
    ChatChannelService.Channels[name] = newChannel

    -- Ensure channel is in correct order
    newChannel.instance.LayoutOrder = CountArray(ChatChannelService.Channels)

    -- Parent channel to UI
    newChannel.instance.Parent = self.channelScroll

    -- Connect pressed event
    newChannel.OnActivated(function()
        ChatChannelService:SwitchChannel(newChannel)
    end)

    -- Add message if channel is active
    ChatChannelService.ChannelHistory:OnEntryAdded(function(message: TextChatMessage)
        if message.TextChannel == channel and self.currentChannel.channel == channel then
            local newMessage = ChatMessage(message)
            newMessage.LayoutOrder = message.Timestamp.UnixTimestamp
            newMessage.Parent = self.list
        end
    end)

    DebugPrint("Channel has been successfully added")
    
    return newChannel
end

function ChatChannelService:SwitchChannel(channel: Channel.Channel)
    local oldChannel = self.currentChannel :: Channel.Channel

    -- Prevent old channel from also being selected
    if oldChannel ~= nil and oldChannel.selected == true then
        oldChannel.OnSelected(false)
    end

    -- Set new channel as selected
    self.currentChannel = channel
    self.currentChannelChanged:Fire(channel)
    self.currentChannel.OnSelected(true)

    -- Destroy old channel list
    self.window:Destroy()

    -- Create new list
    self.window, self.list = List()
    self.window.Parent = self.root

    -- Get new channel history
    local entries = ChatChannelService.ChannelHistory:GetChannelHistory(channel.channel) or {}

    -- Add all messages to the list
    for _, message: TextChatMessage in entries do
        local newMessage = ChatMessage(message)
        newMessage.LayoutOrder = message.Timestamp.UnixTimestamp
        newMessage.Parent = self.list
    end
end

function ChatChannelService:Setup(): ()
    -- Make client wait until server has been loaded
    if RunService:IsClient() then
        DebugPrint("Waiting for server to load channels...")
        while Loaded.Value == false do
            Loaded.Changed:Wait()
        end

        DebugPrint("Server has loaded channels, creating initial UI...")
        local ui = ChatChannelService:SetupUI()
        if ui == false then
            DebugPrint("Failed to create custom UI, disabling ChatChannelService")
            return
        end

        DebugPrint("UI has been created, setting up default roblox channels...")
        
        -- Make general and system always first
        ChatChannelService:AddChannel(TextChatService:WaitForChild("TextChannels"):WaitForChild("RBXGeneral"), "General")
        ChatChannelService:AddChannel(TextChatService:WaitForChild("TextChannels"):WaitForChild("RBXSystem"), "System")

        -- TODO: Roblox whisper commands adds channels, instead of one loop add connection too like custom channels
        for _, object: TextChannel in TextChatService:WaitForChild("TextChannels"):GetChildren() do
            if object:IsA("TextChannel") == false or object.Name == "RBXGeneral" or object.Name == "RBXSystem" then
                -- Prevent other instances from being setup
                continue
            end

            -- Remove RBX part
            local newName = object.Name:gsub("RBX", "")

            -- check if player is in the channel
            local source = object:FindFirstChild(Players.LocalPlayer.Name) and object:WaitForChild(Players.LocalPlayer.Name)
            if source then
                ChatChannelService:AddChannel(object, newName)
            else
                -- Continue as player isn't allowed in this channel
                continue
            end
        end


        -- Select default channel as current
        ChatChannelService:SwitchChannel(ChatChannelService.Channels["General"])

        DebugPrint("Default Roblox channels have been set up, loading custom channels...")

        for _, object: TextChannel in TextChatService:WaitForChild("ChatChannels"):GetChildren() do
            if object:IsA("TextChannel") == false then
                -- Prevent other instances from being setup
                continue
            end

            -- check if player is in the channel
            local source = object:FindFirstChild(Players.LocalPlayer.Name) and object:WaitForChild(Players.LocalPlayer.Name)
            if source then
                ChatChannelService:AddChannel(object)
            else
                -- If player isn't in this channel, setup connection to wait for them to be added
                object.ChildAdded:Connect(function(newObject)
                    if newObject:IsA("TextSource") and newObject.UserId == Players.LocalPlayer.UserId then
                        ChatChannelService:AddChannel(object)
                    end
                end)

                continue
            end
        end

        -- Connect event when custom channels get added
        TextChatService:WaitForChild("ChatChannels").ChildAdded:Connect(function(object)
            if object:IsA("TextChannel") == false then
                -- Prevent other instances from being setup
                return
            end

            -- check if player is in the channel
            local source = object:FindFirstChild(Players.LocalPlayer.Name) and object:WaitForChild(Players.LocalPlayer.Name)
            if source then
                ChatChannelService:AddChannel(object)
            else
                -- If player isn't in this channel, setup connection to wait for them to be added
                object.ChildAdded:Connect(function(newObject)
                    if newObject:IsA("TextSource") and newObject.UserId == Players.LocalPlayer.UserId then
                        ChatChannelService:AddChannel(object)
                    end
                end)

                return
            end
        end)

        self.icon:setEnabled(true)
        DebugPrint("Fully loaded channels! Chat icon has been enabled")
    else
        DebugPrint("Setting up channels...")

        -- for _, object: TextChannel in CollectionService:GetTagged(ChatChannelService.ChannelTag) do
        --     if object:IsA("TextChannel") == false then
        --         -- Prevent other instances from being setup
        --         return
        --     end

        --     -- Setup channel
        --     ChatChannelService.Channels[object] = object
        -- end

        DebugPrint("Channels ready for client")
        Loaded.Value = true
    end
end

return ChatChannelService