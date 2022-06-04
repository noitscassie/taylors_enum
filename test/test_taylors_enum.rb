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
end
