require "rails_helper"

RSpec.describe User, type: :model, aggregate_failures: true do
  context "Test setup de la factory user" do
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
    it "le test est invalide sans mail" do
      # Ici 'build' crée une instance sans la save en base
      # Si on utilise 'create' ca va planté car le schema de db est formel
      # -> email, null: false
      user = build(:user, email: nil)
      expect(user).not_to be_valid
    end
  end

  context "Test de validation et de conformité de USER_NAME" do
    it "le test est invalide sans user_name" do
      user = build(:user, user_name: nil)
      expect(user).not_to be_valid
    end

    it "le test est invalide s'il y a deux user_names à la casse près (citext)" do
      create(:user, user_name: "Benjamin")
      u = build(:user, user_name: "benjamin")
      # Déclenche les validations.
      expect(u).not_to be_valid
      # vérifie que la liste des erreurs sur user_name n’est pas vide (au moins un message).
      expect(u.errors[:user_name]).to be_present
      # vérifie que le message est bien celui que j'ai inscrit dans les contraintes model.
      expect(u.errors[:user_name]).to include("Oups ! Ce nom d'utilisateur est déjà pris.")
    end

    it "le test est invalide si le user_name est < 3 caractères" do
      user = build(:user, user_name: "Be")
      expect(user).not_to be_valid
      expect(user.errors[:user_name]).to be_present
      expect(user.errors[:user_name]).to include("Caractères : min 3 - max 20")
    end

    it "le test est invalide si le user_name est > 20 caractères" do
      user = build(:user, user_name: "lukejesuistonpèrenoooooon")
      expect(user).not_to be_valid
      expect(user.errors[:user_name]).to be_present
      expect(user.errors[:user_name]).to include("Caractères : min 3 - max 20")
    end

    it "le test est valide si < 3 et > 20 caractères" do
        # Ici c'est possible car j'ai activé 'aggregate_failures: true' au niveau de RSpec.describe
        u1 = build(:user, user_name: "Ben")
        expect(u1).to be_valid

        u2 = build(:user, user_name: "b" * 20)
        expect(u2).to be_valid
    end
  end
end
