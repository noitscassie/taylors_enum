module TaylorsEnum
  module ActiveRecord
    module TaylorsEnum
      module ClassMethods
        DEFAULT_OPTIONS = {
          prefix: nil, # can be true, false, or a string; if true, will use the column_name as the default value
          suffix: nil, # can be true, false, or a string; if true, will use the column_name as the default value
          constants: true, # can be true or false
          validations: true, # can be true or false; TODO: allow a hash of validations args to be passed
          single_table_inheritance: false,
          column: nil, # this is set by the first argument passed to taylors_enum
        }.with_indifferent_access.freeze

        def taylors_enum(**enum_args)
          enum_args, *options = *enum_args
          enum_column, raw_values = *enum_args

          options = DEFAULT_OPTIONS
            .merge(**options.to_h)
            .merge(column: enum_column)
            .with_indifferent_access

          values = format_values(raw_values, options: options)

          define_list_methods!(values, column: enum_column)
          define_constants!(values) if options[:constants].present?
          enforce_validations!(values: options[:single_table_inheritance] ? values.values : values.keys, column: enum_column) if options[:validations].present?

          if options[:single_table_inheritance]
            manually_define_enum_methods(values, column: enum_column)
          else
            enum(enum_column => values) unless options[:single_table_inheritance]
          end

        end

        private

        def manually_define_enum_methods(values, column:)
          values.each do |rails_value, database_value|
            # def active?() status == "active" end
            define_method("#{rails_value}?") { self[column] == database_value }

            # # def active!() update!(status: 0) end
            define_method("#{rails_value}!") { update!(column => database_value) }

            # scope :active, -> { where(status: 0) }
            self.scope rails_value, -> { where(column => database_value) }
          end
        end

        def define_list_methods!(values, column:)
          define_singleton_method("#{column}_rails_values") do
            values.keys
          end

          define_singleton_method("#{column}_database_values") do
            values.values
          end
        end

        def define_constants!(values)
          values.each do |rails_value, database_value|
            const_set(rails_value.upcase, database_value)
          end
        end

        def enforce_validations!(values:, column:)
          validates column, presence: true, inclusion: { in: values, message: "%{value} is not a valid #{column}" }
        end

        def format_values(values, options:)
          prefix = generate_prefix_name(options[:prefix], column: options[:column])
          suffix = generate_suffix_name(options[:suffix], column: options[:column])

          values.map do |value|
            formatted_value = value.to_s.demodulize.underscore
            [
              "#{prefix}#{formatted_value}#{suffix}",
              value,
            ]
          end.to_h
        end

        def generate_prefix_name(prefix, column:)
          enum_prefix = generate_nfix_name(prefix, column: column)
          enum_prefix.present? ? "#{enum_prefix}_" : ''
        end

        def generate_suffix_name(suffix, column:)
          enum_suffix = generate_nfix_name(suffix, column: column)
          enum_suffix.present? ? "_#{enum_suffix}" : ''
        end

        def generate_nfix_name(nfix, column:)
          if nfix == true
            column
          elsif nfix
            nfix
          else
            ''
          end
        end
      end
    end
  end
end
