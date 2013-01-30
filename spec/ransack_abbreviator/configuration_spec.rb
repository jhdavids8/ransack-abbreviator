require "spec_helper"

module RansackAbbreviator
  describe Configuration do
    context "parsing a config.yml" do
      it "initializes the abbreviations" do
        RansackAbbreviator.column_abbreviations.should_not be_blank
        RansackAbbreviator.column_abbreviations["name"].should == "nm"
      end
    end
  
    context "messing with column shortcuts" do
      it "adds column shortcuts"
  
      it "removes column shortcuts"
    
      it "modifies column shortcuts"
    
      it "allows columns to have duplicate shortcuts"
    end  
  
    it "does not allow keyword abbreviations of reserved keywords"
    
    it "requires unique table abbreviations"
    
    it "requires unique column abbreviations"
  end
end