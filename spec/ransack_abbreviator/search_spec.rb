require "spec_helper"

module Ransack
  describe Search do
    describe '#build' do
      it 'creates Conditions for top-level attributes' do
        search = Search.new(Person, :name_eq => 'Ernie')
        condition = search.base[:name_eq]
        condition.should be_a Nodes::Condition
        condition.predicate.name.should eq 'eq'
        condition.attributes.first.name.should eq 'name'
        condition.value.should eq 'Ernie'
      end
    end
  end
end