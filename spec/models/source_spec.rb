require 'rails_helper'

RSpec.describe Source, type: :model do
  # Smoke test -> test la factory source pour voir si elle est valide
  it "factory valide" do
    expect(build(:source)).to be_valid
  end
end
