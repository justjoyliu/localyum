class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.integer :sender_id
      t.integer :receiver_id
      t.integer :messagechain_id

      t.boolean :first_flag, default: false
      t.text :message_content
      t.boolean :receiver_read, default: false
      t.boolean :receiver_replied, default: false
      t.boolean :public_flag, default: false
      t.integer :order_id

      t.timestamps
    end

    add_index :messages, :sender_id
    add_index :messages, :receiver_id
    add_index :messages, :messagechain_id
  end
end
