# frozen_string_literal: true

module Skeem
  class SkmElementVisitor
    # Link to the root element to visit
    attr_reader(:root)

    # List of objects that subscribed to the visit event notification.
    attr_reader(:subscribers)

    attr_reader(:runtime)

    # Build a visitor for the given root.
    # @param aRoot [SkmElement] the parse tree to visit.
    def initialize(aRoot)
      raise StandardError if aRoot.nil?
      @root = aRoot
      @subscribers = []
    end

    # Add a subscriber for the visit event notifications.
    # @param aSubscriber [Object]
    def subscribe(aSubscriber)
      subscribers << aSubscriber
    end

    # Remove the given object from the subscription list.
    # The object won't be notified of visit events.
    # @param aSubscriber [Object]
    def unsubscribe(aSubscriber)
      subscribers.delete_if { |entry| entry == aSubscriber }
    end

    # The signal to begin the visit of the root.
    def start(aRuntime)
      @runtime = aRuntime
      root.accept(self)
    end

    # Visit event. The visitor is visiting the
    # given simple datum object.
    # @param aTerminal [SkmTerminal] the terminal to visit.
    def visit_simple_datum(aSimpleDatum)
      broadcast(:before_simple_datum, aSimpleDatum)
      broadcast(:after_simple_datum, aSimpleDatum)
    end

    def visit_compound_datum(aCompoundDatum)
      broadcast(:before_compound_datum, aCompoundDatum)
      traverse_children(aCompoundDatum)
      broadcast(:after_compound_datum, aCompoundDatum)
    end

    # Visit event. The visitor is visiting the
    # given empty list object.
    # @param anEmptyList [SkmEmptyList] the empty list object to visit.
    def visit_empty_list(anEmptyList)
      broadcast(:before_empty_list, anEmptyList)
      broadcast(:after_empty_list, anEmptyList)
    end


    def visit_pair(aPair)
      broadcast(:before_pair, aPair)
      traverse_car_cdr(aPair)
      broadcast(:after_pair, aPair)
    end

=begin
   # Visit event. The visitor is about to visit the given non terminal node.
    # @param aNonTerminalNode [NonTerminalNode] the node to visit.
    def visit_nonterminal(aNonTerminalNode)
      if @traversal == :post_order
        broadcast(:before_non_terminal, aNonTerminalNode)
        traverse_subnodes(aNonTerminalNode)
      else
        traverse_subnodes(aNonTerminalNode)
        broadcast(:before_non_terminal, aNonTerminalNode)
      end
      broadcast(:after_non_terminal, aNonTerminalNode)
    end
=end

    private

    def traverse_children(aParent)
      children = aParent.children
      broadcast(:before_children, aParent, children)

      # Let's proceed with the visit of children
      children.each { |a_child| a_child.accept(self) }

      broadcast(:after_children, aParent, children)
    end

    def traverse_car_cdr(aPair)
      if aPair.car
        broadcast(:before_car, aPair, aPair.car)
        aPair.car.accept(self)
        broadcast(:after_car, aPair, aPair.car)
      end
      if aPair.cdr
        broadcast(:before_cdr, aPair, aPair.cdr)
        aPair.cdr.accept(self)
        broadcast(:after_cdr, aPair, aPair.cdr)
      end
    end

    # Send a notification to all subscribers.
    # @param msg [Symbol] event to notify
    # @param args [Array] arguments of the notification.
    def broadcast(msg, *args)
      subscribers.each do |subscr|
        next unless subscr.respond_to?(msg) || subscr.respond_to?(:accept_all)
        subscr.send(msg, runtime, *args)
      end
    end
  end # class
end # module