--[[
    Holds chat history from textchannel

    @GGshor
]]

export type History = {
	new: () -> HistoryObject,
}

-- Holds entries
export type HistoryObject = {
	messages: {
		[TextChannel]: {
			[number]: TextChatMessage,
		},
	},

	AddEntry: (self: HistoryObject, message: TextChatMessage) -> (),
	GetChannelHistory: (self: HistoryObject, channel: TextChannel) -> { [number]: TextChatMessage },
	ClearChannelHistory: (self: HistoryObject, channel: TextChannel) -> (),
	RemoveChannel: (self: HistoryObject, channel: TextChannel) -> (),

	ChannelChanged: (
		self: HistoryObject,
		callback: (message: TextChatMessage | "CLEARED" | "REMOVED", changedChannel: TextChannel?) -> ()
	) -> RBXScriptConnection,
}

local History = {} :: History
History.__index = History

function History:ChannelChanged(callback: (
	message: TextChatMessage | "CLEARED" | "REMOVED",
	changedChannel: TextChannel?
) -> ()): RBXScriptConnection
	return self._onChannelChanged.Event:Connect(callback)
end

function History:AddEntry(message: TextChatMessage)
	-- Prevent entry indexing nil
	if self.messages[message.TextChannel] == nil then
		self.messages[message.TextChannel] = {}
	end

	self.messages[message.TextChannel][message.Timestamp.UnixTimestamp] = message

	self._onChannelChanged:Fire(message, message.TextChannel)
end

function History:GetChannelHistory(channel: TextChannel): { [number]: TextChatMessage }
	return self.messages[channel]
end

function History:ClearChannelHistory(channel: TextChannel): ()
	if self.messages[channel] then
		self.messages[channel] = {}

		-- Trigger that channel history has been cleared
		self._onChannelChanged:Fire("CLEARED", channel)
	end
end

function History:RemoveChannel(channel: TextChannel): ()
	if self.messages[channel] then
		self.messages[channel] = nil

		-- Trigger that channel history has been removed
		self._onChannelChanged:Fire("REMOVED", channel)
	end
end

function History.new()
	local self = setmetatable(History, {})

	self.messages = {} :: { [number]: TextChatMessage }
	self._onChannelChanged = Instance.new("BindableEvent")

	return self
end

return History
