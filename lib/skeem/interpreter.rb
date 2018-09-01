require_relative 'parser'

module Skeem
  class Interpreter
    attr_reader(:parser)
    
    def initialize()
    end
    
    def run(source)
      @parser ||= Parser.new
      @ptree = parser.parse(source)
      return @ptree.root.interpret
    end
  end # class
end # module