#client sends file to server
require 'socket'

host = 'localhost'
port = ARGV[0]
sock = TCPSocket.open(host, port)

file = open('send_me.mp4', "rb")
fileContent = file.read
sock.puts(fileContent)
sock.close
