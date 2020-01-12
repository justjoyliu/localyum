class CreateSuggestions < ActiveRecord::Migration
  def change
    create_table :suggestions do |t|
      t.string :feature_description
      t.string :status
      t.timestamps
    end
  end
end
