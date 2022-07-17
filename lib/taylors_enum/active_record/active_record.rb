require 'taylors_enum/active_record/active_record'

module TaylorsEnum
  module ActiveRecord
    ActiveSupport.on_load :active_record do
      extend ::TaylorsEnum::ActiveRecord::TaylorsEnum::ClassMethods
    end
  end
end
