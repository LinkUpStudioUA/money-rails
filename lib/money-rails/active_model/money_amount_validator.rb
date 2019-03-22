# frozen_string_literal: true

module MoneyRails
  module ActiveModel
    # This is a separate validator designed for use with Mongoid
    class MoneyAmountValidator < ::ActiveModel::Validations::NumericalityValidator

      # Implementation is based on
      # https://github.com/rails/rails/blob/v5.2.3.rc1/activemodel/lib/active_model/validations/numericality.rb
      # and
      # https://github.com/rails/rails/blob/v5.2.2.1/activemodel/lib/active_model/validations/numericality.rb
      NUMBER_PARSING_METHOD =
        if ::ActiveModel.version < Gem::Version.new('5.2.3.rc1')
          :parse_raw_value_as_a_number
        else
          :parse_as_number
        end

      def validate_each(record, attr_name, value)
        @record = record
        @attr_name = attr_name
        super
        return unless value && options[:for_currency]

        currency_options = options[:for_currency][value.currency.iso_code]
        return unless currency_options

        buffer_options = options
        @options = currency_options
        super
        @options = buffer_options
      end

      private

      attr_reader :record, :attr_name

      define_method(NUMBER_PARSING_METHOD) do |raw_value|
        raw_value = cast_hash_to_money(raw_value) if raw_value.is_a?(Hash)
        return raw_value.amount if raw_value.is_a?(Money)

        super
      end

      def cast_hash_to_money(hash)
        hash = hash.transform_keys(&:to_s)

        unless is_number?(hash['cents'])
          record.errors.add(attr_name, :invalid_cents)
          return nil
        end

        cents = send(NUMBER_PARSING_METHOD, hash['cents'])
        Money.new(cents, hash['currency_iso']).amount
      rescue Money::Currency::UnknownCurrency
        record.errors.add(attr_name, :invalid_currency)
        nil
      end
    end
  end
end
