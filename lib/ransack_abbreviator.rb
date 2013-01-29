require "ostruct"
require "pathname"
require "yaml"
require 'ransack_abbreviator/configuration'


module RansackAbbreviator
  extend Configuration
  @@config = nil
  
  def self.config
    binding.pry
    @@config ||= OpenStruct.new((YAML.load_file(config_dir.join("ransack_abbreviator.yml")) rescue {}))
    yield(@@config) if block_given?

    @@config
  end
  
  private
  def self.config_dir
    defined?(Rails) ? Rails.root.join("config") : Pathname.new("config")
  end
end

RansackAbbreviator.configure do |config|
  begin
    OpenStruct.new(YAML.load_file(config_dir.join("ransack_abbreviator.yml")).ransack_abbreviations.each do |abbr_type, abbreviations|
      case abbr_type
      when "columns"
        abbreviations.each do |column_name, abbr_name|
          
        end
      when "tables"
        abbreviations.each do |table_name, abbr_name|
          
        end
      end
    end
  rescue
    # Jamie: Only catch the error when a config file does not exist. Otherwise, we'll want everything else to get through
  end
end

require "ransack_abbreviator/context"