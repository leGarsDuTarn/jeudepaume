require 'rails_helper'

RSpec.describe Attendance, type: :model do
  # Smoke test -> test la factory attendance pour voir si elle est valide
  it "factory valide" do
    expect(build(:attendance)).to be_valid
  end
end
