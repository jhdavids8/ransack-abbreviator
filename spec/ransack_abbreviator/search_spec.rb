require "spec_helper"

module Ransack # We're testing Ransack's Search wih abbreviations
  describe Search do
    describe '#build' do
      it 'creates Conditions for top-level attributes' do
        search = Search.new(Person)
        search.build(get_abbreviated_form_for(search, :name_eq) => 'Ernie')
        condition = search.base[:name_eq]
        condition.should be_a Nodes::Condition
        condition.predicate.name.should eq 'eq'
        condition.attributes.first.name.should eq 'name'
        condition.value.should eq 'Ernie'
      end
      
      it 'creates Conditions for association attributes' do
        search = Search.new(Person)
        search.build(get_abbreviated_form_for(search, :children_name_eq) => 'Ernie')
        condition = search.base[:children_name_eq]
        condition.should be_a Nodes::Condition
        condition.predicate.name.should eq 'eq'
        condition.attributes.first.name.should eq 'children_name'
        condition.value.should eq 'Ernie'
      end
    end
    
    describe '#result' do
      it "evaluates a basic condition" do
        search = Search.new(Person)
        search.build(get_abbreviated_form_for(search, :name_eq) => 'Ernie')
        search.result.should be_an ActiveRecord::Relation
        where = search.result.where_values.first
        where.to_sql.should match /"people"\."name" = 'Ernie'/
      end
      
      it 'evaluates conditions contextually' do
        search = Search.new(Person)
        search.build(get_abbreviated_form_for(search, :children_name_eq) => 'Ernie')
        search.result.should be_an ActiveRecord::Relation
        where = search.result.where_values.first
        where.to_sql.should match /"children_people"\."name" = 'Ernie'/
      end
    end
  end
end
  # describe Search do
  #     describe '#build' do
  #       it 'creates Conditions for top-level attributes' do
  #         search = Search.new(Person, :children_nm_eq => 'Ernie')
  #         # Jamie: Here. Everything's working fine, except that all this stuff is stored in the abbreviated form ("children_nm")
  #         # I need to store this as the full name OR provide some function that's like 'convert_to_longhand_form'. I'd
  #         # prefer to support either 
  #         
  #         # I'm going to have to be able to support a function called 'shorthand_for(:children_name_eq)' anyways (for the view)
  #         # so I prolly want to go ahead and start with that
  #         condition = search.base[:children_nm_eq]
  #         condition.should be_a Nodes::Condition
  #         condition.predicate.name.should eq 'eq'
  #         condition.attributes.first.name.should eq 'children_name'
  #         condition.value.should eq 'Ernie'
  #       end
  #     end
  #   end
  
describe 'getting abbreviated names' do
  it "fails if table is unknown"
  
  it "fails if column is unknown"
  
  it "fails if table-column pair exists with the same abbreviation"
    # Basically, if both Person.gender and Person.grade have identical abbreviations
end

describe 'something' do
  it "obeys abbreviations added or changed on the fly"
end