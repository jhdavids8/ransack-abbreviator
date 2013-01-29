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
    
    def config_dir
      defined?(Rails) ? Rails.root.join("config") : Pathname.new("config")
    end
  end
end