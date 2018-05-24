-module(erl_tcp).
-compile(export_all).

-define (PORT, 9000).
-define (TCP_OPTS, [binary, {packet, 4}, {nodelay, true}, {reuseaddr, true}, {active, false}]).

start_server() ->
	ClientsPid = spawn(?MODULE, clients, [dict:new()]),
	erlang:register(clients_proc, ClientsPid),
	case gen_tcp:listen(?PORT, ?TCP_OPTS) of
		{ok, Listen} ->
			P = spawn(?MODULE, connect, [Listen]),
			clients_proc ! {new, P},
			io:format("Server started.~n");
		Error ->
			io:format("Error: ~p~n", [Error])
	end.

connect(Listen) ->
	{ok, Socket} = gen_tcp:accept(Listen),
	P = spawn(fun() -> connect(Listen) end),
	clients_proc ! {new, P},
	loop(Socket).

loop(Socket) ->
	inet:setopts(Socket, [{active, once}]),
	receive
		{tcp, Socket, Data} ->
			io:format("Data: ~p ~p ~p~n", [inet:peername(Socket), erlang:localtime(), Data]),
			io:format("~n~ts~n", [Data]),
			loop(Socket);
		{tcp_closed, Socket} ->
			io:format("Client disconnected.~n");
			%clients ! {delete, P};
		shutdown ->
			gen_tcp:close(Socket)
	end.

clients(Clients) -> 
	receive
		{new, Pid} ->
			clients(dict:store(Pid, Pid, Clients));
		{delete, Pid} ->
			case dict:find(Pid) of
				{ok, Pid} ->
					clients(dict:erase(Pid, Clients))
			end;
		close_all ->
			lists:foreach(fun({Pid, _}) -> Pid ! shutdown end, dict:to_list(Clients))
	end.