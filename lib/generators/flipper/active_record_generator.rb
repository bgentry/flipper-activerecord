require 'rails/generators/base'
require "rails/generators/migration"
require "rails/generators/active_record"

# Extend Rails::Generators::Base so that it creates an AR migration
module Flipper
  class ActiveRecordGenerator < Rails::Generators::Base
    include Rails::Generators::Migration
    desc "This generator creates a migration to create Flipper ActiveRecord tables."

    source_paths << File.join(File.dirname(__FILE__), "templates")

    def create_migration_file
      migration_template "migration.rb", "db/migrate/create_flipper_tables.rb"
    end

    def self.next_migration_number(dirname)
      ::ActiveRecord::Generators::Base.next_migration_number dirname
    end
  end
end
