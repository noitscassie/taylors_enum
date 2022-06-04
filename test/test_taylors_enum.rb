# frozen_string_literal: true

require 'test_helper'

class TestTaylorsEnum < ActiveSupport::TestCase
  def setup
    setup_db
  end

  def teardown
    teardown_db
  end

  test 'that it has a valid version number' do
    refute_nil ::TaylorsEnum::VERSION
  end

  test 'that constants are not defined constants: false is passed' do
    refute defined?(::AlbumNoConstants::DEBUT)
    refute defined?(::AlbumNoConstants::FEARLESS)
    refute defined?(::AlbumNoConstants::SPEAK_NOW)
    refute defined?(::AlbumNoConstants::RED)
    refute defined?(::AlbumNoConstants::NINETEEN_EIGHTY_NINE)
    refute defined?(::AlbumNoConstants::REPUTATION)
    refute defined?(::AlbumNoConstants::LOVER)
    refute defined?(::AlbumNoConstants::FOLKLORE)
    refute defined?(::AlbumNoConstants::EVERMORE)
  end

  test 'that the column is not allowed to be nil by default' do
    album = AlbumBase.create(name: nil)

    refute album.persisted?
    assert_includes album.errors.full_messages, "Name can't be blank"
    assert_includes album.errors.full_messages, 'Name  is not a valid name'
  end

  test 'that the column is not allowed to be an unspecified value by default' do
    assert_raises do
      # olivia babe it's a great album and i love it, but it's not one of taylor's
      AlbumBase.create(name: :sour)
    end
  end

  test 'that blank values can be passed if validations: false is passed' do
    assert_nothing_raised do
      AlbumNoValidations.create!(name: nil)
    end
  end

  test '#check_rails_value_for will return the rails value generated for a given database value' do
    # as a standard enum
    rails_value = AlbumBase.check_rails_value_for('lover')
    assert_equal 'lover', rails_value

    # with the default prefix
    rails_value = AlbumBase.check_rails_value_for('lover', column: :name, prefix: true)
    assert_equal 'name_lover', rails_value

    # with a custom prefix
    rails_value = AlbumBase.check_rails_value_for('lover', prefix: 'title')
    assert_equal 'title_lover', rails_value

    # with the default suffix
    rails_value = AlbumBase.check_rails_value_for('lover', column: :name, suffix: true)
    assert_equal 'lover_name', rails_value

    # with a custom suffix
    rails_value = AlbumBase.check_rails_value_for('lover', suffix: 'title')
    assert_equal 'lover_title', rails_value

    # for a modulised class name
    rails_value = AlbumBase.check_rails_value_for('Albums::Lover')
    assert_equal 'lover', rails_value

    # with the default prefix with a modulised class name
    rails_value = AlbumBase.check_rails_value_for('Albums::Lover', column: :name, prefix: true)
    assert_equal 'name_lover', rails_value

    # with a custom prefix with a modulised class name
    rails_value = AlbumBase.check_rails_value_for('Albums::Lover', prefix: 'title')
    assert_equal 'title_lover', rails_value

    # with the default suffix with a modulised class name
    rails_value = AlbumBase.check_rails_value_for('Albums::Lover', column: :name, suffix: true)
    assert_equal 'lover_name', rails_value

    # with a custom suffix with a modulised class name
    rails_value = AlbumBase.check_rails_value_for('Albums::Lover', suffix: 'title')
    assert_equal 'lover_title', rails_value
  end
end
