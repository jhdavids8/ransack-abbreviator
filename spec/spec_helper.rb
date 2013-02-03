require 'machinist/active_record'
require 'sham'
require 'faker'
require 'ransack'
require 'ransack_abbreviator'
require 'pry'

Dir[File.expand_path('../{helpers,support,blueprints}/*.rb', __FILE__)].each do |f|
  require f
end

Sham.define do
  name     { Faker::Name.name }
  middle_name     { Faker::Name.name }
  title    { Faker::Lorem.sentence }
  body     { Faker::Lorem.paragraph }
  salary   {|index| 30000 + (index * 1000)}
  tag_name { Faker::Lorem.words(3).join(' ') }
  note     { Faker::Lorem.words(7).join(' ') }
end

RSpec.configure do |config|
  config.include RansackAbbreviator::ViewHelpers
  
  config.before(:suite) do
    puts '=' * 80
    puts "Running specs against ActiveRecord #{ActiveRecord::VERSION::STRING} and ARel #{Arel::VERSION}..."
    puts '=' * 80
    Schema.create
  end

  config.before(:all) do
    Sham.reset(:before_all)
    RansackAbbreviator.configure do |config|
      config.add_column_abbreviation(:name, :nm)
      config.add_column_abbreviation(:title, :tl)
      config.add_column_abbreviation(:middle_name, :mn)
      config.add_column_abbreviation(:vote_count, :vc)
      config.add_assoc_abbreviation(:person, :pr)
      config.add_assoc_abbreviation(:parent, :pa)
      config.add_assoc_abbreviation(:children, :ch)
      config.add_assoc_abbreviation(:comments, :cm)
      config.add_assoc_abbreviation(:authored_article_comments, :a_ac)
      config.add_assoc_abbreviation(:notable, :nbl)
    end
  end
  
  config.before(:each)  { Sham.reset(:before_each) }
end

RSpec::Matchers.define :be_like do |expected|
  match do |actual|
    actual.gsub(/^\s+|\s+$/, '').gsub(/\s+/, ' ').strip ==
      expected.gsub(/^\s+|\s+$/, '').gsub(/\s+/, ' ').strip
  end
end

RSpec::Matchers.define :have_attribute_method do |expected|
  match do |actual|
    actual.attribute_method?(expected)
  end
end
