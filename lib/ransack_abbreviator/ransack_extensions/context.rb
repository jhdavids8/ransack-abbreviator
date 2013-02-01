require 'ransack_abbreviator/abbreviator'

module Ransack
  class Context
    include RansackAbbreviator::Abbreviator
    
    def get_association_model_and_attribute(str, klass = @klass, assoc = nil)
      attr_name = found_assoc = nil
      
      if ransackable_attribute?(str, klass)
        attr_name = str
      elsif (segments = str.split(/_/)).size > 1
        remainder = []
        while !found_assoc && remainder.unshift(segments.pop) && segments.size > 0 do
          assoc, poly_class = unpolymorphize_association(segments.join('_'))
          if found_assoc = get_association(assoc, klass)
            attr_name = remainder.join('_')
            klass, assoc, attr_name = get_association_model_and_attribute(attr_name, poly_class || found_assoc.klass, found_assoc)
          end
        end
      end

      [klass, assoc, attr_name]
    end
    
    def polymorphic_association_specified?(str)
      str && str.match(/_of_([^_]+?)_type$/)
    end
  end
end