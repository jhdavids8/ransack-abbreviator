module Ransack
  class Search
    alias_method :ransack_search_build, :build
    
    def build(params)
      # Loop through each of the params and test if any contain abbreviations. If so, convert them to the normal Ransack language
      new_params = {}
      collapse_multiparameter_attributes!(params).each do |key, value|
        str = key.to_s.dup
        str = str.split(/\(/).first
        pred = Ransack::Predicate.detect_and_strip_from_string!(str)
        case str
        when /^(g|c|m|groupings|conditions|combinator)=?$/
          new_params[key] = value
        else
          conjunctions = str.split("_").select{|s| s == "and" || s == "or" }
          full_str = ""
          str.split(/_and_|_or_/).each do |s|
            possible_assoc = possible_attr_name = nil
            if s.include?(".")
              parts = s.split(".")
              possible_assoc = parts[0]
              possible_attr_name = parts[1]
            else
              possible_attr_name = s
            end
            
            if !possible_assoc
              attr_name = self.klass.ransackable_column_name_for(possible_attr_name)
              full_str << (attr_name.blank? ? possible_attr_name : attr_name)
            else
              assoc_name = self.klass.ransackable_assoc_name_for(possible_assoc)
              if !assoc_name.blank?
                # Get the model for this association and lookup the full column name on it
                assoc = self.klass.reflect_on_all_associations.find{|a| a.name.to_s == assoc_name}
                attr_name = assoc.klass.ransackable_column_name_for(possible_attr_name)
                full_str << "#{assoc_name}_#{attr_name.blank? ? possible_attr_name : attr_name}"
              else
                full_str << "#{possible_assoc}.#{possible_attr_name}"
              end
            end
            
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