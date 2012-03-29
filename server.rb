#server receive a file from client
require 'socket'
require 'timeout'

CHUNK_SIZE = 4096 # bytes (4Kb)

file = ARGV[0] # full path to file
port = Integer(ARGV[1]) # socket's port
server = TCPServer.open(port)
client = server.accept
File.open(file, 'ab') do |file|
  while chunk = client.read(CHUNK_SIZE)
    file.write(chunk)
  end
end

