require "test_taylors_enum"

class TestSingleTableInheritance < TestTaylorsEnum
  def setup
    super
    @albums_hash = {
      'debut' => 'SingleTableInheritanceAlbums::Debut',
      'fearless' => 'SingleTableInheritanceAlbums::Fearless',
      'speak_now' => 'SingleTableInheritanceAlbums::SpeakNow',
      'red' => 'SingleTableInheritanceAlbums::Red',
      'nineteen_eighty_nine' => 'SingleTableInheritanceAlbums::NineteenEightyNine',
      'reputation' => 'SingleTableInheritanceAlbums::Reputation',
      'lover' => 'SingleTableInheritanceAlbums::Lover',
      'folklore' => 'SingleTableInheritanceAlbums::Folklore',
      'evermore' => 'SingleTableInheritanceAlbums::Evermore',
    }
  end

  test 'that it defines _rails_values method appropriately' do
    assert_equal described_class.type_rails_values, albums_hash.keys
  end

  test 'that it defines _database_values method appropriately' do
    assert_equal described_class.type_database_values, albums_hash.values
  end

  test 'that it defines constants appropriately' do
    assert_equal described_class::DEBUT, described_module::Debut.new.type
    assert_equal described_class::FEARLESS, described_module::Fearless.new.type
    assert_equal described_class::SPEAK_NOW, described_module::SpeakNow.new.type
    assert_equal described_class::RED, described_module::Red.new.type
    assert_equal described_class::NINETEEN_EIGHTY_NINE, described_module::NineteenEightyNine.new.type
    assert_equal described_class::REPUTATION, described_module::Reputation.new.type
    assert_equal described_class::LOVER, described_module::Lover.new.type
    assert_equal described_class::FOLKLORE, described_module::Folklore.new.type
    assert_equal described_class::EVERMORE, described_module::Evermore.new.type
  end

  test 'that enum ? methods work as expected' do
    album = described_module::Debut.new
    assert album.debut?
    refute album.fearless?

    album = described_module::Fearless.new
    assert album.fearless?
    refute album.speak_now?

    album = described_module::SpeakNow.new
    assert album.speak_now?
    refute album.red?

    album = described_module::Red.new
    assert album.red?
    refute album.nineteen_eighty_nine?

    album = described_module::NineteenEightyNine.new
    assert album.nineteen_eighty_nine?
    refute album.reputation?

    album = described_module::Reputation.new
    assert album.reputation?
    refute album.lover?

    album = described_module::Lover.new
    assert album.lover?
    refute album.folklore?

    album = described_module::Folklore.new
    assert album.folklore?
    refute album.evermore?

    album = described_module::Evermore.new
    assert album.evermore?
    refute album.debut?
  end

  test 'that enum ! methods work as expected' do
    album = described_module::Debut.new
    album.fearless!
    assert album.fearless?

    album = described_module::Fearless.new
    album.speak_now!
    assert album.speak_now?

    album = described_module::SpeakNow.new
    album.red!
    assert album.red?

    album = described_module::Red.new
    album.nineteen_eighty_nine!
    assert album.nineteen_eighty_nine?

    album = described_module::NineteenEightyNine.new
    album.reputation!
    assert album.reputation?

    album = described_module::Reputation.new
    album.lover!
    assert album.lover?

    album = described_module::Lover.new
    album.folklore!
    assert album.folklore?

    album = described_module::Folklore.new
    album.evermore!
    assert album.evermore?

    album = described_module::Evermore.new
    album.debut!
    assert album.debut?
  end

  test 'that enum scopes work as expected' do
    debut = described_module::Debut.create!
    fearless = described_module::Fearless.create!
    speak_now = described_module::SpeakNow.create!
    red = described_module::Red.create!
    nineteen_eighty_nine = described_module::NineteenEightyNine.create!
    reputation = described_module::Reputation.create!
    lover = described_module::Lover.create!
    folklore = described_module::Folklore.create!
    evermore = described_module::Evermore.create!

    albums = described_class.debut
    assert_includes albums, debut
    refute_includes albums, fearless

    albums = described_class.fearless
    assert_includes albums, fearless
    refute_includes albums, speak_now

    albums = described_class.speak_now
    assert_includes albums, speak_now
    refute_includes albums, red

    albums = described_class.red
    assert_includes albums, red
    refute_includes albums, nineteen_eighty_nine

    albums = described_class.nineteen_eighty_nine
    assert_includes albums, nineteen_eighty_nine
    refute_includes albums, reputation

    albums = described_class.reputation
    assert_includes albums, reputation
    refute_includes albums, lover

    albums = described_class.lover
    assert_includes albums, lover
    refute_includes albums, folklore

    albums = described_class.folklore
    assert_includes albums, folklore
    refute_includes albums, evermore

    albums = described_class.evermore
    assert_includes albums, evermore
    refute_includes albums, debut
  end

  private

  def described_class
    described_module::SingleTableInheritanceAlbum
  end

  def described_module
    ::SingleTableInheritanceAlbums
  end

  attr_reader :albums_hash
end
