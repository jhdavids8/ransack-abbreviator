module RansackAbbreviator
  module Adapters
    module ActiveRecord
      module Base

        def self.extended(base)
          base.class_eval do
            class_attribute :_ransack_column_abbreviations, :_ransack_assoc_abbreviations
          end
        end
        
        def ransack_abbreviate_column(column_name, column_abbr)
          ransack_abbreviate_column!(column_name, column_abbr) rescue {}
        end
        
        def ransack_abbreviate_column!(column_name, column_abbr)
          raise ActiveModel::MissingAttributeError, "missing attribute: #{column_name}" unless column_names.include?(column_name) 
          raise "column #{self.ransackable_column_abbreviations.key(column_abbr)} has abbreviaiton #{column_abbr}" if self.ransackable_column_abbreviations.has_value?(column_abbr)
          self._ransack_column_abbreviations[column_name] = column_abbr
        end
        
        def ransackable_column_abbreviations
          self._ransack_column_abbreviations ||= RansackAbbreviator.column_abbreviations.select{ |key, val| column_names.include?(key) }
        end
        
        def ransackable_column_name_for(str)
          str = str.to_s
          self.ransackable_column_abbreviations.has_key?(str) ? self.ransackable_column_abbreviations[str] : str
        end
        
        def ransack_abbreviate_assoc(assoc_name, assoc_abbr)
          ransack_abbreviate_assoc!(assoc_name, assoc_abbr) rescue {}
        end
        
        def ransack_abbreviate_assoc!(assoc_name, assoc_abbr)
          raise ActiveModel::MissingAttributeError, "missing association: #{assoc_name}" unless reflect_on_all_associations.map{|a| a.name.to_s}.include?(assoc_name) 
          raise "association #{self.ransackable_assoc_abbreviations.key(assoc_abbr)} has abbreviaiton #{assoc_abbr}" if self.ransackable_assoc_abbreviations.has_value?(assoc_abbr)
          self._ransack_assoc_abbreviations[assoc_name] = assoc_abbr
        end
        
        def ransackable_assoc_abbreviations
          associations = reflect_on_all_associations.map{|a| a.name.to_s}
          self._ransack_assoc_abbreviations ||= RansackAbbreviator.assoc_abbreviations.select{ |key, val| associations.include?(key) }
        end
        
        def ransackable_assoc_name_for(str)
          self.ransackable_assoc_abbreviations.has_key?(str) ? self.ransackable_assoc_abbreviations[str] : str
        end
      end
    end
  end
end