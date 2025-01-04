export type CustomSignal<T...> = {
	Connect: (self: CustomSignal<T...>, callback: (T...) -> ()) -> RBXScriptConnection,
	ConnectParallel: (self: CustomSignal<T...>, callback: (T...) -> ()) -> RBXScriptConnection,
	Once: (self: CustomSignal<T...>, T...) -> RBXScriptConnection,
	Wait: (self: CustomSignal<T...>) -> T...,
}

export type ChannelChangedMessage  = "CLEARED" | "REMOVED" | TextChatMessage

export type History = {
	messages: {
		[TextChannel]: {
			[number]: TextChatMessage,
		},
	},

	AddEntry: (self: History, message: TextChatMessage) -> (),
	GetChannelHistory: (self: History, channel: TextChannel) -> { [number]: TextChatMessage },
	ClearChannelHistory: (self: History, channel: TextChannel) -> (),
	RemoveChannel: (self: History, channel: TextChannel) -> (),

	ChannelChanged: CustomSignal<ChannelChangedMessage, TextChannel?>,

	-- Internal properties
	_onChannelChangedEvent: BindableEvent,
}

export type Channel = {
	name: string,
	selected: boolean,
	unread: boolean,
	unreadTween: Tween?,
	instance: TextButton,
	color: Color3?,
	channel: TextChannel,

	SetSelected: (selected: boolean) -> (),
	Destroy: () -> nil,

	Activated: CustomSignal<InputObject, number>,
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
	ChannelHistory: History,

	SetupUI: (self: ChatChannelService) -> boolean,

	AddChannel: (self: ChatChannelService, channel: TextChannel, customName: string?) -> Channel,
	RemoveChannel: (self: ChatChannelService, channel: TextChannel) -> (),
	SwitchChannel: (self: ChatChannelService, channel: TextChannel) -> (),
	AddCommand: (self: ChatChannelService, Command: TextChatCommand) -> (),

	Setup: (self: ChatChannelService) -> (),
}

return {}