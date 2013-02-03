module Ransack
  module Nodes
    class Condition
      alias_method :ransack_condition_build, :build
      
      def build(params)
        decoded_attr_names = []
        params[:a].each do |possible_abbr|
          decoded_attr_names << @context.decode_parameter(possible_abbr)
        end
        params[:a] = decoded_attr_names
        ransack_condition_build(params)
      end
    end
  end
end