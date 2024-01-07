--[[
	Adds retry to pcall, allowing for a more safe pcall.
	
	@GGshor
--]]
--!strict

return function(retryLimit: number, delayTime: number, ...:any): (boolean, ...any)
	local success, response = false, nil
	local tried = 0
	
	-- If no retry limit, use infinite loop
	if retryLimit <= 0 then
		while not success do
			success, response = pcall(...)

			if success then
				return success, response
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
			end

			task.wait(delayTime)
		end
	end
	
	-- Always return success, response
	return success, response
end