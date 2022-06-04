require "test_taylors_enum"

class TestPolymorphic < TestTaylorsEnum
  def setup
    super
    @awardable_hash = {
      'album' => 'Album',
      'song' => 'Song',
    }
  end

  test 'that it defines _rails_values method appropriately' do
    assert_equal described_class.awardable_type_rails_values, awardable_hash.keys
  end

  test 'that it defines _database_values method appropriately' do
    assert_equal described_class.awardable_type_database_values, awardable_hash.values
  end

  test 'that it defines constants appropriately' do
    assert_equal described_class::SONG, 'Song'
    assert_equal described_class::ALBUM, 'Album'
  end

  test 'that enum ? methods work as expected' do
    song = Song.create!
    award = Award.create!(awardable: song)
    assert award.song?

    album = AlbumBase.create!(name: :folklore)
    award = Award.create!(awardable: album)
    assert award.album?
  end

  test 'that enum ! methods do not exist' do
    song = Song.create!
    award = Award.create!(awardable: song)
    assert_raises(NoMethodError) do
      award.album!
    end

    album = AlbumBase.create!(name: :folklore)
    award = Award.create!(awardable: album)
    assert_raises(NoMethodError) do
      award.song!
    end
  end

  test 'that enum scope methods work as expected' do
    song = Song.create!
    album = AlbumBase.create!(name: :folklore)
    song_award = Award.create!(awardable: song)
    album_award = Award.create!(awardable: album)

    awards = Award.song
    assert_includes awards, song_award
    refute_includes awards, album_award

    awards = Award.album
    assert_includes awards, album_award
    refute_includes awards, song_award
  end

  private

  def described_class
    ::Award
  end

  attr_reader :awardable_hash
end
