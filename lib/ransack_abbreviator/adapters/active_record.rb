require 'active_record'
require 'ransack_abbreviator/adapters/active_record/base'
ActiveRecord::Base.extend RansackAbbreviator::Adapters::ActiveRecord::Base