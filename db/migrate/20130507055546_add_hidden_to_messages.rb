class AddHiddenToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :sender_hidden, :boolean, default: false
    add_column :messages, :receiver_hidden, :boolean, default: false
    add_column :messages, :signup_id, :integer
  end
end
