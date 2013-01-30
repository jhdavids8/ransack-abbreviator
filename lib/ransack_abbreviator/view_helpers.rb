module RansackAbbreviator
  module ViewHelpers
    def get_abbreviated_form_for(ransack_search_object, ransack_name)
      str = ransack_name.is_a?(Symbol) ? ransack_name.to_s : ransack_name.dup
      name = Ransack::Predicate.detect_and_strip_from_string!(str)
      parent, attr_name = ransack_search_object.context.test(str)
      column_abbr = RansackAbbreviator.column_abbreviations[attr_name]  # Jamie: Have a getter method that returns the full name if no column abbr defined
      table_abbr = defined?(parent.tables) ? RansackAbbreviator.table_abbreviations[parent.tables[0].name] : nil
      table_abbr ? "#{table_abbr}.#{column_abbr}_#{name}" : "#{column_abbr}_#{name}"
      # if ransack_search_object.base.attribute_method?(ransack_name)
      #         # condition = Condition.extract(@context, "countries_name_eq", ["Italy"])
      #         # puts condition -> Condition <attributes: ["countries_name"], predicate: eq, values: ["Italy"]>
      #         # create a new attribute
      #         
      #         attr = Attribute.new(ransack_search_object.context, "children_name")
      #         ransack_search_object.context.bind(attr, "children_name")
      #         ransack_search_object.context.contextualize("children_name")
      #       end
    end
  end
end

ActionView::Base.send :include, RansackAbbreviator::ViewHelpers