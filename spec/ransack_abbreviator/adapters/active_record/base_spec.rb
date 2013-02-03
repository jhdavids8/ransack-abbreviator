require 'spec_helper'

module RansackAbbreviator
  module Adapters
    module ActiveRecord
      describe Base do
        subject { ::ActiveRecord::Base }
        
        describe '#ransackable_column_abbreviations' do
          subject { Person.ransackable_column_abbreviations }

          it { should include 'name' => 'nm' }
          it { should include 'middle_name' => 'mn' }
        end

        describe '#ransackable_assoc_abbreviations' do
          subject { Person.ransackable_assoc_abbreviations }

          it { should include 'children' => 'ch' }
          it { should include 'parent' => 'pa' }
        end

        describe '#ransackable_column_name_for' do
          context 'when a defined abbreviation' do
            it "returns the full column name" do
              Person.ransackable_column_name_for("nm").should eq "name"
              Person.ransackable_column_name_for("mn").should eq "middle_name"
            end
          end
          
          context 'when an undefined abbreviation' do
            it "returns nil" do
              Person.ransackable_column_name_for("you_fake").should be_nil
            end
          end
        end
        
        describe '#ransackable_column_abbr_for' do
          context 'when a defined column' do
            it "returns the abbreviation" do
              Person.ransackable_column_abbr_for("name").should eq "nm"
              Person.ransackable_column_abbr_for("middle_name").should eq "mn"
            end
          end
          
          context 'when an undefined column' do
            it "returns the passed-in column" do
              Person.ransackable_column_abbr_for("you_fake").should eq "you_fake"
            end
          end
        end
        
        describe '#ransackable_assoc_name_for' do
          context 'when a defined abbreviation' do
            it "returns the full association name" do
              Person.ransackable_assoc_name_for("ch").should eq "children"
              Person.ransackable_assoc_name_for("pa").should eq "parent"
            end
          end
          
          context 'when an undefined abbreviation' do
            it "returns nil" do
              Person.ransackable_assoc_name_for("you_fake").should be_nil
            end
          end
        end
        
        describe '#ransackable_assoc_abbr_for' do
          context 'when a defined association' do
            it "returns the abbreviation" do
              Person.ransackable_assoc_abbr_for("children").should eq "ch"
              Person.ransackable_assoc_abbr_for("parent").should eq "pa"
            end
          end
          
          context 'when an undefined association' do
            it "returns the passed-in association" do
              Person.ransackable_assoc_abbr_for("you_fake").should eq "you_fake"
            end
          end
        end
      end
    end
  end
end