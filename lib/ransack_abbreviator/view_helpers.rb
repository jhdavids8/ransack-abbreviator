module RansackAbbreviator
  module ViewHelpers
    def ransack_abbreviation_for(ransack_search_object, ransack_name)
      # Jamie: Cleanup this code...these nested ifs and whatnot
      str = ransack_name.is_a?(Symbol) ? ransack_name.to_s : ransack_name.dup
      pred = Ransack::Predicate.detect_and_strip_from_string!(str)
      conjunctions = str.split("_").select{|s| s == "and" || s == "or" }
      abbr_str = ""
      str.split(/_and_|_or_/).each do |s|
        associations, parent, attr_name = ransack_search_object.context.get_associations_parent_and_attribute(s)
        if attr_name
          unless associations.blank?
            encoded_associations, parent = ransack_search_object.context.encode_associations(associations, s)
            abbr_str << "#{encoded_associations}."
          end
          # Lookup the column abbr on the parent of the column
          abbr_str << parent.ransackable_column_abbr_for(attr_name)
        else
          abbr_str << s
        end
        
        abbr_str << "_#{conjunctions.shift}_" if !conjunctions.blank?
      end
      
      pred ? "#{abbr_str}_#{pred}" : abbr_str
    end
    
    def ransack_abbreviations_for(ransack_search_object, params)
      new_params = nil
      
      case params
      when Hash
        new_params = {}
        params.each do |ransack_name, value|
          new_params[ransack_abbreviation_for(ransack_search_object, ransack_name)] = value
        end
      when Array
        new_params = []
        params.each do |ransack_name|
          new_params << ransack_abbreviation_for(ransack_search_object, ransack_name)
        end
      else
        raise ArgumentError, "don't know how to interpret abbreviations for #{params}"
      end
      
      new_params
    end
  end
end

ActionView::Base.send :include, RansackAbbreviator::ViewHelpers