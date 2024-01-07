--[[
    Sets up ChatChannelService on the server
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ChatChannelService = require(ReplicatedStorage:WaitForChild("ChatChannelService"))

-- Setup on server
ChatChannelService:Setup()