$:.unshift(File.expand_path('../../lib', __FILE__))

require 'bundler'
Bundler.setup :default
require 'yaml'
require 'flipper-activerecord'
require 'database_cleaner'

ENV["RAILS_ENV"] = "test"
config = YAML.load(File.read("spec/database.yml"))

ActiveRecord::Base.establish_connection config["postgresql"]
ActiveRecord::Migration.verbose = true

require 'generators/flipper/templates/migration'
ActiveRecord::Schema.define do
  CreateFlipperTables.up

#   create_table :stories, primary_key: :story_id, force: true do |table|
#     table.string :text
#     table.boolean :scoped, default: true
#   end
end

# Add this directory so the ActiveSupport autoloading works
ActiveSupport::Dependencies.autoload_paths << File.dirname(__FILE__)

RSpec.configure do |config|
  config.filter_run :focused => true
  config.alias_example_to :fit, :focused => true
  config.alias_example_to :xit, :pending => true
  config.run_all_when_everything_filtered = true
  config.fail_fast = true

  config.backtrace_exclusion_patterns = [
    /rspec-(core|expectations)/,
  ]

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  config.after(:suite) do
    ActiveRecord::Schema.define do
      CreateFlipperTables.down
    end
  end
end
