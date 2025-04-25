--[[
    Adds channels to the roblox chat.
]]
--!strict

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local TextChatService = game:GetService("TextChatService")

local Loaded = script.Parent:WaitForChild("Loaded") :: BoolValue
local Assets = script.Parent:WaitForChild("Assets")
local Utils = script.Parent:WaitForChild("Utils")
local UI = Assets:WaitForChild("UI")
local Overrides = Assets:WaitForChild("Overrides")
local Channels = UI:WaitForChild("Channels")
local Chat = UI:WaitForChild("Chat")

local Channel = require(Channels:WaitForChild("Channel"))
local ChannelList = require(Channels:WaitForChild("ChannelList"))
local Types = require(Utils:WaitForChild("Types"))
local ChannelOverrides = require(Overrides:WaitForChild("Channels"))
local SortChannels = require(Utils:WaitForChild("SortChannels"))

local ChannelContainer = require(Chat:WaitForChild("ChannelContainer"))

local ChatChannelServiceClient = {
	Debug = false,
	Channels = {} :: { [string]: Types.Channel },
} :: Types.ChatChannelServiceClient

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

local function GetChannelFromTextChannel(textChannel: TextChannel): (string?, Types.Channel?)
	for name, channel in ChatChannelServiceClient.Channels do
		if channel.textChannel == textChannel then
			return name, channel
		end
	end

	return nil, nil
end

function ChatChannelServiceClient.SetupUI(self: Types.ChatChannelServiceClient): boolean
	if RunService:IsServer() == true then
		-- Prevent server making icons
		DebugPrint("Tried to setup UI on server")
		return false
	end

	self.ui = Instance.new("ScreenGui")
	self.ui.Name = "ChatChannelService_UI"
	self.ui.ResetOnSpawn = false
	self.ui.Enabled = false

	local ChatInputbarConfiguration =
		TextChatService:WaitForChild("ChatInputBarConfiguration") :: ChatInputBarConfiguration
	local ChatWindowConfiguration =
		TextChatService:WaitForChild("ChatWindowConfiguration") :: ChatWindowConfiguration

	self.root = ChannelContainer(ChatInputbarConfiguration)
	self.root.Parent = self.ui

	self.currentChannel = nil :: Types.Channel?

	self.channelList, self.channelScroll = ChannelList()
	self.channelList.Parent = self.root

	self.ui.Parent = Players.LocalPlayer and Players.LocalPlayer:WaitForChild("PlayerGui")

	--// When the chat gets disabled, it updates the size of input bar. We use this to trigger for our UI to hide as well.
	local function UpdateChannelsVisibility()
		pcall(function()
			if StarterGui:GetCore("ChatActive") == true then
				if ChatInputbarConfiguration.Enabled == false and ChatWindowConfiguration.Enabled == false then
					self.ui.Enabled = false
				else
					self.ui.Enabled = true
				end
			end

			self.ui.Enabled = StarterGui:GetCore("ChatActive") == true
		end)
	end

	ChatInputbarConfiguration.Changed:Connect(UpdateChannelsVisibility)
	ChatWindowConfiguration.Changed:Connect(UpdateChannelsVisibility)

	return true
end

function ChatChannelServiceClient.AddChannel(
	self: Types.ChatChannelServiceClient,
	channel: TextChannel,
	customName: string?
): Types.Channel
	local name = customName or channel.Name

	DebugPrint(`Adding channel: {name}`)

	if self.Channels[name] then
		error(`[ChatChannelServiceClient] Duplicate channel name! Name: {name}`)
	end

	-- Setup channel
	local newChannel = Channel(name, channel)
	self.Channels[name] = newChannel

	-- Parent channel to UI
	newChannel.uiInstance.Parent = self.channelScroll

	-- Reorder channels
	local sortedChannels = SortChannels(self.Channels)
	for index, sortedChannel in sortedChannels do
		sortedChannel.uiInstance.LayoutOrder = index
	end

	-- Connect pressed event
	newChannel.Activated:Connect(function()
		self:SwitchChannel(newChannel)
	end)

	-- Rerender UI
	self.channelScroll.Parent = Players.LocalPlayer
	task.delay(0.1, function()
		self.channelScroll.Parent = self.channelList
	end)

	DebugPrint("Channel has been successfully added")

	return newChannel
end

function ChatChannelServiceClient.RemoveChannel(self: Types.ChatChannelServiceClient, channel: Types.Channel)
	DebugPrint(`Removing channel: {channel.name}`)

	-- Switch to general channel if we were on that channel
	if channel.selected == true then
		DebugPrint("Switching to general channel")
		self:SwitchChannel(self.Channels["General"])
	end

	-- Prevent original channel from being lost
	local originalName = channel.name

	-- First remove channel from index
	self.Channels[originalName].Destroy()
	self.Channels[originalName] = nil
end

function ChatChannelServiceClient.SwitchChannel(self: Types.ChatChannelServiceClient, channel: Types.Channel)
	local oldChannel = self.currentChannel :: Types.Channel
	local ChatInputbarConfiguration =
		TextChatService:WaitForChild("ChatInputBarConfiguration") :: ChatInputBarConfiguration

	-- Prevent old channel from also being selected
	if oldChannel and oldChannel.selected then
		oldChannel.SetSelected(false)
	end

	-- Set new channel as selected
	self.currentChannel = channel

	if self.currentChannel then
		self.currentChannel.SetSelected(true)
		ChatInputbarConfiguration.TargetTextChannel = channel.textChannel
	end
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
				if self:SetupUI(response) then
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
			local ui = self:SetupUI()
			if ui == false then
				DebugPrint("Failed to create default UI, disabling ChatChannelServiceClient")
				return
			end
		end

		DebugPrint("UI has been created, setting up default roblox channels...")

		-- Make general always first
		if TextChatService.CreateDefaultTextChannels then
			self:AddChannel(TextChatService:WaitForChild("TextChannels"):WaitForChild("RBXGeneral"), "General")
		else
			DebugPrint("Default channels are not created, skipping...")
		end

		DebugPrint("Loading existing channels...")
		for _, object: Instance | TextChannel in TextChatService:WaitForChild("TextChannels"):GetChildren() do
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

			local localPlayer = Players.LocalPlayer
			if not localPlayer then
				return
			end

			DebugPrint(`Checking if player has source in channel...`)

			-- check if player is in the channel
			local source = object:FindFirstChild(localPlayer.Name) and object:WaitForChild(localPlayer.Name)
			if source then
				DebugPrint(`Adding player to channel: {newName}`)
				self:AddChannel(object, newName)
			end

			-- Make sure when added, player can chat
			object.ChildAdded:Connect(function(child)
				if child:IsA("TextSource") == false then
					-- Prevent other instances from triggering channels
					return
				end

				DebugPrint(`New textsource found for {object.Name}`)

				if child.Name == localPlayer.Name then
					self:AddChannel(object, newName)
				end
			end)

			-- Make sure when removed, player doesn't see the channel anymore
			object.ChildRemoved:Connect(function(child)
				if child:IsA("TextSource") == false then
					-- Prevent other instances from triggering channels
					return
				end

				if child.Name == localPlayer.Name then
					DebugPrint(`Player got removed from channel: {object.Name}`)
					local _, channelExists = GetChannelFromTextChannel(object :: TextChannel)

					-- Prevent nil from being removed
					if channelExists then
						self:RemoveChannel(channelExists)
					end
				end
			end)
		end

		-- List to added connection, for channels like (teams/whisper)
		TextChatService:WaitForChild("TextChannels").ChildAdded:Connect(function(object: Instance | TextChannel)
			if
				object:IsA("TextChannel") == false
				or object.Name == "RBXGeneral"
				or object.Name == "RBXSystem"
				or object.Name:match("Nexus")
			then
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

			local localPlayer = Players.LocalPlayer
			if not localPlayer then
				return
			end

			DebugPrint(`Checking if player has source in channel...`)

			-- check if player is in the channel
			local source = object:FindFirstChild(localPlayer.Name) and object:WaitForChild(localPlayer.Name)
			if source then
				DebugPrint(`Adding player to channel: {newName}`)
				self:AddChannel(object :: TextChannel, newName)
			end

			-- Make sure when added, player can chat
			object.ChildAdded:Connect(function(child)
				if child:IsA("TextSource") == false then
					-- Prevent other instances from triggering channels
					return
				end

				if child.Name == localPlayer.Name then
					DebugPrint(`Player got added to channel: {object.Name}`)
					self:AddChannel(object :: TextChannel, newName)
				end
			end)

			-- Make sure when removed, player doesn't see the channel anymore
			object.ChildRemoved:Connect(function(child)
				if child:IsA("TextSource") == false then
					-- Prevent other instances from triggering channels
					return
				end

				if child.Name == localPlayer.Name then
					DebugPrint(`Player got removed from channel: {object.Name}`)
					local _, channelExists = GetChannelFromTextChannel(object :: TextChannel)

					-- Prevent nil from being removed
					if channelExists then
						self:RemoveChannel(channelExists)
					end
				end
			end)
		end)

		-- Select default channel as current
		self:SwitchChannel(self.Channels["General"])

		DebugPrint("Default Roblox channels have been set up, loading custom channels...")

		-- Load through already existing custom channels
		for _, object: TextChannel in TextChatService:WaitForChild("ChatChannels"):GetChildren() do
			if object:IsA("TextChannel") == false then
				-- Prevent other instances from being setup
				continue
			end

			local localPlayer = Players.LocalPlayer
			if not localPlayer then
				-- Prevent other instances from being setup
				return
			end

			-- check if player is in the channel
			local source = object:FindFirstChild(localPlayer.Name) and object:WaitForChild(localPlayer.Name)
			if source then
				self:AddChannel(object :: TextChannel)
			else
				-- If player isn't in this channel, setup connection to wait for them to be added
				object.ChildAdded:Connect(function(newObject)
					if newObject:IsA("TextSource") and newObject.UserId == localPlayer.UserId then
						self:AddChannel(object :: TextChannel)
					end
				end)

				continue
			end
		end

		-- Connect event when custom channels get added
		TextChatService:WaitForChild("ChatChannels").ChildAdded:Connect(function(object: Instance | TextChannel)
			if object:IsA("TextChannel") == false then
				-- Prevent other instances from being setup
				return
			end

			local localPlayer = Players.LocalPlayer
			if not localPlayer then
				-- Prevent other instances from being setup
				return
			end

			-- check if player is in the channel
			local source = object:FindFirstChild(localPlayer.Name) and object:WaitForChild(localPlayer.Name)
			if source then
				self:AddChannel(object :: TextChannel)
			end

			-- Connect events
			object.ChildAdded:Connect(function(newObject: Instance | TextSource)
				if newObject:IsA("TextSource") and newObject.UserId == localPlayer.UserId then
					self:AddChannel(object :: TextChannel)
				end
			end)

			object.ChildRemoved:Connect(function(oldObject: Instance | TextSource)
				if oldObject:IsA("TextSource") and oldObject.UserId == localPlayer.UserId then
					local _, foundChannel = GetChannelFromTextChannel(object :: TextChannel)
					if foundChannel then
						self:RemoveChannel(foundChannel)
					end
				end
			end)
		end)

		DebugPrint("Fully loaded channels! Chat icon has been enabled")

		self.ui.Enabled = StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType.Chat)
	end
end

return ChatChannelServiceClient
