require 'spec_helper'

module RansackAbbreviator
  module ViewHelpers
    describe "#get_abbreviated_form_for" do
      context "a lookup of a defined column" do
        it "returns an abbreviated column name" do
          search = Ransack::Search.new(Person)
          get_abbreviated_form_for(search, :name_eq).should == "nm_eq"
        end
      end
      
      context "a lookup of an undefined column" do
        it "returns the full column name" do
          search = Ransack::Search.new(Person)
          get_abbreviated_form_for(search, :salary_eq).should == "salary_eq"
        end
      end
      
      context "a lookup of a defined table" do
        context "a lookup of a defined column" do
          it "returns an abbreviated table & column pair" do
            search = Ransack::Search.new(Article)
            get_abbreviated_form_for(search, :person_name_eq).should == "pr.nm_eq"
          end
        end
        
        context "a lookup of an undefined column" do
          it "returns an abbreviated table but full column" do
            search = Ransack::Search.new(Article)
            get_abbreviated_form_for(search, :person_salary_eq).should == "pr.salary_eq"
          end
        end
      end
      
      context "a lookup of an undefined table" do
        context "a lookup of a defined column" do
          it "returns the full table but abbreviated column" do
            search = Ransack::Search.new(Person)
            get_abbreviated_form_for(search, :articles_title_cont).should == "articles.tl_cont"
          end
        end
        
        context "a lookup of an undefined column" do
          it "returns a full table & column pair" do
            search = Ransack::Search.new(Person)
            get_abbreviated_form_for(search, :articles_body_cont).should == "articles.body_cont"
          end
        end
      end
    end
  end
end