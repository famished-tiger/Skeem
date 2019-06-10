require 'skeem'

def get_skm_filenames()
  names = Dir.entries('.')
  names.select { |fname| fname =~ /\.s[ck]m$/ }
end

get_skm_filenames.each do |skm_file|
  puts "Testing file: #{skm_file}"
  source_code = File.read(skm_file)
  skeem_interpreter = Skeem::Interpreter.new
  skeem_interpreter.run(source_code)
end