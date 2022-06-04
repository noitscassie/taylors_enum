require 'test_taylors_enum'

class TestSuffix < TestTaylorsEnum
  def setup
    super
    @albums_hash = {
      'debut_name' => 'debut',
      'fearless_name' => 'fearless',
      'speak_now_name' => 'speak_now',
      'red_name' => 'red',
      'nineteen_eighty_nine_name' => 'nineteen_eighty_nine',
      'reputation_name' => 'reputation',
      'lover_name' => 'lover',
      'folklore_name' => 'folklore',
      'evermore_name' => 'evermore'
    }
  end

  test 'that it defines _rails_values method appropriately' do
    assert_equal described_class.name_rails_values, albums_hash.keys
  end

  test 'that it defines _database_values method appropriately' do
    assert_equal described_class.name_database_values, albums_hash.values
  end

  test 'that it defines constants appropriately' do
    assert_equal described_class::DEBUT_NAME, 'debut'
    assert_equal described_class::FEARLESS_NAME, 'fearless'
    assert_equal described_class::SPEAK_NOW_NAME, 'speak_now'
    assert_equal described_class::RED_NAME, 'red'
    assert_equal described_class::NINETEEN_EIGHTY_NINE_NAME, 'nineteen_eighty_nine'
    assert_equal described_class::REPUTATION_NAME, 'reputation'
    assert_equal described_class::LOVER_NAME, 'lover'
    assert_equal described_class::FOLKLORE_NAME, 'folklore'
    assert_equal described_class::EVERMORE_NAME, 'evermore'
  end

  test 'that enum ? methods work as expected' do
    album = described_class.create!(name: described_class::DEBUT_NAME)

    assert album.debut_name?
    refute album.fearless_name?
  end

  test 'that enum ! methods work as expected' do
    album = described_class.create!(name: described_class::SPEAK_NOW_NAME)

    assert album.speak_now_name?
    refute album.red_name?

    album.red_name!
    refute album.speak_now_name?
    assert album.red_name?
  end

  test 'that enum scopes work as expected' do
    nineteen_eighty_nine = described_class.create!(name: described_class::NINETEEN_EIGHTY_NINE_NAME)
    reputation = described_class.create!(name: described_class::REPUTATION_NAME)
    lover = described_class.create!(name: described_class::LOVER_NAME)

    albums = described_class.reputation_name

    assert_includes albums, reputation
    refute_includes albums, nineteen_eighty_nine
    refute_includes albums, lover
  end

  private

  def described_class
    ::AlbumSuffix
  end

  attr_reader :albums_hash
end
