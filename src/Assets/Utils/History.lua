--[[
    Holds chat history from textchannel

    @GGshor
]]

export type History = {
    new: () -> HistoryObject
}

-- Holds entries
export type HistoryObject = {
    messages: {
        [TextChannel]: {
            [number]: TextChatMessage
        }
    },

    AddEntry: (self: HistoryObject, message: TextChatMessage) -> (),
    GetChannelHistory: (self: HistoryObject, channel: TextChannel) -> {[number]: TextChatMessage},

    OnEntryAdded: (self: HistoryObject, callback: (message: TextChatMessage) -> ()) -> RBXScriptConnection
}


local History = {} :: History
History.__index = History


function History:OnEntryAdded(callback: (message: TextChatMessage) -> ()): RBXScriptConnection
    return self._onEntryAddedEvent.Event:Connect(callback)
end

function History:AddEntry(message: TextChatMessage)
    -- Prevent entry indexing nil
    if self.messages[message.TextChannel] == nil then
        self.messages[message.TextChannel] = {}
    end

    self.messages[message.TextChannel][message.Timestamp.UnixTimestamp] = message

    self._onEntryAddedEvent:Fire(message)
end

function History:GetChannelHistory(channel: TextChannel): {[number]: TextChatMessage}
    return self.messages[channel]
end

function History.new()
    local self = setmetatable(History, {})

    self.messages = {} :: {[number]: TextChatMessage}
    self._onEntryAddedEvent = Instance.new("BindableEvent")

    return self
end


return History