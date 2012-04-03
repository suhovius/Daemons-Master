class UploadSession < ActiveRecord::Base

  STATUS_ACTIVE = "active"
  STATUS_STOPPED = "stopped"
  STATUS_FINISHED = "finished"
  
  RESERVED_PORTS_RANGE = 30000..65535  

  TMPFILES_DIR = "#{::Rails.root}/tmp/upload_sessions"
 
  validates :user_id, :file_checksum, :file_size, :file_name, :event_id, presence: :true

  before_destroy do |upload_session|  
    upload_session.stop
    upload_session.remove_attached_data 
  end
   
  after_create do |upload_session| 
    # Prepare upload folder
    upload_session.make_uploads_folder
    upload_session.update_attribute(:status, UploadSession::STATUS_STOPPED)
  end
   
  def open_tcp_port!
    raise "Can't open tcp port for unsaved upload session!" if self.new_record?
    raise "Port is already open!" if self.status == UploadSession::STATUS_ACTIVE
    free_ports = RESERVED_PORTS_RANGE.to_a - UploadSession.active.map(&:port)
    tcp_port = free_ports[0]
    success = system "ruby #{::Rails.root}/lib/tcp_socket_daemon.rb #{self.tmpfile_fullpath} #{tcp_port} #{self.pidfile_fullpath} &" if tcp_port
    if success
      self.update_attributes(status: UploadSession::STATUS_ACTIVE, port: tcp_port)
    else
      self.update_attributes(status: UploadSession::STATUS_STOPPED, port: nil)
    end
  end
 
  def directory_fullpath
    TMPFILES_DIR + "/#{self.id}"
  end

  def tmpfile_fullpath
    "#{directory_fullpath}/tmpfile"
  end
  
  def pidfile_fullpath
    "#{directory_fullpath}/process.pid"
  end
  
  def get_pid_of_daemon
    Integer(File.open(self.pidfile_fullpath, 'r') { |file| file.read })
  end
  
  def stop
    system "kill -9 #{self.get_pid_of_daemon}" # Kill tcp daemon if it is still alive
    self.update_attributes(status: UploadSession::STATUS_STOPPED, port: nil)
  end

  def start
    self.open_tcp_port!
  end

  scope :active, where(:status => UploadSession::STATUS_ACTIVE)

  def remove_attached_data
    FileUtils.rm_rf self.directory_fullpath
  end
  
  def make_uploads_folder
    Dir.mkdir(TMPFILES_DIR) unless File.directory? TMPFILES_DIR # create dir if it is not exist      
    Dir.mkdir(self.directory_fullpath) unless File.directory? self.directory_fullpath # create dir if it is not exist   
  end
 
end
