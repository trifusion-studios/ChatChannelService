--[[
    Adds channels to the roblox chat.
]]

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local TextChatService = game:GetService("TextChatService")
local UserInputService = game:GetService("UserInputService")

local Loaded = script:WaitForChild("Loaded") :: BoolValue
local Assets = script:WaitForChild("Assets")
local UI = Assets:WaitForChild("UI")
local Utils = Assets:WaitForChild("Utils")


local InputBar = require(script.Assets.UI.Chat.InputBar)
local Layout = require(script.Assets.UI.Chat.Layout)
local List = require(script.Assets.UI.Chat.List)
local ChatMessage = require(script.Assets.UI.Messages.ChatMessage)
local Icon = require(UI:WaitForChild("Icon"))
local SafePcall = require(Utils:WaitForChild("SafePcall"))
local History = require(Utils:WaitForChild("History"))


local ChatChannelService = {
    Debug = true,
    ChannelTag = "ChatChannelService_Channel",
    Channels = {},
    DefaultRobloxChannels = {} :: {[string]: TextChannel}
}


local function DebugPrint(...: any)
    if ChatChannelService.Debug == true then
        print("[ChatChannelService]", ..., `\n{debug.traceback()}`)
    end
end

local function SetupRobloxChannel(channel: TextChannel)
    ChatChannelService.DefaultRobloxChannels[channel.Name:gsub("RBX", "")] = channel
end

function ChatChannelService:SetupUI()
    if RunService:IsServer() == true then
        -- Prevent server making icons
        DebugPrint("Tried to setup UI on server")
        return
    end

    -- try to disable the chat gui
    local disabledChat = SafePcall(15, 5, function()
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false)
    end)

    if disabledChat == false then
        error("[ChatChannelService] Failed to disable the default chat, channels are now disabled on this client.")
    end

    -- Recreates the original chat theme
    self.icon = Icon.new()
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
    self.list = List()
    self.input, self.textbox, self.send = InputBar()

    self.root.Parent = self.ui
    self.input.Parent = self.root
    self.list.Parent = self.root

    self.ui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

    local sending = false
    local function SendCurrentText()
        if sending == true then return else sending = false end

        -- Send message to current channel
        self.currentChannel:SendAsync(self.textbox.Text)

        -- Reset UI
        self.textbox.PlaceholderText = "To chat click here or press / key"
        self.textbox.TextTransparency = 0.5
        self.textbox.Text = ""
    end

    -- Connect events
    self.icon:bindEvent("selected", function()
        self.ui.Enabled = true
        self.icon:clearNotices()
    end)
    self.icon:bindEvent("deselected", function()
        self.ui.Enabled = false
    end)

    TextChatService.MessageReceived:Connect(function(textChatMessage: TextChatMessage)
        if self.icon:getToggleState() == "deselected" then
            self.icon:notify()
        end

        local message = ChatMessage(textChatMessage)
        message.Parent = self.list
    end)

    UserInputService.InputEnded:Connect(function(input: InputObject, gameProcessedEvent: boolean)
        if gameProcessedEvent or input.KeyCode ~= Enum.KeyCode.Slash then
            -- Prevent accidental activate when typing or wrong input
            return
        end
        
        self.icon:select()
        self.textbox:CaptureFocus()
    end)

    self.textbox.Focused:Connect(function()
        self.textbox.PlaceholderText = ""
        self.textbox.TextTransparency = 0
    end)
    
    self.textbox.FocusLost:Connect(function(enterPressed: boolean, input: InputObject)
        -- if enterPressed then
            
        -- end

    end)

    self.textbox.Changed:Connect(function(property)
        if property == "Text" then
            if self.textbox.Text:len() > 0 then
                self.send.SendIcon.ImageColor3 = Color3.new(1, 1, 1)
                self.send.SendIcon.ImageTransparency = 0
                self.send.TextTransparency = 0
            else
                self.send.SendIcon.ImageColor3 = Color3.fromRGB(178, 178, 178)
                self.send.SendIcon.ImageTransparency = 0.5
                self.send.TextTransparency = 0.5
            end
        end
    end)

    self.send.Activated:Connect(function()
        local textInput = self.textbox.Text

        self.textbox.Text = ""
        self.currentChannel:SendAsync(textInput)
    end)
end

function ChatChannelService:AddChannel(channel: TextChannel)
    DebugPrint(`Adding channel: {channel.Name}`)
    task.wait(1)
    DebugPrint("Channel has been successfully added")
end

function ChatChannelService:Setup(): ()
    -- Make client wait until server has been loaded
    if RunService:IsClient() then
        DebugPrint("Waiting for server to load channels...")
        while Loaded.Value == false do
            Loaded.Changed:Wait()
        end

        DebugPrint("Server has loaded channels, creating initial UI...")
        ChatChannelService:SetupUI()

        DebugPrint("UI has been created, setting up default roblox channels...")
        for _, object: TextChannel in TextChatService:WaitForChild("TextChannels"):GetChildren() do
            if object:IsA("TextChannel") == false then
                -- Prevent other instances from being setup
                return
            end

            -- Setup channel
            SetupRobloxChannel(object)
        end

        -- Select default channel as current
        self.currentChannel = ChatChannelService.DefaultRobloxChannels["General"]
    else
        DebugPrint("Setting up default roblox channels...")
        for _, object: TextChannel in TextChatService:WaitForChild("TextChannels"):GetChildren() do
            if object:IsA("TextChannel") == false then
                -- Prevent other instances from being setup
                return
            end

            -- Setup channel
            SetupRobloxChannel(object)
        end

        for _, object: TextChannel in CollectionService:GetTagged(ChatChannelService.ChannelTag) do
            if object:IsA("TextChannel") == false then
                -- Prevent other instances from being setup
                return
            end

            -- Setup channel
            ChatChannelService:AddChannel(object)
        end
        task.wait(5)
        DebugPrint("Channels ready for client")
        Loaded.Value = true
    end
end

return ChatChannelService