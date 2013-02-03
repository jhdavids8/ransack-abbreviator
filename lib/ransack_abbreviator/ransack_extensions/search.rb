module Ransack
  class Search
    alias_method :ransack_search_build, :build
    
    def build(params)
      # Loop through each of the params and test if any contain abbreviations. If so, convert them to the normal Ransack language
      new_params = {}
      collapse_multiparameter_attributes!(params.with_indifferent_access).each do |key, value|
        pred = Predicate.detect_from_string(key)
        str = base.strip_predicate_and_index_from_param_string(key)
        if base.special_condition?(str)
          # Maintain the param as-is
          new_params[key] = value
        else
          conjunctions = str.split("_").select{|s| s == "and" || s == "or" }
          full_str = ""
          str.split(/_and_|_or_/).each do |possible_abbr|
            decoded_str = self.context.decode_possible_abbr(possible_abbr)
            full_str << (!decoded_str.blank? ? decoded_str : possible_abbr)
            full_str << "_#{conjunctions.shift}_" if !conjunctions.blank?
          end
          full_str << "_#{pred}" if pred
          new_params[full_str] = value
        end
      end

      ransack_search_build(new_params)
    end
  end
end