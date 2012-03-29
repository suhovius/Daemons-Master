require 'daemons'

full_base_path = File.dirname(File.expand_path(__FILE__))

daemon_name = ARGV[1]
port = Integer(ARGV[2])
TEMP_FILE_NAME = 'tmpfile'
SCRIPT_FILE_NAME = 'server.rb'

dir = full_base_path + '/tmp/uploads/' + daemon_name
Dir.mkdir(dir) unless File.directory? dir # create dir if it is not exist
full_tempfile_name = dir + '/' + TEMP_FILE_NAME

script_file_and_options = full_base_path + "/#{SCRIPT_FILE_NAME} #{full_tempfile_name} #{port}"
File.open(dir + "/#{daemon_name}.port", 'w') {|f| f.write(port) }

Daemons.run_proc(
   daemon_name, # name of daemon
   dir_mode: :normal, # absolute path to dir
   dir: dir, # dir for pid files
#   keep_pid_files: false,   
   log_output: true
 ) do
   exec "ruby #{script_file_and_options}"
end

