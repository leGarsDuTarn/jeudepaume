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

    it "n'est pas valide avec un user_name réservé même avec des majuscule" do
      user = build(:user, user_name: "ADMIN")
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

  context "Test de validation et de conformité de PASSWORD" do
    it "le test est valide avec un mot de pass fort" do
      u = build(:user, password: "Password1!", password_confirmation: "Password1!")
      expect(u).to be_valid
    end

    it "n'est pas valide avec un mot de passe sans caractère spécial" do
      u = build(:user, password: "Password1", password_confirmation: "Password1")
      expect(u).not_to be_valid
      expect(u.errors[:password]).to be_present
      expect(u.errors[:password]).to include("Doit contenir : min 8 caractères, 0 espace, 1 majuscule, 1 minuscule, 1 chiffre et un caractère spécial.")
    end

    it "les test valide 72 caractères mais n'est pas valide avec 73" do
      # (72 - 4) -> -4 = 'Aa1!' ici ça couvre les 4 classes exigées
      # Puis on fait 68 * "x" -> (72 - 4 = 68)
      # Donc 72 caractères au total
      ok = "A" + "a" + "1" + "!" + "x" * (72 - 4)
      ko = ok + "y"

      expect(build(:user, password: ok, password_confirmation: ok)).to be_valid
      u = build(:user, password: ko, password_confirmation: ko)
      expect(u).not_to be_valid
      expect(u.errors[:password]).to be_present
    end

    it "le test est valide avec 8 caractères mais n'est pas valide avec 7" do
      # 8 au total, avec toutes les classes (Maj, min, chiffre, spécial)
      ok = "Aa1!" + "x" * (8 - 4)  # => "Aa1!xxxx"
      ko = "Aa1!" + "x" * (7 - 4)  # => "Aa1!xxx" (7)

      expect(build(:user, password: ok, password_confirmation: ok)).to be_valid
      u = build(:user, password: ko, password_confirmation: ko)
      expect(u).not_to be_valid
      expect(u.errors[:password]).to be_present
    end
  end

  context "Test de validation et de conformité de EMAIL" do
    it "n'est pas valide avec deux emails identiques à la casse près (citext)" do
      create(:user, email: "Benjamin@GMAIL.com")
      u = build(:user, email: "benjamin@gmail.com")
      expect(u).not_to be_valid
      expect(u.errors[:email]).to be_present
    end

    it "normalise l'email" do
      u = build(:user, email: "    Benji@GMail.com    ")
      expect(u).to be_valid
      expect(u.email).to eq("benji@gmail.com")
    end
  end
end
