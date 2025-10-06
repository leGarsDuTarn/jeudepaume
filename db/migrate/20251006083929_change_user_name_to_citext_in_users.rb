class ChangeUserNameToCitextInUsers < ActiveRecord::Migration[8.0]
  def change
    remove_index :users, :user_name
    change_column :users, :user_name, :citext, null: false
    add_index :users, :user_name, unique: true
  end
end
