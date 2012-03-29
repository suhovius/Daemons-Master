#server receive a file from client
require 'socket'

file = ARGV[0] # full path to file
port = Integer(ARGV[1]) # socket's port

server = TCPServer.open(port)

loop do
  Thread.start(server.accept) do |client|
    #client.puts(Time.now.ctime)
    data = client.read
    destFile = File.open(file, 'wb')
    destFile.print data
    destFile.close
  end
end


