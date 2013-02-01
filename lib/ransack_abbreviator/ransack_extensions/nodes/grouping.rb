module Ransack
  module Nodes
    class Grouping < Node
      def strip_predicate_and_index_from_param_string(param_string)
        strip_predicate_and_index(param_string)
      end
      
      def special_condition?(str)
        case str
        when /^(g|c|m|groupings|conditions|combinator)=?$/
          true
        else
          false
        end
      end
    end
  end
end