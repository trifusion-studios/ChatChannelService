--[[
    Merges the new theme with the default one

    @GGshor
]]

-- Merges tables
local function MergeTables(originalTable: {}, newTable: {})
	local mergedTable = originalTable

	for k, v in pairs(newTable) do
		if type(v) == "table" and type(mergedTable[k]) == "table" then
			mergedTable[k] = MergeTables(mergedTable[k], v) -- Recursively merge nested tables
		else
			mergedTable[k] = v -- Assign non-table values directly
		end
	end

	return mergedTable
end

return function(DefaultTheme: {}, NewTheme: {}): {}
    return MergeTables(DefaultTheme, NewTheme)
end
