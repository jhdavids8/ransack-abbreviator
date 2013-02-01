require 'spec_helper'

module RansackAbbreviator
  module ViewHelpers
    describe "#ransack_abbreviation_for" do
      context "a lookup of a defined column" do
        it "returns an abbreviated column name" do
          search = Ransack::Search.new(Person)
          ransack_abbreviation_for(search, :name_eq).should == "nm_eq"
        end
      end
      
      context "a lookup of an undefined column" do
        it "returns the full column name" do
          search = Ransack::Search.new(Person)
          ransack_abbreviation_for(search, :salary_eq).should == "salary_eq"
        end
      end
      
      context "a lookup of a defined association" do
        context "a lookup of a defined column" do
          it "returns an abbreviated assoc & column pair" do
            search = Ransack::Search.new(Article)
            ransack_abbreviation_for(search, :person_name_eq).should == "pr.nm_eq"
          end
        end
        
        context "a lookup of an undefined column" do
          it "returns an abbreviated table but full column" do
            search = Ransack::Search.new(Article)
            ransack_abbreviation_for(search, :person_salary_eq).should == "pr.salary_eq"
          end
        end
      end
      
      context "a lookup of an undefined association" do
        context "a lookup of a defined column" do
          it "returns the full association but abbreviated column" do
            search = Ransack::Search.new(Person)
            ransack_abbreviation_for(search, :articles_title_cont).should == "articles.tl_cont"
          end
        end
        
        context "a lookup of an undefined column" do
          it "returns a full association & column pair" do
            search = Ransack::Search.new(Person)
            ransack_abbreviation_for(search, :articles_body_cont).should == "articles.body_cont"
          end
        end
      end
      
      context "a lookup of a multi-condition string" do
        it "returns abbreviated forms for all conditions" do
          search = Ransack::Search.new(Person)
          ransack_abbreviation_for(search, :children_name_or_children_salary_eq).should == "ch.nm_or_ch.salary_eq"
        end
      end
      
      context "a lookup of a defined polymorphic belongs_to association" do
        it "returns the abbreviated name for the polymorphic association" do
          search = Ransack::Search.new(Note)
          ransack_abbreviation_for(search, :notable_of_Person_type_name_eq).should == "nbl_of_pr_type.nm_eq"
        end
      end
      
      context "a lookup of a nested condition" do
        it "abbreviates each association and column" do
          search = Ransack::Search.new(Person)
          ransack_abbreviation_for(search, :articles_comments_body_cont).should == "articles_cm.body_cont"
        end
      end
    end
  end
end