require 'rails_helper'

RSpec.describe Mandate, type: :model do
  # Smoke test -> test la factory mandate pour voir si elle est valide
  it "factory valide" do
    expect(build(:mandate)).to be_valid
  end
end
