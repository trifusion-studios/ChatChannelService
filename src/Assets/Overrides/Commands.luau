--[[
    Overrides the Roblox default commands.

    Template:
        ["Command Instance Name"] = Trigger function
]]

local Players = game:GetService("Players")
local Teams = game:GetService("Teams")

return {
	["RBXClearCommand"] = function(self)
		self.ChannelHistory:ClearChannelHistory(self.currentChannel.channel)
		return
	end,
	["RBXTeamCommand"] = function(self)
		if Players.LocalPlayer.Team == nil or Teams:FindFirstChild(Players.LocalPlayer.Team.Name) == nil then
			return
		end

		for name, channel in self.Channels do
			if name:lower() == Players.LocalPlayer.Team.Name:lower() then
				self:SwitchChannel(channel)
				break
			end
		end
	end,
}
