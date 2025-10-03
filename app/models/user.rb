class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Call back -> voir section private
  before_validation :normalize_user_name
  enum :role, { citoyen: 0, admin: 1 }

  private

  def normalize_user_name
    # .to_s : évite les erreurs si nil
    # .strip : supprime les espaces
    # .gsub(/\s+/, ' ') : remplace les espaces multiples par un seul
    self.user_name = user_name.to_s.strip.gsub(/\s+/, " ")
  end
end
