-module(client).
-export([hello/2, subscribe/1, loop/2]).

hello(Token, ConnectorPid) ->
	P = spawn(?MODULE, loop, [Token, ConnectorPid]),
	channels ! {hello, Token, P},
	ok.

subscribe(Channel) ->
	channels ! {subscribe, Channel, spawn(client, loop, [])}.

loop(Token, ConnectorPid) ->
	receive
		{msg, Body} ->
			ConnectorPid ! {msg, Body};
		{msg, Channel, Body} ->
			io:format("Message in Channel *~ts*: ~ts~n", [Channel, Body]),
			loop(Token, ConnectorPid)
	end.