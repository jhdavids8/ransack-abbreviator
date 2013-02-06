module Ransack
  module Nodes
    class Condition
      alias_method :ransack_condition_build, :build
      
      def build(params)
        attrs = params[:a]
        if !attrs.blank?
          case attrs
          when Array
            attrs.each_with_index do |attr, i|
              params[:a][i] = @context.decode_parameter(attr)
            end
          when Hash
            attrs.each do |index, attr|
              params[:a][index][:name] = @context.decode_parameter(attr[:name])
            end
          end
        end
        ransack_condition_build(params)
      end
    end
  end
end