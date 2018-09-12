require_relative '../../spec_helper' # Use the RSpec framework

# Load the class under test
require_relative '../../../lib/skeem/primitive/primitive_builder'

module Skeem
  describe Primitive::PrimitiveBuilder do
    
    context 'Initialization:' do
      it 'should be initialized without argument' do
        expect { Interpreter.new() }.not_to raise_error
      end
    end # context
  end # describe
end # module      