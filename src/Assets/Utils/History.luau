--[[
    Holds chat history from textchannel

    @GGshor
]]

local Types = require(script.Parent:WaitForChild("Types"))

local History = {} :: Types.History
History.__index = History

function History.AddEntry(self: Types.HistoryObject, message: TextChatMessage)
	-- Prevent entry indexing nil
	if self.messages[message.TextChannel] == nil then
		self.messages[message.TextChannel] = {}
	end

	self.messages[message.TextChannel][message.Timestamp.UnixTimestamp] = message

	self._onChannelChanged:Fire(message, message.TextChannel)
end

function History.GetChannelHistory(self: Types.HistoryObject, channel: TextChannel): { [number]: TextChatMessage }
	return self.messages[channel]
end

function History.ClearChannelHistory(self: Types.HistoryObject, channel: TextChannel): ()
	if self.messages[channel] then
		self.messages[channel] = {}

		-- Trigger that channel history has been cleared
		self._onChannelChanged:Fire("CLEARED", channel)
	end
end

function History.RemoveChannel(self: Types.HistoryObject, channel: TextChannel): ()
	if self.messages[channel] then
		self.messages[channel] = nil

		-- Trigger that channel history has been removed
		self._onChannelChanged:Fire("REMOVED", channel)
	end
end

function History.new(): Types.HistoryObject
	local onChannelChanged = Instance.new("BindableEvent")

	return setmetatable({
		messages = {},
		ChannelChanged = onChannelChanged.Event,
		_onChannelChanged = Instance.new("BindableEvent").Changed
	})
end

return History
