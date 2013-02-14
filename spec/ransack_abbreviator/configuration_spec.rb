require "spec_helper"

module RansackAbbreviator
  describe Configuration do
    it 'yields RansackAbbreviator on configure' do
      RansackAbbreviator.configure do |config|
        config.should eq RansackAbbreviator
      end
    end  
    
    it "adds column abbreviations" do
      RansackAbbreviator.configure do |config|
        config.add_column_abbreviation(:tag_id, :tid)
      end
      
      RansackAbbreviator.column_abbreviations.should have_key('tag_id')
      RansackAbbreviator.column_abbreviation_for(:tag_id).should eq 'tid'
      RansackAbbreviator.column_name_for('tid').should eq 'tag_id'
    end
    
    it "adds association abbreviations" do
      RansackAbbreviator.configure do |config|
        config.add_assoc_abbreviation(:notes, :ns)
      end
      
      RansackAbbreviator.assoc_abbreviations.should have_key('notes')
      RansackAbbreviator.assoc_abbreviation_for('notes').should eq 'ns'
      RansackAbbreviator.assoc_name_for(:ns).should eq 'notes'
    end
  end
end