require 'test_taylors_enum'

class TestOptionsConflicts < TestTaylorsEnum
  test 'raises an OptionsConflictError if single_table_inheritance and polymorphic are both passed as true' do
    assert_raises(described_class::OptionsConflictError, 'taylors_enum cannot work for both polymorphic associations and single table inheritance on the same column') do
      class PolymorphicAssociationSingleTableInheritanceConflict < ActiveRecord::Base
        self.table_name = 'albums'
        taylors_enum name: %w[debut fearless speak_now red nineteen_eighty_nine reputation lover folklore evermore], polymorphic: true, single_table_inheritance: true
      end
    end
  end

  test 'raises an OptionsConflictError if single_table_inheritance and integer are both passed as true' do
    assert_raises(described_class::OptionsConflictError, 'taylors_enum cannot work for integer columns with single table inheritance') do
      class IntegerSingleTableInheritanceConflict < ActiveRecord::Base
        self.table_name = 'albums'
        taylors_enum name: %w[debut fearless speak_now red nineteen_eighty_nine reputation lover folklore evermore], single_table_inheritance: true, integer: true
      end
    end
  end

  test 'raises an OptionsConflictError if polymorphic and integer are both passed as true' do
    assert_raises(described_class::OptionsConflictError, 'taylors_enum cannot work for integer columns with single table inheritance') do
      class IntegerPolymorphicAssociationConflict < ActiveRecord::Base
        self.table_name = 'albums'
        taylors_enum name: %w[debut fearless speak_now red nineteen_eighty_nine reputation lover folklore evermore], polymorphic: true, integer: true
      end
    end
  end

  private

  def described_class
    ::TaylorsEnum::ActiveRecord::TaylorsEnum::ClassMethods
  end
end
