module RansackAbbreviator
  module Abbreviator
    def get_possible_assoc_and_attribute_abbr(s)
      possible_assoc = possible_attr_name = nil
      if s.include?(".")
        parts = s.split(".")
        possible_assoc = parts[0]
        possible_attr_name = parts[1]
      else
        possible_attr_name = s
      end
      
      [possible_assoc, possible_attr_name]
    end
    
    def decode_possible_abbreviations(possible_attr_name, possible_assoc=nil)
      decoded_str = nil
      if possible_assoc && assoc_name = self.klass.ransackable_assoc_name_for(possible_assoc)
        # Get the model for this association and lookup the full column name on it
        assoc = self.klass.reflect_on_all_associations.find{|a| a.name.to_s == assoc_name}
        attr_name = assoc.klass.ransackable_column_name_for(possible_attr_name)
        decoded_str = "#{assoc_name}_#{attr_name.blank? ? possible_attr_name : attr_name}"
      elsif attr_name = self.klass.ransackable_column_name_for(possible_attr_name)
        decoded_str = attr_name
      end
      
      decoded_str
    end
  end
end