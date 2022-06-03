require "test_taylors_enum"

class TestPrefix < TestTaylorsEnum
  def setup
    super
    @albums_hash = {
      'name_debut' => 'debut',
      'name_fearless' => 'fearless',
      'name_speak_now' => 'speak_now',
      'name_red' => 'red',
      'name_nineteen_eighty_nine' => 'nineteen_eighty_nine',
      'name_reputation' => 'reputation',
      'name_lover' => 'lover',
      'name_folklore' => 'folklore',
      'name_evermore' => 'evermore',
    }
  end

  test 'that it defines _rails_values method appropriately' do
    assert_equal described_class.name_rails_values, albums_hash.keys
  end

  test 'that it defines _database_values method appropriately' do
    assert_equal described_class.name_database_values, albums_hash.values
  end

  test 'that it defines constants appropriately' do
    assert_equal described_class::NAME_DEBUT, 'debut'
    assert_equal described_class::NAME_FEARLESS, 'fearless'
    assert_equal described_class::NAME_SPEAK_NOW, 'speak_now'
    assert_equal described_class::NAME_RED, 'red'
    assert_equal described_class::NAME_NINETEEN_EIGHTY_NINE, 'nineteen_eighty_nine'
    assert_equal described_class::NAME_REPUTATION, 'reputation'
    assert_equal described_class::NAME_LOVER, 'lover'
    assert_equal described_class::NAME_FOLKLORE, 'folklore'
    assert_equal described_class::NAME_EVERMORE, 'evermore'
  end

  test 'that enum ? methods work as expected' do
    album = described_class.create!(name: described_class::NAME_DEBUT)

    assert album.name_debut?
    refute album.name_fearless?
  end

  test 'that enum ! methods work as expected' do
    album = described_class.create!(name: described_class::NAME_SPEAK_NOW)

    assert album.name_speak_now?
    refute album.name_red?

    album.name_red!
    refute album.name_speak_now?
    assert album.name_red?
  end

  test 'that enum scopes work as expected' do
    nineteen_eighty_nine = described_class.create!(name: described_class::NAME_NINETEEN_EIGHTY_NINE)
    reputation = described_class.create!(name: described_class::NAME_REPUTATION)
    lover = described_class.create!(name: described_class::NAME_LOVER)

    albums = described_class.name_reputation

    assert_includes albums, reputation
    refute_includes albums, nineteen_eighty_nine
    refute_includes albums, lover
  end

  private

  def described_class
    ::AlbumPrefix
  end

  attr_reader :albums_hash
end
