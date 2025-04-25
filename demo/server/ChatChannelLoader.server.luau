--[[
	Adds moderator channel to users above certain rank
]]

local Configuration = {
	GroupId = 10775756,
	MinimumRank = 6,
}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Teams = game:GetService("Teams")

-- Initialize server side of ChatChannelService
require(ReplicatedStorage:WaitForChild("ChatChannelService")):Setup()

-- Create the custom team
local ModeratorsTeam = Instance.new("Team")
ModeratorsTeam.Name = "Mod+"
ModeratorsTeam.AutoAssignable = false
ModeratorsTeam.Parent = Teams

-- Add a custom color to the prefix
ModeratorsTeam.TeamColor = BrickColor.new(Color3.fromHex("#00f7ad"))

-- Add players to it
local function AddPlayerToModerator(player: Player)
	if player:GetRankInGroup(Configuration.GroupId) >= Configuration.MinimumRank then
		player.Team = ModeratorsTeam
		player.TeamColor = ModeratorsTeam.TeamColor
	end
end

-- Make sure all players get added
Players.PlayerAdded:Connect(AddPlayerToModerator)
for _, player: Player in Players:GetPlayers() do
	task.spawn(AddPlayerToModerator, player)
end
