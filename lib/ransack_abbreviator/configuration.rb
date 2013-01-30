require "pathname"

module RansackAbbreviator
  module Configuration
    mattr_accessor :column_abbreviations, :table_abbreviations
    self.column_abbreviations = self.table_abbreviations = {}
    
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
    
    def table_abbreviation_for(table)
      table.is_a?(String) ? 
        (self.table_abbreviations.has_key?(table) ? self.table_abbreviations[table] : table) :
        (defined?(table.tables) ? self.table_abbreviation_for(table.tables[0].name) : nil)
    end
    
    def config_dir
      defined?(Rails) ? Rails.root.join("config") : Pathname.new("config")
    end
  end
end