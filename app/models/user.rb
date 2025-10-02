class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  # Par default chaque inscrit est automatiquement un citoyen et non un admin
  # -> voir migration add_tole_to_user
  enum role: { citoyen: 0, admin: 1 }
end
