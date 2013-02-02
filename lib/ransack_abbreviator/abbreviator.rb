module RansackAbbreviator
  module Abbreviator
    def decode_possible_abbr(possible_abbr)
      possible_assoc, possible_attr_abbr = get_possible_assoc_and_attribute_abbr(possible_abbr)
      decode_possible_abbreviations(possible_attr_abbr, possible_assoc)
    end
    
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
      decoded_str, klass = possible_assoc_abbr ? decode_assoc_abbr(possible_assoc_abbr) : ["", self.klass]

      if attr_name = decode_column_abbr(possible_attr_abbr, klass)
        decoded_str << attr_name
      else
        decoded_str << possible_attr_abbr
      end
      
      decoded_str
    end
    
    def decode_assoc_abbr(possible_assoc_abbr)
      # possible_assoc_abbr can be a chain of abbreviated associations, so decode them all and reconstruct into
      # the format expected by Ransack
      decoded_str = ""
      segments = possible_assoc_abbr.split(/_/)
      association_parts = []
      klass = self.klass
      
      while segments.size > 0 && association_parts << segments.shift
        assoc_to_test = association_parts.join('_')
        if polymorphic_association_specified?(assoc_to_test)
          assoc_name, class_type = get_polymorphic_assoc_and_class_type(assoc_to_test)
          klass = Kernel.const_get(class_type)
          decoded_str << "of_#{class_type}_type_"
          association_parts.clear
        elsif assoc_name = klass.ransackable_assoc_name_for(assoc_to_test)
          assoc = klass.reflect_on_all_associations.find{|a| a.name.to_s == assoc_name}
          # Get the model for this association, as the next association/attribute will be related to it
          klass = assoc.klass unless assoc.options[:polymorphic]
          decoded_str << "#{assoc_name}_"
          association_parts.clear unless segments[0] == "of"  # Cheat a bit. We want to clear unless this is a polymorphic query
        end
      end

      decoded_str = "#{possible_assoc_abbr}_" if decoded_str.blank?
      [decoded_str, klass]
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