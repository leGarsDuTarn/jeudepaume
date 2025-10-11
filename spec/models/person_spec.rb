require 'rails_helper'

RSpec.describe Person, type: :model do
  context "test friendly_id" do
    it "génération d'un slug à partir de full_name" do
      p = create(:person, full_name: "John     Doe")
      expect(p.slug).to eq("john-doe")
    end

    it "regénération du slug quand le nom change" do
      p = create(:person, full_name: "John Doe")
      p.update!(full_name: "Jeanne Doe")
      p.reload
      expect(p.slug).to eq("jeanne-doe")
    end

    it "activation du fallback sur first_name + last_name si full_name est absent" do
      p = create(:person, :with_names, first_name: "Éric", last_name: "Dupond-Moretti", full_name: nil)
      expect(p.slug).to eq("eric-dupond-moretti")
    end
  end

  context "Test JSON" do
    it "le test est valide, accepte un JSON cassé en import et retourne {} dans la vue" do
      p = build(:person, socials: "JSON non conforme")
      expect(p).to be_valid
      expect(p.socials_hash).to eq({})
    end

    it "n'est pas valide avec un JSON cassé en mode admin" do
      p = build(:person, :admin_manual, :bad_socials)
      expect(p).not_to be_valid
      expect(p.errors[:socials]).to include("doit être un JSON valide")
    end

    it "le test est valide avec un JSON conforme en mode admin" do
      p = build(:person, :admin_manual, :with_socials_json, :with_external_ids_json, :with_image_meta_json)
      expect(p).to be_valid
    end
  end

  context "test validation métier" do
    it "n'est pas valide avec une date de naissance future" do
      p = build(:person, :future_birth_date)
      expect(p).not_to be_valid
      expect(p.errors[:birth_date]).to be_present
    end

    it "le test est valide avec un code postal français à 5 chiffres si non conforme n'est pas valide" do
      ok = build(:person, birth_postal_code: "81000")
      bad = build(:person, birth_postal_code: "81A00")
      expect(ok).to be_valid
      expect(bad).not_to be_valid
      expect(bad.errors[:birth_postal_code]).to be_present
    end

    it "le test est valide avec les URLs en format valide mais n'est pas valide si mauvais formatage" do
      ok = build(:person, website: "https://exemple.test", image_url: "http://cdn.exemple.test/photo.jpg")
      bad = build(:person, website: "fttq://bad", image_url: "bad-url")
      expect(ok).to be_valid
      expect(bad).not_to be_valid
      expect(bad.errors[:website]).to be_present
      expect(bad.errors[:image_url]).to be_present
    end
  end

  context "test des normalisations" do
    it "squish les noms avant validation" do
      p = create(:person, full_name: "    Benjamin   Grassiano    ")
      expect(p.full_name).to eq("Benjamin Grassiano")
    end
  end
end
