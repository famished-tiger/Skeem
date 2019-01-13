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

    # Construct new instance with car and cdr respectively equal to
    # car.evaluate and cdr.evaluate
    def clone_evaluate(aRuntime)
      new_car = car.evaluate(aRuntime)
      if cdr.nil?
        new_cdr = nil
      elsif cdr.kind_of?(SkmPair)
        new_cdr = cdr.clone_evaluate(aRuntime)
      else
        new_cdr = cdr.evaluate(aRuntime)
      end

      self.class.new(new_car, new_cdr)
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

    # Works correctly for proper lists.
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

    def eqv?(_other)
      false
    end

    def skm_equal?(other)
      return true if equal?(other)

      equal = true
      if car.nil?
        equal = other.car.nil?
      else
        equal &&= car.skm_equal?(other.car)
      end
      return false unless equal

      if cdr.nil?
        equal &&= other.cdr.nil?
      else
        equal &&= cdr.skm_equal?(other.cdr)
      end

      equal
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
      if car.kind_of?(SkmIdentifier) && car.is_var_name
        result = aRuntime.evaluate_form(self)
      else
        begin
          result = clone_evaluate(aRuntime)
        rescue NoMethodError => exc
          $stderr.puts self.inspect
          $stderr.puts self.to_a.inspect
          raise exc
        end
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

    def quoted!
      car.quoted!
      cdr.quoted! if cdr
    end

    def unquoted!
      car.unquoted!
      cdr.unquoted! if cdr
    end

    def verbatim?()
      return false unless car.verbatim?
      if cdr.nil?
        true
      else
        cdr.verbatim?
      end
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