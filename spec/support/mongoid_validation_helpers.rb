# frozen_string_literal: true

# To be used in validations specs (currently for Mongoid validator only).
# Heavily inspired by:
# https://github.com/rails/rails/blob/v6.0.0.beta3/activemodel/test/cases/validations/numericality_validation_test.rb
module MongoidValidationHelpers
  NIL = [nil]
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

  # TODO: add contants like ONE_USD, ONE_EUR, ONE_USD_CENT, ONE_EUR_CENT,
  #       MONEY_OBJECTS, MONEY_HASHES

  def invalid!(values, error = nil)
    with_each_price_value(values) do |priceable|
      expect(priceable).not_to be_invalid
      errors = priceable.errors[:price]
      expect(errors).not_to be_empty
      expect(errors.first).to eq(error) if error
    end
  end

  def valid!(values)
    with_each_price_value(values) do |priceable|
      exepect(priceable).to be_valid
    end
  end

  def with_each_price_value(values)
    priceable = Priceable.new
    values.each do |value|
      priceable.price = value
      yield priceable
    end
  end
end

RSpec.configure do |config|
  config.include MongoidValidationHelpers, validations: true
end
