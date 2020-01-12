class AddValidationToUsers < ActiveRecord::Migration
  def change
    add_column :users, :validation_code, :string
    add_column :users, :validation_flag, :boolean
  end
end
