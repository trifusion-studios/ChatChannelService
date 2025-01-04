--[[
	Searches through an array and returns an array of strings that match the search key.

	@GGshor
]]

return function(searchArray: { string }, searchKey: string): { string }
	local found = {}

	for _, value: string in searchArray do
		if
			typeof(value:lower():match(`^{searchKey:lower()}`)) == "string"
			and value:lower():match(`^{searchKey:lower()}`) ~= ""
		then
			table.insert(found, value)
		end
	end

	return found
end
