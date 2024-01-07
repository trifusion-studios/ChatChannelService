--[[
    Sets up ChatChannelService on the server
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")

local ChatChannelService = require(ReplicatedStorage:WaitForChild("ChatChannelService"))

local ChatChannels = Instance.new("Folder")
ChatChannels.Name = "ChatChannels"
ChatChannels.Parent = TextChatService

-- Setup on server
ChatChannelService:Setup()

-- Create custom channel
local Moderators = Instance.new("TextChannel")
Moderators.Name = "Moderators"

-- Add custom color to the prefix
Moderators:SetAttribute("ChatColor", Color3.fromHex("#00f7ad"))

-- Parent channel
Moderators.Parent = ChatChannels

-- Add players to it
local function AddPlayerToModerator(player: Player)
    Moderators:AddUserAsync(player.UserId)
end

-- Make sure all players get added
Players.PlayerAdded:Connect(AddPlayerToModerator)
for _, player: Player in Players:GetPlayers() do
    task.spawn(AddPlayerToModerator, player)
end