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

  ActiveRecord::Base.connection.create_table :songs do |t|
    t.column :name, :string
    t.column :created_at, :datetime
    t.column :updated_at, :datetime
  end

  ActiveRecord::Base.connection.create_table :single_table_inheritance_albums do |t|
    t.column :type, :string
    t.column :created_at, :datetime
    t.column :updated_at, :datetime
  end

  ActiveRecord::Base.connection.create_table :awards do |t|
    t.column :awardable_type, :string
    t.column :awardable_id, :string
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
end

class AlbumBase < Album
  taylors_enum name: %w[debut fearless speak_now red nineteen_eighty_nine reputation lover folklore evermore]
end

class AlbumPrefix < Album
  taylors_enum name: %w[debut fearless speak_now red nineteen_eighty_nine reputation lover folklore evermore], prefix: true
end

class AlbumSuffix < Album
  taylors_enum name: %w[debut fearless speak_now red nineteen_eighty_nine reputation lover folklore evermore], suffix: true
end

class AlbumNoConstants < Album
  taylors_enum name: %w[debut fearless speak_now red nineteen_eighty_nine reputation lover folklore evermore], constants: false
end

class AlbumNoValidations < Album
  taylors_enum name: %w[debut fearless speak_now red nineteen_eighty_nine reputation lover folklore evermore], validations: false
end

module SingleTableInheritanceAlbums
  class SingleTableInheritanceAlbum < ActiveRecord::Base
    self.table_name = 'single_table_inheritance_albums'

    taylors_enum type: %w[
      SingleTableInheritanceAlbums::Debut
      SingleTableInheritanceAlbums::Fearless
      SingleTableInheritanceAlbums::SpeakNow
      SingleTableInheritanceAlbums::Red
      SingleTableInheritanceAlbums::NineteenEightyNine
      SingleTableInheritanceAlbums::Reputation
      SingleTableInheritanceAlbums::Lover
      SingleTableInheritanceAlbums::Folklore
      SingleTableInheritanceAlbums::Evermore
    ], single_table_inheritance: true
  end

  class Debut < SingleTableInheritanceAlbum; end
  class Fearless < SingleTableInheritanceAlbum; end
  class SpeakNow < SingleTableInheritanceAlbum; end
  class Red < SingleTableInheritanceAlbum; end
  class NineteenEightyNine < SingleTableInheritanceAlbum; end
  class Reputation < SingleTableInheritanceAlbum; end
  class Lover < SingleTableInheritanceAlbum; end
  class Folklore < SingleTableInheritanceAlbum; end
  class Evermore < SingleTableInheritanceAlbum; end
end

class Song < ActiveRecord::Base
  self.table_name = 'songs'
end

class Award < ActiveRecord::Base
  self.table_name = 'awards'
  belongs_to :awardable, polymorphic: true
  taylors_enum awardable_type: %w[Album Song], polymorphic: true
end
