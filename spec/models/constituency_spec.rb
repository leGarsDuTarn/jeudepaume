require 'rails_helper'

RSpec.describe Constituency, type: :model do
  # Smoke test -> test la factory constituency pour voir si elle est valide
  it "factory valide" do
    expect(build(:constituency)).to be_valid
  end
end
