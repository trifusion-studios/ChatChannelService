# ChatChannelService
ChatChannelService is a service module that adds the channel UI back to the Roblox chat UI.

## Installation
Add the `ChatChannelService` module to the `ReplicatedStorage` service.
Run `:Setup()` on both the client and the server to set up the module.

## Usage
To use `ChatChannelService`, simply add your own channels to the `ChatChannels` folder in the `TextChatService` service.

## Examples
Here is an example of how to set up ChatChannelService:

```lua
-- On the client and server
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ChatChannelService = require(ReplicatedStorage:WaitForChild("ChatChannelService"))

ChatChannelService:Setup()
```

Here are the steps of how to add a channel to `ChatChannelService`:

1. Create a new `TextChannel` instance in the `ChatChannels` folder in the `TextChatService` service.
2. Set the `Name` property of the channel instance to the desired name of the channel.

Here is an example of how to create and add a channel to ChatChannelService:
```lua
-- On the server
local TextChatService = game:GetService("TextChatService")
local ChatChannels = TextChatService:WaitForChild("ChatChannels")

-- Create a new channel instance
local myChannel = Instance.new("TextChannel")
myChannel.Name = "My Channel"

-- Add the channel to the ChatChannels folder
myChannel.Parent = ChatChannels
```

This will create a new public channel called "My Channel".

## Contribute
To contribute to the project, please follow these guidelines:
- Fork this repository
- Make your changes (keep it clean!)
- Submit a pull request with a detailed description of what you changed/added