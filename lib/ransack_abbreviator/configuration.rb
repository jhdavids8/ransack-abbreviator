require "pathname"

module RansackAbbreviator
  module Configuration
    mattr_accessor :column_abbreviations, :assoc_abbreviations
    self.column_abbreviations = self.assoc_abbreviations = {}
    
    def configure
      yield self
    end
    
    def column_abbreviations=(abbreviations)
      if abbreviations
        if !(abbreviations.values & RansackAbbreviator::Constants::RESERVED_KEYWORDS).blank?
          fail "You used a reserved keyword as a column abbreviation. Reserverd keywords: #{RansackAbbreviator::Constants::RESERVED_KEYWORDS.join(", ")}"
        end
        
        @@column_abbreviations = abbreviations
      end
    end
    
    def assoc_abbreviations=(abbreviations)
      if abbreviations
        if !(abbreviations.values & RansackAbbreviator::Constants::RESERVED_KEYWORDS).blank?
          fail "You used a reserved keyword as an association abbreviation. Reserverd keywords: #{RansackAbbreviator::Constants::RESERVED_KEYWORDS.join(", ")}"
        end
        
        @@assoc_abbreviations = abbreviations
      end
    end
    
    def add_column_abbreviation(column, abbr)
      self.column_abbreviations[column.to_s] = abbr.to_s
    end
    
    def add_assoc_abbreviation(assoc, abbr)
      self.assoc_abbreviations[assoc.to_s] = abbr.to_s
    end
    
    def column_abbreviation_for(column)
      column = column.to_s
      self.column_abbreviations.has_key?(column) ? self.column_abbreviations[column] : column
    end
    
    def column_name_for(column_abbr)
      column_abbr = column_abbr.to_s
      self.column_abbreviations.has_value?(column_abbr) ? self.column_abbreviations.key(column_abbr) : column_abbr
    end
    
    def assoc_abbreviation_for(assoc)
      assoc = assoc.to_s
      self.assoc_abbreviations.has_key?(assoc) ? self.assoc_abbreviations[assoc] : assoc
    end
    
    def assoc_name_for(assoc_abbr)
      assoc_abbr = assoc_abbr.to_s
      self.assoc_abbreviations.has_value?(assoc_abbr) ? self.assoc_abbreviations.key(assoc_abbr) : assoc_abbr
    end
    
    def config_dir
      Pathname.new("config")
    end
  end
end