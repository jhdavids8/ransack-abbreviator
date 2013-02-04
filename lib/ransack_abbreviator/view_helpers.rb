module RansackAbbreviator
  module ViewHelpers
    def ransack_abbreviation_for(ransack_search_object, param)
      ransack_search_object.context.encode_parameter(param)
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