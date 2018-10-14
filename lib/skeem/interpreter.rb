require_relative 'parser'
require_relative 'environment'
require_relative 'runtime'
require_relative './primitive/primitive_builder'

module Skeem
  class Interpreter
    include Primitive::PrimitiveBuilder
    attr_reader(:parser)
    attr_reader(:runtime)

    def initialize()
      @runtime = Runtime.new(Environment.new)
      add_primitives(runtime)
      add_standard(runtime)
    end

    def run(source)
      @parser ||= Parser.new
      @ptree = parser.parse(source)
      # $stderr.puts @ptree.root.inspect
      return @ptree.root.evaluate(runtime)
    end
    
    def fetch(anIdentifier)
      runtime.environment.fetch(anIdentifier)
    end

    private

    def add_standard(aRuntime)
      std_pathname = File.dirname(__FILE__) + '/standard/base.skm'
      load_lib(std_pathname)
    end

    def load_lib(aPathname)
      lib_source = nil
      File.open(aPathname, 'r') do |lib|
        lib_source = lib.read
        run(lib_source)
      end
    end
  end # class
end # module