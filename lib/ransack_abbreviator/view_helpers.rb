module RansackAbbreviator
  module ViewHelpers
    def ransack_abbreviation_for(ransack_search_object, ransack_name)
      str = ransack_name.is_a?(Symbol) ? ransack_name.to_s : ransack_name.dup
      pred = Ransack::Predicate.detect_and_strip_from_string!(str)
      conjunctions = str.split("_").select{|s| s == "and" || s == "or" }
      abbr_str = ""
      str.split(/_and_|_or_/).each do |s|
        abbr_str << ransack_search_object.context.encode_ransack_str(s)
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