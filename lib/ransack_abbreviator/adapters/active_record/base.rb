module RansackAbbreviator
  module Adapters
    module ActiveRecord
      module Base

        def self.extended(base)
          base.class_eval do
            class_attribute :_ransack_abbreviations
          end
        end
        
        def ransack_abbreviate_column(column_name, column_abbr)
          ransack_abbreviate_column!(column_name, column_abbr) rescue {}
        end
        
        def ransack_abbreviate_column!(column_name, column_abbr)
          raise ActiveModel::MissingAttributeError, "missing attribute: #{column_name}" unless column_names.include?(column_name) 
          raise "column #{self._ransack_abbreviations.key(column_abbr)} has abbreviaiton #{column_abbr}" if self._ransack_abbreviations.has_value?(column_abbr)
          self._ransack_abbreviations ||= self.ransackable_abbreviations
          self._ransack_abbreviations[column_name] = column_abbr
        end
        
        def ransackable_abbreviations
          self._ransack_abbreviations ||= RansackAbbreviator.column_abbreviations.select{ |key, val| column_names.include?(key) }
        end
        
        def ransackable_column_name_for(str)
          column_names.include?(str) ? str : self.ransackable_abbreviations.key(str)
        end
      end
    end
  end
end