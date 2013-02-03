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
        
        it 'creates Conditions for multiple polymorphic belongs_to association attributes' do
          search = Search.new(Note)
          search.build(ransack_abbreviation_for(search, :notable_of_Person_type_name_or_notable_of_Article_type_title_eq) => 'Ernie')
          condition = search.base[:notable_of_Person_type_name_or_notable_of_Article_type_title_eq]
          condition.should be_a Nodes::Condition
          condition.predicate.name.should eq 'eq'
          condition.attributes.first.name.should eq 'notable_of_Person_type_name'
          condition.attributes.last.name.should eq 'notable_of_Article_type_title'
          condition.value.should eq 'Ernie'
        end

        it 'discards empty conditions' do
          search = Search.new(Person)
          search.build(ransack_abbreviation_for(search, :children_name_eq) => '')
          condition = search.base[:children_name_eq]
          condition.should be_nil
        end

        it 'accepts arrays of groupings' do
          search = Search.new(Person)
          search.build(
            :g => [
              ransack_abbreviations_for(search, :m => 'or', :name_eq => 'Ernie', :children_name_eq => 'Ernie'),
              ransack_abbreviations_for(search, :m => 'or', :name_eq => 'Bert', :children_name_eq => 'Bert')
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
          search = Search.new(Person)
          search.build(
            :g => {
              '0' => ransack_abbreviations_for(search, :m => 'or', :name_eq => 'Ernie', :children_name_eq => 'Ernie'),
              '1' => ransack_abbreviations_for(search, :m => 'or', :name_eq => 'Bert', :children_name_eq => 'Bert'),
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
          search = Search.new(Person)
          search.build(
            :c => {
              '0' => {:a => ransack_abbreviations_for(search, ['name']), :p => 'eq', :v => ['Ernie']},
              '1' => {:a => ransack_abbreviations_for(search, ['children_name', 'parent_name']), :p => 'eq', :v => ['Ernie'], :m => 'or'}
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

          search = Search.new(Person)
          search.build(ransack_abbreviation_for(search, :name_ary_pred) => ['Ernie', 'Bert'])
          condition = search.base[:name_ary_pred]
          condition.should be_a Nodes::Condition
          condition.predicate.name.should eq 'ary_pred'
          condition.attributes.first.name.should eq 'name'
          condition.value.should eq ['Ernie', 'Bert']
        end

        it 'does not evaluate the query on #inspect' do
          search = Search.new(Person)
          search.build(ransack_abbreviation_for(search, :children_id_in) => [1, 2, 3])
          search.inspect.should_not match /ActiveRecord/
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
      context "with abbreviations" do
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
        
        it 'evaluates polymorphic belongs_to association conditions contextually' do
          search = Search.new(Note)
          search.build(ransack_abbreviation_for(search, :notable_of_Person_type_name_eq) => 'Ernie')
          search.result.should be_an ActiveRecord::Relation
          where = search.result.where_values.first
          where.to_sql.should match /"people"."name" = 'Ernie'/
        end

        it 'evaluates nested conditions' do
          search = Search.new(Person)
          search.build(
            ransack_abbreviation_for(search, :children_name_eq) => 'Ernie',
            :g => [
              ransack_abbreviations_for(search, :m => 'or', :name_eq => 'Ernie', :children_children_name_eq => 'Ernie')
            ]
          )
          search.result.should be_an ActiveRecord::Relation
          where = search.result.where_values.first
          where.to_sql.should match /"children_people"."name" = 'Ernie'/
          where.to_sql.should match /"people"."name" = 'Ernie'/
          where.to_sql.should match /"children_people_2"."name" = 'Ernie'/
        end

        it 'evaluates arrays of groupings' do
          search = Search.new(Person)
          search.build(
            :g => [
              ransack_abbreviations_for(search, :m => 'or', :name_eq => 'Ernie', :children_name_eq => 'Ernie'),
              ransack_abbreviations_for(search, :m => 'or', :name_eq => 'Bert', :children_name_eq => 'Bert'),
            ]
          )
          search.result.should be_an ActiveRecord::Relation
          where = search.result.where_values.first
          sql = where.to_sql
          first, second = sql.split(/ AND /)
          first.should match /"people"."name" = 'Ernie'/
          first.should match /"children_people"."name" = 'Ernie'/
          second.should match /"people"."name" = 'Bert'/
          second.should match /"children_people"."name" = 'Bert'/
        end

        it 'returns distinct records when passed :distinct => true' do
          search = Search.new(Person)
          search.build(
            :g => [ransack_abbreviations_for(search, :m => 'or', :comments_body_cont => 'e', :articles_comments_body_cont => 'e')]
          )
          search.result.all.should have(920).items
          search.result(:distinct => true).should have(330).items
          search.result.all.uniq.should eq search.result(:distinct => true).all
        end
      end
      
      context "without abbreviations" do
        it 'evaluates conditions contextually' do
          search = Search.new(Person, :children_name_eq => 'Ernie')
          search.result.should be_an ActiveRecord::Relation
          where = search.result.where_values.first
          where.to_sql.should match /"children_people"\."name" = 'Ernie'/
        end

        it 'evaluates compound conditions contextually' do
          search = Search.new(Person, :children_name_or_name_eq => 'Ernie')
          search.result.should be_an ActiveRecord::Relation
          where = search.result.where_values.first
          where.to_sql.should match /"children_people"\."name" = 'Ernie' OR "people"\."name" = 'Ernie'/
        end

        it 'evaluates polymorphic belongs_to association conditions contextually' do
          search = Search.new(Note, :notable_of_Person_type_name_eq => 'Ernie')
          search.result.should be_an ActiveRecord::Relation
          where = search.result.where_values.first
          where.to_sql.should match /"people"."name" = 'Ernie'/
        end

        it 'evaluates nested conditions' do
          search = Search.new(Person, :children_name_eq => 'Ernie',
            :g => [{
              :m => 'or',
              :name_eq => 'Ernie',
              :children_children_name_eq => 'Ernie'
            }]
          )
          search.result.should be_an ActiveRecord::Relation
          where = search.result.where_values.first
          where.to_sql.should match /"children_people"."name" = 'Ernie'/
          where.to_sql.should match /"people"."name" = 'Ernie'/
          where.to_sql.should match /"children_people_2"."name" = 'Ernie'/
        end

        it 'evaluates arrays of groupings' do
          search = Search.new(Person,
            :g => [
              {:m => 'or', :name_eq => 'Ernie', :children_name_eq => 'Ernie'},
              {:m => 'or', :name_eq => 'Bert', :children_name_eq => 'Bert'},
            ]
          )
          search.result.should be_an ActiveRecord::Relation
          where = search.result.where_values.first
          sql = where.to_sql
          first, second = sql.split(/ AND /)
          first.should match /"people"."name" = 'Ernie'/
          first.should match /"children_people"."name" = 'Ernie'/
          second.should match /"people"."name" = 'Bert'/
          second.should match /"children_people"."name" = 'Bert'/
        end

        it 'returns distinct records when passed :distinct => true' do
          search = Search.new(Person, :g => [{:m => 'or', :comments_body_cont => 'e', :articles_comments_body_cont => 'e'}])
          search.result.all.should have(920).items
          search.result(:distinct => true).should have(330).items
          search.result.all.uniq.should eq search.result(:distinct => true).all
        end
      end
      
      it "has the same results for a query with and without abbreviations" do
        # Just some random sanity checks
        search = Search.new(Person, :authored_article_comments_vote_count_lteq => 10)
        abbr_search = Search.new(Person)
        abbr_search.build(ransack_abbreviation_for(abbr_search, :authored_article_comments_vote_count_lteq) => 10)
        search.result.where_values.first.to_sql.should eq abbr_search.result.where_values.first.to_sql
        
        search = Search.new(Note, :notable_of_Person_type_children_name_eq => "Ernie")
        abbr_search = Search.new(Note)
        abbr_search.build(ransack_abbreviation_for(abbr_search, :notable_of_Person_type_children_name_eq) => "Ernie")
        search.result.where_values.first.to_sql.should eq abbr_search.result.where_values.first.to_sql
      end
    end
    
    describe '#method_missing' do
      before do
        @search = Search.new(Person)
      end
      
      it 'support abbreviations' do
        abbr_middle_name_search = ransack_abbreviation_for(@search, :middle_name_eq)
        @search.send(abbr_middle_name_search, 'Ernie')
        @search.send(abbr_middle_name_search).should eq 'Ernie'
      end
      
      it 'raises NoMethodError when sent an invalid attribute/aabreviation' do
        expect {@search.i_am_garvage}.to raise_error NoMethodError
      end
    end
  end
end