export type CustomSignal<T...> = {
	Connect: (self: CustomSignal<T...>, callback: (T...) -> ()) -> RBXScriptConnection,
	ConnectParallel: (self: CustomSignal<T...>, callback: (T...) -> ()) -> RBXScriptConnection,
	Once: (self: CustomSignal<T...>, T...) -> RBXScriptConnection,
	Wait: (self: CustomSignal<T...>) -> T...,
}

export type ChannelChangedMessage  = "CLEARED" | "REMOVED" | TextChatMessage

export type ChannelChangedCallbackArgs = {
	message: ChannelChangedMessage,
	changedChannel: TextChannel?
}

export type History = {
	new: () -> HistoryObject,
}

-- Holds entries
export type HistoryObject = {
	messages: {
		[TextChannel]: {
			[number]: TextChatMessage,
		},
	},

	AddEntry: (self: HistoryObject, message: TextChatMessage) -> (),
	GetChannelHistory: (self: HistoryObject, channel: TextChannel) -> { [number]: TextChatMessage },
	ClearChannelHistory: (self: HistoryObject, channel: TextChannel) -> (),
	RemoveChannel: (self: HistoryObject, channel: TextChannel) -> (),

	ChannelChanged: CustomSignal<ChannelChangedCallbackArgs>,
	-- ChannelChangedV1: (
	-- 	self: HistoryObject,
	-- 	callback: (message: ChannelChangedMessage, changedChannel: TextChannel?) -> ()
	-- ) -> RBXScriptConnection,
}

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
	ChannelHistory: HistoryObject,

	--[[
		Creates the custom chat UI and returns a success boolean
	]]
	SetupUI: (self: ChatChannelService) -> boolean,

	AddChannel: (self: ChatChannelService, channel: TextChannel, customName: string?) -> Channel,
	RemoveChannel: (self: ChatChannelService, channel: TextChannel) -> (),
	SwitchChannel: (self: ChatChannelService, channel: TextChannel) -> (),
	AddCommand: (self: ChatChannelService, Command: TextChatCommand) -> (),

	Setup: (self: ChatChannelService) -> (),
}

return {}