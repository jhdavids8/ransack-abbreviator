module RansackAbbreviator
  module Abbreviators
    module Encoder
      def encode_ransack_str(str)
        encoded_str = ""
        associations, attr_name = self.get_associations_and_attribute(str)
        parent_of_attribute = self.klass
        
        if attr_name
          unless associations.blank?
            encoded_associations, parent_of_attribute = self.encode_associations(associations, str)
            encoded_str = "#{encoded_associations}."
          end
          encoded_str << self.encode_attribute(attr_name, parent_of_attribute)
        else
          encoded_str = str
        end
        
        encoded_str
      end
      
      def encode_associations(associations, ransack_name)
        klass = self.klass
        encoded_str = ""
        
        associations.each_with_index do |assoc, i|
          encoded_str << "_" unless i == 0
          encoded_str << klass.ransackable_assoc_abbr_for(assoc.name.to_s)
          if assoc.options[:polymorphic] && (match = ransack_name.match(/_of_([^_]+?)_type.*$/))
            # Polymorphic belongs_to format detected
            # Lookup the association abbreviation out of all association abbreviations, as the value 
            # can be the name of any model (e.g. PersonItem...which is why we underscore)
            klass_name = match.captures.first
            encoded_str << "_of_#{RansackAbbreviator.assoc_abbreviation_for(klass_name.underscore)}_type"
            klass = Kernel.const_get(klass_name)
          else
            klass = assoc.klass
          end
        end
        
        [encoded_str, klass]
      end
      
      def encode_attribute(attr_name, parent=@klass)
        parent.ransackable_column_abbr_for(attr_name)
      end
    end
  end
end