require_relative '../spec_helper' # Use the RSpec framework
require_relative '../../lib/skeem/environment' # Load the class under test

module Skeem
  describe Environment do
    context 'Initialization:' do
      it 'should be initialized without argument' do
        expect { Environment.new() }.not_to raise_error
      end

      it 'should have no bindings' do
        expect(subject.bindings).to be_empty
      end
    end # context

    context 'Provided services:' do
      it 'should add entries' do
        entry = double('dummy')
        subject.define('dummy', entry)
        expect(subject.bindings.size).to eq(1) 
        expect(subject.bindings['dummy']).not_to be_nil
        expect(subject.bindings['dummy']).to eq(entry)
      end
    end # context
    
  end # describe
end # module