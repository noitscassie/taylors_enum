# taylors_enum

taylors_enum is a gem that builds on top of ActiveRecord's built in [enums](https://api.rubyonrails.org/v5.2.4.4/classes/ActiveRecord/Enum.html#method-i-enum). Specifically, it will:

###### - Define additional methods to make it clearer which values exist in Rails-land, and which in the database
In Rails:
```
class Album < ActiveRecord::Base
  self.table_name = 'albums'
  enum name: %w[debut fearless speak_now red nineteen_eighty_nine reputation lover folklore evermore]
end

[1] pry(#<TestDefault>)> Album.names
=> {"debut"=>0, "fearless"=>1, "speak_now"=>2, "red"=>3, "nineteen_eighty_nine"=>4, "reputation"=>5, "lover"=>6, "folklore"=>7, "evermore"=>8}
```

With taylors_enum:
```
class AlbumBase < Album
  taylors_enum name: %w[debut fearless speak_now red nineteen_eighty_nine reputation lover folklore evermore]
end

[2] pry(#<TestDefault>)> AlbumBase.name_rails_values
=> ["debut", "fearless", "speak_now", "red", "nineteen_eighty_nine", "reputation", "lover", "folklore", "evermore"]
[3] pry(#<TestDefault>)> AlbumBase.name_database_values
=> ["debut", "fearless", "speak_now", "red", "nineteen_eighty_nine", "reputation", "lover", "folklore", "evermore"]

```


###### - Define constants for each value provided
```
class AlbumBase < Album
  taylors_enum name: %w[debut fearless speak_now red nineteen_eighty_nine reputation lover folklore evermore]
end

[5] pry(#<TestDefault>)> AlbumBase::FOLKLORE
=> "folklore"
[6] pry(#<TestDefault>)> AlbumBase::EVERMORE
=> "evermore"
# etc.

```

###### - Enables support for all the enum goodness when enumerating classes for Single Table Inheritance
```
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

[5] pry(#<TestSingleTableInheritance>)> album = ::SingleTableInheritanceAlbums::Debut.create
=> #<SingleTableInheritanceAlbums::Debut:0x000000010581a708 id: 2, type: "SingleTableInheritanceAlbums::Debut", created_at: 2022-06-04 14:34:24.951932 UTC, updated_at: 2022-06-04 14:34:24.951932 UTC>
[6] pry(#<TestSingleTableInheritance>)> album.type
=> "SingleTableInheritanceAlbums::Debut"
[7] pry(#<TestSingleTableInheritance>)> album.debut?
=> true
[8] pry(#<TestSingleTableInheritance>)> album.fearless!
=> true
[9] pry(#<TestSingleTableInheritance>)> album.debut?
=> false
[10] pry(#<TestSingleTableInheritance>)> album.fearless?
=> true
[11] pry(#<TestSingleTableInheritance>)> album.type
=> "SingleTableInheritanceAlbums::Fearless"
[12] pry(#<TestSingleTableInheritance>)> ::SingleTableInheritanceAlbums::SingleTableInheritanceAlbum.fearless
=> [#<SingleTableInheritanceAlbums::Fearless:0x00000001059821e0 id: 1, type: "SingleTableInheritanceAlbums::Fearless", created_at: 2022-06-04 14:33:55.178418 UTC, updated_at: 2022-06-04 14:33:55.178418 UTC>,
 #<SingleTableInheritanceAlbums::Fearless:0x0000000105981a10 id: 2, type: "SingleTableInheritanceAlbums::Fearless", created_at: 2022-06-04 14:34:24.951932 UTC, updated_at: 2022-06-04 14:34:50.616316 UTC>]
[13] pry(#<TestSingleTableInheritance>)> ::SingleTableInheritanceAlbums::SingleTableInheritanceAlbum.fearless.to_sql
=> "SELECT \"single_table_inheritance_albums\".* FROM \"single_table_inheritance_albums\" WHERE \"single_table_inheritance_albums\".\"type\" = 'SingleTableInheritanceAlbums::Fearless'"
```

###### - Enables support for all the enum goodness when enumerating classes for Polymorphic Associations
Note: this excludes the `<attribute>!` method to update a value, as, as I write this, I can't conceive of a scenario in which you'd want to update just the type, and not also the ID, of an associated object. That doesn't mean you won't ever want to! And if you do, you can still do so manually via the `ActiveRecord#update` [method](https://guides.rubyonrails.org/active_record_basics.html#update).

```
class Award < ActiveRecord::Base
  self.table_name = 'awards'
  belongs_to :awardable, polymorphic: true
  taylors_enum awardable_type: %w[Album Song], polymorphic: true
end

[1] pry(#<TestPolymorphic>)> song = Song.create!
=> #<Song:0x0000000105beddd0 id: 1, name: nil, created_at: 2022-06-04 14:39:38.837973 UTC, updated_at: 2022-06-04 14:39:38.837973 UTC>
[2] pry(#<TestPolymorphic>)> album = AlbumBase.create!(name: :folklore)
=> #<AlbumBase:0x0000000105c36c10 id: 1, name: "folklore", created_at: 2022-06-04 14:39:43.001592 UTC, updated_at: 2022-06-04 14:39:43.001592 UTC>
[3] pry(#<TestPolymorphic>)> song_award = Award.create!(awardable: song)
=> #<Award:0x0000000105c77030 id: 1, awardable_type: "Song", awardable_id: "1", created_at: 2022-06-04 14:39:46.714235 UTC, updated_at: 2022-06-04 14:39:46.714235 UTC>
[4] pry(#<TestPolymorphic>)> album_award = Award.create!(awardable: album)
=> #<Award:0x0000000105cb4ac0 id: 2, awardable_type: "Album", awardable_id: "1", created_at: 2022-06-04 14:39:49.444071 UTC, updated_at: 2022-06-04 14:39:49.444071 UTC>
[5] pry(#<TestPolymorphic>)> song_award.song?
=> true
[6] pry(#<TestPolymorphic>)> song_award.album?
=> false
[7] pry(#<TestPolymorphic>)> album_award.song?
=> false
[8] pry(#<TestPolymorphic>)> album_award.album?
=> true
[9] pry(#<TestPolymorphic>)> Award.song
=> [#<Award:0x0000000105dbfca8 id: 1, awardable_type: "Song", awardable_id: "1", created_at: 2022-06-04 14:39:46.714235 UTC, updated_at: 2022-06-04 14:39:46.714235 UTC>]
[10] pry(#<TestPolymorphic>)> Award.song.to_sql
=> "SELECT \"awards\".* FROM \"awards\" WHERE \"awards\".\"awardable_type\" = 'Song'"
```


## Installation

Install the gem and add to the application's Gemfile by running:

    $ bundle add taylors_enum

If bundler is not being used to manage dependencies, install the gem by running:

    $ gem install taylors_enum

## Usage

Once the gem is installed, add `taylors_enum <my_column>: ['array', 'of', 'values'], **options` to any model that ultimately inherits from `ActiveRecord::Base`.

The values that you pass will be the values that are stored in the database - except when passing `integer: true` (see below) in the options; in this case, pass an array of the values you expect to see in the Rails application. taylors_enum will then generate a companion for each value that will be used to define constants, `?` methods to check if an object has the given value in the specified column, `!` methods to update the column to that value, and scopes to query for records with that value. See the top of this README for what this looks like in practice.

taylors_enum also takes a series of options, provided as a hash following the specified values:
- `prefix`: defaults to `nil`. If `true` is passed, the name of the column will be prepended to the start of the helper methods, scopes, and constants. If a string is passed, the given string will be prepended to the start of the helper methods, scopes, and constants.

- `suffix`: defaults to `nil`. If `true` is passed, the name of the column will be appended to the end of the helper methods, scopes, and constants. If a string is passed, the given string will be appended to the end of the helper methods, scopes, and constants.

- `constants`: defaults to `true`. If `false` is passed, constants will not be defined. This can be helpful for migrating onto taylors_enum, if you already have constants defined for certain enum values.

- `validations`: defaults to `true`. If `false` is passed, validations, `nil` will be allowed as a value in the specified column.

- `single_table_inheritance`: defaults to `false`. When using taylors_enum to help with columns on [Single Table Inheritance](https://api.rubyonrails.org/classes/ActiveRecord/Inheritance.html) models, pass this value as `true`, otherwise things won't work, and then you'll be sad. Note: this cannot be passed as `true` if `integer` or `polymorphic` are both specified as `true`; this will raise an OptionsConflictError when loading the application.

- `polymorphic`: defaults to `false`. When using taylors_enum to help with _type column for [polymorphic associations](https://guides.rubyonrails.org/association_basics.html#polymorphic-associations), pass this value as `true`; this will ensure validations are run correctly, against database values rather than Rails values, and will also not create a `!` method to update the value of the column. Note: this cannot be passed as `true` if `single_table_inheritance` or `integer` are both specified as `true`; this will raise an OptionsConflictError when loading the application.

- `integer`: defaults to `false`. When using taylors_enum with an integer column rather than a string column, pass this as `true` to ensure constants, scopes, and helper methods are defined appropriately. Should this be something that can be inferred, rather than needing to be passed explicitly? Absolutely. However, at the time of writing, I can't figure out how to get access to this information at the point that this code is called (in the `ActiveSupport::LazyLoadHooks.on_load` [callback](https://api.rubyonrails.org/classes/ActiveSupport/LazyLoadHooks.html)), so this fudge allows integer columns to function as expected for now. Note: this cannot be passed as `true` if `single_table_inheritance` or `polymorphic` are both specified as `true`; this will raise an OptionsConflictError when loading the application.

If you want to see the base Rails value that will be used to generate the `value?` and `value!` methods, that `VALUE` constants, and the `value` scopes, you can load up a Rails console with `rails c`, and run `MyModel.check_rails_value_for(database_value)`. For example:
```
class AlbumBase < Album
  taylors_enum name: %w[debut fearless speak_now red nineteen_eighty_nine reputation lover folklore evermore]
end

[2] pry(#<TestDefault>)> AlbumBase.check_rails_value_for('folklore')
=> 'folklore'
[3] pry(#<TestDefault>)> AlbumBase.check_rails_value_for('folklore', column: :name, prefix: true)
=> 'name_folklore'
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

You'll also need to have a working database in order to run the tests. First, make sure you have [Postgres](https://www.postgresql.org/) installed. You can easily do this on a Mac with [Homebrew](https://wiki.postgresql.org/wiki/Homebrew).

From there, run `createdb taylors_enum` in the terminal to create a database with the required name. Then, run `psql taylors_enum` to open a terminal to that database, and run `create user postgres;` to create a user with the correct username for the test suite to connect to it. The database connection config is specified in `test/database.yml`

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/isitpj/taylors_enum.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
