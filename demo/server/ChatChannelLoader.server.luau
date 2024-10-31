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
local Teams = game:GetService("Teams")

-- Initialize server side of ChatChannelService
require(ReplicatedStorage:WaitForChild("ChatChannelService")):Setup()

-- Wait for custom channels folder
local ChatChannels = TextChatService:WaitForChild("ChatChannels")

-- Create the custom channel
local Moderators = Instance.new("TextChannel")
Moderators.Name = "Moderators"

local ModeratorsTeam = Instance.new("Team")
ModeratorsTeam.Name = "Mod+"
ModeratorsTeam.AutoAssignable = false
ModeratorsTeam.TeamColor = BrickColor.Black()
ModeratorsTeam.Parent = Teams

-- Add a custom color to the prefix
Moderators:SetAttribute("ChatColor", Color3.fromHex("#00f7ad"))

-- Parent channel
Moderators.Parent = ChatChannels

-- Add players to it
local function AddPlayerToModerator(player: Player)
	if player:GetRankInGroup(Configuration.GroupId) >= Configuration.MinimumRank then
		Moderators:AddUserAsync(player.UserId)
	end

	task.wait(5)
	player.Team = ModeratorsTeam
	player.TeamColor = ModeratorsTeam.TeamColor
end

-- Make sure all players get added
Players.PlayerAdded:Connect(AddPlayerToModerator)
for _, player: Player in Players:GetPlayers() do
	task.spawn(AddPlayerToModerator, player)
end