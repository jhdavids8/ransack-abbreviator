module Ransack
  class Search
    alias_method :ransack_search_build, :build
    
    def build(params)
      # Loop through each of the params and test if any contain abbreviations. If so, convert them to the normal Ransack language
      new_params = {}
      collapse_multiparameter_attributes!(params).each do |key, value|
        pred = Predicate.detect_from_string(key)
        str = base.strip_predicate_and_index_from_param_string(key)
        if base.special_condition?(str)
          # Maintain the param as-is
          new_params[key] = value
        else
          conjunctions = str.split("_").select{|s| s == "and" || s == "or" }
          full_str = ""
          str.split(/_and_|_or_/).each do |s|
            possible_assoc, possible_attr_name = get_possible_assoc_and_attribute_abbr(s)
            
            if possible_assoc && assoc_name = self.klass.ransackable_assoc_name_for(possible_assoc)
              # Get the model for this association and lookup the full column name on it
              assoc = self.klass.reflect_on_all_associations.find{|a| a.name.to_s == assoc_name}
              attr_name = assoc.klass.ransackable_column_name_for(possible_attr_name)
              full_str << "#{assoc_name}_#{attr_name.blank? ? possible_attr_name : attr_name}"
            elsif attr_name = self.klass.ransackable_column_name_for(possible_attr_name)
              full_str << attr_name
            else
              # For some reason, we couldn't find the association, so maintain the parameter name as-is
              full_str << s
            end
            
            full_str << "_#{conjunctions.shift}_" if !conjunctions.blank?
          end
          full_str << "_#{pred}" if pred
          new_params[full_str] = value
        end
      end
      
      ransack_search_build(new_params)
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
  end
end