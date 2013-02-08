require 'spec_helper'

module RansackAbbreviator
  module Abbreviators
    describe Encoder do
      describe '#encode_parameter' do
        context "a lookup of a defined column" do
          it "returns an abbreviated column name" do
            search = Ransack::Search.new(Person)
            search.context.encode_parameter(:name_eq).should == "nm_eq"
            search.context.encode_parameter(:middle_name_eq).should == "mn_eq"          
          end
        end
      
        context "a lookup of an undefined column" do
          it "returns the full column name" do
            search = Ransack::Search.new(Person)
            search.context.encode_parameter(:salary_eq).should == "salary_eq"
          end
        end
      
        context "a lookup of a defined association" do
          context "a lookup of a defined column" do
            it "returns an abbreviated assoc & column pair" do
              search = Ransack::Search.new(Article)
              search.context.encode_parameter(:person_name_eq).should == "pr.nm_eq"
              search.context.encode_parameter(:person_middle_name_eq).should == "pr.mn_eq"
              search = Ransack::Search.new(Person)
              search.context.encode_parameter(:authored_article_comments_vote_count_lteq).should == "a_ac.vc_lteq"
            end
          end
        
          context "a lookup of an undefined column" do
            it "returns an abbreviated table but full column" do
              search = Ransack::Search.new(Article)
              search.context.encode_parameter(:person_salary_eq).should == "pr.salary_eq"
            end
          end
        end
      
        context "a lookup of an undefined association" do
          context "a lookup of a defined column" do
            it "returns the full association but abbreviated column" do
              search = Ransack::Search.new(Person)
              search.context.encode_parameter(:articles_title_cont).should == "articles.tl_cont"
            end
          end
        
          context "a lookup of an undefined column" do
            it "returns a full association & column pair" do
              search = Ransack::Search.new(Person)
              search.context.encode_parameter(:articles_body_cont).should == "articles.body_cont"
            end
          end
        end
      
        context "a lookup of a multi-condition string" do
          it "returns abbreviated forms for all conditions" do
            search = Ransack::Search.new(Person)
            search.context.encode_parameter(:children_name_or_children_salary_eq).should == "ch.nm_or_ch.salary_eq"
          end
        end
      
        context "a lookup of a defined polymorphic belongs_to association" do
          it "returns the abbreviated name for the polymorphic association" do
            search = Ransack::Search.new(Note)
            search.context.encode_parameter(:notable_of_Person_type_name_eq).should == "nbl_of_pr_type.nm_eq"
          end
        end
      
        context "a lookup of a nested condition" do
          it "abbreviates each association and column" do
            search = Ransack::Search.new(Person)
            search.context.encode_parameter(:articles_comments_body_cont).should == "articles_cm.body_cont"
          end
        
          it "abbreviates nested conditions for polymorphic associations" do
            search = Ransack::Search.new(Note)
            search.context.encode_parameter(:notable_of_Person_type_children_name_eq).should == "nbl_of_pr_type_ch.nm_eq"
          end
        end
      
        context "a lookup of something totally random" do
          it "does absolutely nothing" do
            search = Ransack::Search.new(Note)
            search.context.encode_parameter(:i_am_garbage).should == "i_am_garbage"
          end
        end
      end
    end
  end
end