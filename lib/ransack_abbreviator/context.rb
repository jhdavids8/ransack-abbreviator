module Ransack
  class Context
    alias_method :is_ransackable_attribute?, :ransackable_attribute?
    alias_method :ransack_bind, :bind
    
    def test(str)
      # Jamie: Here. I can SO use this to extract the table and column from the string
      # column is attr_name
      # table is parent.tables[0].name (not sure if there would ever be more than 1 table). It is the actual pluralize
      # (and lower case) name for the table (e.g. "notes" when referencing a Note model)
      parent, attr_name = get_parent_and_attribute_name(str)
    end
    
    def bind(object, str)
      ransack_bind(object, str)
    end

    def ransackable_attribute?(str, klass)
      is_ransackable_attribute?(str, klass) || str == "nm"
    end
  end
  
  module Adapters
    module ActiveRecord
      class Context
        alias_method :ransack_type_for, :type_for

        def type_for(attr)
          ransack_type_for(attr)
        end
      end
    end
  end
  
  module Nodes
    class Attribute
      alias_method :ransack_name=, :name=
      alias_method :ransack_attr_name=, :attr_name=
      alias_method :ransack_initialize, :initialize
      
      def initialize(context, name = nil)
        super(context)
        self.name = name unless name.blank?
      end
      
      def name=(name)
        # Jamie: Here. name was "children_nm"
        name = "name" if name == "nm"
        self.ransack_name = name
      end
      
      def attr_name=(attr_name)
        attr_name = "name" if attr_name == "nm"
        self.ransack_attr_name = attr_name
      end
    end
  end
end