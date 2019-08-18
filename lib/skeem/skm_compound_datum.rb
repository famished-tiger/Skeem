# frozen_string_literal: true

require 'forwardable'
require_relative 'skm_element'

module Skeem
  # Abstract class.
  class SkmCompoundDatum < SkmElement
    extend Forwardable

    attr_accessor(:members)
    alias children members

    def_delegators :@members, :each, :first, :last, :length, :empty?, :size
    alias to_a members

    def initialize(theMembers)
      super(nil)
      @members = theMembers.nil? ? [] : theMembers
    end

    def ==(other)
      return true if equal?(other)

      result = case other
        when SkmCompoundDatum
          self.class == other.class && members == other.members
        when Array
          members == other
      end
      result
    end

    alias eqv? equal?
    alias skm_equal? ==

    def verbatim?
      found = members.find_index { |elem| !elem.verbatim? }
      found ? false : true
    end

    def evaluate(aRuntime)
      members_eval = members.map { |elem| elem.evaluate(aRuntime) }
      self.class.new(members_eval)
    end

    # Return this object un-evaluated.
    # Reminder: As terminals are atomic, there is no need to launch a visitor.
    # @param aRuntime [Skeem::Runtime]
    def quasiquote(aRuntime)
      quasi_members = members.map { |elem| elem.quasiquote(aRuntime) }
      self.class.new(quasi_members)
    end

    def quoted!
      members.each(&:quoted!)
    end

    def unquoted!
      members.each(&:unquoted!)
    end

    # Part of the 'visitee' role in Visitor design pattern.
    # @param aVisitor [SkmElementVisitor] the visitor
    def accept(aVisitor)
      aVisitor.visit_compound_datum(self)
    end

    protected

    def inspect_specific
      result = +''
      members.each { |elem| result << elem.inspect + ', ' }
      result.sub!(/, $/, '')
      result
    end
  end # class

  class SkmVector < SkmCompoundDatum
    def vector?
      true
    end
  end # class
end # module
