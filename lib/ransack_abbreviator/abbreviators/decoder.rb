module RansackAbbreviator
  module Abbreviators
    class Decoder
      attr_reader :context
      
      def initialize(context)
        @context = context
      end
      
      def decode_parameter(param)
        str = param.is_a?(Symbol) ? param.to_s : param.dup
        pred = Ransack::Predicate.detect_and_strip_from_string!(str)
        decoded_param = nil
        case str
        when /^(g|c|m|groupings|conditions|combinator)=?$/
          decoded_param = param
        else
          conjunctions = str.split("_").select{|s| s == "and" || s == "or" }
          decoded_param = ""
          str.split(/_and_|_or_/).each do |possible_abbr|
            decoded_str = self.context.decode_association_and_column(possible_abbr)
            decoded_param << (!decoded_str.blank? ? decoded_str : possible_abbr)
            decoded_param << "_#{conjunctions.shift}_" if !conjunctions.blank?
          end
        end
        
        decoded_param << "_#{pred}" if pred
        decoded_param
      end
      
      def decode_association_and_column(possible_abbr)
        possible_assoc_abbr, possible_attr_abbr = extract_possible_assoc_and_attribute_abbr(possible_abbr)
        parent_of_attribute = @context.klass
        decoded_str = ""
        if possible_assoc_abbr 
          decoded_str, parent_of_attribute = decode_association(possible_assoc_abbr)
        end

        if attr_name = decode_attribute(possible_attr_abbr, parent_of_attribute)
          decoded_str << attr_name
        else
          decoded_str << possible_attr_abbr
        end
      
        decoded_str
      end
    
      def decode_association(possible_assoc_abbr)
        # possible_assoc_abbr can be a chain of abbreviated associations, so decode them all and reconstruct into
        # the format expected by Ransack
        decoded_str = ""
        segments = possible_assoc_abbr.split(/_/)
        association_parts = []
        klass = @context.klass
      
        while segments.size > 0 && association_parts << segments.shift
          assoc_to_test = association_parts.join('_')
          if Ransack::Context.polymorphic_association_specified?(assoc_to_test)
            assoc_name, class_type = get_polymorphic_assoc_and_class_type(assoc_to_test)
            klass = Kernel.const_get(class_type)
            decoded_str << "of_#{class_type}_type_"
            association_parts.clear
          elsif assoc_name = klass.ransackable_assoc_name_for(assoc_to_test)
            assoc = klass.reflect_on_all_associations.find{|a| a.name.to_s == assoc_name}
            decoded_str << "#{assoc_name}_"
            unless assoc.options[:polymorphic]
              # Get the model for this association, as the next association/attribute will be related to it
              klass = assoc.klass 
              association_parts.clear
            end
          end
        end

        decoded_str = "#{possible_assoc_abbr}_" if decoded_str.blank?
        [decoded_str, klass]
      end
    
      def decode_attribute(possible_attr_abbr, klass=@context.klass)
        klass.ransackable_column_name_for(possible_attr_abbr)
      end
      
      private
    
      def get_polymorphic_assoc_and_class_type(possible_assoc_abbr)
        assoc_name = class_type = nil
        if (match = possible_assoc_abbr.match(/_of_([^_]+?)_type$/))
          assoc_name = @context.klass.ransackable_assoc_name_for(match.pre_match)
          class_type = RansackAbbreviator.assoc_name_for(match.captures.first).camelize
        end
        [assoc_name, class_type]
      end
      
      def extract_possible_assoc_and_attribute_abbr(s)
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
    end
  end
end