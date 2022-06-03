require "test_taylors_enum"

class TestDefault < TestTaylorsEnum
  def setup
    super
    @albums_hash = {
      'debut' => 'debut',
      'fearless' => 'fearless',
      'speak_now' => 'speak_now',
      'red' => 'red',
      'nineteen_eighty_nine' => 'nineteen_eighty_nine',
      'reputation' => 'reputation',
      'lover' => 'lover',
      'folklore' => 'folklore',
      'evermore' => 'evermore',
    }
  end

  test 'that it defines _rails_values method appropriately' do
    assert_equal described_class.name_rails_values, albums_hash.keys
  end

  test 'that it defines _database_values method appropriately' do
    assert_equal described_class.name_database_values, albums_hash.values
  end

  test 'that it defines constants appropriately' do
    assert_equal described_class::DEBUT, 'debut'
    assert_equal described_class::FEARLESS, 'fearless'
    assert_equal described_class::SPEAK_NOW, 'speak_now'
    assert_equal described_class::RED, 'red'
    assert_equal described_class::NINETEEN_EIGHTY_NINE, 'nineteen_eighty_nine'
    assert_equal described_class::REPUTATION, 'reputation'
    assert_equal described_class::LOVER, 'lover'
    assert_equal described_class::FOLKLORE, 'folklore'
    assert_equal described_class::EVERMORE, 'evermore'
  end

  test 'that enum ? methods work as expected' do
    album = described_class.create!(name: described_class::DEBUT)

    assert album.debut?
    refute album.fearless?
  end

  test 'that enum ! methods work as expected' do
    album = described_class.create!(name: described_class::SPEAK_NOW)

    assert album.speak_now?
    refute album.red?

    album.red!
    refute album.speak_now?
    assert album.red?
  end

  test 'that enum scopes work as expected' do
    nineteen_eighty_nine = described_class.create!(name: described_class::NINETEEN_EIGHTY_NINE)
    reputation = described_class.create!(name: described_class::REPUTATION)
    lover = described_class.create!(name: described_class::LOVER)

    albums = described_class.reputation

    assert_includes albums, reputation
    refute_includes albums, nineteen_eighty_nine
    refute_includes albums, lover
  end

  private

  def described_class
    ::AlbumBase
  end

  attr_reader :albums_hash
end
