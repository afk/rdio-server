-module(channels).
-export([start/0]).

start() ->
	register(channels, spawn(fun() -> loop([]) end)).

loop(Channels) ->
	receive
		{hello, Token, Pid} ->
			Pid ! {msg, "Hello, world!"};
		{join, Channel, Pid} ->
			%case lists:keysearch(Channel, 1, Channels) of
			%	false ->
					NewChannels = Channels ++ [{Channel, Pid}],
					loop(NewChannels);
			%end;
		{msg, Channel, Body} ->
			msg(Channels, Channel, Body),
			loop(Channels)
	end.

msg(Channels, ChannelTo, Body) ->
	[Pid ! {msg, Channel, Body} || {Channel, Pid} <- Channels, Channel =:= ChannelTo].