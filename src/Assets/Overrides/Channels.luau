--[[
    Overrides the Roblox default channels name.

    Template:
        ["Channel match format"] = NewName funcion
]]
--!strict

local Players = game:GetService("Players")
local Teams = game:GetService("Teams")

local Types = require(script.Parent.Parent.Parent:WaitForChild("Utils"):WaitForChild("Types"))

local function FindPlayerByUserId(userid: number?): Player?
	for _, player: Player in Players:GetPlayers() do
		if player.UserId == userid then
			return player
		end
	end

	return nil
end

local function GetTeamFromColor(color: BrickColor): Team?
	for _, team: Team in Teams:GetTeams() do
		if (team :: Team).TeamColor == color then
			return team
		end
	end

	return nil
end

return {
	["Whisper:"] = function(_, name: string)
		local newName = ""
		local split = name:gsub("Whisper:", ""):split("_")
		local possibleTarget = FindPlayerByUserId(tonumber(split[2]))

		-- Prevent target from being local player
		if possibleTarget == Players.LocalPlayer then
			possibleTarget = FindPlayerByUserId(tonumber(split[1]))
			newName = possibleTarget and possibleTarget.Name or "Whisper"
		elseif possibleTarget and possibleTarget ~= Players.LocalPlayer then
			newName = possibleTarget.Name
		end

		return newName
	end,
	["Team"] = function(_, name: string)
		local newName = ""
		local teamColor = name:gsub("Team", ""):split()[1]
		local brickColor = BrickColor.new(teamColor)
		local possibleTeam = GetTeamFromColor(brickColor)

		if possibleTeam then
			newName = possibleTeam.Name
		else
			newName = "Team" -- Failsafe in case brick color fails
		end

		return newName
	end,
} :: { [string]: (self: Types.ChatChannelServiceClient, name: string) -> string }
