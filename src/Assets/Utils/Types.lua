local History = require(script.Parent:WaitForChild("History"))

export type Channel = {
	name: string,
	selected: boolean,
	unread: boolean,
	unreadTween: Tween?,
	instance: TextButton,
	color: Color3?,
	channel: TextChannel,

	OnSelected: (selected: boolean) -> (),
	OnMessage: () -> (),
	Destroy: () -> nil,

	OnActivated: (callback: (inputObject: InputObject, clickCount: number) -> ()) -> RBXScriptConnection,
}

export type Command = {
	AutocompleteVisible: boolean,
	Enabled: boolean,

	PrimaryAlias: string,
	SecondaryAlias: string,
}

export type ChatChannelService = {
	Debug: boolean,
	Channels: { [string]: Channel },
	Commands: { [string]: Command },
	ChannelHistory: History.HistoryObject,

	SetupUI: (self: ChatChannelService) -> (),
	AddChannel: (self: ChatChannelService, channel: TextChannel, customName: string?) -> Channel,
	RemoveChannel: (self: ChatChannelService, channel: TextChannel) -> (),
	SwitchChannel: (self: ChatChannelService, channel: TextChannel) -> (),
	AddCommand: (self: ChatChannelService, Command: TextChatCommand) -> (),

	Setup: (self: ChatChannelService) -> (),
}

return nil
