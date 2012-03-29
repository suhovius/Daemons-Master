require 'optparse'
files = Hash.new

option_parser = OptionParser.new do |opts|
  opts.on('-i', '--input FILENAME', 'Input filename - required') do |filename|
    files[:input] = filename
  end
  opts.on('-o', '--output FILENAME', 'Output filename - required') do |filename|
    files[:output] = filename
  end
end

begin
  option_parser.parse!(ARGV)
rescue OptionParser::ParseError
  $stderr.print "Error: " + $! + "\n"
  exit
end

files.keys.each do |key|
  print "#{key}  #{files[key]}\n"
end

