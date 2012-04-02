#client sends file to server
require 'socket'

CHUNK_SIZE = 4096 # bytes (4Kb)

file_name = ARGV[0]
port = Integer(ARGV[1])
host = 'localhost'
upload_session_id = Integer(ARGV[2])
start_chunk = Integer(ARGV[3])
end_chunk = Integer(ARGV[4])


TCPSocket.open(host, port) do |socket|
  File.open(file_name, 'rb') do |file|
    chunks_count = (file.size.to_f / CHUNK_SIZE).ceil
    puts "Total chunks count is #{chunks_count}. Chunk size is #{CHUNK_SIZE} bytes"
    puts "Chunks between #{start_chunk}..#{end_chunk} are set for transfer"
    puts "Upload session ID #{upload_session_id}"
    current_chunk_number = 0
    puts "Transfered chunks numbers: "
    while chunk = file.read(CHUNK_SIZE)
      current_chunk_number += 1
      if (start_chunk..end_chunk).include? current_chunk_number
        print "#{current_chunk_number} "
        socket.puts(upload_session_id)
        socket.write(chunk)
      end
    end
  end
end
puts "\nEnd of transfer"
