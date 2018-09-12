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
    end
    
    def run(source)
      @parser ||= Parser.new
      @ptree = parser.parse(source)
      return @ptree.root.evaluate(runtime)
    end
  end # class
end # module