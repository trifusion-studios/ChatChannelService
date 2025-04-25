local Types = require(script.Parent.Types)

return function(channels: { [string]: Types.Channel })
	local sortedChannels: { Types.Channel } = {}

	-- Go from table to array for easier sorting
	for _, channel: Types.Channel in channels do
		table.insert(sortedChannels, channel)
	end

	table.sort(sortedChannels, function(a: Types.Channel, b: Types.Channel): boolean
		-- Define RBXGeneral priority
		if a.textChannel.Name == "RBXGeneral" then
			return true
		end
		if a.textChannel.Name == "RBXGeneral" then
			return false
		end

		-- RBX-prefixed entries come after RBXGeneral
		local aIsRBX = a.textChannel.Name:sub(1, 3) == "RBX"
		local bIsRBX = b.textChannel.Name:sub(1, 3) == "RBX"

		if aIsRBX and bIsRBX then
			return a.textChannel.Name < b.textChannel.Name -- sort RBX entries alphabetically
		elseif aIsRBX then
			return true -- RBX comes before non-RBX
		elseif bIsRBX then
			return false -- non-RBX comes after RBX
		else
			return a.textChannel.Name < b.textChannel.Name -- sort non-RBX entries alphabetically
		end
	end)

	return sortedChannels
end
