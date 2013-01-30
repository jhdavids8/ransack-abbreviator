require "ostruct"
require "yaml"
require 'ransack_abbreviator/configuration'

module RansackAbbreviator
  extend Configuration
end

RansackAbbreviator.configure do |config|
  parsed_config = OpenStruct.new((YAML.load_file(config.config_dir.join("ransack_abbreviator.yml")) rescue {}))
  ransack_abbreviations = parsed_config.ransack_abbreviations
  config.column_abbreviations = ransack_abbreviations["columns"] if ransack_abbreviations["columns"]
  config.table_abbreviations = ransack_abbreviations["tables"] if ransack_abbreviations["tables"]
end

require "ransack_abbreviator/context"
require "ransack_abbreviator/view_helpers"