require 'ransack_abbreviator/abbreviators/decoder'
require 'ransack_abbreviator/abbreviators/encoder'

module Ransack
  class Context
    attr_reader :decoder, :encoder
    alias_method :full_ransackable_attribute?, :ransackable_attribute?
    alias_method :full_ransackable_association?, :ransackable_association?
    
    delegate :encode_ransack_str, to: :encoder
    delegate :decode_parameter, :decode_possible_abbr, to: :decoder
    
    def get_associations_and_attribute(str, klass = @klass, associations = [])
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
            associations, attr_name = get_associations_and_attribute(attr_name, poly_class || found_assoc.klass, associations << found_assoc)
          end
        end
      end

      [associations, attr_name]
    end
    
    def decoder
      @decoder ||= RansackAbbreviator::Abbreviators::Decoder.new(self)
    end
    
    def encoder
      @encoder ||= RansackAbbreviator::Abbreviators::Encoder.new(self)
    end
    
    def ransackable_attribute?(str, klass)
      full_ransackable_attribute?(str, klass) || ransackable_attribute_abbreviation?(str, klass)
    end
    
    def ransackable_association?(str, klass)
      full_ransackable_association?(str, klass) || ransackable_assoc_abbreviation?(str, klass)
    end
    
    def ransackable_attribute_abbreviation?(str, klass)
      klass.ransackable_column_abbreviations.has_value?(str)
    end
    
    def ransackable_assoc_abbreviation?(str, klass)
      klass.ransackable_assoc_abbreviations.has_value?(str)
    end
    
    def self.polymorphic_association_specified?(str)
      str && str.match(/_of_([^_]+?)_type$/)
    end
  end
end