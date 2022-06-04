# frozen_string_literal: true

require_relative 'taylors_enum/version'

module TaylorsEnum
  require 'active_support'
  require 'active_support/core_ext/hash'
  require 'taylors_enum/active_record/active_record'
  require 'taylors_enum/active_record/taylors_enum'
end
