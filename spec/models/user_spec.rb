require "rails_helper"

RSpec.describe User, type: :model do
  context "Test de creation avec la factory user" do
    it "crée un citoyen par défaut" do
      user = create(:user)
      expect(user).to be_valid
      expect(user.role).to eq("citoyen")
    end

    it "peut créer également un admin via le trait" do
      admin = create(:user, :admin)
      expect(admin).to be_valid
      expect(admin.role).to eq("admin")
    end
  end

  context "Test de validation" do
    it "le test est invalide sans mail" do
      # Ici 'build' crée une instance sans la save en base
      # Si on utilise 'create' ca va planté car le schema de db est formel
      # -> email, null: false
      user = build(:user, email: nil)
      expect(user).not_to be_valid
    end
  end
end
