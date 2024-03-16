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

	OnTriggered: (
		callback: (self: ChatChannelService, originTextSource: TextSource, unfilteredText: string) -> ()
	) -> (),
}

export type ChatChannelService = {
	Debug: boolean,
	Channels: { [string]: Channel },
	Commands: {},
	ChannelHistory: History.HistoryObject,

	SetupUI: (self: ChatChannelService) -> (),
	AddChannel: (self: ChatChannelService, channel: TextChannel, customName: string?) -> Channel,
	RemoveChannel: (self: ChatChannelService, channel: TextChannel) -> (),
	SwitchChannel: (self: ChatChannelService, channel: TextChannel) -> (),

	Setup: (self: ChatChannelService) -> (),
}

return nil
