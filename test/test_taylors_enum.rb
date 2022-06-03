# frozen_string_literal: true

require "test_helper"

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

  def test_it_does_something_useful
    assert false
  end
end
