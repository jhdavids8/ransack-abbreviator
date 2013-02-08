require "ostruct"
require "yaml"
require 'ransack'
require 'ransack_abbreviator/configuration'
require 'ransack_abbreviator/constants'
require 'ransack_abbreviator/engine' if defined? Rails


module RansackAbbreviator
  extend Configuration
end

RansackAbbreviator.configure do |config|
  if File.exist?(config.config_dir.join("ransack_abbreviator.yml"))
    parsed_config = OpenStruct.new(YAML.load_file(config.config_dir.join("ransack_abbreviator.yml")))
    ransack_abbreviations = parsed_config.ransack_abbreviations
    config.column_abbreviations = ransack_abbreviations["columns"] if ransack_abbreviations["columns"]
    config.assoc_abbreviations = ransack_abbreviations["associations"] if ransack_abbreviations["associations"]
  end
end

require "ransack_abbreviator/ransack_extensions/nodes/condition"
require "ransack_abbreviator/ransack_extensions/context"
require "ransack_abbreviator/ransack_extensions/search"
require 'ransack_abbreviator/adapters/active_record'
require "ransack_abbreviator/ransack_extensions/helpers/form_builder"