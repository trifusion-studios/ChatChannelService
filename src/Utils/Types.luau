export type CustomSignal<T...> = {
	Connect: (self: CustomSignal<T...>, callback: (T...) -> ()) -> RBXScriptConnection,
	ConnectParallel: (self: CustomSignal<T...>, callback: (T...) -> ()) -> RBXScriptConnection,
	Once: (self: CustomSignal<T...>, T...) -> RBXScriptConnection,
	Wait: (self: CustomSignal<T...>) -> T...,
}

export type ChannelChangedMessage = "CLEARED" | "REMOVED" | TextChatMessage

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
	uiInstance: ImageButton,
	textChannel: TextChannel,

	SetSelected: (selected: boolean) -> (),
	Destroy: () -> nil,

	Activated: RBXScriptSignal,
	TextLabelChanged: RBXScriptConnection,
}

export type ChatChannelServiceClient = {
	Debug: boolean,
	Channels: { [string]: Channel },
	ChannelHistory: History,

	SetupUI: (self: ChatChannelServiceClient, overrideTheme: {}?) -> boolean,

	AddChannel: (self: ChatChannelServiceClient, channel: TextChannel, customName: string?) -> Channel,
	RemoveChannel: (self: ChatChannelServiceClient, channel: Channel) -> (),
	SwitchChannel: (self: ChatChannelServiceClient, channel: Channel) -> (),

	Setup: (self: ChatChannelServiceClient, overrideUI: ModuleScript?) -> (),

	-- Internal properties
	ui: ScreenGui,
	root: Frame,

	currentChannel: Channel?,

	channelList: Frame,
	channelScroll: ScrollingFrame,
}

export type ChatChannelServiceServer = {
	Debug: boolean,
	Loaded: BoolValue,

	Setup: (self: ChatChannelServiceServer) -> (),
}

export type ChatChannelService = ChatChannelServiceClient & ChatChannelServiceServer

return {}
