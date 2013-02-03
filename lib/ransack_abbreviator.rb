require "ostruct"
require "yaml"
require 'ransack_abbreviator/configuration'
require 'ransack_abbreviator/constants'

module RansackAbbreviator
  extend Configuration
  
  class DuplicateColumnAbbreviation < StandardError; end;
end

RansackAbbreviator.configure do |config|
  parsed_config = OpenStruct.new((YAML.load_file(config.config_dir.join("ransack_abbreviator.yml")) rescue {}))
  ransack_abbreviations = parsed_config.ransack_abbreviations
  if !(ransack_abbreviations["columns"].values & RansackAbbreviator::Constants::RESERVED_KEYWORDS).blank? ||
    !(ransack_abbreviations["associations"].values & RansackAbbreviator::Constants::RESERVED_KEYWORDS).blank?
    fail "You used a reserved keyword as an abbreviation. Reserverd keywords: #{RansackAbbreviator::Constants::RESERVED_KEYWORDS.join(", ")}"
  end
  config.column_abbreviations = ransack_abbreviations["columns"] if ransack_abbreviations["columns"]
  config.assoc_abbreviations = ransack_abbreviations["associations"] if ransack_abbreviations["associations"]
end

require "ransack_abbreviator/ransack_extensions/nodes/condition"
require "ransack_abbreviator/ransack_extensions/nodes/grouping"
require "ransack_abbreviator/ransack_extensions/context"
require "ransack_abbreviator/ransack_extensions/search"
require 'ransack_abbreviator/adapters/active_record'
require "ransack_abbreviator/view_helpers"