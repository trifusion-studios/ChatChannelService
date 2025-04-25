--[[
    Adds channels to the roblox chat.
]]
--!strict

local TextChatService = game:GetService("TextChatService")

local Types = require(script.Parent:WaitForChild("Utils"):WaitForChild("Types"))

local ChatChannelServiceServer = {
	Debug = false,
	Loaded = script.Parent:WaitForChild("Loaded"),
} :: Types.ChatChannelServiceServer

--[=[
	Prints out the message if debug is enabled.

	@param ... any -- The messages you want to send
]=]
local function DebugPrint(...: any): ()
	if ChatChannelServiceServer.Debug == true then
		local finalString = "[ChatChannelServiceServer]"
		for _, object in { ... } do
			finalString = `{finalString} {tostring(object)}`
		end
		finalString = `{finalString}\n{debug.traceback()}`
		print(finalString)
	end
end

function ChatChannelServiceServer.Setup(self: Types.ChatChannelServiceServer): ()
	DebugPrint("Setting up custom channel and commands folder...")

	local ChatChannels = Instance.new("Folder")
	ChatChannels.Name = "ChatChannels"
	ChatChannels.Parent = TextChatService

	local ChatCommands = Instance.new("Folder")
	ChatCommands.Name = "ChatCommands"
	ChatChannels.Parent = TextChatService

	self.Loaded.Value = true
	DebugPrint("Setup done!")
end

return ChatChannelServiceServer
