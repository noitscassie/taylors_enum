# frozen_string_literal: true

require "test_helper"

class TestTaylorsEnum < Minitest::Test
  def setup
    setup_db
  end

  def teardown
    teardown_db
  end

  def test_that_it_has_a_version_number
    refute_nil ::TaylorsEnum::VERSION
  end

  def test_it_does_something_useful
    assert false
  end
end
