require_relative 'skm_empty_list'

module Skeem
  class SkmPair < SkmElement
    attr_accessor :car
    attr_accessor :cdr
    
    alias first car
    alias members to_a

    def initialize(head, tail)
      super(0)
      @car = head
      @cdr = tail
    end

    def self.create_from_a(anArray)
      current = nil
      return SkmEmptyList.instance if anArray.empty?
      anArray.reverse_each do |elem|
        if current.nil?
          current = self.new(elem, SkmEmptyList.instance)
        else
          current = self.new(elem, current)
        end
      end

      current
    end
    
    def empty?
      return false if car
      if [SkmPair, SkmEmptyList].include? cdr.class
        cdr.empty? 
      else
        false
      end
    end

    def list?
      if cdr.nil?
        false
      else
        cdr.list?
      end
    end

    def pair?
      true
    end

    def length
      if [SkmPair, SkmEmptyList].include?(cdr.class)
        cdr.length + 1
      else
        raise StandardError, 'Improper list'
      end
    end
    
    def to_a
      result = [car]
      if cdr && !cdr.null?
        result.concat(cdr.to_a)
      end

      result    
    end
    
    def last
      self.to_a.last
    end
    
    def each(&aBlock)
      aBlock.call(car)
      cdr.each(&aBlock) if cdr && !cdr.null?
    end
    
    def append(anElement)
      if cdr.nil? || cdr.kind_of?(SkmEmptyList)
        self.cdr = SkmPair.new(anElement, SkmEmptyList.instance)
      elsif cdr.kind_of?(SkmPair)
        self.cdr.append(anElement)
      else
        raise StandardError, "Cannot append #{anElement.inspect}"
      end
    end

    def evaluate(aRuntime)
      return SkmEmptyList.instance if empty?
      if car.kind_of?(SkmIdentifier)
        result = aRuntime.evaluate_form(self)
      else
        members_eval = self.to_a.map { |elem| elem.evaluate(aRuntime) }
        result = self.class.create_from_a(members_eval)
      end
      result
    end

    def quasiquote(aRuntime)
      members_eval = self.to_a.map { |elem| elem.quasiquote(aRuntime) }
      self.class.create_from_a(members_eval)  
    end   

    # Part of the 'visitee' role in Visitor design pattern.
    # @param _visitor [SkmElementVisitor] the visitor
    def accept(aVisitor)
      aVisitor.visit_pair(self)
    end
    
    def done!()
      # Do nothing
    end

    protected

    def inspect_specific
      result = car.inspect
      if cdr && !cdr.null?
        result << ', ' << cdr.send(:inspect_specific)
      end

      result
    end

  end # class
end # module