class CreateRecipereqs < ActiveRecord::Migration
  def change
    create_table :recipereqs do |t|
      t.integer :user_id
      t.integer :menuitem_id

      t.timestamps
    end
  end
end
