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
          unless column_names.include?(column_name) 
            raise ActiveModel::MissingAttributeError, "missing attribute: #{column_name}" 
          end
          if self.ransackable_column_abbreviations.has_value?(column_abbr)
            raise "Column #{self.ransackable_column_abbreviations.key(column_abbr)} already has abbreviaiton #{column_abbr}. Column abbreviations need to be unique" 
          end
          self._ransack_column_abbreviations[column_name] = column_abbr
        end
        
        def ransack_abbreviate_assoc(assoc_name, assoc_abbr)
          ransack_abbreviate_assoc!(assoc_name, assoc_abbr) rescue {}
        end
        
        def ransack_abbreviate_assoc!(assoc_name, assoc_abbr)
          unless reflect_on_all_associations.map{|a| a.name.to_s}.include?(assoc_name) 
            raise ActiveModel::MissingAttributeError, "missing association: #{assoc_name}" 
          end
          if self.ransackable_assoc_abbreviations.has_value?(assoc_abbr)
            raise "Association #{self.ransackable_assoc_abbreviations.key(assoc_abbr)} already has abbreviaiton #{assoc_abbr} Association abbreviations need to be unique" 
          end
          self._ransack_assoc_abbreviations[assoc_name] = assoc_abbr
        end
        
        def ransackable_column_abbreviations
          self._ransack_column_abbreviations ||= begin
            self._ransack_column_abbreviations = {}
            RansackAbbreviator.column_abbreviations.select{ |key, val| column_names.include?(key) }.each do |col, abbr|
              raise "Column #{self._ransack_column_abbreviations.key(abbr)} already has abbreviaiton #{abbr}" if self._ransack_column_abbreviations.has_value?(abbr)
              self._ransack_column_abbreviations[col] = abbr
            end
          end
        end
        
        def ransackable_assoc_abbreviations
          self._ransack_assoc_abbreviations ||= begin 
            self._ransack_assoc_abbreviations = {}
            associations = reflect_on_all_associations.map{|a| a.name.to_s}
            RansackAbbreviator.assoc_abbreviations.select{ |key, val| associations.include?(key) }.each do |assoc, abbr|
              raise "Association #{self._ransack_assoc_abbreviations.key(abbr)} already has abbreviaiton #{abbr}" if self._ransack_assoc_abbreviations.has_value?(abbr)
              self._ransack_assoc_abbreviations[assoc] = abbr
            end
          end
        end
        
        def ransackable_column_name_for(possible_abbr)
          possible_abbr = possible_abbr.to_s
          column_names.include?(possible_abbr) ? possible_abbr : self.ransackable_column_abbreviations.key(possible_abbr)
        end
        
        def ransackable_column_abbr_for(column_name)
          column_name = column_name.to_s
          self.ransackable_column_abbreviations.has_key?(column_name) ? self.ransackable_column_abbreviations[column_name] : column_name
        end
        
        def ransackable_assoc_name_for(possible_abbr)
          possible_abbr = possible_abbr.to_s
          reflect_on_all_associations.map{|a| a.name.to_s}.include?(possible_abbr) ? possible_abbr : self.ransackable_assoc_abbreviations.key(possible_abbr)
        end
        
        def ransackable_assoc_abbr_for(assoc)
          assoc = assoc.to_s
          self.ransackable_assoc_abbreviations.has_key?(assoc) ? self.ransackable_assoc_abbreviations[assoc] : assoc
        end
      end
    end
  end
end