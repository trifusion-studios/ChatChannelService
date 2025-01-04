--[[
    Adds channels to the roblox chat.
]]
--!strict

local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local TextChatService = game:GetService("TextChatService")
local UserInputService = game:GetService("UserInputService")

local Loaded = script.Parent:WaitForChild("Loaded") :: BoolValue
local Assets = script.Parent:WaitForChild("Assets")
local Modules = script.Parent:WaitForChild("Modules")
local Utils = script.Parent:WaitForChild("Utils")
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

local ChatChannelServiceClient = {
	Debug = false,
	Channels = {} :: { [string]: Types.Channel },
	Commands = {} :: { [string]: Types.Command },
	ChannelHistory = History.new(),
} :: Types.ChatChannelServiceClient

local BlockChatMessageStatus = {
	"Unknown",
	"Sending",
	"TextFilterFailed",
	"Floodchecked",
	"InvalidPrivacySettings",
	"InvalidTextChannelPermissions",
	"MessageTooLong",
}

--[=[
	Prints out the message if debug is enabled.

	@param ... any -- The messages you want to send
]=]
local function DebugPrint(...: any): ()
	if ChatChannelServiceClient.Debug == true then
		local finalString = "[ChatChannelServiceClient]"
		for _, object in { ... } do
			finalString = `{finalString} {tostring(object)}`
		end
		finalString = `{finalString}\n{debug.traceback()}`
		print(finalString)
	end
end

--[[
	Returns the amount
]]
local function CountArray(array: { [any]: any }): number
	local count = 0
	for _ in array do
		count += 1
	end
	return count
end

local function GetChannelFromTextChannel(textChannel: TextChannel): (string?, Types.Channel?)
	for name, channel in ChatChannelServiceClient.Channels do
		if channel.channel == textChannel then
			return name, channel
		end
	end

	return nil, nil
end

local function GetAliasFromCommands(): { string }
	local converted = {}

	for _, command: Types.Command in ChatChannelServiceClient.Commands do
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

function ChatChannelServiceClient.SetupUI(self: Types.ChatChannelServiceClient): boolean
	if RunService:IsServer() == true then
		-- Prevent server making icons
		DebugPrint("Tried to setup UI on server")
		return false
	end

	-- Disable chat on console
	if GuiService:IsTenFootInterface() == true then
		return false
	end

	-- try to disable the chat gui with a delay to prevent from disabling it too fast
	task.delay(5, function()
		local disabledChat = SafePcall(30, 1, ChatChannelServiceClient.Debug, function()
			StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false)
			DebugPrint("Succesfully disabled core chat gui!")
		end)

		if disabledChat == false then
			error("[ChatChannelServiceClient] Failed to disable the default chat, channels are now disabled on this client.")
		end
	end)

	self.icon = Icon.new()
	self.icon:setEnabled(false)
	self.icon:setImage("rbxasset://LuaPackages/Packages/_Index/FoundationImages/FoundationImages/SpriteSheets/img_set_1x_7.png")
	self.icon:modifyTheme({
		{ "IconButton", "BackgroundColor3", Color3.new(0, 0, 0), "selected" },
		{ "IconButton", "BackgroundTransparency", 0.5, "selected" },
		{ "IconImage", "ImageColor3", Color3.fromRGB(255, 255, 255), "selected" },
		{ "IconImage", "ImageRectSize", Vector2.new(36, 36) },
		{ "IconImage", "ImageRectOffset", Vector2.new(76, 190)}
	} :: {{any}})
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

	self.currentChannel = nil :: Types.Channel?
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
		if self.currentChannel then
			task.spawn(self.currentChannel.channel.SendAsync, self.currentChannel.channel, self.textbox.Text)
		end

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
		self.icon:clearNotices()
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

		DebugPrint(`Received message! From channel: {textChatMessage.TextChannel}, with status: {textChatMessage.Status}`)
		local _, channel = GetChannelFromTextChannel(textChatMessage.TextChannel)
		if channel then
			ChatChannelServiceClient.ChannelHistory:AddEntry(textChatMessage)
		end
	end)

	-- Setup autocomplete event
	self.autoCompleteList = {
		selected = "",
		index = 2,
		list = {},
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

				if ((self.autoCompleteList.index - 1) * 30) >= self.commandScroll.AbsoluteWindowSize.Y then
					self.commandScroll.CanvasPosition = Vector2.new(
						0,
						self.commandScroll.AbsoluteWindowSize.Y
							+ (((self.autoCompleteList.index - 1) * 30) - self.commandScroll.AbsoluteWindowSize.Y)
					)
				else
					self.commandScroll.CanvasPosition = Vector2.zero
				end
			elseif
				input.KeyCode == Enum.KeyCode.Down
				and self.autoCompleteList.index >= 1
				and self.autoCompleteList.index < #self.autoCompleteList.list
			then
				self.autoCompleteList.index = self.autoCompleteList.index + 1
				self.autoCompleteList.event:Fire(self.autoCompleteList.index)

				if ((self.autoCompleteList.index - 1) * 30) >= self.commandScroll.AbsoluteWindowSize.Y then
					self.commandScroll.CanvasPosition = Vector2.new(
						0,
						self.commandScroll.AbsoluteWindowSize.Y
							+ (((self.autoCompleteList.index - 1) * 30) - self.commandScroll.AbsoluteWindowSize.Y)
					)
				else
					self.commandScroll.CanvasPosition = Vector2.zero
				end
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
			local sendIcon = ((self.send:WaitForChild("SendIcon")) :: any)
			if self.textbox.Text:len() > 0 then
				sendIcon.ImageColor3 = Color3.new(1, 1, 1)
				sendIcon.ImageTransparency = 0
				self.textbox.TextTransparency = 0
			else
				sendIcon.ImageColor3 = Color3.fromRGB(178, 178, 178)
				sendIcon.ImageTransparency = 0.5
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
					ChatChannelServiceClient.Commands[commandName].AutocompleteVisible == false
					or ChatChannelServiceClient.Commands[commandName].Enabled == false
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

	self.currentChannelChanged.Event:Connect(function(newChannel: Types.Channel)
		local source = ((newChannel.channel:FindFirstChild(Players.LocalPlayer.Name)) :: TextSource?)
			or { CanSend = false } :: { CanSend: boolean }

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

function ChatChannelServiceClient.AddChannel(self: Types.ChatChannelServiceClient, channel: TextChannel, customName: string?): Types.Channel
	local name = customName or channel.Name

	DebugPrint(`Adding channel: {name}`)

	if ChatChannelServiceClient.Channels[name] then
		error(`[ChatChannelServiceClient] Duplicate channel name! Name: {name}`)
	end

	-- Setup channel
	local color = channel:GetAttribute("ChatColor")
	if typeof(color) ~= "Color3" and typeof(color) ~= "nil" then
		error(`[ChatChannelServiceClient] Inccorrect color type, expected Color3 or nil! Channel name: {name}`)
	end

	local newChannel = Channel(name, color, channel)
	ChatChannelServiceClient.Channels[name] = newChannel

	-- Ensure channel is in correct order
	newChannel.instance.LayoutOrder = CountArray(ChatChannelServiceClient.Channels)

	-- Parent channel to UI
	newChannel.instance.Parent = self.channelScroll

	-- Connect pressed event
	newChannel.Activated:Connect(function()
		ChatChannelServiceClient:SwitchChannel(newChannel)
	end)

	-- Add message if channel is active
	local channelChangedConnection: RBXScriptConnection = nil
	channelChangedConnection = ChatChannelServiceClient.ChannelHistory.ChannelChanged:Connect(
		function(message: Types.ChannelChangedMessage, changedChannel: TextChannel?)
			if self.currentChannel == nil then
				return
			end

			if message == "REMOVED" and changedChannel == channel then
				-- Disconnect to prevent memory leaks
				channelChangedConnection:Disconnect()
			elseif message == "CLEARED" and self.currentChannel.channel == channel then
				-- Use SwitchChannel to reset ui as no message means channel got reset
				ChatChannelServiceClient:SwitchChannel(self.currentChannel)
			elseif
				typeof(message) == "Instance"
				and message.TextChannel == channel
				and self.currentChannel.channel == channel
			then
				local newMessage = ChatMessage(message)
				newMessage.LayoutOrder = message.Timestamp.UnixTimestamp
				newMessage.Parent = self.list
			end
		end
	)


	DebugPrint("Channel has been successfully added")

	return newChannel
end

function ChatChannelServiceClient.RemoveChannel(self: Types.ChatChannelServiceClient, channel: Types.Channel)
	DebugPrint(`Removing channel: {channel.name}`)

	-- Switch to general channel as default
	ChatChannelServiceClient:SwitchChannel(ChatChannelServiceClient.Channels["General"])

	-- Prevent original channel from being lost
	local originalInstance = channel.channel
	local originalName = channel.name

	-- First remove channel from index
	ChatChannelServiceClient.Channels[originalName].Destroy()
	ChatChannelServiceClient.Channels[originalName] = nil

	-- Clear history
	ChatChannelServiceClient.ChannelHistory:RemoveChannel(originalInstance)
end

function ChatChannelServiceClient.SwitchChannel(self: Types.ChatChannelServiceClient, channel: Types.Channel)
	local oldChannel = self.currentChannel :: Types.Channel

	-- Prevent old channel from also being selected
	if oldChannel ~= nil and oldChannel.selected == true then
		oldChannel.SetSelected(false)
	end

	-- Set new channel as selected
	self.currentChannel = channel
	self.currentChannelChanged:Fire(channel)

	if self.currentChannel then
		self.currentChannel.SetSelected(true)
	end

	-- Destroy old channel list
	self.window:Destroy()

	-- Create new list
	self.window, self.list = List()
	self.window.Parent = self.root

	-- Get new channel history
	local entries = ChatChannelServiceClient.ChannelHistory:GetChannelHistory(channel.channel)

	-- Add all messages to the list
	for _, message: TextChatMessage in entries do
		local newMessage = ChatMessage(message)
		newMessage.LayoutOrder = message.Timestamp.UnixTimestamp
		newMessage.Parent = self.list
	end
end

function ChatChannelServiceClient.AddCommand(self: Types.ChatChannelServiceClient, newCommand: TextChatCommand): ()
	-- Prevents registering command twice
	if self.Commands[newCommand.PrimaryAlias:lower()] then
		return
	end

	DebugPrint(`Registering command: {newCommand.Name}`)

	self.Commands[newCommand.PrimaryAlias:lower()] = {
		AutocompleteVisible = newCommand.AutocompleteVisible,
		Enabled = newCommand.Enabled,

		PrimaryAlias = newCommand.PrimaryAlias,
		SecondaryAlias = newCommand.SecondaryAlias,
	}

	if CommandOverrides[newCommand.Name] then
		DebugPrint(`Found override for command, using it instead of base implementation.`)
		newCommand.Triggered:Connect(function(textSource: TextSource, originalString: string)
			task.spawn(CommandOverrides[newCommand.Name], self, textSource, originalString)
		end)
	end

	DebugPrint(`Succesfully registered command as: {newCommand.PrimaryAlias:lower()}`)
end

function ChatChannelServiceClient.Setup(self: Types.ChatChannelServiceClient, overrideUI: ModuleScript?): ()
	-- Make client wait until server has been loaded
	if RunService:IsClient() then
		DebugPrint("Waiting for server to load channels...")
		while Loaded.Value == false do
			Loaded.Changed:Wait()
		end

		local customThemeEnabled = false
		DebugPrint("Server has loaded channels, creating initial UI...")
		if overrideUI and overrideUI:IsA("ModuleScript") == true then
			DebugPrint("Custom UI was given, loading UI from provided configuration...")
			local success, response: any = pcall(require, overrideUI)

			if success == false then
				warn(`[ChatChannelService] Failed to load given override module, got response: {response}`)
			else
				if ChatChannelServiceClient:SetupUI(response) then
					DebugPrint("Successfully setup custom theme, ChatChannelServiceClient has been enabled")
					customThemeEnabled = true
				else
					DebugPrint("Failed to create UI with given theme, falling back to default UI.")
				end
			end
		end

		-- Prevent making UI again when custom theme was loaded
		if customThemeEnabled == false then
			DebugPrint("Setting up default UI")
			local ui = ChatChannelServiceClient:SetupUI()
			if ui == false then
				DebugPrint("Failed to create default UI, disabling ChatChannelServiceClient")
				return
			end
		end

		DebugPrint("UI has been created, setting up default roblox channels...")

		-- Make general and system always first
		ChatChannelServiceClient:AddChannel(
			TextChatService:WaitForChild("TextChannels"):WaitForChild("RBXGeneral"),
			"General"
		)
		ChatChannelServiceClient:AddChannel(TextChatService:WaitForChild("TextChannels"):WaitForChild("RBXSystem"), "System")

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
				DebugPrint(`Adding player to channel: {newName}`)
				ChatChannelServiceClient:AddChannel(object, newName)
			end

			-- Make sure when added, player can chat
			object.ChildAdded:Connect(function(child)
				if child:IsA("TextSource") == false then
					-- Prevent other instances from triggering channels
					return
				end

				DebugPrint(`New textsource found for {object.Name}`)

				if child.Name == Players.LocalPlayer.Name then
					ChatChannelServiceClient:AddChannel(object, newName)
				end
			end)

			-- Make sure when removed, player doesn't see the channel anymore
			object.ChildRemoved:Connect(function(child)
				if child:IsA("TextSource") == false then
					-- Prevent other instances from triggering channels
					return
				end

				if child.Name == Players.LocalPlayer.Name then
					DebugPrint(`Player got removed from channel: {object.Name}`)
					local _, channelExists = GetChannelFromTextChannel(object)

					-- Prevent nil from beign removed
					if channelExists then
						ChatChannelServiceClient:RemoveChannel(channelExists)
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
				DebugPrint(`Adding player to channel: {newName}`)
				ChatChannelServiceClient:AddChannel(object, newName)
			end

			-- Make sure when added, player can chat
			object.ChildAdded:Connect(function(child)
				if child:IsA("TextSource") == false then
					-- Prevent other instances from triggering channels
					return
				end

				if child.Name == Players.LocalPlayer.Name then
					DebugPrint(`Player got added to channel: {object.Name}`)
					ChatChannelServiceClient:AddChannel(object, newName)
				end
			end)

			-- Make sure when removed, player doesn't see the channel anymore
			object.ChildRemoved:Connect(function(child)
				if child:IsA("TextSource") == false then
					-- Prevent other instances from triggering channels
					return
				end

				if child.Name == Players.LocalPlayer.Name then
					DebugPrint(`Player got removed from channel: {object.Name}`)
					local _, channelExists = GetChannelFromTextChannel(object)

					-- Prevent nil from beign removed
					if channelExists then
						ChatChannelServiceClient:RemoveChannel(channelExists)
					end
				end
			end)
		end)

		-- Select default channel as current
		ChatChannelServiceClient:SwitchChannel(ChatChannelServiceClient.Channels["General"])

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
				ChatChannelServiceClient:AddChannel(object)
			else
				-- If player isn't in this channel, setup connection to wait for them to be added
				object.ChildAdded:Connect(function(newObject)
					if newObject:IsA("TextSource") and newObject.UserId == Players.LocalPlayer.UserId then
						ChatChannelServiceClient:AddChannel(object)
					end
				end)

				continue
			end
		end

		-- Connect event when custom channels get added
		TextChatService:WaitForChild("ChatChannels").ChildAdded:Connect(function(object: TextChannel)
			if object:IsA("TextChannel") == false then
				-- Prevent other instances from being setup
				return
			end

			-- check if player is in the channel
			local source = object:FindFirstChild(Players.LocalPlayer.Name)
				and object:WaitForChild(Players.LocalPlayer.Name)
			if source then
				ChatChannelServiceClient:AddChannel(object)
			end

			-- Connect events
			object.ChildAdded:Connect(function(newObject: Instance | TextSource)
				if newObject:IsA("TextSource") and newObject.UserId == Players.LocalPlayer.UserId then
					ChatChannelServiceClient:AddChannel(object)
				end
			end)

			object.ChildRemoved:Connect(function(oldObject: Instance | TextSource)
				if oldObject:IsA("TextSource") and oldObject.UserId == Players.LocalPlayer.UserId then
					local _, foundChannel = GetChannelFromTextChannel(object)
					if foundChannel then
						ChatChannelServiceClient:RemoveChannel(foundChannel)
					end
				end
			end)
		end)

		-- Connect command overrides
		TextChatService:WaitForChild("TextChatCommands").ChildAdded:Connect(function(addedCommand: TextChatCommand)
			if
				addedCommand:IsA("TextChatCommand")
				and not ChatChannelServiceClient.Commands[addedCommand.PrimaryAlias:lower()]
			then
				ChatChannelServiceClient:AddCommand(addedCommand)
			end
		end)
		for _, addedCommand: TextChatCommand in TextChatService:WaitForChild("TextChatCommands"):GetChildren() do
			-- Prevents registering command twice
			if
				addedCommand:IsA("TextChatCommand")
				and not ChatChannelServiceClient.Commands[addedCommand.PrimaryAlias:lower()]
			then
				ChatChannelServiceClient:AddCommand(addedCommand)
			end
		end

		self.icon:setEnabled(true)
		DebugPrint("Fully loaded channels! Chat icon has been enabled")
	end
end

return ChatChannelServiceClient
