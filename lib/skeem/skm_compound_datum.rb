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
      return true if self.equal?(other)
      result = case other
        when SkmCompoundDatum
          self.class == other.class && self.members == other.members
        when Array
          members == other
      end
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
      result = ''
      members.each { |elem| result << elem.inspect + ', ' }
      result.sub!(/, $/, '')
      result
    end
  end # class

  # @deprecated Use {#SkmPair} class instead.
  class SkmList < SkmCompoundDatum
    def tail()
      SkmList.new(members.slice(1..-1))
    end

    def list?
      true
    end

    def null?
      empty?
    end

    def evaluate(aRuntime)
      if empty?
        self.class.new(nil)
      else
        first_evaluated = members.first.evaluate(aRuntime)

        if first_evaluated.kind_of?(SkmIdentifier)
          aRuntime.evaluate_form(self)
        else
          members_eval = members.map { |elem| elem.evaluate(aRuntime) }
          self.class.new(members_eval)
        end
      end
    end


    # Factory method.
    # Construct an Enumerator that will return iteratively the result
    # of 'evaluate' method of each members of self.
    def to_eval_enum(aRuntime)
=begin
      elements = self.members

      new_enum = Enumerator.new do |result|
        context = aRuntime
        elements.each { |elem| result << elem.evaluate(context) }
      end

      new_enum
=end
      members.map { |elem| elem.evaluate(aRuntime) }
    end

    def done!()
      # Do nothing
    end

    alias head first
    alias rest tail
  end # class

  class SkmVector < SkmCompoundDatum
    def vector?
      true
    end
  end # class
end # module