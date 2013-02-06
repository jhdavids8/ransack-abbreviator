require 'action_view'

module Ransack
  module Helpers
    class FormBuilder < ::ActionView::Helpers::FormBuilder
      def method_missing(method_id, *args, &block)
        method_name = method_id.to_s
        if method_name.starts_with?('abbr_')
          raise ArgumentError, "abbreviated form helpers must be called inside a search FormBuilder!" unless object.respond_to?(:context)
          ransack_name = args.shift
          actual_method = method_name.sub('abbr_', '')
          abbreviated_ransack_name = object.context.encode_parameter(ransack_name)
          self.send(actual_method, abbreviated_ransack_name, *args, &block)
        else
          super
        end
      end
      
      def abbr_attribute_select(options = {}, html_options = {})
        raise ArgumentError, "abbr_attribute_select must be called inside a search FormBuilder!" unless object.respond_to?(:context)
        options[:include_blank] = true unless options.has_key?(:include_blank)
        associations = association_array(options[:associations])
        if associations.size > 0
          bases = [''] + associations
          grouped_collection = encoded_attribute_collection_for_bases(bases)
          @template.grouped_collection_select(
            @object_name, :name, grouped_collection, :last, :first, :first, :last,
            objectify_options(options), @default_options.merge(html_options)
          )
        else
          collection = encoded_attribute_collection_for_base
          @template.collection_select(
            @object_name, :name, collection, :first, :last,
            objectify_options(options), @default_options.merge(html_options)
          )
        end
      end
      
      private
      
      def encoded_attribute_collection_for_base(base=nil)
        prefix = base.blank? ?  "" : "#{base}_"
        object.context.searchable_attributes(base).map do |attr|
          [
            object.context.encode_parameter(prefix + attr),
            Translate.attribute(prefix + attr, :context => object.context)
          ]
        end
      end
      
      def encoded_attribute_collection_for_bases(bases)
        bases.map do |base|
          begin
          [
            Translate.association(base, :context => object.context),
            encoded_attribute_collection_for_base(base)
          ]
          rescue UntraversableAssociationError => e
            nil
          end
        end.compact
      end
    end
  end
end