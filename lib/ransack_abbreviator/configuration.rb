require "pathname"

module RansackAbbreviator
  module Configuration
    mattr_accessor :column_abbreviations, :assoc_abbreviations
    self.column_abbreviations = self.assoc_abbreviations = {}
    
    def configure
      yield self
    end
    
    def add_column_abbreviation(column, abbr)
      self.column_abbreviations[column] = abbr
    end
    
    def add_assoc_abbreviation(assoc, abbr)
      self.assoc_abbreviations[assoc] = abbr
    end
    
    def column_abbreviation_for(column)
      self.column_abbreviations.has_key?(column) ? self.column_abbreviations[column] : column
    end
    
    def assoc_abbreviation_for(assoc)
      self.assoc_abbreviations.has_key?(assoc) ? self.assoc_abbreviations[assoc] : assoc
    end
    
    def config_dir
      defined?(Rails) ? Rails.root.join("config") : Pathname.new("config")
    end
  end
end