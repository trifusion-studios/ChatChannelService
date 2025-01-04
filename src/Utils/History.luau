--[[
    Holds chat history from textchannel

    @GGshor
]]

local Types = require(script.Parent:WaitForChild("Types"))

local History = {} :: Types.History
History.__index = History

function History.AddEntry(self: Types.History, message: TextChatMessage)
	-- Prevent entry indexing nil
	if self.messages[message.TextChannel] == nil then
		self.messages[message.TextChannel] = {}
	end

	self.messages[message.TextChannel][message.Timestamp.UnixTimestamp] = message

	self._onChannelChangedEvent:Fire(message, message.TextChannel)
end

function History.GetChannelHistory(self: Types.History, channel: TextChannel): { [number]: TextChatMessage }
	return self.messages[channel] or {}
end

function History.ClearChannelHistory(self: Types.History, channel: TextChannel): ()
	if self.messages[channel] then
		self.messages[channel] = {}

		-- Trigger that channel history has been cleared
		self._onChannelChangedEvent:Fire("CLEARED", channel)
	end
end

function History.RemoveChannel(self: Types.History, channel: TextChannel): ()
	if self.messages[channel] then
		self.messages[channel] = nil

		-- Trigger that channel history has been removed
		self._onChannelChangedEvent:Fire("REMOVED", channel)
	end
end

function History.new(): Types.History
	local onChannelChanged = Instance.new("BindableEvent")

	local self: Types.History = setmetatable(History, {
		messages = {},
		_onChannelChangedEvent = onChannelChanged,
	})

	return self
end

return History
