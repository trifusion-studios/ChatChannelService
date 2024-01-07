--[[
    Sets up ChatChannelService on the client
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ChatChannelService = require(ReplicatedStorage:WaitForChild("ChatChannelService"))

-- Setup on client
ChatChannelService:Setup()