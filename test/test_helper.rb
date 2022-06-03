# frozen_string_literal: true
require "rubygems"
require "bundler/setup"

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require "taylors_enum"
require "active_record"
require "active_support"

require "minitest/autorun"
require "pry"

db_config = YAML.load_file(File.expand_path("../database.yml", __FILE__)).fetch("postgresql")
ActiveRecord::Base.establish_connection(db_config)

def setup_db
  ActiveRecord::Base.connection.create_table :albums do |t|
    t.column :name, :string
    t.column :created_at, :datetime
    t.column :updated_at, :datetime
  end
end

def teardown_db
  tables =
    if ActiveRecord::VERSION::MAJOR >= 5
      ActiveRecord::Base.connection.data_sources
    else
      ActiveRecord::Base.connection.tables
    end

  tables.each do |table|
    ActiveRecord::Base.connection.drop_table(table)
  end
end

class Album < ActiveRecord::Base
  self.table_name = 'albums'
  taylors_enum name: %w[debut fearless speak_now red nineteen_eighty_nine reputation lover folklore evermore]
end
