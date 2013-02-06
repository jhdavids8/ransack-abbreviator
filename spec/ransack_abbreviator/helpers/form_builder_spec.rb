require 'spec_helper'

module Ransack
  module Helpers
    describe FormBuilder do
      # Below setup copied from Ransack 0.7.2 form_builder_spec
      router = ActionDispatch::Routing::RouteSet.new
      router.draw do
        resources :people
        match ':controller(/:action(/:id(.:format)))'
      end

      include router.url_helpers

      # FIXME: figure out a cleaner way to get this behavior
      before do
        @controller = ActionView::TestCase::TestController.new
        @controller.instance_variable_set(:@_routes, router)
        @controller.class_eval do
          include router.url_helpers
        end

        @controller.view_context_class.class_eval do
          include router.url_helpers
        end

        @s = Person.search
        @controller.view_context.search_form_for @s do |f|
          @f = f
        end
      end
      
      describe 'form helpers with abbreviations' do
        it 'shortens the method to defined Ransack abbreviations' do
          html = @f.abbr_label :name_eq
          html.should match /for="q_nm_eq"/
          
          html = @f.abbr_select :children_name_eq, "<option value=\"Ernie\">Ernie</option><option value=\"Bob\">Bob</option>"
          html.should match /id="q_ch.nm_eq"/
        end
        
        it 'uses the full name for undefined abbreviations' do
          html = @f.abbr_text_area :articles_body_cont
          html.should match /id="q_articles.body_cont"/
        end
        
        it 'selects previously-entered values' do
          @s.name_eq = 'Ernie'
          html = @f.abbr_text_field :name_eq
          html.should match /value="Ernie"/
          
          @s.children_name_eq = 'Ernie'
          html = @f.abbr_text_field :children_name_eq
          html.should match /value="Ernie"/
        end
      end
      
      describe '#abbr_attribute_select' do
        it 'returns ransackable attributes as abbreviations' do
          html = @f.abbr_attribute_select
          html.split(/\n/).should have(Person.ransackable_attributes.size + 1).lines
          Person.ransackable_attributes.each do |attribute|
            html.should match /<option value="#{@s.context.encode_parameter(attribute)}">/
          end
        end
        
        it 'returns ransackable attributes as abbreviations for associations' do
          attributes = Person.ransackable_attributes + Comment.ransackable_attributes.map {|a| "authored_article_comments_#{a}"}
          html = @f.abbr_attribute_select :associations => ['authored_article_comments']
          html.split(/\n/).should have(attributes.size).lines
          attributes.each do |attribute|
            html.should match /<option value="#{@s.context.encode_parameter(attribute)}">/
          end
        end
      end
    end
  end
end