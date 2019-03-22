# frozen_string_literal: true

require 'spec_helper'

if defined?(Mongoid)
  describe MoneyRails::ActiveModel::MoneyAmountValidator, validations: true do

    it "is sane by default" do
      Priceable.validates :price, money_amount: true
      invalid!(NIL + BLANK + JUNK)
      valid!(FLOATS + INTEGERS + BIGDECIMAL + INFINITY)
    end
  end
end
