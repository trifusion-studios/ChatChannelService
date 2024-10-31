--[[
	Adds retry to pcall, allowing for a more safe pcall.
	
	@GGshor
--]]
--!strict

return function(retryLimit: number, delayTime: number, logError: boolean, ...: any): (boolean, ...any)
	local success, response = false, nil
	local tried = 0
	local verbose = false

	-- If no retry limit, use infinite loop
	if retryLimit <= 0 then
		while not success do
			success, response = pcall(...)

			if success then
				return success, response
			elseif verbose then
				task.spawn(error, response) -- Prevents error 
			end

			task.wait(delayTime)
		end

	-- Use limited retry
	else
		while retryLimit >= tried do
			success, response = pcall(...)

			if success then
				return success, response
			else
				tried += 1

				if verbose then
					task.spawn(error, response) -- Prevents error 
				end
			end

			task.wait(delayTime)
		end
	end

	-- Always return success, response
	return success, response
end
