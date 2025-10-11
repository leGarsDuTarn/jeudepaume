require 'rails_helper'

RSpec.describe Institution, type: :model do
  context "Test de génération de SLUG" do
    it "génération d'un slug lisible" do
      i = create(:institution, name: "Conseil des ministres", kind: "Gouvernement")
      expect(i.slug).to eq("conseil-des-ministres")
    end
  end

  context "Test de validation métier" do
    it "le test est valide avec un name unique et un kind conforme" do
      i = build(:institution, name: "Assemblée nationale", kind: "Assemblée nationale")
      expect(i).to be_valid
    end

    it "n'est pas valide si name est absent" do
      i = build(:institution, name: nil)
      expect(i).not_to be_valid
      expect(i.errors[:name]).to be_present
    end

    it "imposition de l'unicité de name (case-insensitive)" do
      create(:institution, name: "Sénat", kind: "Sénat")
      i = build(:institution, name: "sénat", kind: "Sénat")
      expect(i).not_to be_valid
    end

    it "n'est pas valide avec un kind non-conforme" do
      i = build(:institution, kind: "krema")
      expect(i).not_to be_valid
      expect(i.errors[:kind]).to be_present
    end
  end
end
