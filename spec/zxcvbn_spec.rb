# frozen_string_literal: true

RSpec.describe Zxcvbn do
  it "runs" do
    expect{ Zxcvbn.zxcvbn("1234") }.not_to raise_error
  end
end
