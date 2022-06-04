module TaylorsEnum
  module ActiveRecord
    module TaylorsEnum
      module ClassMethods
        DEFAULT_OPTIONS = {
          prefix: nil, # can be true, false, or a string; if true, will use the column_name as the default value
          suffix: nil, # can be true, false, or a string; if true, will use the column_name as the default value
          constants: true, # can be true or false
          validations: true, # can be true or false; TODO: allow a hash of validations args to be passed
          integer: false, # can be true or false; pass true if the column taylors_enum is called on is an integer value rather than a string
          single_table_inheritance: false,
          polymorphic: false,
          column: nil # this is set by the first argument passed to taylors_enum
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

          define_constants!(values, integer: options[:integer]) if options[:constants].present?

          # NOTE: when relying on the default rails enum, we validate against the rails-side values, as enum does its own custom validation; however, taylors_enum validates against the database-side values, as it relies on active_record validations
          values_to_validate = options[:single_table_inheritance] || options[:polymorphic] ? values.values : values.keys
          enforce_validations!(values: values_to_validate, column: enum_column) if options[:validations].present?

          if options[:single_table_inheritance]
            manually_define_single_table_inheritance_enum_methods(values, column: enum_column)
          elsif options[:polymorphic]
            manually_define_polymorphic_enum_methods(values, column: enum_column)
          else
            enum(enum_column => values)
          end
        end

        def check_rails_value_for(database_value, column: nil, prefix: nil, suffix: nil)
          format_values(
            [database_value],
            options: {
              column: column,
              prefix: prefix,
              suffix: suffix
            },
          ).keys.first
        end

        private

        def manually_define_single_table_inheritance_enum_methods(values, column:)
          values.each do |rails_value, database_value|
            define_boolean_method(rails_value, database_value, column)
            define_update_method(rails_value, database_value, column)
            define_scope(rails_value, database_value, column)
          end
        end

        # NOTE: skip defining the update method for polymorphic, as it makes little sense to update the associated type without also updating the corresponding id
        def manually_define_polymorphic_enum_methods(values, column:)
          values.each do |rails_value, database_value|
            define_boolean_method(rails_value, database_value, column)
            define_scope(rails_value, database_value, column)
          end
        end

        # def active?() status == "active" end
        def define_boolean_method(rails_value, database_value, column)
          method_name = "#{rails_value}?"
          detect_method_conflict(column, method_name, class_method: false)
          define_method(method_name) { self[column] == database_value }
        end

        # def active!() update!(status: :active) end
        def define_update_method(rails_value, database_value, column)
          method_name = "#{rails_value}!"
          detect_method_conflict(column, method_name, class_method: false)
          define_method(method_name) { update!(column => database_value) }
        end

        # scope :active, -> { where(status: :active) }
        def define_scope(rails_value, database_value, column)
          method_name = rails_value
          detect_method_conflict(column, method_name, class_method: true)
          scope method_name, -> { where(column => database_value) }
        end

        def detect_method_conflict(column, method_name, class_method:)
          send(
            :detect_enum_conflict!,
            column,
            method_name,
            class_method,
          )
        end

        def define_list_methods!(values, column:)
          define_singleton_method("#{column}_rails_values") do
            values.keys
          end

          define_singleton_method("#{column}_database_values") do
            values.values
          end
        end

        def define_constants!(values, integer:)
          values.each do |rails_value, database_value|
            const_set(rails_value.upcase, integer ? rails_value : database_value)
          end
        end

        def enforce_validations!(values:, column:)
          validates column, presence: true, inclusion: { in: values, message: "%{value} is not a valid #{column}" }
        end

        def format_values(values, options:)
          prefix = generate_prefix_name(options[:prefix], column: options[:column])
          suffix = generate_suffix_name(options[:suffix], column: options[:column])

          values.map.with_index do |value, index|
            formatted_value = value.to_s.demodulize.underscore
            value = index if options[:integer]
            [
              "#{prefix}#{formatted_value}#{suffix}",
              value
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
