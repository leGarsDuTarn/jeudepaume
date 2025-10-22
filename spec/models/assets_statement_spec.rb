require 'rails_helper'

RSpec.describe AssetsStatement, type: :model do
  # Smoke test -> test la factory assets pour voir si elle est valide
  it "factory valide" do
    expect(build(:assets_statement)).to be_valid
  end
end
