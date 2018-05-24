-module(server_tcp).

-export([start_link/0, accept/1]).

-define(PORT, 9000).
-define(TCP_OPTS, [binary, {packet, 4}, {nodelay, true}, {reuseaddr, true}, {active, true}]).

start_link() ->
	case gen_tcp:listen(?PORT, ?TCP_OPTS) of
		{ok, Listen} ->
			spawn(?MODULE, accept, [Listen]);
		Error ->
			io:format("Error: ~p~n", [Error])
	end.

accept(Listen) ->
	{ok, Socket} = gen_tcp:accept(Listen),
	%spawn(client_tcp, loop, [Socket]),
	spawn(?MODULE, accept, [Listen]),
	%accept(Listen).
	client_tcp:loop(Socket).