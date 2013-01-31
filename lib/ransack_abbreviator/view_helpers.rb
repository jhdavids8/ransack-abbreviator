module RansackAbbreviator
  module ViewHelpers
    def get_abbreviated_form_for(ransack_search_object, ransack_name)
      str = ransack_name.is_a?(Symbol) ? ransack_name.to_s : ransack_name.dup
      pred = Ransack::Predicate.detect_and_strip_from_string!(str)
      conjunctions = str.split("_").select{|s| s == "and" || s == "or" }
      abbr_str = ""
      str.split(/_and_|_or_/).each do |s|
        parent, assoc, attr_name = ransack_search_object.context.get_association_model_and_attribute(s)
        # Lookup the association abbr on the subject of the search
        abbr_str << ransack_search_object.klass.ransackable_assoc_name_for(assoc.name.to_s) << "." if assoc
        # Lookup the column abbr on the parent of the column (could be the same as the subject of the search, 
        # could be an associated model)
        abbr_str << ransack_search_object.context.klassify(parent).ransackable_column_name_for(attr_name)
        abbr_str << "_#{conjunctions.shift}_" if !conjunctions.blank?
      end
      
      "#{abbr_str}_#{pred}"
    end
  end
end

ActionView::Base.send :include, RansackAbbreviator::ViewHelpers