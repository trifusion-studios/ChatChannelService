local TextChatService = game:GetService("TextChatService")
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

    OnEntryAdded: (self: HistoryObject, callback: (message: TextChatMessage) -> ()) -> RBXScriptConnection
}


local History = {} :: History
History.__index = History


function History:OnEntryAdded(callback: (message: TextChatMessage) -> ()): RBXScriptConnection
    return self._onEntryAddedEvent:Connect(callback)
end

function History:AddEntry(message: TextChatMessage)
    self.messages[message.TextChannel][message.Timestamp] = message

    self._onEntryAddedEvent:Fire(message)
end

function History.new()
    local self = setmetatable(History, {})

    self.messages = {} :: {[number]: TextChatMessage}
    self._onEntryAddedEvent = Instance.new("BindableEvent")

    return self
end


return History