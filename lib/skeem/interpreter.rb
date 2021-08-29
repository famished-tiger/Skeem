# frozen_string_literal: true

require_relative 'parser'
require_relative 'skm_frame'
require_relative 'runtime'
require_relative './primitive/primitive_builder'

module Skeem
  class Interpreter
    include Primitive::PrimitiveBuilder
    attr_reader(:parser)
    attr_reader(:runtime)

    def initialize
      @runtime = Runtime.new(SkmFrame.new)
      @parser = Parser.new

      if block_given?
        yield self
      else
        add_default_procedures
      end
    end

    def add_default_procedures
      add_primitives(runtime)
      add_standard(runtime)
    end

    def parse(source, _mode = nil)
      @parser ||= Parser.new
      @ptree = parser.parse(source)
      # $stderr.puts @ptree.root.inspect if _mode.nil?
      # require 'debug' unless _mode.nil?
    end

    def run(source, mode = nil)
      parse(source, mode)
      # require 'debug' unless mode.nil?
      @ptree.root.evaluate(runtime)
    end

    def fetch(anIdentifier)
      runtime.environment.fetch(anIdentifier)
    end

    def add_standard(_runtime)
      std_pathname = "#{File.dirname(__FILE__)}/standard/base.skm"
      load_lib(std_pathname)
    end

    private

    def load_lib(aPathname)
      lib_source = nil
      File.open(aPathname, 'r') do |lib|
        lib_source = lib.read
        run(lib_source, :silent)
      end
    end
  end # class
end # module
