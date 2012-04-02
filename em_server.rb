require 'eventmachine'

CHUNK_SIZE = 4096 # Kb
PORT = 7000 

module UploadServer

  def post_init
    log_string("Connection esablished")
  end
=begin
  def receive_data data
    upload_session_id, chunk = data.split("\n")
    File.open(uploads_path_for(upload_session_id), 'ab') { |file| file.write(chunk) }
    log_string("Upload to #{uploads_path_for(upload_session_id)}")   
  end
=end
  def receive_data(data)  
    @buf << data  
    while line = @buf.slice!(/(.+)\r?\n/)  
      send_data "You said: #{line}\n"  
    end
  end

  def unbind
    log_string("Connection closed")
  end
  
  def uploads_path_for(upload_session_id)
    "#{File.dirname(File.expand_path(__FILE__))}/tmp/uploads/#{upload_session_id}/tmpfile"
  end
  
  def log_string(string)
    "#{Time.now} #{string}"
  end

end

EventMachine::run {
  EventMachine::start_server "127.0.0.1", PORT, UploadServer
}
