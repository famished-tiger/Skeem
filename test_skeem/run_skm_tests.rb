# frozen_string_literal: true

require 'skeem'

def skm_filenames
  names = Dir.entries('.')
  names.grep(/\.s[ck]m$/)
end

skm_filenames.each do |skm_file|
  puts "Testing file: #{skm_file}"
  source_code = File.read(skm_file)
  skeem_interpreter = Skeem::Interpreter.new
  skeem_interpreter.run(source_code)
end
