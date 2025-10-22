require 'rails_helper'

RSpec.describe Compensation, type: :model do
  # Smoke test -> test la factory compensation pour voir si elle est valide
  it "factory valide" do
    expect(build(:compensation)).to be_valid
  end
end
