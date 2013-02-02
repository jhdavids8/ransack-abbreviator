require 'ransack_abbreviator/abbreviators/decoder'
require 'ransack_abbreviator/abbreviators/encoder'

module Ransack
  class Context
    include RansackAbbreviator::Abbreviators::Decoder
    include RansackAbbreviator::Abbreviators::Encoder
    
    def get_associations_parent_and_attribute(str, klass = @klass, associations = [])
      attr_name = nil
      if ransackable_attribute?(str, klass)
        attr_name = str
      elsif (segments = str.split(/_/)).size > 1
        remainder = []
        found_assoc = nil
        while !found_assoc && remainder.unshift(segments.pop) && segments.size > 0 do
          assoc, poly_class = unpolymorphize_association(segments.join('_'))
          if found_assoc = get_association(assoc, klass)
            attr_name = remainder.join('_')
            associations, klass, attr_name = get_associations_parent_and_attribute(attr_name, poly_class || found_assoc.klass, associations << found_assoc)
          end
        end
      end

      [associations, klass, attr_name]
    end
    
    private
    
    def polymorphic_association_specified?(str)
      str && str.match(/_of_([^_]+?)_type$/)
    end
  end
end