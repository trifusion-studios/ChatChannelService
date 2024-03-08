--[[
  Adds moderator channel to users above certain rank
]]

local Configuration = {
	GroupId = 10775756,
	MinimumRank = 6,
}

local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Create the custom channels folder
local ChatChannels = Instance.new("Folder")
ChatChannels.Name = "ChatChannels"
ChatChannels.Parent = TextChatService

-- Create the custom channel
local Moderators = Instance.new("TextChannel")
Moderators.Name = "Moderators"

-- Add a custom color to the prefix
Moderators:SetAttribute("ChatColor", Color3.fromHex("#00f7ad"))

-- Parent channel
Moderators.Parent = ChatChannels

-- Add players to it
local function AddPlayerToModerator(player: Player)
	if player:GetRankInGroup(Configuration.GroupId) >= Configuration.MinimumRank then
		Moderators:AddUserAsync(player.UserId)
	end
end

-- Make sure all players get added
Players.PlayerAdded:Connect(AddPlayerToModerator)
for _, player: Player in Players:GetPlayers() do
	task.spawn(AddPlayerToModerator, player)
end

-- Initialize server side of ChatChannelService
require(ReplicatedStorage:WaitForChild("ChatChannelService")):Setup()
