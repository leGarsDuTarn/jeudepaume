class AddCitextToEmailInUsers < ActiveRecord::Migration[8.0]
  def change
    remove_index :users, :email
    change_column_default :users, :email, from: "", to: nil
    change_column :users, :email, :citext, null: false
    add_index :users, :email, unique: true
  end
end
