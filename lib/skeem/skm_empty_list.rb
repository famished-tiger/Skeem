require 'singleton'
require_relative 'skm_element'

module Skeem
  # From R7RS: The empty list is a special object of its own type. 
  # It is not a pair, it has no elements, and its length is zero.
  class SkmEmptyList < SkmElement
    include Singleton

    def list?
      true
    end

    def null?
      true
    end
    
    def pair?
      false
    end
    
    def length
      0
    end
    
    def empty?
      true
    end
    
    def verbatim?
      true
    end
    
    def skm_equal?(other)
      equal?(other)
    end
    
    def to_a
      []
    end    

    def evaluate(_runtime)
      self
    end

    def quasiquote(_runtime)
      self
    end

    # Part of the 'visitee' role in Visitor design pattern.
    # @param _visitor [SkmElementVisitor] the visitor
    def accept(aVisitor)
      aVisitor.visit_empty_list(self)
    end

    protected

    def inspect_specific
      '()'
    end

    private

    def initialize()
      super(0)
      self.freeze
    end
  end # class
end # module
