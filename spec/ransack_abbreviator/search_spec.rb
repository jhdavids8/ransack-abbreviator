require "spec_helper"
require "pry"

module Ransack
  describe Search do
    describe '#build' do
      it 'creates Conditions for top-level attributes' do
        search = Search.new(Person, :children_nm_eq => 'Ernie')
        binding.pry
        # Jamie: Here. Everything's working fine, except that all this stuff is stored in the abbreviated form ("children_nm")
        # I need to store this as the full name OR provide some function that's like 'convert_to_longhand_form'. I'd
        # prefer to support either 
        
        # I'm going to have to be able to support a function called 'shorthand_for(:children_name_eq)' anyways (for the view)
        # so I prolly want to go ahead and start with that
        condition = search.base[:children_nm_eq]
        condition.should be_a Nodes::Condition
        condition.predicate.name.should eq 'eq'
        condition.attributes.first.name.should eq 'children_name'
        condition.value.should eq 'Ernie'
      end
    end
  end
end