require "pathname"

module RansackAbbreviator
  module Configuration
    mattr_accessor :column_abbreviations, :assoc_abbreviations
    self.column_abbreviations = self.assoc_abbreviations = {}
    
    def configure
      yield self
    end
    
    def column_abbreviation_for(column)
      self.column_abbreviations.has_key?(column) ? self.column_abbreviations[column] : column
    end
    
    def column_name_for(column_abbr)
      self.column_abbreviations.has_value?(column_abbr) ? self.column_abbreviations.key(column_abbr) : column_abbr
    end
    
    def assoc_abbreviation_for(assoc)
      self.assoc_abbreviations.has_key?(assoc) ? self.assoc_abbreviations[assoc] : assoc
    end
    
    def assoc_name_for(assoc_abbr)
      self.assoc_abbreviations.has_value?(assoc_abbr) ? self.assoc_abbreviations.key(assoc_abbr) : assoc_abbr
    end
    
    def config_dir
      defined?(Rails) ? Rails.root.join("config") : Pathname.new("config")
    end
  end
end