#server receive a file from client
require 'socket'

CHUNK_SIZE = 4096 # bytes (4Kb)

file = ARGV[0] # full path to file
port = Integer(ARGV[1]) # socket's port
pid_file = ARGV[2] # full path to pid file
File.open(pid_file, 'w') { |file| file.write Process.pid }

server = TCPServer.open(port)

puts "#{Time.now} TCP Server listening."

client = server.accept
puts "#{Time.now} Receiving binary data."
File.open(file, 'ab') do |file|
  while chunk = client.read(CHUNK_SIZE)
    file.write(chunk)
  end
end

puts "#{Time.now} Connection closed."
File.delete(pid_file)
puts "#{Time.now} Pidfile deleted."

