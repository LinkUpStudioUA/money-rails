# frozen_string_literal: true

# To be used in validations specs (currently for Mongoid validator only).
# Heavily inspired by:
# https://github.com/rails/rails/blob/v6.0.0.beta3/activemodel/test/cases/validations/numericality_validation_test.rb
module MongoidValidationHelpers
  NILS = [nil]
  BLANK = ["", " ", " \t \r \n"]
  # 30 significant digits
  BIGDECIMAL_STRINGS = %w[12345678901234567890.1234567890]
  FLOAT_STRINGS = %w[
    0.0 +0.0 -0.0 10.0 10.5 -10.5 -0.0001 -090.1 90.1e1 -90.1e5 -90.1e-5 90e-5
  ]
  INTEGER_STRINGS = %w[0 +0 -0 10 +10 -10 0090 -090]
  FLOATS = [0.0, 10.0, 10.5, -10.5, -0.0001] + FLOAT_STRINGS
  INTEGERS = [0, 10, -10] + INTEGER_STRINGS
  BIGDECIMAL = BIGDECIMAL_STRINGS.map { |bd| BigDecimal(bd) }
  JUNK = [
    "not a number", "42 not a number", "0xdeadbeef", "0xinvalidhex",
    "0Xdeadbeef", "00-1", "--3", "+-3", "+3-1", "-+019.0", "12.12.13.12",
    "123\nnot a number"
  ]
  INFINITY = [1.0 / 0.0]

  ONE_USD = [Money.new(1_00, :usd)]
  ONE_EUR = [Money.new(1_00, :eur)]
  ONE_USD_CENT = [Money.new(1, :usd)]
  ONE_EUR_CENT = [Money.new(1, :eur)]
  MONEY_OBJECTS = ONE_USD + ONE_EUR + ONE_USD_CENT + ONE_EUR_CENT

  ONE_USD_HASH = [{cents: 1_00, currency_iso: "USD"}]
  ONE_EUR_HASH = [{cents: 1_00, currency_iso: "EUR"}]
  ONE_USD_CENT_HASH = [{cents: 1, currency_iso: "USD"}]
  ONE_EUR_CENT_HASH = [{cents: 1, currency_iso: "EUR"}]
  MONEY_HASHES =  ONE_USD_HASH + ONE_EUR_HASH + ONE_USD_CENT_HASH +
                  ONE_EUR_CENT_HASH

  current_module = self
  constants.each do |constant_name|
    define_method(constant_name.to_s.downcase) do
      current_module.const_get(constant_name)
    end
  end

  def invalid!(values, error = nil)
    with_each_price_value(values) do |priceable, inspected_value|
      expect(priceable).to  be_invalid,
                            "#{inspected_value} not rejected as a number"
      errors = priceable.errors[:price]
      expect(errors).to be_any, "FAILED for #{inspected_value}"
      expect(errors.first).to eq(error) if error
    end
  end

  def valid!(values)
    with_each_price_value(values) do |priceable, inspected_value|
      expect(priceable).to(
        be_valid,
        lambda do
          "#{inspected_value} not accepted as a number with validation " \
          "error: #{priceable.errors[:price].first}"
        end
      )
    end
  end

  def with_each_price_value(values)
    priceable = Priceable.new
    values.each do |value|
      priceable.price = value
      yield priceable, value.inspect
    end
  end
end

RSpec.configure do |config|
  config.include MongoidValidationHelpers, mongoid_validations: true
end
