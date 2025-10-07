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
    it "n'est pas valide sans mail" do
      # Ici 'build' crée une instance sans la save en base
      # Si on utilise 'create' ca va planté car le schema de db est formel
      # -> email, null: false
      user = build(:user, email: nil)
      expect(user).not_to be_valid
    end
  end

  context "Test de validation et de conformité de USER_NAME" do
    it "n'est pas valide sans user_name" do
      user = build(:user, user_name: nil)
      expect(user).not_to be_valid
    end

    it "n'est pas valide s'il y a deux user_names à la casse près (citext)" do
      create(:user, user_name: "Benjamin")
      u = build(:user, user_name: "benjamin")
      # Déclenche les validations.
      expect(u).not_to be_valid
      # vérifie que la liste des erreurs sur user_name n’est pas vide (au moins un message).
      expect(u.errors[:user_name]).to be_present
      # vérifie que le message est bien celui que j'ai inscrit dans les contraintes model.
      expect(u.errors[:user_name]).to include("Oups ! Ce nom d'utilisateur est déjà pris.")
    end

    it "n'est pas valide si le user_name est < 3 caractères" do
      user = build(:user, user_name: "Be")
      expect(user).not_to be_valid
      expect(user.errors[:user_name]).to be_present
      expect(user.errors[:user_name]).to include("Caractères : min 3 - max 20")
    end

    it "n'est pas valide si le user_name est > 20 caractères" do
      user = build(:user, user_name: "lukejesuistonpèrenoooooon")
      expect(user).not_to be_valid
      expect(user.errors[:user_name]).to be_present
      expect(user.errors[:user_name]).to include("Caractères : min 3 - max 20")
    end

    it "valide si user_name comporte < 3 et > 20 caractères" do
        # Ici c'est possible car j'ai activé 'aggregate_failures: true' au niveau de RSpec.describe
        u1 = build(:user, user_name: "Ben")
        expect(u1).to be_valid

        u2 = build(:user, user_name: "b" * 20)
        expect(u2).to be_valid
    end

    it "Le test normalise et valide un user_name écrit avec des caractères non autorisés" do
      user = build(:user, user_name: "Ben8+=")
      expect(user).to be_valid
      expect(user.user_name).to eq("ben8")
    end

    it "n'est pas valide si user_name est nil ex -> user saisie un 🎃" do
      user = build(:user, user_name: "🎃")
      expect(user).not_to be_valid
      expect(user.errors[:user_name]).to be_present
      expect(user.errors[:user_name]).to include("seulement lettres, chiffres et _")
    end

    it "n'est pas valide si user_name est réservé" do
      user = build(:user, user_name: "admin")
      expect(user).not_to be_valid
      expect(user.errors[:user_name]).to be_present
      expect(user.errors[:user_name]).to include("n'est pas disponible")
    end
  end

  context "Test de validation et de conformité de FIRST_NAME & LAST_NAME" do
    it "n'est pas valide si first_name & last_name sont absent" do
      u1 = build(:user, first_name: nil)
      expect(u1).not_to be_valid
      expect(u1.errors[:first_name]).to be_present
      expect(u1.errors[:first_name]).to include("Veuillez renseigner un prénom")

      u2 = build(:user, last_name: nil)
      expect(u2).not_to be_valid
      expect(u2.errors[:last_name]).to be_present
      expect(u2.errors[:last_name]).to include("Veuillez renseigner un nom")
    end

    it "n'est pas valide si first_name & last_name > 50 caractères" do
      u1 = build(:user, first_name: "b" * 51)
      expect(u1).not_to be_valid
      expect(u1.errors[:first_name]).to be_present

      u2 = build(:user, last_name: "g" * 51)
      expect(u2).not_to be_valid
      expect(u2.errors[:last_name]).to be_present
    end

    it "n'est pas valide si first_name & last_name contiennent des chiffres ou un underscore" do
      u1 = build(:user, first_name: "legarsdutarn81")
      expect(u1).not_to be_valid
      expect(u1.errors[:first_name]).to be_present

      u2 = build(:user, last_name: "Benjamin_Grassiano")
      expect(u2).not_to be_valid
      expect(u2.errors[:last_name]).to be_present
    end

    it "n'est pas valide si first_name & last_name sont nil ex -> user saisi un 👻" do
      u1 = build(:user, first_name: "👻")
      expect(u1).not_to be_valid
      expect(u1.errors[:first_name]).to be_present

      u2 = build(:user, last_name: "😈")
      expect(u2).not_to be_valid
      expect(u2.errors[:last_name]).to be_present
    end

    it "le test est valide si first_name & last_name comporte des apostrophes et des tirets" do
      u = build(:user, first_name: "o'mallet", last_name: "l'ptit-nicolas")
      expect(u).to be_valid
      expect(u.first_name).to eq("O'Mallet")
      expect(u.last_name).to eq("L'Ptit-Nicolas")
    end
  end
end
