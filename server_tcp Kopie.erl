-module(server_tcp).

-behaviour(gen_server).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

%% API
-export([start_link/1]).

-define(PORT, 9000).
-define(TCP_OPTS, [binary, {packet, 4}, {nodelay, true}, {reuseaddr, true}, {active, false}]).

start_link() ->
	gen_server:start_link(?MODULE, [], []).

%% gen_server callbacks
init([]) ->
	case gen_tcp:listen(?PORT, ?TCP_OPTS) of
		{ok, Listen} ->
			spawn(?MODULE, accept, [Listen]);
		Error ->
			io:format("Error: ~p~n", [Error])
	end.
	{ok, Listen}.

handle_call(_Request, _From, Socket) ->
	Reply = ok,
	{reply, Reply, Socket}.

handle_cast(_Msg, Socket) ->
	{noreply, Socket}.

handle_info({msg_in_channel, Channel, Msg}, Socket) ->
	Data = [Channel, Msg],
	gen_tcp:send(Socket, Data),
	{noreply, Socket};

handle_info(_Info, Socket) ->
	{noreply, Socket}.

terminate(_Reason, _Socket) ->
	ok.

code_change(_OldVsn, Socket, _Extra) ->
	{ok, Socket}.

%% internal functions
accept(Listen) ->
	{ok, Socket} = gen_tcp:accept(Listen),
	gen_server:cast(Server, {accepted, self()}),