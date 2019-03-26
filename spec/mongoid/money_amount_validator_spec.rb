# frozen_string_literal: true

require 'spec_helper'

if defined?(Mongoid)
  describe  MoneyRails::ActiveModel::MoneyAmountValidator,
            mongoid_validations: true do

    it "is sane by default" do
      Priceable.validates :price, money_amount: true
      invalid!(nils + blank + junk + infinity)
      valid!(floats + integers + bigdecimal + money_objects + money_hashes)
    end
  end
end
