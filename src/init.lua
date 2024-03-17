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
local Modules = script:WaitForChild("Modules")
local Utils = Assets:WaitForChild("Utils")
local UI = Assets:WaitForChild("UI")
local Overrides = Assets:WaitForChild("Overrides")
local Channels = UI:WaitForChild("Channels")
local Chat = UI:WaitForChild("Chat")
local Messages = UI:WaitForChild("Messages")

local Channel = require(Channels:WaitForChild("Channel"))
local ChannelList = require(Channels:WaitForChild("ChannelList"))
local SafePcall = require(Utils:WaitForChild("SafePcall"))
local History = require(Utils:WaitForChild("History"))
local Types = require(Utils:WaitForChild("Types"))
local AutoComplete = require(Utils:WaitForChild("AutoComplete"))
local ChannelOverrides = require(Overrides:WaitForChild("Channels"))
local CommandOverrides = require(Overrides:WaitForChild("Commands"))

local InputBar = require(Chat:WaitForChild("InputBar"))
local Layout = require(Chat:WaitForChild("Layout"))
local List = require(Chat:WaitForChild("List"))
local Command = require(Chat:WaitForChild("Command"))
local ChatMessage = require(Messages:WaitForChild("ChatMessage"))
local Icon = RunService:IsClient() and require(Modules:WaitForChild("Icon"))

local ChatChannelService = {
	Debug = true,
	Channels = {} :: { [string]: Channel.Channel },
	Commands = {} :: { [string]: Types.Command },
	ChannelHistory = History.new(),
} :: Types.ChatChannelService

local BlockChatMessageStatus = {
	"Unknown",
	"Sending",
	"TextFilterFailed",
	"Floodchecked",
	"InvalidPrivacySettings",
	"InvalidTextChannelPermissions",
	"MessageTooLong",
}

local function DebugPrint(...: any)
	if ChatChannelService.Debug == true then
		local finalString = "[ChatChannelService]"
		for _, object in { ... } do
			finalString = `{finalString} {tostring(object)}`
		end
		finalString = `{finalString}\n{debug.traceback()}`
		print(finalString)
		finalString = nil
	end
end

local function CountArray(array: { [any]: any }): number
	local count = 0
	for _ in array do
		count += 1
	end
	return count
end

local function GetChannelFromTextChannel(textChannel: TextChannel): (string?, Channel.Channel?)
	for name, channel in ChatChannelService.Channels do
		if channel.channel == textChannel then
			return name, channel
		end
	end

	return nil, nil
end

local function GetAliasFromCommands(): { string }
	local converted = {}

	for _, command: Types.Command in ChatChannelService.Commands do
		table.insert(converted, command.PrimaryAlias)
	end

	return converted
end

local function ClearAutoCompleteFrame(listFrame: Frame, mainWindow: Frame): ()
	for _, child: Instance in listFrame:GetChildren() do
		-- Prevent UI Layout from getting deleted
		if child:IsA("UIListLayout") then
			continue
		end

		child:Destroy()
	end

	-- Hide frame again
	mainWindow.Visible = false
end

function ChatChannelService:SetupUI(): boolean
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
		DebugPrint("Succesfully disabled core chat gui!")
	end)

	if disabledChat == false then
		error("[ChatChannelService] Failed to disable the default chat, channels are now disabled on this client.")
	end

	self.icon = Icon.new()
	self.icon:setEnabled(false)
	self.icon:setImage("rbxasset://LuaPackages/Packages/_Index/UIBlox/UIBlox/AppImageAtlas/img_set_1x_7.png")
	self.icon:modifyTheme({
		{ "IconButton", "BackgroundColor3", Color3.new(0, 0, 0), "selected" },
		{ "IconButton", "BackgroundTransparency", 0.5, "selected" },
		{ "IconImage", "ImageColor3", Color3.fromRGB(255, 255, 255), "selected" },
		{ "IconImage", "ImageRectSize", Vector2.new(36, 36) },
		{ "IconImage", "ImageRectOffset", Vector2.new(342, 76), "selected" },
		{ "IconImage", "ImageRectOffset", Vector2.new(38, 304), "deselected" },
	})
	self.icon:setImageScale(1) -- Fixes image from being too small

	self.ui = Instance.new("ScreenGui")
	self.ui.Name = "ChatChannelService_UI"
	self.ui.ResetOnSpawn = false
	self.ui.Enabled = false

	self.root = Layout()
	self.window, self.list = List()
	self.input, self.textbox, self.send, self.commandList, self.autocomplete, self.commandScroll = InputBar()

	self.root.Parent = self.ui
	self.input.Parent = self.root
	self.window.Parent = self.root

	self.currentChannel = nil :: Channel.Channel?
	self.currentChannelChanged = Instance.new("BindableEvent")
	self.canSend = false
	self.isGuest = (Players.LocalPlayer.UserId < 0 and RunService:IsStudio() == false)

	self.channelList, self.channelScroll = ChannelList()
	self.channelList.Parent = self.root

	self.ui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

	local sending = false
	local function SendCurrentText()
		if sending == true or self.canSend == false then
			return
		else
			sending = true
		end

		-- Send message to current channel
		DebugPrint("Sending message!")

		-- Run send async in seperate thread as it can stop the current thread
		task.spawn(self.currentChannel.channel.SendAsync, self.currentChannel.channel, self.textbox.Text)

		-- Reset UI
		self.textbox.PlaceholderText = "To chat click here or press / key"
		self.textbox.TextTransparency = 0.5
		self.textbox.Text = ""

		-- Allow send again
		sending = false
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

		if self.icon.activeState == "Deselected" then
			self.icon:notify()
		end

		DebugPrint(`Received message! Current status: {textChatMessage.Status}`)
		local _, channel = GetChannelFromTextChannel(textChatMessage.TextChannel)
		if channel then
			channel.OnMessage()
			ChatChannelService.ChannelHistory:AddEntry(textChatMessage)
		end
	end)

	-- Setup autocomplete event
	self.autoCompleteList = {
		selected = "",
		index = 2,
		list = {} :: { string },
		event = Instance.new("BindableEvent"),
	}

	UserInputService.InputEnded:Connect(function(input: InputObject, gameProcessedEvent: boolean)
		if self.canSend == false then
			-- Don't select anything when not active
			return
		end

		if gameProcessedEvent == false and input.KeyCode == Enum.KeyCode.Slash then
			self.icon:select()
			self.textbox:CaptureFocus()
			return
		end

		if self.isFocused == true then
			if
				input.KeyCode == Enum.KeyCode.Up
				and self.autoCompleteList.index > 1
				and self.autoCompleteList.index <= #self.autoCompleteList.list
			then
				self.autoCompleteList.index = self.autoCompleteList.index - 1
				self.autoCompleteList.event:Fire(self.autoCompleteList.index)
				self.commandScroll.CanvasPosition = Vector2.new(0, (self.autoCompleteList.index - 1) * 30)
			elseif
				input.KeyCode == Enum.KeyCode.Down
				and self.autoCompleteList.index >= 1
				and self.autoCompleteList.index < #self.autoCompleteList.list
			then
				self.autoCompleteList.index = self.autoCompleteList.index + 1
				self.autoCompleteList.event:Fire(self.autoCompleteList.index)
				self.commandScroll.CanvasPosition = Vector2.new(0, (self.autoCompleteList.index - 1) * 30)
			elseif input.KeyCode == Enum.KeyCode.Tab then
				self.textbox.Text = `{self.autoCompleteList.selected} `
				self.textbox.CursorPosition = self.textbox.Text:len() + 1
			end
		end
	end)

	self.textbox.Focused:Connect(function()
		self.isFocused = true
	end)

	self.textbox.FocusLost:Connect(function(enterPressed: boolean)
		self.isFocused = false

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

			-- Show autocomplete
			ClearAutoCompleteFrame(self.commandList, self.autocomplete)
			self.autoCompleteList.list = {}
			self.autoCompleteList.index = 1

			for index, commandName: string in AutoComplete(GetAliasFromCommands(), self.textbox.Text) do
				-- Prevents command list from not being visible
				self.autocomplete.Visible = true

				-- Prevent showing hidden/disabled commands
				if
					ChatChannelService.Commands[commandName].AutocompleteVisible == false
					or ChatChannelService.Commands[commandName].Enabled == false
				then
					continue
				end

				local newCommand, newButton = Command(commandName, index, function()
					self.textbox.Text = `{commandName} `
				end)
				newCommand.Parent = self.commandList
				self.autoCompleteList.list[index] = newCommand

				-- Mark first as selected
				if index == 1 then
					newButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					newButton.BackgroundTransparency = 0.8
					self.autoCompleteList.selected = commandName
				end

				local connection = self.autoCompleteList.event.Event:Connect(function(newIndex)
					if newIndex == index then
						newButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
						newButton.BackgroundTransparency = 0.8
						self.autoCompleteList.selected = commandName
					else
						newButton.BackgroundColor3 = Color3.fromRGB(163, 162, 165)
						newButton.BackgroundTransparency = 1
					end
				end) :: RBXScriptConnection
				-- Clean up connections
				newCommand.Destroying:Once(function()
					if connection.Connected then
						connection:Disconnect()
					end
				end)
			end
		end
	end)

	self.send.Activated:Connect(SendCurrentText)

	self.currentChannelChanged.Event:Connect(function(newChannel: Channel.Channel)
		local source = newChannel.channel:FindFirstChild(Players.LocalPlayer.Name)
			or { CanSend = false } :: TextSource | { CanSend: boolean }

		-- Reset autocomplete
		ClearAutoCompleteFrame(self.commandList, self.autocomplete)

		if self.isGuest == true then
			self.canSend = false
			self.textbox.TextEditable = false
			self.textbox.PlaceholderText = "Create a free account to get access to chat permissions!"
			self.textbox.Text = ""
			self.textbox:ReleaseFocus()
		elseif source.CanSend == false then
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
	local channelChangedConnection: RBXScriptConnection = nil
	channelChangedConnection = ChatChannelService.ChannelHistory:ChannelChanged(
		function(message: TextChatMessage | "CLEARED" | "REMOVED", changedChannel: TextChannel?)
			if
				typeof(message) == "Instance"
				and message.TextChannel == channel
				and self.currentChannel.channel == channel
			then
				local newMessage = ChatMessage(message)
				newMessage.LayoutOrder = message.Timestamp.UnixTimestamp
				newMessage.Parent = self.list
			elseif message == "CLEARED" and self.currentChannel.channel == channel then
				-- Use SwitchChannel to reset ui as no message means channel got reset
				ChatChannelService:SwitchChannel(self.currentChannel)
			elseif message == "REMOVED" and changedChannel == channel then
				-- Disconnect to prevent memory leaks
				channelChangedConnection:Disconnect()
			end
		end
	)

	DebugPrint("Channel has been successfully added")

	return newChannel
end

function ChatChannelService:RemoveChannel(channel: Channel.Channel)
	DebugPrint(`Removing channel: {channel.name}`)

	-- Prevent original channel from being lost
	local originalInstance = channel.channel
	local originalName = channel.name

	-- First remove channel from index
	ChatChannelService.Channels[originalName].Destroy()
	ChatChannelService.Channels[originalName] = nil

	-- Clear history
	ChatChannelService.ChannelHistory:RemoveChannel(originalInstance)
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

function ChatChannelService:AddCommand(newCommand: TextChatCommand): ()
	-- Prevents registering command twice
	if ChatChannelService.Commands[newCommand.PrimaryAlias:lower()] then
		return
	end

	DebugPrint(`Registering command: {newCommand.Name}`)

	ChatChannelService.Commands[newCommand.PrimaryAlias:lower()] = {
		AutocompleteVisible = newCommand.AutocompleteVisible,
		Enabled = newCommand.Enabled,

		PrimaryAlias = newCommand.PrimaryAlias,
		SecondaryAlias = newCommand.SecondaryAlias,
	}

	if CommandOverrides[newCommand.Name] then
		DebugPrint(`Found override for command, using it instead of base implementation.`)
		newCommand.Triggered:Connect(function(textSource: TextSource, originalString: string)
			task.spawn(CommandOverrides[newCommand.Name], ChatChannelService, textSource, originalString)
		end)
	end

	DebugPrint(`Succesfully registered command as: {newCommand.PrimaryAlias:lower()}`)
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
		ChatChannelService:AddChannel(
			TextChatService:WaitForChild("TextChannels"):WaitForChild("RBXGeneral"),
			"General"
		)
		ChatChannelService:AddChannel(TextChatService:WaitForChild("TextChannels"):WaitForChild("RBXSystem"), "System")

		for _, object: TextChannel in TextChatService:WaitForChild("TextChannels"):GetChildren() do
			if object:IsA("TextChannel") == false or object.Name == "RBXGeneral" or object.Name == "RBXSystem" then
				-- Prevent other instances from being setup
				continue
			end

			-- Remove RBX part
			local newName = object.Name:gsub("RBX", "")

			-- Check if any overrides match channel name
			for possibleMatch, override in ChannelOverrides do
				if newName:match(possibleMatch) then
					newName = override(self, newName)
					break
				end
			end

			DebugPrint(`Checking if player has source in channel...`)

			-- check if player is in the channel
			local source = object:FindFirstChild(Players.LocalPlayer.Name)
				and object:WaitForChild(Players.LocalPlayer.Name)
			if source then
				DebugPrint("Adding player to channel:", newName)
				ChatChannelService:AddChannel(object, newName)
			end

			-- Make sure when added, player can chat
			object.ChildAdded:Connect(function(child)
				if child:IsA("TextSource") == false then
					-- Prevent other instances from triggering channels
					return
				end

				DebugPrint("New textsource found for ", object.Name)

				if child.Name == Players.LocalPlayer.Name then
					ChatChannelService:AddChannel(object, newName)
				end
			end)

			-- Make sure when removed, player doesn't see the channel anymore
			object.ChildRemoved:Connect(function(child)
				if child:IsA("TextSource") == false then
					-- Prevent other instances from triggering channels
					return
				end

				if child.Name == Players.LocalPlayer.Name then
					DebugPrint("Player got removed from channel:", object.Name)
					local _, channelExists = GetChannelFromTextChannel(object)

					-- Prevent nil from beign removed
					if channelExists then
						ChatChannelService:RemoveChannel(channelExists)
					end
				end
			end)
		end

		-- List to added connection, for channels like (teams/whisper)
		TextChatService:WaitForChild("TextChannels").ChildAdded:Connect(function(object: TextChannel)
			if object:IsA("TextChannel") == false or object.Name == "RBXGeneral" or object.Name == "RBXSystem" then
				-- return other instances from being setup
				return
			end

			-- Remove RBX part
			local newName = object.Name:gsub("RBX", "")

			-- Check if any overrides match channel name
			for possibleMatch, override in ChannelOverrides do
				if newName:match(possibleMatch) then
					newName = override(self, newName)
					break
				end
			end

			DebugPrint(`Checking if player has source in channel...`)

			-- check if player is in the channel
			local source = object:FindFirstChild(Players.LocalPlayer.Name)
				and object:WaitForChild(Players.LocalPlayer.Name)
			if source then
				DebugPrint("Adding player to channel:", newName)
				ChatChannelService:AddChannel(object, newName)
			end

			-- Make sure when added, player can chat
			object.ChildAdded:Connect(function(child)
				if child:IsA("TextSource") == false then
					-- Prevent other instances from triggering channels
					return
				end

				if child.Name == Players.LocalPlayer.Name then
					DebugPrint("Player got added to channel:", object.Name)
					ChatChannelService:AddChannel(object, newName)
				end
			end)

			-- Make sure when removed, player doesn't see the channel anymore
			object.ChildRemoved:Connect(function(child)
				if child:IsA("TextSource") == false then
					-- Prevent other instances from triggering channels
					return
				end

				if child.Name == Players.LocalPlayer.Name then
					DebugPrint("Player got removed from channel:", object.Name)
					local _, channelExists = GetChannelFromTextChannel(object)

					-- Prevent nil from beign removed
					if channelExists then
						ChatChannelService:RemoveChannel(channelExists)
					end
				end
			end)
		end)

		-- Select default channel as current
		ChatChannelService:SwitchChannel(ChatChannelService.Channels["General"])

		DebugPrint("Default Roblox channels have been set up, loading custom channels...")

		-- Load through already existing custom channels
		for _, object: TextChannel in TextChatService:WaitForChild("ChatChannels"):GetChildren() do
			if object:IsA("TextChannel") == false then
				-- Prevent other instances from being setup
				continue
			end

			-- check if player is in the channel
			local source = object:FindFirstChild(Players.LocalPlayer.Name)
				and object:WaitForChild(Players.LocalPlayer.Name)
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
			local source = object:FindFirstChild(Players.LocalPlayer.Name)
				and object:WaitForChild(Players.LocalPlayer.Name)
			if source then
				ChatChannelService:AddChannel(object)
			end

			-- Connect events
			object.ChildAdded:Connect(function(newObject: TextSource)
				if newObject:IsA("TextSource") and newObject.UserId == Players.LocalPlayer.UserId then
					ChatChannelService:AddChannel(object)
				end
			end)

			object.ChildRemoved:Connect(function(oldObject: TextSource)
				if oldObject:IsA("TextSource") and oldObject.UserId == Players.LocalPlayer.UserId then
					ChatChannelService:RemoveChannel(object)
				end
			end)
		end)

		-- Connect command overrides
		TextChatService:WaitForChild("TextChatCommands").ChildAdded:Connect(function(addedCommand: TextChatCommand)
			if
				addedCommand:IsA("TextChatCommand")
				and not ChatChannelService.Commands[addedCommand.PrimaryAlias:lower()]
			then
				ChatChannelService:AddCommand(addedCommand)
			end
		end)
		for _, addedCommand: TextChatCommand in TextChatService:WaitForChild("TextChatCommands"):GetChildren() do
			-- Prevents registering command twice
			if
				addedCommand:IsA("TextChatCommand")
				and not ChatChannelService.Commands[addedCommand.PrimaryAlias:lower()]
			then
				ChatChannelService:AddCommand(addedCommand)
			end
		end

		self.icon:setEnabled(true)
		DebugPrint("Fully loaded channels! Chat icon has been enabled")
	else
		DebugPrint("Setting up custom channel and commands folder...")

		local ChatChannels = Instance.new("Folder")
		ChatChannels.Name = "ChatChannels"
		ChatChannels.Parent = TextChatService

		local ChatCommands = Instance.new("Folder")
		ChatCommands.Name = "ChatCommands"
		ChatChannels.Parent = TextChatService

		DebugPrint("ChatChannelService is ready for client!")
		Loaded.Value = true
	end
end

return ChatChannelService
