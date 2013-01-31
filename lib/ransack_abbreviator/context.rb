# Jamie: Split this up into the right folder/file structure

module Ransack
  class Context
    alias_method :ransackable_attribute_wo_abbr?, :ransackable_attribute?
    alias_method :ransackable_association_wo_abbr?, :ransackable_association?
    
    def get_association_model_and_attribute(str, klass = @klass, assoc = nil)
      attr_name = found_assoc = nil
      
      if ransackable_attribute?(str, klass)
        attr_name = str
      elsif (segments = str.split(/_/)).size > 1
        remainder = []
        while !found_assoc && remainder.unshift(segments.pop) && segments.size > 0 do
          assoc, poly_class = unpolymorphize_association(segments.join('_'))
          if found_assoc = get_association(assoc, klass)
            attr_name = remainder.join('_')
            klass, assoc, attr_name = get_association_model_and_attribute(attr_name, poly_class || found_assoc.klass, found_assoc)
          end
        end
      end

      [klass, assoc, attr_name]
    end

    def ransackable_attribute?(str, klass)
      ransackable_attribute_wo_abbr?(str, klass) || klass.ransackable_column_abbreviations.values.include?(str)
    end
    
    def ransackable_association?(str, klass)
      ransackable_association_wo_abbr?(str, klass) || klass.ransackable_assoc_abbreviations.values.include?(str)
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