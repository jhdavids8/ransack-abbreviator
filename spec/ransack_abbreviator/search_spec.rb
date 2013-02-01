require "spec_helper"

module Ransack # We're testing Ransack's Search wih abbreviations
  describe Search do
    describe '#build' do
      context "with abbreviations" do
        it 'creates Conditions for top-level attributes' do
          search = Search.new(Person)
          search.build(ransack_abbreviation_for(search, :name_eq) => 'Ernie')
          condition = search.base[:name_eq]
          condition.should be_a Nodes::Condition
          condition.predicate.name.should eq 'eq'
          condition.attributes.first.name.should eq 'name'
          condition.value.should eq 'Ernie'
        end
      
        it 'creates Conditions for association attributes' do
          search = Search.new(Person)
          search.build(ransack_abbreviation_for(search, :children_name_eq) => 'Ernie')
          condition = search.base[:children_name_eq]
          condition.should be_a Nodes::Condition
          condition.predicate.name.should eq 'eq'
          condition.attributes.first.name.should eq 'children_name'
          condition.value.should eq 'Ernie'
        end
        
        it 'creates Conditions for polymorphic belongs_to association attributes' do
          search = Search.new(Note)
          search.build(ransack_abbreviation_for(search, :notable_of_Person_type_name_eq) => 'Ernie')
          condition = search.base[:notable_of_Person_type_name_eq]
          condition.should be_a Nodes::Condition
          condition.predicate.name.should eq 'eq'
          condition.attributes.first.name.should eq 'notable_of_Person_type_name'
          condition.value.should eq 'Ernie'
        end
      end
    end
    
    context "without abbreviations" do
      it 'creates Conditions for top-level attributes' do
        search = Search.new(Person, :name_eq => 'Ernie')
        condition = search.base[:name_eq]
        condition.should be_a Nodes::Condition
        condition.predicate.name.should eq 'eq'
        condition.attributes.first.name.should eq 'name'
        condition.value.should eq 'Ernie'
      end

      it 'creates Conditions for association attributes' do
        search = Search.new(Person, :children_name_eq => 'Ernie')
        condition = search.base[:children_name_eq]
        condition.should be_a Nodes::Condition
        condition.predicate.name.should eq 'eq'
        condition.attributes.first.name.should eq 'children_name'
        condition.value.should eq 'Ernie'
      end

      it 'creates Conditions for polymorphic belongs_to association attributes' do
        search = Search.new(Note, :notable_of_Person_type_name_eq => 'Ernie')
        condition = search.base[:notable_of_Person_type_name_eq]
        condition.should be_a Nodes::Condition
        condition.predicate.name.should eq 'eq'
        condition.attributes.first.name.should eq 'notable_of_Person_type_name'
        condition.value.should eq 'Ernie'
      end

      it 'creates Conditions for multiple polymorphic belongs_to association attributes' do
        search = Search.new(Note, :notable_of_Person_type_name_or_notable_of_Article_type_title_eq => 'Ernie')
        condition = search.base[:notable_of_Person_type_name_or_notable_of_Article_type_title_eq]
        condition.should be_a Nodes::Condition
        condition.predicate.name.should eq 'eq'
        condition.attributes.first.name.should eq 'notable_of_Person_type_name'
        condition.attributes.last.name.should eq 'notable_of_Article_type_title'
        condition.value.should eq 'Ernie'
      end

      it 'discards empty conditions' do
        search = Search.new(Person, :children_name_eq => '')
        condition = search.base[:children_name_eq]
        condition.should be_nil
      end

      it 'accepts arrays of groupings' do
        search = Search.new(Person,
          :g => [
            {:m => 'or', :name_eq => 'Ernie', :children_name_eq => 'Ernie'},
            {:m => 'or', :name_eq => 'Bert', :children_name_eq => 'Bert'},
          ]
        )
        ors = search.groupings
        ors.should have(2).items
        or1, or2 = ors
        or1.should be_a Nodes::Grouping
        or1.combinator.should eq 'or'
        or2.should be_a Nodes::Grouping
        or2.combinator.should eq 'or'
      end

      it 'accepts "attributes" hashes for groupings' do
        search = Search.new(Person,
          :g => {
            '0' => {:m => 'or', :name_eq => 'Ernie', :children_name_eq => 'Ernie'},
            '1' => {:m => 'or', :name_eq => 'Bert', :children_name_eq => 'Bert'},
          }
        )
        ors = search.groupings
        ors.should have(2).items
        or1, or2 = ors
        or1.should be_a Nodes::Grouping
        or1.combinator.should eq 'or'
        or2.should be_a Nodes::Grouping
        or2.combinator.should eq 'or'
      end

      it 'accepts "attributes" hashes for conditions' do
        search = Search.new(Person,
          :c => {
            '0' => {:a => ['name'], :p => 'eq', :v => ['Ernie']},
            '1' => {:a => ['children_name', 'parent_name'], :p => 'eq', :v => ['Ernie'], :m => 'or'}
          }
        )
        conditions = search.base.conditions
        conditions.should have(2).items
        conditions.map {|c| c.class}.should eq [Nodes::Condition, Nodes::Condition]
      end

      it 'creates Conditions for custom predicates that take arrays' do
        Ransack.configure do |config|
          config.add_predicate 'ary_pred',
          :wants_array => true
        end

        search = Search.new(Person, :name_ary_pred => ['Ernie', 'Bert'])
        condition = search.base[:name_ary_pred]
        condition.should be_a Nodes::Condition
        condition.predicate.name.should eq 'ary_pred'
        condition.attributes.first.name.should eq 'name'
        condition.value.should eq ['Ernie', 'Bert']
      end

      it 'does not evaluate the query on #inspect' do
        search = Search.new(Person, :children_id_in => [1, 2, 3])
        search.inspect.should_not match /ActiveRecord/
      end
    end
    
    describe '#result' do
      it "evaluates a basic condition" do
        search = Search.new(Person)
        search.build(ransack_abbreviation_for(search, :name_eq) => 'Ernie')
        search.result.should be_an ActiveRecord::Relation
        where = search.result.where_values.first
        where.to_sql.should match /"people"\."name" = 'Ernie'/
      end
      
      it 'evaluates conditions contextually' do
        search = Search.new(Person)
        search.build(ransack_abbreviation_for(search, :children_name_eq) => 'Ernie')
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