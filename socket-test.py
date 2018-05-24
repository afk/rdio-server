import socket
import struct

sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
server_address = ('localhost', 9000)
sock.connect(server_address)

#values = (2, 'a')
#packer = struct.Struct('!Is')
#packed_data = packer.pack(*values)
s = 'testö🌟'
s = s.encode('utf-8')
packed_data = struct.pack("!I", len(s)) + s
#packed_data = struct.pack("!IB", len(s) + 1, 1) + s
sock.sendall(packed_data)

try:
	pass
    #sock.sendall(packed_data)
finally:
    sock.close()
