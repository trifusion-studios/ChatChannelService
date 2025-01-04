--[[
    Adds channels to the roblox chat.
]]

local RunService = game:GetService("RunService")

local Types = require(script:WaitForChild("Utils"):WaitForChild("Types"))

local ChatChannelService: Types.ChatChannelService

-- Set ChatChannelService to it's respected side
if RunService:IsServer() == true then
	ChatChannelService = script:WaitForChild("Server")
else
	ChatChannelService = script:WaitForChild("Client")
end

return ChatChannelService