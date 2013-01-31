require "pathname"

module RansackAbbreviator
  module Configuration
    mattr_accessor :column_abbreviations, :association_abbreviations
    self.column_abbreviations = self.association_abbreviations = {}
    
    def configure
      yield self
    end
    
    def add_column_abbreviation(column, abbr)
      self.column_abbreviations[column] = abbr
    end
    
    def add_table_abbreviation(table, abbr)
      self.table_abbreviations[table] = abbr
    end
    
    def column_abbreviation_for(column)
      self.column_abbreviations.has_key?(column) ? self.column_abbreviations[column] : column
    end
    
    def association_abbreviation_for(association)
      self.association_abbreviations.has_key?(association) ? self.association_abbreviations[association] : association
    end
    
    def config_dir
      defined?(Rails) ? Rails.root.join("config") : Pathname.new("config")
    end
  end
end