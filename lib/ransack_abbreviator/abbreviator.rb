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
    
    def decode_possible_abbreviations(possible_attr_abbr, possible_assoc_abbr=nil)
      decoded_str = nil
      if (polymorphic_association_specified?(possible_assoc_abbr))
        assoc_name, class_type = get_polymorphic_assoc_and_class_type(possible_assoc_abbr)
        attr_name = decode_column_abbr(possible_attr_abbr, Kernel.const_get(class_type))
        decoded_str = "#{assoc_name}_of_#{class_type}_type_#{attr_name}"
      elsif possible_assoc_abbr && assoc_name = self.klass.ransackable_assoc_name_for(possible_assoc_abbr)
        # Get the model for this association and lookup the full column name on it
        assoc = self.klass.reflect_on_all_associations.find{|a| a.name.to_s == assoc_name}
        attr_name = decode_column_abbr(possible_attr_abbr, assoc.klass)
        decoded_str = "#{assoc_name}_#{attr_name.blank? ? possible_attr_abbr : attr_name}"
      elsif attr_name = decode_column_abbr(possible_attr_abbr)
        decoded_str = attr_name
      end
      
      decoded_str
    end
    
    def decode_column_abbr(possible_attr_abbr, klass=@klass)
      klass.ransackable_column_name_for(possible_attr_abbr)
    end
    
    def get_polymorphic_assoc_and_class_type(possible_assoc_abbr)
      assoc_name = class_type = nil
      if (match = possible_assoc_abbr.match(/_of_([^_]+?)_type$/))
        assoc_name = self.klass.ransackable_assoc_name_for(match.pre_match)
        class_type = RansackAbbreviator.assoc_name_for(match.captures.first).camelize
      end
      [assoc_name, class_type]
    end
  end
end