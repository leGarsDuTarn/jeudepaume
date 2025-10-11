require 'rails_helper'

RSpec.describe Person, type: :model do
  context "friendly_id" do
    it "génération d'un slug à partir de full_name" do
      p = create(:person, full_name: "John     Doe")
      expect(p.slug).to eq("john-doe")
    end

    it "regénération du slug quand le nom change" do
      p = create(:person, full_name: "John Doe")
      p.update!(full_name: "Jeanne Doe")
      expect(p.slug).to eq("jeanne-doe")
    end

    it "activation du fallback sur first_name + last_name si full_name est absent" do
      p = create(:person, :with_names, first_name: "Éric", last_name: "Dupond-Moretti", full_name: nil)
      expect(p.slug).to eq("eric-dupond-moretti")
    end
  end

  context "Test du JSON" do
    it "le test est valide, accepte un JSON cassé en import et retourne {} dans la vue" do
      p = build(:person, socials: "JSON non conforme")
      expect(p).to be_valid
      expect(p.socials_hash).to eq({})
    end
  end
end
