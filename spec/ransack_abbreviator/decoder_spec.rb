require 'spec_helper'

module RansackAbbreviator
  module Abbreviators
    describe Decoder do
      describe '#decode_parameter' do
        context "a lookup of a defined column abbr" do
          it "returns the full column name" do
            search = Ransack::Search.new(Person)
            search.context.decode_parameter("nm_eq").should == "name_eq"
            search.context.decode_parameter("mn_eq").should == "middle_name_eq"          
          end
        end
      
        context "a lookup of an undefined column" do
          it "returns the full column name" do
            search = Ransack::Search.new(Person)
            search.context.decode_parameter(:salary_eq).should == "salary_eq"
          end
        end
      
        context "a lookup of a defined association abbr" do
          context "a lookup of a defined column abbr" do
            it "returns the full assoc & column pair" do
              search = Ransack::Search.new(Article)
              search.context.decode_parameter("pr.nm_eq").should == "person_name_eq"
              search.context.decode_parameter("pr.mn_eq").should == "person_middle_name_eq"
              search = Ransack::Search.new(Person)
              search.context.decode_parameter("a_ac.vc_lteq").should == "authored_article_comments_vote_count_lteq"
            end
          end
        
          context "a lookup of a column without an abbr" do
            it "returns the table and full column" do
              search = Ransack::Search.new(Article)
              search.context.decode_parameter("pr.salary_eq").should == "person_salary_eq"
            end
          end
        end
      
        context "a lookup of an association without an abbr" do
          context "a lookup of a column with an abbr" do
            it "returns the full association and full column" do
              search = Ransack::Search.new(Person)
              search.context.decode_parameter("articles.tl_cont").should == "articles_title_cont"
            end
          end
        
          context "a lookup of a column without an abbr" do
            it "returns a full association & column pair" do
              search = Ransack::Search.new(Person)
              search.context.decode_parameter("articles.body_cont").should == "articles_body_cont"
            end
          end
        end
      
        context "a lookup of a multi-condition string" do
          it "returns full forms for all conditions" do
            search = Ransack::Search.new(Person)
            search.context.decode_parameter("ch.nm_or_ch.salary_eq").should == "children_name_or_children_salary_eq"
          end
        end
      
        context "a lookup of an abbreviated polymorphic belongs_to association" do
          it "returns the full name for the polymorphic association" do
            search = Ransack::Search.new(Note)
            search.context.decode_parameter("nbl_of_pr_type.nm_eq").should == "notable_of_Person_type_name_eq"
          end
        end
      
        context "a lookup of a nested condition" do
          it "returns the full name for each association and column" do
            search = Ransack::Search.new(Person)
            search.context.decode_parameter("articles_cm.body_cont").should == "articles_comments_body_cont"
          end
        
          it "returns the full name for nested conditions for polymorphic associations" do
            search = Ransack::Search.new(Note)
            search.context.decode_parameter("nbl_of_pr_type_ch.nm_eq").should == "notable_of_Person_type_children_name_eq"
          end
        end
      
        context "a lookup of something totally random" do
          it "does absolutely nothing" do
            search = Ransack::Search.new(Note)
            search.context.decode_parameter("i_am_garbage").should == "i_am_garbage"
          end
        end
      end
    end
  end
end