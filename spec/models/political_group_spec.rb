require 'rails_helper'

RSpec.describe PoliticalGroup, type: :model do
  # Smoke test -> test la factory source pour voir si elle est valide
  it "factory valide" do
    expect(build(:political_group)).to be_valid
  end
end
