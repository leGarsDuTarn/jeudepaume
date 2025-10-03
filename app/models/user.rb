class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Call back -> voir section private
  enum :role, { citoyen: 0, admin: 1 }
end
