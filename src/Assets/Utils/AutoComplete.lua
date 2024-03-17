return function(searchTable: { string }, searchKey: string): { string }
	-- Searches through searchTable and finds anything that matches the searchKey
	local found = {}

	for _, value: string in searchTable do
		if
			typeof(value:lower():match(`^{searchKey:lower()}`)) == "string"
			and value:lower():match(`^{searchKey:lower()}`) ~= ""
		then
			table.insert(found, value)
		end
	end

	return found
end
