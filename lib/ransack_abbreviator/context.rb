# Jamie: Split this up into the right folder/file structure

module Ransack
  class Context
    alias_method :ransackable_attribute_wo_abbr?, :ransackable_attribute?
    
    def extract_parent_and_attribute(str)
      parent, attr_name = get_parent_and_attribute_name(str)
    end

    def ransackable_attribute?(str, klass)
      ransackable_attribute_wo_abbr?(str, klass) || klass.ransackable_abbreviations.values.include?(str)
    end
  end
  
  module Adapters
    module ActiveRecord
      class Context
        # alias_method :ransack_type_for, :type_for
        # 
        #         def type_for(attr)
        #           ransack_type_for(attr)
        #         end
      end
    end
  end
  
  module Nodes
    class Attribute
      # alias_method :ransack_name=, :name=
      alias_method :ransack_attr_name=, :attr_name=
      #       
      #       def name=(name)
      #         # Jamie: Here. name was "children_nm"
      #         name = "name" if name == "nm"
      #         self.ransack_name = name
      #       end
      #       
      def attr_name=(attr_name)
        self.ransack_attr_name = context.klassify(parent).ransackable_column_name_for(attr_name)
      end
    end
  end
end