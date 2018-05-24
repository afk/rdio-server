-module(client_tcp).

-export([loop/1]).

loop(Socket) ->
	receive
		{tcp, Socket, Data} ->
			case Data of
				% check who connected -> message to client module
				<<1, Token/binary>> ->
					client:hello(Token, self());
				% subscribe to channel
				<<2, Rest/binary>> ->
					[Token, Channel] = string:split(Rest, "\n");
				Got ->
					io:format("Got ~p", [Got])
			end,
			loop(Socket);
		{msg_to_channel, Channel, Msg} ->
			ChannelB = list_to_binary(Channel),
			MsgB = list_to_binary(Msg),
			Data = <<3, ChannelB/binary, "\n", MsgB/binary>>,
			gen_tcp:send(Socket, Data),
			loop(Socket);
		{msg, Body} ->
			gen_tcp:send(Socket, Body),
			loop(Socket);
		{tcp_closed, Socket} ->
			io:format("Client disconnected.~n");
		shutdown ->
			gen_tcp:close(Socket)
	end.