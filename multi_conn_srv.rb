#server receive a file from client
require 'socket'

CHUNK_SIZE = 4096 # bytes (4Kb)

full_base_path = File.dirname(File.expand_path(__FILE__))

port = Integer(ARGV[0]) # socket's port
pid_file = ARGV[1] || "daemon.pid" # full path to pid file
File.open(pid_file, 'w') { |file| file.write Process.pid }

server = TCPServer.open(port)

puts "#{Time.now} TCP Server listening."

loop do
  Thread.start(server.accept) do |client|
    puts "#{Time.now} Receiving binary data."
    while upload_session_id = client.readline.chomp and chunk = client.read(CHUNK_SIZE)
      puts "#{Time.now} Write data chunk #{CHUNK_SIZE} Kb to file:\n\t #{full_base_path}/tmp/uploads/#{upload_session_id}/tmpfile"
      File.open("#{full_base_path}/tmp/uploads/#{upload_session_id}/tmpfile", 'ab') { |file| file.write(chunk) }
    end
    puts "#{Time.now} Connection closed."
  end
end
