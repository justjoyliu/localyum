class CreateSuggestionInputs < ActiveRecord::Migration
  def change
    create_table :suggestion_inputs do |t|
      t.integer :suggestion_id
      t.integer :user_id
      t.integer :want
      t.integer :like_vote

      t.timestamps
    end
  end
end
