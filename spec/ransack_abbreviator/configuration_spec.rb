require "spec_helper"

module RansackAbbreviator
  describe Configuration do
    context "parsing a config.yml" do
      it "initializes the abbreviations" do
        RansackAbbreviator.column_abbreviations.should_not be_blank
        RansackAbbreviator.column_abbreviations["name"].should == "nm"
        RansackAbbreviator.assoc_abbreviations.should_not be_blank
        RansackAbbreviator.assoc_abbreviations[:authored_article_comments].should == "a_ac"
      end
    end
  end
end