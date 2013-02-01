module RansackAbbreviator
  module ViewHelpers
    def ransack_abbreviation_for(ransack_search_object, ransack_name)
      # Jamie: Cleanup this code...these nested ifs and whatnot
      str = ransack_name.is_a?(Symbol) ? ransack_name.to_s : ransack_name.dup
      pred = Ransack::Predicate.detect_and_strip_from_string!(str)
      conjunctions = str.split("_").select{|s| s == "and" || s == "or" }
      abbr_str = ""
      str.split(/_and_|_or_/).each do |s|
        parent, assoc, attr_name = ransack_search_object.context.get_association_model_and_attribute(s)
        if assoc
          # Lookup the association abbr on the subject of the search
          abbr_str << ransack_search_object.klass.ransackable_assoc_abbr_for(assoc.name.to_s)
          
          if (match = s.match(/_of_([^_]+?)_type.*$/))
            # Polymorphic belongs_to format detected
            # Lookup the association abbreviation out of all association abbreviations, as the value 
            # can be the name of any model (e.g. Person...which is why we downcase)
            abbr_str << "_of_" << RansackAbbreviator.assoc_abbreviation_for(match.captures.first.downcase) << "_type"
          end
          
          abbr_str << "." 
        end
        # Lookup the column abbr on the parent of the column (could be the same as the subject of the search, 
        # could be an associated model)
        abbr_str << ransack_search_object.context.klassify(parent).ransackable_column_abbr_for(attr_name)
        abbr_str << "_#{conjunctions.shift}_" if !conjunctions.blank?
      end
      
      "#{abbr_str}_#{pred}"
    end
  end
end

ActionView::Base.send :include, RansackAbbreviator::ViewHelpers